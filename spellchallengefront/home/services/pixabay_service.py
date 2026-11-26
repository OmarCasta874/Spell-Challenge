from io import BytesIO
import re
from urllib.parse import urlparse

import requests
from django.conf import settings
from django.core.files.base import ContentFile
from PIL import Image


PIXABAY_API_URL = "https://pixabay.com/api/"


def search_pixabay_images(query, per_page=6):
    """
    Search safe English vocabulary images on Pixabay.
    Returns a list of dicts with preview_url and web_url.
    """
    query = (query or "").strip()
    if not query:
        raise ValueError("Please enter a word before searching for images.")

    api_key = getattr(settings, "PIXABAY_API_KEY", "")
    if not api_key:
        raise RuntimeError("The Pixabay API key is not configured.")

    response = requests.get(
        PIXABAY_API_URL,
        params={
            "key": api_key,
            "q": query,
            "image_type": "photo",
            "safesearch": "true",
            "lang": "en",
            "per_page": per_page,
        },
        timeout=10,
    )

    if response.status_code == 429:
        raise RuntimeError("Pixabay rate limit reached. Please try again in a moment.")

    if not response.ok:
        raise RuntimeError("Could not connect to the image search service.")

    data = response.json()
    hits = data.get("hits", [])

    results = []
    for item in hits:
        preview_url = item.get("previewURL") or item.get("webformatURL")
        web_url = item.get("webformatURL") or item.get("previewURL")
        if preview_url and web_url:
            results.append({
                "id": item.get("id"),
                "preview_url": preview_url,
                "web_url": web_url,
                "tags": item.get("tags", ""),
            })

    return results


def download_pixabay_image(image_url, word):
    """
    Downloads an image from Pixabay, validates it with Pillow,
    and returns (short_filename, ContentFile) ready to save in Palabra.imagen.
    """
    image_url = (image_url or "").strip()
    parsed = urlparse(image_url)

    if parsed.scheme != "https" or not (
        parsed.hostname == "pixabay.com"
        or (parsed.hostname and parsed.hostname.endswith(".pixabay.com"))
    ):
        raise ValueError("Invalid Pixabay image URL.")

    response = requests.get(image_url, timeout=15)
    if not response.ok:
        raise RuntimeError("The selected image could not be downloaded.")

    if len(response.content) > 3 * 1024 * 1024:
        raise ValueError("The selected image exceeds the 3 MB limit.")

    content_type = (response.headers.get("Content-Type") or "").lower()
    if not content_type.startswith("image/"):
        raise ValueError("The downloaded file is not a valid image.")

    try:
        with Image.open(BytesIO(response.content)) as img:
            img.verify()
            img_format = (img.format or "JPEG").lower()
    except Exception as exc:
        raise ValueError("The downloaded file is corrupted or not an image.") from exc

    ext = "png" if img_format == "png" else ("webp" if img_format == "webp" else "jpg")
    slug = re.sub(r"[^a-z0-9]+", "_", (word or "word").lower()).strip("_")[:20] or "word"
    filename = f"pix_{slug}.{ext}"

    return filename, ContentFile(response.content, name=filename)