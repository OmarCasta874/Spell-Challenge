import os
import tempfile 

from django.conf import settings
from google import genai
from google.genai import types

def transcribe_audio(audio_file):
    """
    Transcribe a short English audio recording using Gemini.
    """
    
    if not settings.GEMINI_API_KEY:
        raise RuntimeError(
            "The Gemini API Key is not configured."
        )
        
    if not audio_file:
        raise ValueError("No audio file was provided.")
    
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
    
    finally:
        if temporary_path and os.path.exists(temporary_path):
            os.remove(temporary_path)
            
        if uploaded_file:
            client.files.delete(name=uploaded_file.name)