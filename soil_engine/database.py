"""
Optional database integration: persist soil tests with farm_id and location_coords.
Uses PostgreSQL when DATABASE_URL is set; otherwise analysis still works without DB.
"""
from __future__ import annotations

import json
from datetime import date, datetime
from typing import Any
from uuid import UUID

from config import DATABASE_URL
from schema_db import get_postgres_schema

# Optional: uncomment when using PostgreSQL
# import asyncpg


def is_db_configured() -> bool:
    return bool(DATABASE_URL)


async def save_soil_test(
    farm_id: str,
    lab_data: dict[str, Any],
    ai_report: dict[str, Any],
    validation_npk: dict[str, Any] | None,
    test_date: date | str | None = None,
    location_lat: float | None = None,
    location_long: float | None = None,
    lab_reference: str | None = None,
    crop_type: str | None = None,
) -> str | None:
    """
    Persist one soil test to the database (PostgreSQL).
    Returns the inserted row id or None if DB not configured.
    """
    if not is_db_configured():
        return None

    # Optional: implement with asyncpg
    # conn = await asyncpg.connect(DATABASE_URL)
    # try:
    #     row = await conn.fetchrow(
    #         """
    #         INSERT INTO soil_tests (
    #             farm_id, test_date, lab_reference,
    #             n_ppm, p_ppm, k_ppm, ph, ec_ds_m, organic_matter_pct,
    #             location_lat, location_long,
    #             crop_type,
    #             soil_status_summary, fertilizer_steps_json, warnings_json,
    #             next_test_date, strategic_insight, validation_npk_json
    #         ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
    #         RETURNING id
    #         """,
    #         farm_id,
    #         test_date,
    #         lab_reference,
    #         lab_data.get("N_ppm"),
    #         lab_data.get("P_ppm"),
    #         lab_data.get("K_ppm"),
    #         lab_data.get("pH"),
    #         lab_data.get("EC_dS_m"),
    #         lab_data.get("organic_matter_pct"),
    #         location_lat,
    #         location_long,
    #         crop_type,
    #         ai_report.get("soil_status_summary"),
    #         json.dumps(ai_report.get("specific_fertilizer_steps", [])),
    #         json.dumps(ai_report.get("warnings", [])),
    #         ai_report.get("next_test_date"),
    #         ai_report.get("strategic_insight"),
    #         json.dumps(validation_npk) if validation_npk else None,
    #     )
    #     return str(row["id"])
    # finally:
    #     await conn.close()

    return None


async def get_tests_by_farm(farm_id: str, limit: int = 50) -> list[dict[str, Any]]:
    """Fetch Land Medical History for a farm (longitudinal data). Returns [] if DB not configured."""
    if not is_db_configured():
        return []
    # Implement with asyncpg when DB is in use
    return []
