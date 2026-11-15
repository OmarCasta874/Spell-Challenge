import re
import time
import unicodedata

from django.core.management.base import BaseCommand
from django.db import IntegrityError, transaction

from home.models import Palabra, Pista_Boss_Battle
from home.services.gemini_service import generate_boss_battle_clues


def normalize_word(word):
    normalized = unicodedata.normalize(
        'NFKD',
        word.upper().strip()
    ).encode(
        'ASCII',
        'ignore'
    ).decode('ASCII')

    return re.sub(
        r'[^A-Z]',
        '',
        normalized
    )


class Command(BaseCommand):

    help = 'Generate and save progressive Boss Battle clues.'

    def add_arguments(self, parser):

        parser.add_argument(
            '--limit',
            type=int,
            default=0,
            help='Maximum number of words to process. 0 means all.'
        )

        parser.add_argument(
            '--delay',
            type=float,
            default=20,
            help='Seconds to wait between Gemini requests.'
        )

    def handle(self, *args, **options):

        limit = options['limit']
        delay = options['delay']

        if limit < 0:
            self.stdout.write(
                self.style.ERROR(
                    'The limit cannot be negative.'
                )
            )
            return

        if delay < 0:
            self.stdout.write(
                self.style.ERROR(
                    'The delay cannot be negative.'
                )
            )
            return

        # =========================================
        # GET WORDS WITHOUT EXISTING CLUES
        # =========================================

        words = Palabra.objects.select_related(
            'nivel'
        ).exclude(
            significado__isnull=True
        ).exclude(
            definicion__isnull=True
        ).filter(
            pistas_boss_battle__isnull=True
        ).order_by(
            'codigo'
        )

        candidates = []

        for word in words:

            answer = normalize_word(
                word.significado
            )

            definition = word.definicion.strip()

            if not 3 <= len(answer) <= 10:
                continue

            if not definition:
                continue

            candidates.append(word)

        if limit > 0:
            candidates = candidates[:limit]

        total = len(candidates)

        self.stdout.write(
            self.style.SUCCESS(
                f'Words pending: {total}'
            )
        )

        if total == 0:

            self.stdout.write(
                'There are no eligible words pending.'
            )
            return

        # =========================================
        # GENERATE UNIQUE RECORD CODES
        # =========================================

        existing_codes = Pista_Boss_Battle.objects.values_list(
            'codigo',
            flat=True
        )

        highest_code = 0

        for code in existing_codes:

            match = re.fullmatch(
                r'PBB(\d+)',
                code
            )

            if match:
                highest_code = max(
                    highest_code,
                    int(match.group(1))
                )

        next_code = highest_code + 1

        # =========================================
        # PROCESS WORDS
        # =========================================

        generated = 0
        failed = 0

        for index, word in enumerate(candidates, start=1):

            self.stdout.write(
                f'[{index}/{total}] Processing: '
                f'{word.significado} ({word.nivel.codigo})'
            )

            try:

                clues = generate_boss_battle_clues(
                    word.significado,
                    word.definicion,
                    word.nivel.codigo,
                    word.nivel.descripcion
                )

                # =================================
                # SAVE VALIDATED CLUES
                # =================================

                with transaction.atomic():

                    Pista_Boss_Battle.objects.create(
                        codigo=f'PBB{next_code:06d}',
                        palabra=word,
                        pista_facil=clues['easy'],
                        pista_intermedia=clues['medium'],
                        pista_dificil=clues['hard']
                    )

                generated += 1
                next_code += 1

                self.stdout.write(
                    self.style.SUCCESS(
                        'Clues saved successfully.'
                    )
                )

            except IntegrityError:

                failed += 1

                self.stdout.write(
                    self.style.WARNING(
                        'The word already has a clue record. Skipping.'
                    )
                )

            except Exception as error:

                failed += 1

                self.stdout.write(
                    self.style.ERROR(
                        f'Could not process {word.significado}: {error}'
                    )
                )

            # =================================
            # REQUEST PACING
            # =================================

            if index < total and delay > 0:
                time.sleep(delay)

        # =========================================
        # FINAL SUMMARY
        # =========================================

        self.stdout.write('\n========== BOSS BATTLE CLUES ==========')

        self.stdout.write(
            self.style.SUCCESS(
                f'Successfully generated: {generated}'
            )
        )

        self.stdout.write(
            self.style.WARNING(
                f'Failed or skipped: {failed}'
            )
        )

        self.stdout.write(
            f'Processed: {total}'
        )

        self.stdout.write('=======================================')
