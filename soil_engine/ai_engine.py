"""
AI Prompt Wrapper: Gemini integration for Expert Agronomist.
Calls Google Generative AI and returns structured JSON (soil_status_summary,
fertilizer_steps, warnings, next_test_date).
"""
import json
from typing import Any

import google.generativeai as genai

from config import GEMINI_MODEL, GOOGLE_API_KEY, require_google_api_key
from models import AIAnalysisResponse, FertilizerStep
from prompts import SYSTEM_PROMPT, build_user_prompt


def _parse_json_from_response(text: str) -> dict[str, Any]:
    """Extract a single JSON object from model output (handles markdown fences)."""
    text = text.strip()
    # Remove markdown code block if present
    if "```json" in text:
        text = text.split("```json", 1)[-1].split("```", 1)[0].strip()
    elif "```" in text:
        text = text.split("```", 1)[-1].split("```", 1)[0].strip()
    return json.loads(text)


def _normalize_ai_response(raw: dict[str, Any]) -> AIAnalysisResponse:
    """Map raw JSON to AIAnalysisResponse; tolerate minor key/format variations."""
    steps: list[FertilizerStep] = []
    for item in raw.get("specific_fertilizer_steps") or []:
        if isinstance(item, dict):
            steps.append(
                FertilizerStep(
                    nutrient=item.get("nutrient", "?"),
                    product_suggestion=item.get("product_suggestion"),
                    amount_kg_per_ha=item.get("amount_kg_per_ha"),
                    amount_units=item.get("amount_units"),
                    timing=item.get("timing"),
                    notes=item.get("notes"),
                )
            )
    return AIAnalysisResponse(
        soil_status_summary=raw.get("soil_status_summary") or "No summary generated.",
        specific_fertilizer_steps=steps,
        warnings=list(raw.get("warnings") or []),
        next_test_date=raw.get("next_test_date"),
        strategic_insight=raw.get("strategic_insight"),
    )


def analyze_soil_with_ai(lab_data: dict[str, Any], crop_type: str | None = None) -> AIAnalysisResponse:
    """
    Send lab data to Gemini and return structured agronomic analysis.
    Raises on missing API key or API/parse errors.
    """
    require_google_api_key()
    genai.configure(api_key=GOOGLE_API_KEY)
    model = genai.GenerativeModel(
        model_name=GEMINI_MODEL,
        system_instruction=SYSTEM_PROMPT,
    )
    lab_json_str = json.dumps(lab_data, indent=2)
    user_prompt = build_user_prompt(lab_json_str, crop_type)

    try:
        response = model.generate_content(
            user_prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=0.3,
                max_output_tokens=2048,
            ),
        )
    except Exception as e:
        raise RuntimeError(f"Gemini API call failed: {e}") from e

    if not response or not response.text:
        raise ValueError("Gemini returned empty response.")

    try:
        raw = _parse_json_from_response(response.text)
    except json.JSONDecodeError as e:
        raise ValueError(f"Gemini response was not valid JSON: {e}") from e

    return _normalize_ai_response(raw)
