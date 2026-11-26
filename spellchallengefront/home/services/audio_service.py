from io import BytesIO
import re

from django.core.files.base import ContentFile
from gtts import gTTS


def generate_word_audio_mp3(word):
    """
    Generate an English MP3 pronunciation file using gTTS
    and return (short_filename, ContentFile) ready for Palabra.audio.
    """
    word = (word or "").strip()
    if not word:
        raise ValueError("Please provide a valid English word.")

    buffer = BytesIO()
    tts = gTTS(text=word, lang="en", tld="com", slow=False)
    tts.write_to_fp(buffer)
    buffer.seek(0)

    slug = re.sub(r"[^a-z0-9]+", "_", word.lower()).strip("_")[:20] or "word"
    filename = f"tts_{slug}.mp3"

    return filename, ContentFile(buffer.read(), name=filename)