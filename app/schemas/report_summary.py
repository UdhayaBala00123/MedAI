from pydantic import BaseModel


class ReportSummaryResponse(BaseModel):
    report_id: int
    title: str
    total_results: int
    normal_count: int
    high_count: int
    low_count: int
    results: list[dict]