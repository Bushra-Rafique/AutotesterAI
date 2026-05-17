import asyncio
import sys

if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsProactorEventLoopPolicy())

import os
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers.test_router import router as test_router

# Load .env from the backend/ directory
load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup / shutdown hooks."""
    print("✅ AutoTester AI backend is ready.")
    yield
    print("🛑 Shutting down.")


def create_app() -> FastAPI:
    app = FastAPI(
        title="AutoTester AI",
        description="AI-powered Playwright test generator",
        version="1.0.0",
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],   # Tighten this in production
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(test_router)
    return app


app = create_app()
