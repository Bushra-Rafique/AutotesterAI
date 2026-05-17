from fastapi import APIRouter, HTTPException

from app.models.schemas import TestRequest, TestResponse, ThoughtStep
from app.services.browser_service import capture_page
from app.services.ai_service import generate_test_script

router = APIRouter(prefix="/generate-test", tags=["tests"])


@router.post("", response_model=TestResponse)
async def generate_test(request: TestRequest) -> TestResponse:
    thought_stream: list[ThoughtStep] = []
    logs: list[str] = []

    thought_stream.append(ThoughtStep(
        thought="Initializing headless browser session...",
        action=f"Navigating to {request.url}",
    ))

    try:
        html, screenshot, healing_log = await capture_page(str(request.url))
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"Browser error: {exc}") from exc

    # Build thought steps from healing log
    for entry in healing_log:
        attempt = entry["attempt"]
        strategy = entry["strategy"]
        status = entry["status"]

        if status == "success" and attempt == 1:
            thought_stream.append(ThoughtStep(
                thought="Page loaded on first attempt.",
                action=f"Strategy: {strategy} ✅",
            ))
        elif status == "failed":
            thought_stream.append(ThoughtStep(
                thought=f"Attempt {attempt} failed — activating self-heal...",
                action=f"Retrying with strategy: {strategy} ❌",
            ))
        elif status == "success" and attempt > 1:
            thought_stream.append(ThoughtStep(
                thought=f"Self-healed successfully on attempt {attempt}!",
                action=f"Strategy: {strategy} ✅",
            ))

    logs.append(f"Connected to {request.url}")
    thought_stream.append(ThoughtStep(
        thought="Extracting DOM for analysis...",
        action=f"Captured {len(html):,} chars of HTML + screenshot",
    ))

    thought_stream.append(ThoughtStep(
        thought="Sending DOM + intent to Gemini 2.5 Flash...",
        action="Generating Playwright script",
    ))

    try:
        code = generate_test_script(str(request.url), request.user_intent, html)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"AI error: {exc}") from exc

    thought_stream.append(ThoughtStep(
        thought="Script generated successfully.",
        action="Returning result to client",
    ))

    return TestResponse(
        status="success",
        thought_stream=thought_stream,
        logs=logs,
        code=code,
        screenshot=screenshot,
    )
