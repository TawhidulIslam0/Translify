# Translify

> **Real-Time Multimodal Translation System**

Translify is a mobile application designed to bridge real-world communication gaps. It provides camera-based OCR text translation and real-time bidirectional speech translation in an architecture engineered for user privacy and low latency.

---

## Table of Contents

- [Overview](#overview)
- [Problem](#problem)
- [Solution](#solution)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [Tech Stack](#tech-stack)
- [Data Flow](#data-flow)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Security & Privacy](#security--privacy)
- [Performance Considerations](#performance-considerations)

---

## Overview

Translify enables seamless, multimodal translation across everyday real-world contexts:

* **Camera-Based Text Translation:** Point your camera at menus, signs, or printed documents to detect, transcribe, and overlay translations directly onto the live view.
* **Conversational Speech Translation:** Two users share a single device to converse. Spoken input is transcribed into text, translated, and displayed on screen in real time.
* **Core Language Support:** Initial release supports English and Spanish, with an extensible framework built for scalable multi-language expansion.
* **Privacy-First Design:** Features complete user data ownership. Users choose whether translation history is stored locally or on the server.

---

## Problem

In globalized urban environments and travel destinations, language barriers present continuous friction:

* **Daily Interactions:** Difficulty asking for directions or understanding local transport signs.
* **Travel Friction:** Anxiety and communication blockages when arriving in foreign environments.
* **Legal & Official Documents:** Inability to inspect or understand physical documents without intermediate translators.

Relying on human translators can be costly, slow, and unfeasible for immediate everyday needs. Existing mobile commercial solutions (e.g., Google Translate, DeepL) often bundle cluttered interfaces, unnecessary features, and aggressive data retention policies that compromise user privacy.

---

## Solution

Translify delivers a streamlined, self-hosted translation pipeline:

* **Integrated Dual-Engine:** OCR and Speech processing accessible from a unified mobile interface.
* **Self-Hosted Infrastructure:** Translation tasks run on self-hosted instances to eliminate third-party telemetry and data harvesting.
* **Flexible Data Storage:** Strict user opt-in controls for storing past translations.

---

## Key Features

* **Dual-Mode Translation Engine:** Unified handling of live camera frames (OCR) and microphone streams (Speech-to-Text).
* **Low-Latency Pipeline:** Optimized microservice processing for real-time overlay and display.
* **Modular Architecture:** Fully decoupled microservices (Server Core, Image Processing, Speech Processing, Translation Engine).
* **Self-Hosted Translation:** Powered by LibreTranslate to maintain full execution control.
* **Granular Security Controls:** JWT authentication, hashed credentials, and explicit opt-in history retention.

---

## System Architecture

```
                       ┌──────────────────────┐
                       │    Flutter Client    │
                       │   (Android / iOS)    │
                       └──────────┬───────────┘
                                  │ HTTP / JSON
                                  ▼
                       ┌──────────────────────┐
                       │  FastAPI Server Core │
                       └────┬────────────┬────┘
                            │            │
            ┌───────────────┼────────────┴───────────────┐
            ▼               ▼                            ▼
  ┌───────────────────┐  ┌────────────────────┐  ┌──────────────────────┐
  │ Image Processing  │  │ Speech Processing  │  │  Translation Engine  │
  │ (OpenCV/Pytess.)  │  │ (SpeechRec/PyAudio)│  │   (LibreTranslate)   │
  └───────────────────┘  └────────────────────┘  └──────────────────────┘
            │               │                            │
            └───────────────┼────────────────────────────┘
                            ▼
                   ┌──────────────────┐
                   │   PostgreSQL     │
                   │    Database      │
                   └──────────────────┘
```

---

## Tech Stack

| Domain | Technology |
| :--- | :--- |
| **Frontend** | Flutter, Dart |
| **Backend Core** | Python, FastAPI, Uvicorn |
| **Database** | PostgreSQL |
| **Image Processing** | OpenCV, Pytesseract |
| **Speech Processing** | SpeechRecognition, PyAudio |
| **Translation Engine** | Self-hosted LibreTranslate |
| **Containerization** | Docker |

---

## Data Flow

### Camera Translation (OCR)
1. User captures or points camera at text in the Flutter mobile application.
2. Flutter sends payload to `/server_core`.
3. `/server_core` forwards image to the `image-processing` microservice for text detection and OCR extraction.
4. Extracted text is sent to `translation-engine` (LibreTranslate).
5. Translated text payload is returned to Flutter and rendered on-screen.

### Conversational Speech Translation
1. User records speech input in the app.
2. Audio stream is sent via `/server_core` to the `speech-processing` microservice for transcription.
3. Transcribed text is dispatched to `translation-engine`.
4. Translated response is returned to the client interface for display.

---

## Repository Structure

```
.
├── translify/               # Flutter mobile application codebase
├── server_core/             # FastAPI backend orchestration service
├── image_processing/        # Microservice for OpenCV & OCR operations
├── speech_processing/       # Microservice for SpeechRecognition logic
├── translation_engine/      # Dockerized LibreTranslate service configuration
└── README.md                # Project documentation
```

---

## Getting Started

### Prerequisites
* **RAM:** Minimum 16GB (24GB recommended for running all microservices locally).
* **Tools:** Flutter SDK, Android Studio (with an emulator or physical device), Docker Desktop, Python 3.10+, PostgreSQL.

---

### Step-by-Step Setup

#### 1. Clone the Repository
```bash
git clone https://github.com/your-username/translify.git
cd translify
```

#### 2. Mobile Frontend Configuration
Navigate to the `translify` directory and follow the setup guide inside `translify/README.md`. Ensure Flutter dependencies are resolved:
```bash
cd translify
flutter pub get
```

#### 3. Spin Up Docker Microservices
Build and run the auxiliary microservices (`image-processing`, `speech-processing`, `translation-engine`). 

> **Note:** To prevent re-downloading Hugging Face model weights on container restart, mount your host cache directory.

* **Linux / macOS:**
  ```bash
  docker run -d -p 5001:8080 -v $HOME/.cache/huggingface/hub:/root/.cache/huggingface/hub <image-processing-img>
  docker run -d -p 5002:8080 <speech-processing-img>
  docker run -d -p 5003:8080 -v $HOME/.cache/huggingface/hub:/root/.cache/huggingface/hub <translation-engine-img>
  ```

* **Windows (PowerShell):**
  ```powershell
  docker run -d -p 5001:8080 -v C:\Users\$env:USERNAME\.cache\huggingface:/root/.cache/huggingface <image-processing-img>
  docker run -d -p 5002:8080 <speech-processing-img>
  docker run -d -p 5003:8080 -v C:\Users\$env:USERNAME\.cache\huggingface:/root/.cache/huggingface <translation-engine-img>
  ```

#### 4. PostgreSQL Configuration
Ensure your local PostgreSQL service is running on default port `5432` and create a database instance for the application.

#### 5. Backend Server Core Environment Setup
Create a `.env` file in `/server_core`:

```env
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password
DATABASE_NAME=translify_db
DATABASE_SOCKET=localhost

TRANSLATE_SERVICE=http://127.0.0.1:5003
IMAGE_TO_TEXT_SERVICE=http://127.0.0.1:5001
SPEECH_TO_TEXT_SERVICE=http://127.0.0.1:5002
```

Ensure `load_dotenv()` is un-commented in `/server_core/app/config.py`.

#### 6. Run the Backend Core

* **macOS / Linux:**
  ```bash
  cd server_core
  python3 -m venv venv
  source venv/bin/activate
  pip install -r requirements.txt
  ```

* **Windows (PowerShell / Git Bash):**
  ```powershell
  cd server_core
  python -m venv venv
  .\venv\Scripts\activate
  pip install -r requirements.txt
  ```

**Launch Uvicorn Server:**
* **For Android Emulator:**
  ```bash
  uvicorn app.main:app --reload --port 8000
  ```
* **For Physical Device (Local Network):**
  ```bash
  uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
  ```

---

## Development Workflow

1. **Branching Strategy:** Use feature branches (`feature/ocr-optimization`, `fix/audio-latency`) stemming from `main`.
2. **Local Testing:** Test endpoints via FastAPI built-in documentation at `http://127.0.0.1:8000/docs`.
3. **Frontend Integration:** Update local API service URLs in Flutter configuration files to target `10.0.2.2:8000` (for Android Emulator) or your workstation's LAN IP address (for physical devices).

---

## Security & Privacy

* **Strict Opt-In Data Retention:** Translation streams are processed transiently in memory and purged immediately unless the user explicitly opts into saving translation history.
* **Credential Protection:** Passwords and access tokens are hashed using bcrypt prior to database persistence.
* **Data Isolation:** Translation history is strictly scoped to authenticated user accounts via JWT.

---

## Performance Considerations

* **Payload Optimization:** Small text blocks are processed incrementally to maintain low latency during vision OCR tasks.
* **Translation Caching:** Frequently translated phrases are cached locally to prevent redundant microservice requests.
* **Input Capping:** Image payloads and speech duration are bounded at API boundaries to avoid memory spikes on the backend core.
