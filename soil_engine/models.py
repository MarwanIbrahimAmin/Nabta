"""
Pydantic models for request/response and internal data structures.
Ensures typed, actionable payloads for the Soil Intelligence API.
"""
from datetime import date
from typing import Any

from pydantic import BaseModel, Field


# ---------- Request: Lab data input ----------


class LocationCoords(BaseModel):
    """Geo-spatial tagging for heatmaps and land medical history."""

    lat: float = Field(..., description="Latitude")
    long: float = Field(..., description="Longitude", alias="long")
    elevation_m: float | None = Field(None, description="Elevation in meters (optional)")

    class Config:
        populate_by_name = True


class SoilLabInput(BaseModel):
    """Raw chemical data from soil lab (single test)."""

    # Core nutrients (units: typically ppm or mg/kg; specify in unit if needed)
    N_ppm: float | None = Field(None, description="Nitrogen (ppm)")
    P_ppm: float | None = Field(None, description="Phosphorus (ppm)")
    K_ppm: float | None = Field(None, description="Potassium (ppm)")
    pH: float | None = Field(None, description="Soil pH")
    EC_dS_m: float | None = Field(None, description="Electrical conductivity (dS/m)")
    organic_matter_pct: float | None = Field(None, description="Organic matter (%)")

    # Context
    crop_type: str | None = Field(None, description="Intended or current crop")
    farm_id: str | None = Field(None, description="Farm identifier for longitudinal data")
    location: LocationCoords | None = Field(None, description="Lat/Long for geo tagging")
    test_date: date | str | None = Field(None, description="Date of sample/test")
    lab_reference: str | None = Field(None, description="Lab report reference id")

    class Config:
        json_schema_extra = {
            "example": {
                "N_ppm": 25.0,
                "P_ppm": 18.0,
                "K_ppm": 120.0,
                "pH": 6.8,
                "EC_dS_m": 0.4,
                "organic_matter_pct": 2.1,
                "crop_type": "Wheat",
                "farm_id": "farm_001",
                "location": {"lat": 30.0444, "long": 31.2357},
                "test_date": "2025-02-15",
            }
        }


# ---------- AI response structure (structured JSON from Gemini) ----------


class FertilizerStep(BaseModel):
    """A single actionable fertilizer recommendation."""

    nutrient: str = Field(..., description="e.g. N, P2O5, K2O")
    product_suggestion: str | None = Field(None, description="Example product or form")
    amount_kg_per_ha: float | None = Field(None, description="Dose in kg per hectare")
    amount_units: str | None = Field(None, description="e.g. kg/ha, g/m²")
    timing: str | None = Field(None, description="When to apply")
    notes: str | None = Field(None, description="Extra guidance")


class AIAnalysisResponse(BaseModel):
    """Structured JSON output from the Expert Agronomist (Gemini)."""

    soil_status_summary: str = Field(..., description="Human-friendly analysis in simple language")
    specific_fertilizer_steps: list[FertilizerStep] = Field(
        default_factory=list,
        description="Exact dosages and steps",
    )
    warnings: list[str] = Field(default_factory=list, description="Risks or cautions")
    next_test_date: str | None = Field(None, description="Recommended next test date (ISO or readable)")
    strategic_insight: str | None = Field(None, description="Long-term trend or insight")

    class Config:
        extra = "allow"  # Allow AI to add optional fields without breaking


# ---------- Validation layer output ----------


class NPKValidationResult(BaseModel):
    """Result of manual N-P-K requirement calculation (validation layer)."""

    N_kg_per_ha: float | None = None
    P2O5_kg_per_ha: float | None = None
    K2O_kg_per_ha: float | None = None
    method: str = Field(..., description="e.g. soil_test_deficit, crop_requirement")
    notes: list[str] = Field(default_factory=list)


# ---------- Full API response ----------


class AnalyzeSoilResponse(BaseModel):
    """Full response from POST /analyze-soil: AI report + validation + metadata."""

    success: bool = True
    ai_report: AIAnalysisResponse = Field(..., description="Gemini-generated analysis")
    validation_npk: NPKValidationResult | None = Field(
        None,
        description="Manual formula validation for N-P-K",
    )
    farm_id: str | None = None
    location: dict[str, Any] | None = None
    test_date: str | None = None
    error_message: str | None = None
