import os
import re
import tempfile
import math

from datetime import timedelta

from django.conf import settings
from django.db import transaction
from django.utils import timezone
from google import genai
from google.genai import types

from home.models import Estado_Transcripcion

# CONFIGURACION DEL SERVICIO

DAILY_REQUEST_LIMIT = 25
DAILY_WINDOW_HOURS = 24
MIN_REQUEST_INTERVAL = 20

class TranscriptionUnavailable(Exception):

    def __init__(
        self,
        error_type,
        message,
        retry_after,
        status_code=429
    ):
        super().__init__(message)

        self.error_type = error_type
        self.retry_after = max(1, int(retry_after))
        self.status_code = status_code
        self.code = status_code


def _get_retry_after_seconds(error):

    response = getattr(error, 'response', None)

    if response is not None:

        headers = getattr(response, 'headers', None)

        if headers:

            retry_after = headers.get('Retry-After')

            if retry_after:

                try:
                    return max(1, int(float(retry_after)))
                except (TypeError, ValueError):
                    pass

    error_details = str(error)

    patterns = [
        r'retryDelay["\']?\s*:\s*["\']?(\d+(?:\.\d+)?)s',
        r'retry in\s+(\d+(?:\.\d+)?)s',
        r'retry after\s+(\d+(?:\.\d+)?)s',
    ]

    for pattern in patterns:

        match = re.search(
            pattern,
            error_details,
            re.IGNORECASE
        )

        if match:
            return max(1, math.ceil(float(match.group(1))))

    return None

def get_transcription_status():

    state = Estado_Transcripcion.objects.get(pk=1)

    now = timezone.now()

    if state.blocked_until and state.blocked_until > now:

        remaining = (
            state.blocked_until - now
        ).total_seconds()

        return {
            'available': False,
            'reason': state.block_reason,
            'retry_after': math.ceil(remaining),
        }

    if state.daily_window_started_at:

        daily_reset = (
            state.daily_window_started_at
            + timedelta(hours=DAILY_WINDOW_HOURS)
        )

        if (
            state.daily_request_count >= DAILY_REQUEST_LIMIT
            and daily_reset > now
        ):

            return {
                'available': False,
                'reason': 'daily_quota',
                'retry_after': math.ceil(
                    (daily_reset - now).total_seconds()
                ),
            }

    if state.next_request_at and state.next_request_at > now:

        return {
            'available': False,
            'reason': 'rate_limit',
            'retry_after': math.ceil(
                (state.next_request_at - now).total_seconds()
            ),
        }

    return {
        'available': True,
        'reason': None,
        'retry_after': 0,
    }

def _reserve_transcription_request():

    unavailable = None

    with transaction.atomic():

        state = (
            Estado_Transcripcion.objects
            .select_for_update()
            .get(pk=1)
        )

        now = timezone.now()

        # BLOQUEO GLOBAL ACTIVO

        if state.blocked_until and state.blocked_until > now:

            remaining = (
                state.blocked_until - now
            ).total_seconds()

            unavailable = (
                state.block_reason or 'service_unavailable',
                math.ceil(remaining)
            )

        else:

            # LIMPIAR BLOQUEO EXPIRADO

            if state.blocked_until and state.blocked_until <= now:

                state.blocked_until = None
                state.block_reason = None

            # CONTROL DE VENTANA DIARIA

            if (
                not state.daily_window_started_at
                or now >= (
                    state.daily_window_started_at
                    + timedelta(hours=DAILY_WINDOW_HOURS)
                )
            ):

                state.daily_window_started_at = now
                state.daily_request_count = 0

            # LIMITE DIARIO LOCAL

            if state.daily_request_count >= DAILY_REQUEST_LIMIT:

                daily_reset = (
                    state.daily_window_started_at
                    + timedelta(hours=DAILY_WINDOW_HOURS)
                )

                state.blocked_until = daily_reset
                state.block_reason = 'daily_quota'

                remaining = (
                    daily_reset - now
                ).total_seconds()

                unavailable = (
                    'daily_quota',
                    math.ceil(remaining)
                )

                state.save()

            # CONTROL GLOBAL POR MINUTO

            elif (
                state.next_request_at
                and state.next_request_at > now
            ):

                remaining = (
                    state.next_request_at - now
                ).total_seconds()

                unavailable = (
                    'rate_limit',
                    math.ceil(remaining)
                )

                state.save()

            else:

                # RESERVAR SOLICITUD

                state.daily_request_count += 1

                state.next_request_at = (
                    now + timedelta(seconds=MIN_REQUEST_INTERVAL)
                )

                state.save()

    # LANZAR LA EXCEPCION DESPUES DE CONFIRMAR LA TRANSACCION

    if unavailable:

        reason, retry_after = unavailable

        raise TranscriptionUnavailable(
            reason,
            'The transcription service is temporarily unavailable.',
            retry_after
        )

