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

def generate_boss_battle_clues(word, definition, level_code, level_description):
    """
    Generate three progressive clues for Boss Battle.
    """

    word = word.strip()
    definition = definition.strip()

    if not word:
        raise ValueError("Please provide an English word.")

    if not definition:
        raise ValueError("Please provide the word definition.")

    if len(word) > 50:
        raise ValueError("The word cannot exceed 50 characters.")

    if len(definition) > 255:
        raise ValueError("The definition cannot exceed 255 characters.")

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
You are an expert English vocabulary teacher
designing clues for a university spelling game.

The target vocabulary word is:
{json.dumps(word)}

Its original definition is:
{json.dumps(definition)}

The student's English level is:
{json.dumps(level_code)}

Level description:
{json.dumps(level_description)}

Generate exactly three progressive clues for this word.

Return ONLY a valid JSON object with exactly these keys:
- "easy": A simple, direct clue suitable for beginner students.
- "medium": A more descriptive clue requiring additional understanding.
- "hard": A less direct clue that requires more vocabulary knowledge
  or reasoning, but remains fair and understandable.

Requirements:
- All clues must be written in natural English.
- Each clue must not exceed 255 characters.
- Do not include the target word in any clue.
- Do not reveal the answer through spelling or letter hints.
- Do not use the same idea in all three clues.
- The clues must describe the same target word accurately.
- Easy must be easier than Medium.
- Medium must be easier than Hard.
- Hard must remain solvable using the information provided.
- Do not include Markdown or text outside the JSON object.
- Adapt the vocabulary and complexity of all clues to the student's English level.
- For A1 and A2, use basic vocabulary and familiar concepts.
- For B1 and B2, use intermediate vocabulary and more detailed descriptions.
- For C1 and C2, more advanced vocabulary and indirect descriptions are acceptable.
- Even at advanced levels, all clues must remain accurate and solvable.
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

    required_fields = {"easy", "medium", "hard"}

    if not isinstance(content, dict):
        raise RuntimeError("Gemini returned an unexpected response.")

    if set(content.keys()) != required_fields:
        raise RuntimeError(
            "Gemini did not return exactly the three required clues."
        )

    clues = {
        "easy": content["easy"],
        "medium": content["medium"],
        "hard": content["hard"],
    }

    if not all(
        isinstance(value, str) and value.strip()
        for value in clues.values()
    ):
        raise RuntimeError("Gemini returned incomplete clues.")

    clues = {
        key: value.strip()
        for key, value in clues.items()
    }

    for clue in clues.values():
        if len(clue) > 255:
            raise RuntimeError("A generated clue exceeds 255 characters.")

    return clues
