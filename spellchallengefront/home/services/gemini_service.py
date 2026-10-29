import json

from django.conf import settings
from google import genai
from google.genai import types

MODEL_NAME = settings.GEMINI_TEXT_MODEL

def generate_word_content(word):
    """
    Generate a definition, example sentence and pronunciation
    suggestion for an English vocabulary word.
    """
    word = word.strip()
    
    if not word:
        raise ValueError("Please enter an English word.")
    
    if len(word) > 50:
        raise ValueError("The word cannot exceed 50 characters.")
    
    if not settings.GEMINI_API_KEY:
        raise RuntimeError("The Gemini API key is not configured.")
    
    client = genai.Client(
        api_key=settings.GEMINI_API_KEY,
        http_options=types.HttpOptions(
            api_version="v1",
            timeout=30000,
            retry_options=types.HttpRetryOptions(attempts=1),
        ),
    )
    
    prompt = f"""
You are an English vocabulary assistant for university students
learning English at levels A1 to C2.

Generate learning content for this English vocabulary word:
{json.dumps(word)}

Return ONLY a valid JSON object with exactly these three keys:
- "definition": A clear, accurate definition in simple English.
- "example": One natural English example sentence using the word.
- "pronunciation": A learner-friendly IPA pronunciation in American English.

Requirements:
- The definition must not exceed 255 characters.
- The example must not exceed 255 characters.
- The pronunciation must not exceed 100 characters.
- Do not include Markdown or text outside the JSON object.
- Do not invent a pronunciation if the word is ambiguous or unclear.
"""
    
    response = client.interactions.create(
        model=MODEL_NAME,
        input=prompt,
        generation_config={"thinking_level": "minimal"},
    )
    
    output_text = response.output_text
    
    if not output_text:
        raise RuntimeError("Gemini returned an empty response.")
    
    try:
        content = json.loads(output_text)
    except json.JSONDecodeError as exc:
        raise RuntimeError(
            "Gemini returned an invalid response format."
        ) from exc
        
    required_fields = {"definition", "example", "pronunciation"}
    
    if not isinstance(content, dict):
        raise RuntimeError("Gemini returned an unexpected response.")
    
    if not required_fields.issubset(content.keys()):
        raise RuntimeError("Gemini did not return all required fields.")
    
    definition = content["definition"]
    example = content["example"]
    pronunciation = content["pronunciation"]
    
    if not all(
        isinstance(value, str) and value.strip()
        for value in (definition, example, pronunciation)
    ):
        raise RuntimeError("Gemini returned incomplete text content.")
    
    content = {
        "definition": definition.strip(),
        "example": example.strip(),
        "pronunciation": pronunciation.strip(),
    }
    
    if len(content["definition"]) > 255:
        raise RuntimeError("The generated definition is too long.")
    
    if len(content["example"]) > 255:
        raise RuntimeError("The generated example is too long.")
    
    if len(content["pronunciation"]) > 100:
        raise RuntimeError("The generated pronunciation is too long.")
    
    return content