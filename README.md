# AutoTester AI

An AI-powered mobile agent that generates robust Playwright test scripts from plain-English intent. Point it at any URL, describe what you want to test, and it returns a production-ready Python test script — automatically.

Built with Flutter, FastAPI, Playwright, and Gemini 2.5 Flash.

---

## Overview

AutoTester AI combines a headless browser, a large language model, and a mobile interface into a single test generation pipeline. The agent navigates to the target URL, captures the live DOM, and sends it alongside your intent to Gemini, which returns a Playwright script using semantic selectors. If the browser fails to load the page, the agent automatically retries with alternative strategies before giving up.

---

## Features

- Generate Playwright scripts from plain English
- Self-healing browser — three fallback navigation strategies
- Live agent thought stream with step-by-step reasoning
- Page screenshot with pinch-to-zoom
- Copy or export the generated `.py` script
- Full test history with pass/fail status, grouped by date
- Glassmorphism dark UI with animated splash screen

---

## Project Structure

```
autotester-ai/
├── .github/
│   └── workflows/
│       └── ci.yml
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── models/
│   │   │   └── schemas.py
│   │   ├── services/
│   │   │   ├── browser_service.py
│   │   │   └── ai_service.py
│   │   └── routers/
│   │       └── test_router.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
└── mobile/
    ├── lib/
    │   ├── main.dart
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   └── widgets/
    ├── pubspec.yaml
    └── .env.example
```

---

## Getting Started

### Prerequisites

- Python 3.12
- Flutter 3.x
- A [Google AI Studio](https://aistudio.google.com) API key

### Backend

```bash
cd backend
python -m venv .venv

# Mac / Linux
source .venv/bin/activate

# Windows
.venv\Scripts\activate

pip install -r requirements.txt
playwright install chromium
cp .env.example .env
```

Open `.env` and add your key:

```
GEMINI_API_KEY=your_key_here
```

Start the server:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Mobile

```bash
cd mobile
flutter pub get
cp .env.example .env
```

Open `.env` and set the backend URL:

```
# Android emulator
APP_URL=http://10.0.2.2:8000

# Physical device — use your machine's local IP
APP_URL=http://192.168.x.x:8000
```

Run the app:

```bash
flutter run
```

---

## Environment Variables

| Variable | Location | Description |
|---|---|---|
| `GEMINI_API_KEY` | `backend/.env` | Google AI Studio API key |
| `APP_URL` | `mobile/.env` | Backend base URL |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter + Dart |
| Backend | FastAPI + Uvicorn |
| Browser automation | Playwright (Chromium) |
| AI model | Gemini 2.5 Flash |
| CI/CD | GitHub Actions |

---

## CI/CD

GitHub Actions runs on every push to `main` and on pull requests:

- **Backend** — Ruff linter on all Python source files
- **Mobile** — `flutter analyze` and `dart format` check

---

## Notes

- The backend must be running for the mobile app to connect
- The `--reload` flag causes issues on Windows — omit it
- Screenshots are not stored in history to keep local storage light
- History is capped at 30 entries stored in device preferences

---

## License

MIT