def _register_provider_failure(error):

    status = getattr(error, 'code', None)

    if not isinstance(status, int):
        status = getattr(error, 'status_code', None)

    if not isinstance(status, int):

        response = getattr(error, 'response', None)

        status = getattr(response, 'status_code', None)

    if status not in (429, 503):
        return

    error_details = str(error).lower()

    retry_after = _get_retry_after_seconds(error)

    if status == 429:

        daily_quota = (
            'per day' in error_details
            or 'daily' in error_details
            or 'requests_per_day' in error_details
            or 'per_day' in error_details
        )

        if daily_quota:

            if retry_after is None:
                retry_after = 24 * 60 * 60

            reason = 'daily_quota'

        else:

            if retry_after is None:
                retry_after = MIN_REQUEST_INTERVAL

            reason = 'rate_limit'

    else:

        if retry_after is None:
            retry_after = 30

        reason = 'service_busy'

    blocked_until = (
        timezone.now()
        + timedelta(seconds=retry_after)
    )

    with transaction.atomic():

        state = (
            Estado_Transcripcion.objects
            .select_for_update()
            .get(pk=1)
        )

        if (
            not state.blocked_until
            or blocked_until > state.blocked_until
        ):

            state.blocked_until = blocked_until
            state.block_reason = reason

            state.save(
                update_fields=[
                    'blocked_until',
                    'block_reason',
                    'updated_at',
                ]
            )


def transcribe_audio(audio_file):

    if not settings.GEMINI_API_KEY:

        raise RuntimeError(
            "The Gemini API Key is not configured."
        )

    if not audio_file:

        raise ValueError(
            "No audio file was provided."
        )

    mime_type = audio_file.content_type or "audio/webm"

    client = genai.Client(
        api_key=settings.GEMINI_API_KEY,
        http_options=types.HttpOptions(
            api_version="v1beta",
            timeout=30000,
            retry_options=types.HttpRetryOptions(attempts=1),
        ),
    )

    temporary_path = None
    uploaded_file = None

    try:

        suffix = ".webm"

        with tempfile.NamedTemporaryFile(
            suffix=suffix,
            delete=False
        ) as temporary_file:

            for chunk in audio_file.chunks():
                temporary_file.write(chunk)

            temporary_path = temporary_file.name

        uploaded_file = client.files.upload(
            file=temporary_path,
            config={"mime_type": mime_type},
        )

        # RESERVAR SOLICITUD ANTES DE ENVIARLA A GEMINI

        _reserve_transcription_request()

        interaction = client.interactions.create(
            model=settings.GEMINI_TRANSCRIPTION_MODEL,
            input=[
                {
                    "type": "audio",
                    "uri": uploaded_file.uri,
                    "mime_type": uploaded_file.mime_type,
                }
            ],
            generation_config={
                "transcription_config": {
                    "language_codes": ["en-US"],
                    "mode": {"type": "verbatim"},
                }
            },
        )

        transcription = interaction.output_text

        if not transcription:

            raise RuntimeError(
                "Gemini could not recognize the audio."
            )

        return transcription.strip()

    except Exception as error:

        # TAMBIEN DETECTAR LIMITES DURANTE LA CARGA DEL AUDIO

        if not isinstance(error, TranscriptionUnavailable):
            _register_provider_failure(error)

        raise

    finally:

        if temporary_path and os.path.exists(temporary_path):
            os.remove(temporary_path)

        if uploaded_file:

            try:

                client.files.delete(
                    name=uploaded_file.name
                )

            except Exception as error:

                print(
                    "GEMINI FILE CLEANUP ERROR:",
                    repr(error)
                )
