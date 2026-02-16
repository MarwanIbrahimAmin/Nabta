"""
Logic Layer: Manual N-P-K requirement calculation using standard agronomic formulas.
Serves as a validation layer before/alongside AI interpretation.
Assumes soil test in ppm (mg/kg); converts to kg/ha for a 0–15 cm layer.
"""
from models import NPKValidationResult, SoilLabInput

# Conversion: ppm in 0–15 cm layer ≈ ppm * 2.24 ≈ kg/ha (assuming bulk density ~1.5 g/cm³)
# Simplified: kg_per_ha_from_ppm ≈ ppm * 2.0 for 0–15 cm
PPM_TO_KG_HA_FACTOR = 2.0

# Typical crop uptake (kg nutrient per tonne yield) – simplified lookup
# Keys: crop_type lower; values (N, P2O5, K2O) kg per tonne yield
CROP_UPTAKE_KG_PER_TONNE: dict[str, tuple[float, float, float]] = {
    "wheat": (25.0, 12.0, 8.0),
    "maize": (25.0, 10.0, 20.0),
    "rice": (18.0, 8.0, 6.0),
    "barley": (22.0, 10.0, 8.0),
    "sugar beet": (5.0, 6.0, 8.0),
    "potato": (4.5, 2.0, 6.0),
    "tomato": (3.2, 1.5, 5.0),
    "cotton": (50.0, 25.0, 25.0),
    "default": (25.0, 12.0, 15.0),
}

# Critical levels (ppm) below which we consider soil deficient and recommend fertilization
CRITICAL_P_ppm = 15.0
CRITICAL_K_ppm = 80.0
# N is often not tested directly (we use OM and crop need as proxy); critical ~20 ppm as nitrate-N
CRITICAL_N_ppm = 20.0

# Recovery efficiency (fraction of applied fertilizer taken up) – conservative
N_RECOVERY = 0.5
P_RECOVERY = 0.25
K_RECOVERY = 0.5


def _soil_supply_kg_per_ha(ppm: float | None) -> float:
    """Convert soil test ppm to approximate kg/ha (0–15 cm)."""
    if ppm is None:
        return 0.0
    return max(0.0, ppm * PPM_TO_KG_HA_FACTOR)


def _crop_requirement(crop_type: str | None, target_yield_t_ha: float = 5.0) -> tuple[float, float, float]:
    """Get N, P2O5, K2O requirement in kg/ha for target yield."""
    key = (crop_type or "default").lower().strip()
    uptake = CROP_UPTAKE_KG_PER_TONNE.get(key) or CROP_UPTAKE_KG_PER_TONNE["default"]
    n, p, k = uptake
    return (
        n * target_yield_t_ha,
        p * target_yield_t_ha,
        k * target_yield_t_ha,
    )


def calculate_npk_requirements(lab_input: SoilLabInput) -> NPKValidationResult:
    """
    Compute N-P-K fertilizer requirements using soil test and crop need.
    Uses deficit-based approach: requirement = (crop need - soil supply) / recovery.
    """
    notes: list[str] = []
    n_kg = None
    p_kg = None
    k_kg = None

    crop = (lab_input.crop_type or "").strip() or None
    target_yield = 5.0  # default t/ha
    req_n, req_p2o5, req_k2o = _crop_requirement(crop, target_yield)

    # Soil supply from lab (ppm -> kg/ha)
    supply_n = _soil_supply_kg_per_ha(lab_input.N_ppm)
    supply_p = _soil_supply_kg_per_ha(lab_input.P_ppm)
    supply_k = _soil_supply_kg_per_ha(lab_input.K_ppm)

    # N recommendation: deficit / recovery (crop requirement - supply)
    if lab_input.N_ppm is not None:
        deficit_n = max(0.0, req_n - supply_n)
        n_kg = round(deficit_n / N_RECOVERY, 1)
        if lab_input.N_ppm < CRITICAL_N_ppm:
            notes.append("Soil N below critical level; recommendation is for supplemental N.")
    else:
        notes.append("N not tested; using crop requirement only.")
        n_kg = round(req_n / N_RECOVERY, 1)

    # P recommendation
    if lab_input.P_ppm is not None:
        deficit_p = max(0.0, req_p2o5 - supply_p * 0.4)  # rough P to P2O5
        p_kg = round(deficit_p / P_RECOVERY, 1)
        if lab_input.P_ppm < CRITICAL_P_ppm:
            notes.append("Soil P below critical level; P application recommended.")
    else:
        p_kg = round(req_p2o5 / P_RECOVERY, 1)
        notes.append("P not tested; recommendation from crop requirement.")

    # K recommendation
    if lab_input.K_ppm is not None:
        deficit_k = max(0.0, req_k2o - supply_k * 0.83)  # K to K2O factor
        k_kg = round(deficit_k / K_RECOVERY, 1)
        if lab_input.K_ppm < CRITICAL_K_ppm:
            notes.append("Soil K below critical level; K application recommended.")
    else:
        k_kg = round(req_k2o / K_RECOVERY, 1)
        notes.append("K not tested; recommendation from crop requirement.")

    return NPKValidationResult(
        N_kg_per_ha=n_kg,
        P2O5_kg_per_ha=p_kg,
        K2O_kg_per_ha=k_kg,
        method="soil_test_deficit_crop_requirement",
        notes=notes,
    )
