from typing import Optional
from pydantic import BaseModel, HttpUrl


class TestRequest(BaseModel):
    url: HttpUrl
    user_intent: str


class ThoughtStep(BaseModel):
    thought: str
    action: str


class TestResponse(BaseModel):
    status: str
    thought_stream: list[ThoughtStep]
    logs: list[str]
    code: str
    screenshot: Optional[str] = None
