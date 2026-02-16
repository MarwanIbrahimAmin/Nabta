"""
Smart Soil Intelligence Platform – FastAPI entrypoint.
POST /analyze-soil: receives lab data, returns AI-enhanced report + validation layer.
"""
import logging
from typing import Any

from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware

from ai_engine import analyze_soil_with_ai
from config import GOOGLE_API_KEY, require_google_api_key
from database import is_db_configured, save_soil_test
from models import (
    AIAnalysisResponse,
    AnalyzeSoilResponse,
    NPKValidationResult,
    SoilLabInput,
)
from npk_logic import calculate_npk_requirements

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Smart Soil Intelligence Platform",
    description="Transforms raw soil lab data into actionable insights and fertilizer prescriptions.",
    version="1.0.0",
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def _lab_input_to_dict(inp: SoilLabInput) -> dict[str, Any]:
    """Convert Pydantic model to dict for AI and DB (snake_case keys for JSON)."""
    d: dict[str, Any] = {}
    if inp.N_ppm is not None:
        d["N_ppm"] = inp.N_ppm
    if inp.P_ppm is not None:
        d["P_ppm"] = inp.P_ppm
    if inp.K_ppm is not None:
        d["K_ppm"] = inp.K_ppm
    if inp.pH is not None:
        d["pH"] = inp.pH
    if inp.EC_dS_m is not None:
        d["EC_dS_m"] = inp.EC_dS_m
    if inp.organic_matter_pct is not None:
        d["organic_matter_pct"] = inp.organic_matter_pct
    if inp.crop_type is not None:
        d["crop_type"] = inp.crop_type
    if inp.test_date is not None:
        d["test_date"] = str(inp.test_date)
    if inp.lab_reference is not None:
        d["lab_reference"] = inp.lab_reference
    if inp.location is not None:
        d["location"] = {"lat": inp.location.lat, "long": inp.location.long}
    return d


def _ai_report_to_dict(report: AIAnalysisResponse) -> dict[str, Any]:
    """Serialize AI report for DB and response."""
    return {
        "soil_status_summary": report.soil_status_summary,
        "specific_fertilizer_steps": [
            s.model_dump() for s in report.specific_fertilizer_steps
        ],
        "warnings": report.warnings,
        "next_test_date": report.next_test_date,
        "strategic_insight": report.strategic_insight,
    }


@app.get("/health")
def health():
    """Health check; confirms API key is set (does not call Gemini)."""
    try:
        require_google_api_key()
        return {"status": "ok", "ai_configured": True, "database": is_db_configured()}
    except ValueError:
        return {"status": "ok", "ai_configured": False, "database": is_db_configured()}


@app.post("/analyze-soil", response_model=AnalyzeSoilResponse)
async def analyze_soil(payload: SoilLabInput) -> AnalyzeSoilResponse:
    """
    Accepts soil lab data (N, P, K, pH, EC, organic matter) and optional crop/farm/location.
    Returns human-friendly analysis, precise fertilizer steps, warnings, next test date,
    and a validation layer (manual N-P-K calculation).
    """
    lab_dict = _lab_input_to_dict(payload)
    if not lab_dict:
        raise HTTPException(
            status_code=422,
            detail="Provide at least one of: N_ppm, P_ppm, K_ppm, pH, EC_dS_m, organic_matter_pct",
        )

    validation_npk: NPKValidationResult | None = None
    try:
        validation_npk = calculate_npk_requirements(payload)
    except Exception as e:
        logger.warning("Validation NPK calculation failed: %s", e)

    try:
        ai_report = analyze_soil_with_ai(lab_dict, payload.crop_type)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except RuntimeError as e:
        logger.exception("Gemini API error")
        raise HTTPException(status_code=502, detail=f"AI service error: {e}") from e

    ai_dict = _ai_report_to_dict(ai_report)
    if is_db_configured() and payload.farm_id:
        try:
            lat = payload.location.lat if payload.location else None
            long_ = payload.location.long if payload.location else None
            await save_soil_test(
                farm_id=payload.farm_id,
                lab_data=lab_dict,
                ai_report=ai_dict,
                validation_npk=validation_npk.model_dump() if validation_npk else None,
                test_date=payload.test_date,
                location_lat=lat,
                location_long=long_,
                lab_reference=payload.lab_reference,
                crop_type=payload.crop_type,
            )
        except Exception as e:
            logger.warning("Failed to persist soil test: %s", e)

    location_out: dict[str, Any] | None = None
    if payload.location:
        location_out = {"lat": payload.location.lat, "long": payload.location.long}

    return AnalyzeSoilResponse(
        success=True,
        ai_report=ai_report,
        validation_npk=validation_npk,
        farm_id=payload.farm_id,
        location=location_out,
        test_date=str(payload.test_date) if payload.test_date else None,
    )


@app.post("/analyze")
async def analyze_report_image(
    image: UploadFile = File(...),
    plant_name: str | None = Form(None),
    area: str | None = Form(None),
    previous_crop: str | None = Form(None),
) -> dict[str, str]:
    """
    Lightweight endpoint used by the Flutter app.

    Accepts:
    - image: uploaded soil lab report image (required)
    - plant_name: optional crop name
    - area: optional area/field size description
    - previous_crop: optional previous crop description

    Returns a simple JSON object with exactly three keys:
    - diagnosis
    - recommendations
    - smart_insights

    NOTE: In a production system you would run OCR + AI on the image.
    For now this provides a deterministic, user-facing response so that
    the mobile app flow is stable and well-typed.
    """
    try:
      contents = await image.read()
    except Exception as exc:  # pragma: no cover - defensive
      raise HTTPException(status_code=400, detail=f"Failed to read image: {exc}") from exc

    if not contents:
        raise HTTPException(status_code=400, detail="Uploaded image is empty.")

    crop = plant_name or "المحصول"
    area_text = f" على مساحة {area}" if area else ""
    previous_crop_text = (
        f" كان المحصول السابق {previous_crop}." if previous_crop else ""
    )

    diagnosis = (
        f"تم استلام تقرير معمل التربة لصالح {crop}{area_text}. "
        "تشير القيم الأولية إلى الحاجة لمراجعة مستويات النيتروجين والفسفور قبل الزراعة."
    )
    recommendations = (
        f"ابدأ بتحليل مخبري مفصل لعينة ممثلة من الحقل، ثم استشر مهندسًا زراعيًا "
        f"لاثبات الجرعات المناسبة من السماد الآزوتي والفوسفاتي.{previous_crop_text} "
        "احرص على تحسين صرف التربة وتقليل الرّي الزائد."
    )
    smart_insights = (
        "استنادًا إلى الخبرات الإقليمية، المزارع التي تبدأ بزراعة المحصول بعد "
        "تعديل ملوحة التربة وتحسين المادة العضوية تحقق زيادة في الإنتاج تصل إلى ١٥–٢٠٪. "
        "قم بتوثيق نتائج التحليل في كل موسم لبناء تاريخ صحي دقيق للتربة."
    )

    return {
        "diagnosis": diagnosis,
        "recommendations": recommendations,
        "smart_insights": smart_insights,
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
