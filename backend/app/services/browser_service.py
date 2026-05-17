import base64
import asyncio
from concurrent.futures import ThreadPoolExecutor
from playwright.sync_api import sync_playwright

_DOM_CHAR_LIMIT = 15_000
_executor = ThreadPoolExecutor(max_workers=2)

# Self-healing strategies — tried in order on failure
_STRATEGIES = [
    {"wait_until": "domcontentloaded", "timeout": 60_000},
    {"wait_until": "load",             "timeout": 60_000},
    {"wait_until": "commit",           "timeout": 30_000},
]


def _capture_page_sync(url: str) -> tuple[str, str, list[dict]]:
    healing_log: list[dict] = []
    last_error = None

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)

        for i, strategy in enumerate(_STRATEGIES):
            page = browser.new_page()
            entry: dict = {"attempt": i + 1, "strategy": strategy["wait_until"]}
            try:
                page.goto(str(url), wait_until=strategy["wait_until"], timeout=strategy["timeout"])
                html = page.content()
                screenshot_bytes = page.screenshot(type="png")
                page.close()
                browser.close()

                entry["status"] = "success"
                healing_log.append(entry)

                trimmed_html = html[:_DOM_CHAR_LIMIT]
                screenshot_b64 = base64.b64encode(screenshot_bytes).decode("utf-8")
                return trimmed_html, screenshot_b64, healing_log

            except Exception as exc:
                last_error = exc
                entry["status"] = "failed"
                entry["error"] = str(exc)[:200]
                healing_log.append(entry)
                page.close()

        browser.close()

    raise RuntimeError(f"All strategies failed. Last: {last_error}")


async def capture_page(url: str) -> tuple[str, str, list[dict]]:
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(_executor, _capture_page_sync, url)
