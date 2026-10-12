LAB_REFERENCE_RANGES = {
    "Hemoglobin": {
        "unit": "g/dL",
        "low": 13.0,
        "high": 17.0,
        "range": "13.0 - 17.0"
    },
    "RBC Count": {
        "unit": "million/µL",
        "low": 4.5,
        "high": 5.9,
        "range": "4.5 - 5.9"
    },
    "WBC Count": {
        "unit": "thousand/µL",
        "low": 4.0,
        "high": 11.0,
        "range": "4.0 - 11.0"
    },
    "Platelet Count": {
        "unit": "thousand/µL",
        "low": 150.0,
        "high": 450.0,
        "range": "150 - 450"
    },
    "Hematocrit": {
        "unit": "%",
        "low": 40.0,
        "high": 52.0,
        "range": "40.0 - 52.0"
    },
    "MCV": {
        "unit": "fL",
        "low": 80.0,
        "high": 100.0,
        "range": "80.0 - 100.0"
    },
    "MCH": {
        "unit": "pg",
        "low": 27.0,
        "high": 33.0,
        "range": "27.0 - 33.0"
    },
    "MCHC": {
        "unit": "g/dL",
        "low": 32.0,
        "high": 36.0,
        "range": "32.0 - 36.0"
    },
    "Fasting Glucose": {
        "unit": "mg/dL",
        "low": 70.0,
        "high": 99.0,
        "range": "70 - 99"
    },
    "Total Cholesterol": {
        "unit": "mg/dL",
        "low": 0.0,
        "high": 199.0,
        "range": "< 200"
    },
    "HDL Cholesterol": {
        "unit": "mg/dL",
        "low": 40.0,
        "high": 1000.0,
        "range": ">= 40"
    },
    "LDL Cholesterol": {
        "unit": "mg/dL",
        "low": 0.0,
        "high": 129.0,
        "range": "< 130"
    },
    "Triglycerides": {
        "unit": "mg/dL",
        "low": 0.0,
        "high": 149.0,
        "range": "< 150"
    }
}


def get_reference_range(test_name: str):
    return LAB_REFERENCE_RANGES.get(test_name)


def get_result_status(test_name: str, value: float):
    reference = get_reference_range(test_name)

    if reference is None:
        return None

    if value < reference["low"]:
        return "low"

    if value > reference["high"]:
        return "high"

    return "normal"

import re


def evaluate_reference_range(value: float, reference_range: str) -> str:
    """
    Evaluate a lab value against the reference range printed
    on the medical report.

    Supported formats:
    - 13.0 - 17.0
    - 13.0 – 17.0
    - < 200
    - > 40
    """

    if not reference_range:
        return "unknown"

    normalized = reference_range.strip()

    # ---------------------------------------------------------
    # Range: 13.0 - 17.0 or 13.0 – 17.0
    # ---------------------------------------------------------

    range_match = re.match(
        r"^\s*([0-9]+(?:\.[0-9]+)?)\s*[-–]\s*"
        r"([0-9]+(?:\.[0-9]+)?)\s*$",
        normalized
    )

    if range_match:
        low = float(range_match.group(1))
        high = float(range_match.group(2))

        if value < low:
            return "low"

        if value > high:
            return "high"

        return "normal"

    # ---------------------------------------------------------
    # Less than: < 200
    # ---------------------------------------------------------

    less_match = re.match(
        r"^\s*<\s*([0-9]+(?:\.[0-9]+)?)\s*$",
        normalized
    )

    if less_match:
        upper_limit = float(less_match.group(1))

        if value < upper_limit:
            return "normal"

        return "high"

    # ---------------------------------------------------------
    # Greater than: > 40
    # ---------------------------------------------------------

    greater_match = re.match(
        r"^\s*>\s*([0-9]+(?:\.[0-9]+)?)\s*$",
        normalized
    )

    if greater_match:
        lower_limit = float(greater_match.group(1))

        if value > lower_limit:
            return "normal"

        return "low"

    return "unknown"