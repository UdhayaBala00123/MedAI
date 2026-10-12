from app.models.report_result import ReportResult


def build_report_summary(report_id: int, title: str, results: list[ReportResult]) -> dict:
    normal_count = sum(
        1 for result in results
        if result.status == "normal"
    )

    high_count = sum(
        1 for result in results
        if result.status == "high"
    )

    low_count = sum(
        1 for result in results
        if result.status == "low"
    )

    return {
        "report_id": report_id,
        "title": title,
        "total_results": len(results),
        "normal_count": normal_count,
        "high_count": high_count,
        "low_count": low_count,
        "results": [
            {
                "id": result.id,
                "test_name": result.test_name,
                "value": result.value,
                "unit": result.unit,
                "reference_range": result.reference_range,
                "status": result.status
            }
            for result in results
        ]
    }