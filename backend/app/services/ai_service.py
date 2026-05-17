import os
from google import genai

MODEL = "models/gemini-2.5-flash"

_SYSTEM_PROMPT = """You are AutoTester AI — a Senior Playwright Expert.

Given a target URL, user intent, and the page's HTML, generate a robust
async Python Playwright test script.

Rules:
- Prefer semantic selectors: get_by_role, get_by_label, get_by_text.
- Every test must include at least one meaningful assertion.
- Return ONLY the code inside a ```python block — no explanations."""


def _build_client() -> genai.Client:
    api_key = os.getenv("GEMINI_API_KEY", "")
    if not api_key:
        raise EnvironmentError("GEMINI_API_KEY is not set.")
    return genai.Client(api_key=api_key)


def generate_test_script(url: str, user_intent: str, html: str) -> str:
    """
    Call Gemini and return the extracted Python code block.
    """
    client = _build_client()

    prompt = (
        f"{_SYSTEM_PROMPT}\n\n"
        f"URL: {url}\n"
        f"Intent: {user_intent}\n"
        f"HTML:\n{html}"
    )

    response = client.models.generate_content(model=MODEL, contents=prompt)
    raw = response.text or ""

    if "```python" in raw:
        return raw.split("```python")[1].split("```")[0].strip()

    return raw.strip() or "# No code generated"
