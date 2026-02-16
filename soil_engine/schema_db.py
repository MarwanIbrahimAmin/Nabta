"""
Database schema for Land Medical History and geo-spatial tagging.
Breaks the "Data Silo" by linking every test to farm_id and location_coords.
Supports PostgreSQL and MongoDB designs.
"""

# ---------- PostgreSQL ----------
# Run these in order: farms first, then soil_tests (FK to farms).

POSTGRES_SCHEMA_SQL = """
-- Farms (one per land/farm; optional if you only have tests)
CREATE TABLE IF NOT EXISTS farms (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farm_id     VARCHAR(128) NOT NULL UNIQUE,
    name        VARCHAR(256),
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Soil tests: every lab result linked to farm + location (longitudinal + geo)
CREATE TABLE IF NOT EXISTS soil_tests (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farm_id               VARCHAR(128) NOT NULL,
    test_date             DATE,
    lab_reference         VARCHAR(128),

    -- Raw lab data
    n_ppm                 NUMERIC(10,2),
    p_ppm                 NUMERIC(10,2),
    k_ppm                 NUMERIC(10,2),
    ph                    NUMERIC(4,2),
    ec_ds_m               NUMERIC(8,4),
    organic_matter_pct    NUMERIC(5,2),

    -- Geo-spatial (for heatmaps)
    location_lat          NUMERIC(10,6),
    location_long         NUMERIC(10,6),
    elevation_m           NUMERIC(8,2),

    -- Context
    crop_type             VARCHAR(128),

    -- AI-enhanced report (actionable data)
    soil_status_summary   TEXT,
    fertilizer_steps_json  JSONB,
    warnings_json         JSONB,
    next_test_date        VARCHAR(64),
    strategic_insight     TEXT,

    -- Validation layer
    validation_npk_json   JSONB,

    created_at            TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_farm FOREIGN KEY (farm_id) REFERENCES farms(farm_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_soil_tests_farm_id ON soil_tests(farm_id);
CREATE INDEX IF NOT EXISTS idx_soil_tests_test_date ON soil_tests(test_date);
CREATE INDEX IF NOT EXISTS idx_soil_tests_location ON soil_tests(location_lat, location_long);
"""

# ---------- MongoDB ----------
# Collections: farms, soil_tests. Each test document has farm_id and location for geo queries.

MONGODB_SCHEMA_DOC = """
# MongoDB schema (document model)

## Collection: farms
{
  "_id": ObjectId,
  "farm_id": "string (unique)",
  "name": "string",
  "created_at": ISODate,
  "updated_at": ISODate
}

## Collection: soil_tests (Land Medical History + Geo)
{
  "_id": ObjectId,
  "farm_id": "string (required, index)",
  "test_date": ISODate,
  "lab_reference": "string",

  "n_ppm": number,
  "p_ppm": number,
  "k_ppm": number,
  "ph": number,
  "ec_ds_m": number,
  "organic_matter_pct": number,

  "location": {
    "type": "Point",
    "coordinates": [longitude, latitude]
  },
  "elevation_m": number,

  "crop_type": "string",

  "ai_report": {
    "soil_status_summary": "string",
    "specific_fertilizer_steps": [...],
    "warnings": ["string"],
    "next_test_date": "string",
    "strategic_insight": "string"
  },
  "validation_npk": {
    "N_kg_per_ha": number,
    "P2O5_kg_per_ha": number,
    "K2O_kg_per_ha": number,
    "method": "string",
    "notes": ["string"]
  },

  "created_at": ISODate
}

# Indexes (create for performance)
db.soil_tests.createIndex({ "farm_id": 1, "test_date": -1 })
db.soil_tests.createIndex({ "location": "2dsphere" })
"""


def get_postgres_schema() -> str:
    """Return PostgreSQL DDL for use in migrations or setup."""
    return POSTGRES_SCHEMA_SQL.strip()


def get_mongodb_schema_doc() -> str:
    """Return MongoDB schema documentation."""
    return MONGODB_SCHEMA_DOC.strip()
