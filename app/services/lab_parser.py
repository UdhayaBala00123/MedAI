import re


def parse_lab_results(text: str) -> list[dict]:
    results = []

    patterns = {
        "Hemoglobin": (
            r"Hemoglobin\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(g/dL)\s+"
            r"([0-9]+(?:\.[0-9]+)?\s*[–-]\s*[0-9]+(?:\.[0-9]+)?)"
        ),

        "RBC Count": (
            r"RBC Count\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(million/µL)\s+"
            r"([0-9]+(?:\.[0-9]+)?\s*[–-]\s*[0-9]+(?:\.[0-9]+)?)"
        ),

        "WBC Count": (
            r"WBC Count\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(thousand/µL)\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s*[–-]\s*"
            r"([0-9]+(?:\.[0-9]+)?)"
        ),

        "Platelet Count": (
            r"Platelet Count\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(thousand/µL)\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s*[–-]\s*"
            r"([0-9]+(?:\.[0-9]+)?)"
        ),

        "Hematocrit": (
            r"Hematocrit\s+\(PCV\)\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(%)\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s*[–-]\s*"
            r"([0-9]+(?:\.[0-9]+)?)"
        ),

        "MCV": (
            r"MCV\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(fL)\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s*[–-]\s*"
            r"([0-9]+(?:\.[0-9]+)?)"
        ),

        "MCH": (
            r"MCH\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(pg)\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s*[–-]\s*"
            r"([0-9]+(?:\.[0-9]+)?)"
        ),

        "MCHC": (
            r"MCHC\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(g/dL)\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s*[–-]\s*"
            r"([0-9]+(?:\.[0-9]+)?)"
        ),

        "Fasting Glucose": (
            r"Fasting Glucose\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(mg/dL)\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s*[–-]\s*"
            r"([0-9]+(?:\.[0-9]+)?)"
        ),

        "Total Cholesterol": (
            r"Total Cholesterol\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(mg/dL)\s+"
            r"(<\s*[0-9]+)"
        ),

        "HDL Cholesterol": (
            r"HDL Cholesterol\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(mg/dL)\s+"
            r"(>\s*[0-9]+)"
        ),

        "LDL Cholesterol": (
            r"LDL Cholesterol\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(mg/dL)\s+"
            r"(<\s*[0-9]+)"
        ),

        "Triglycerides": (
            r"Triglycerides\s+"
            r"([0-9]+(?:\.[0-9]+)?)\s+"
            r"(mg/dL)\s+"
            r"(<\s*[0-9]+)"
        ),
    }

    # Normalize PDF whitespace.
    normalized_text = re.sub(r"\s+", " ", text).strip()

    for test_name, pattern in patterns.items():
        match = re.search(
            pattern,
            normalized_text,
            re.IGNORECASE
        )

        if not match:
            continue

        value = float(match.group(1))
        unit = match.group(2)

        # Handle reference range formats.
        if test_name in {
            "Hemoglobin",
            "RBC Count"
        }:
            reference_range = match.group(3)

        elif test_name in {
            "WBC Count",
            "Platelet Count",
            "Hematocrit",
            "MCV",
            "MCH",
            "MCHC",
            "Fasting Glucose"
        }:
            reference_range = (
                f"{match.group(3)} - {match.group(4)}"
            )

        else:
            reference_range = match.group(3)

        results.append({
            "test_name": test_name,
            "value": value,
            "unit": unit,
            "reference_range": reference_range
        })

    return results