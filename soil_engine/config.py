"""
Environment and configuration for the Smart Soil Intelligence Platform.
Loads GOOGLE_API_KEY and optional DB settings from .env.
"""
import os
from pathlib import Path

from dotenv import load_dotenv

# Load .env from soil_engine directory (or project root)
_env_path = Path(__file__).resolve().parent / ".env"
load_dotenv(dotenv_path=_env_path)
load_dotenv()  # Fallback: current working directory

GOOGLE_API_KEY: str = os.getenv("GOOGLE_API_KEY", "").strip()
GEMINI_MODEL: str = os.getenv("GEMINI_MODEL", "gemini-1.5-flash").strip()
DATABASE_URL: str = os.getenv("DATABASE_URL", "").strip()
MONGODB_URI: str = os.getenv("MONGODB_URI", "").strip()


def require_google_api_key() -> None:
    """Raise if GOOGLE_API_KEY is missing (for AI features)."""
    if not GOOGLE_API_KEY:
        raise ValueError(
            "GOOGLE_API_KEY is not set. Add it to soil_engine/.env or set the environment variable."
        )
