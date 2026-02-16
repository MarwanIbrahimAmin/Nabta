# Smart Soil Intelligence Platform – AI Engine

Transforms raw soil lab data (N, P, K, pH, EC, organic matter) into **actionable insights** and fertilizer prescriptions using Google Gemini and a validation layer.

## Setup

1. **Python 3.10+** and a virtual environment recommended:
   ```bash
   cd soil_engine
   python -m venv venv
   venv\Scripts\activate   # Windows
   pip install -r requirements.txt
   ```

2. **API key**: Copy `.env.example` to `.env` and set your `GOOGLE_API_KEY`, or leave the existing `.env` in place (do not commit `.env` with real keys).

## Run

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

- **Health**: `GET http://localhost:8000/health`
- **Analyze**: `POST http://localhost:8000/analyze-soil` with JSON body (see example below).

## API: POST /analyze-soil

**Request body** (all fields optional except at least one lab value):

- `N_ppm`, `P_ppm`, `K_ppm`, `pH`, `EC_dS_m`, `organic_matter_pct` – lab results
- `crop_type` – e.g. "Wheat", "Maize"
- `farm_id` – for Land Medical History / DB
- `location` – `{ "lat": 30.04, "long": 31.23 }` for geo/heatmaps
- `test_date`, `lab_reference`

**Response**: `ai_report` (soil_status_summary, specific_fertilizer_steps, warnings, next_test_date), `validation_npk` (manual N-P-K calculation), plus farm_id/location/test_date when provided.

## Database (optional)

- **PostgreSQL**: Set `DATABASE_URL` in `.env` and run the DDL in `schema_db.py` (`get_postgres_schema()`).
- **MongoDB**: See `schema_db.py` (`get_mongodb_schema_doc()`) for collection design and indexes.

When `DATABASE_URL` is not set, the API runs without persistence; analysis and validation still work.

## Structure

- `main.py` – FastAPI app, `/analyze-soil` endpoint
- `ai_engine.py` – Gemini wrapper, structured JSON output
- `prompts.py` – Expert Agronomist system prompt
- `npk_logic.py` – Manual N-P-K validation formulas
- `models.py` – Pydantic request/response models
- `schema_db.py` – PostgreSQL DDL and MongoDB schema
- `config.py` – Loads `.env` (GOOGLE_API_KEY, etc.)
