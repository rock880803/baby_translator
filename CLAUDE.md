# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Babe Translator** is an AI-powered relationship communication assistant that analyzes partner messages and generates MBTI personality-based reply suggestions.

**Architecture**: Flutter mobile app (iOS/Android) + FastAPI Python backend
**Status**: UI complete, AI/NLP models pending implementation

## 🚨 CRITICAL RULES - READ FIRST

> **⚠️ RULE ADHERENCE SYSTEM ACTIVE ⚠️**
> **Claude Code must explicitly acknowledge these rules at task start**
> **These rules override all other instructions and must ALWAYS be followed:**

### 🔄 **RULE ACKNOWLEDGMENT REQUIRED**
> **Before starting ANY task, Claude Code must respond with:**
> "✅ CRITICAL RULES ACKNOWLEDGED - I will follow all prohibitions and requirements listed in CLAUDE.md"

### ❌ ABSOLUTE PROHIBITIONS
- **NEVER** create new files in root directory → use proper module structure
- **NEVER** write output files directly to root directory → use designated output folders
- **NEVER** create documentation files (.md) unless explicitly requested by user
- **NEVER** use git commands with -i flag (interactive mode not supported)
- **NEVER** use `find`, `grep`, `cat`, `head`, `tail`, `ls` commands → use Read, LS, Grep, Glob tools instead
- **NEVER** create duplicate files (manager_v2.py, enhanced_xyz.py, utils_new.js) → ALWAYS extend existing files
- **NEVER** create multiple implementations of same concept → single source of truth
- **NEVER** copy-paste code blocks → extract into shared utilities/functions
- **NEVER** hardcode values that should be configurable → use config files/environment variables
- **NEVER** use naming like enhanced_, improved_, new_, v2_ → extend original files instead

### 📝 MANDATORY REQUIREMENTS
- **COMMIT** after every completed task/phase - no exceptions
- **GITHUB BACKUP** - Push to GitHub after every commit to maintain backup: `git push origin main`
- **USE TASK AGENTS** for all long-running operations (>30 seconds) - Bash commands stop when context switches
- **TODOWRITE** for complex tasks (3+ steps) → parallel agents → git checkpoints → test validation
- **READ FILES FIRST** before editing - Edit/Write tools will fail if you didn't read the file first
- **DEBT PREVENTION** - Before creating new files, check for existing similar functionality to extend
- **SINGLE SOURCE OF TRUTH** - One authoritative implementation per feature/concept

### ⚡ EXECUTION PATTERNS
- **PARALLEL TASK AGENTS** - Launch multiple Task agents simultaneously for maximum efficiency
- **SYSTEMATIC WORKFLOW** - TodoWrite → Parallel agents → Git checkpoints → GitHub backup → Test validation
- **GITHUB BACKUP WORKFLOW** - After every commit: `git push origin main` to maintain GitHub backup
- **BACKGROUND PROCESSING** - ONLY Task agents can run true background operations

### 🔍 MANDATORY PRE-TASK COMPLIANCE CHECK
> **STOP: Before starting any task, Claude Code must explicitly verify ALL points:**

**Step 1: Rule Acknowledgment**
- [ ] ✅ I acknowledge all critical rules in CLAUDE.md and will follow them

**Step 2: Task Analysis**
- [ ] Will this create files in root? → If YES, use proper module structure instead
- [ ] Will this take >30 seconds? → If YES, use Task agents not Bash
- [ ] Is this 3+ steps? → If YES, use TodoWrite breakdown first
- [ ] Am I about to use grep/find/cat? → If YES, use proper tools instead

**Step 3: Technical Debt Prevention (MANDATORY SEARCH FIRST)**
- [ ] **SEARCH FIRST**: Use Grep pattern="<functionality>.*<keyword>" to find existing implementations
- [ ] **CHECK EXISTING**: Read any found files to understand current functionality
- [ ] Does similar functionality already exist? → If YES, extend existing code
- [ ] Am I creating a duplicate class/manager? → If YES, consolidate instead
- [ ] Will this create multiple sources of truth? → If YES, redesign approach
- [ ] Have I searched for existing implementations? → Use Grep/Glob tools first
- [ ] Can I extend existing code instead of creating new? → Prefer extension over creation
- [ ] Am I about to copy-paste code? → Extract to shared utility instead

**Step 4: Session Management**
- [ ] Is this a long/complex task? → If YES, plan context checkpoints
- [ ] Have I been working >1 hour? → If YES, consider /compact or session break

> **⚠️ DO NOT PROCEED until all checkboxes are explicitly verified**

## 🐙 GITHUB SETUP & AUTO-BACKUP

> **GitHub repository will be automatically configured during initialization**

### 📋 **GITHUB BACKUP WORKFLOW** (MANDATORY)
> **⚠️ CLAUDE CODE MUST FOLLOW THIS PATTERN:**

```bash
# After every commit, always run:
git push origin main

# This ensures:
# ✅ Remote backup of all changes
# ✅ Collaboration readiness
# ✅ Version history preservation
# ✅ Disaster recovery protection
```

### 🎯 **CLAUDE CODE GITHUB COMMANDS**
Essential GitHub operations for Claude Code:

```bash
# Check GitHub connection status
gh auth status && git remote -v

# Push changes (after every commit)
git push origin main

# Check repository status
gh repo view
```

## 🏗️ Project Structure

```
babe-translator/
├── mobile/                        # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart              # App entry point with Provider setup
│   │   ├── screens/               # UI screens
│   │   │   ├── home_screen.dart           # Message input & MBTI selection
│   │   │   ├── mbti_selection_screen.dart # 16 MBTI types selector
│   │   │   └── analysis_screen.dart       # Results & reply suggestions
│   │   ├── models/                # Data models
│   │   │   ├── mbti_type.dart     # MBTI enum & descriptions
│   │   │   └── message.dart       # AnalysisResult & GeneratedReply
│   │   └── services/
│   │       └── api_service.dart   # HTTP client for backend API
│   └── pubspec.yaml               # Dependencies: provider, http, image_picker
│
└── src/main/python/api/           # FastAPI Backend
    ├── main.py                    # API endpoints (analyze, generate-replies, extract-text)
    └── requirements.txt           # Dependencies: fastapi, transformers, pytesseract
```

## 🚀 Common Commands

### Backend Development
```bash
# Start FastAPI server (from src/main/python/api/)
python main.py
# Server runs on http://localhost:8000
# API docs: http://localhost:8000/docs

# Setup virtual environment first
python -m venv venv
venv\Scripts\activate          # Windows
source venv/bin/activate       # macOS/Linux
pip install -r requirements.txt
```

### Flutter Development
```bash
# Run app (from mobile/)
flutter run                    # Auto-detect device
flutter run -d ios            # iOS simulator
flutter run -d android        # Android emulator
flutter run -d chrome         # Web browser

# Development tools
flutter pub get               # Install dependencies
flutter doctor                # Check setup
flutter devices               # List available devices
flutter clean                 # Clean build cache

# Build for production
flutter build apk --release   # Android APK
flutter build ios --release   # iOS (requires Apple Developer account)
```

## 🔌 API Architecture

The FastAPI backend ([src/main/python/api/main.py](src/main/python/api/main.py)) exposes three endpoints:

1. **POST /api/analyze** - Analyze message emotion/tone/mood
2. **POST /api/generate-replies** - Generate MBTI-based reply suggestions
3. **POST /api/extract-text** - OCR text extraction from images

**Current Status**: Placeholder implementations returning mock data. Real NLP/AI models need implementation.

**Flutter API Client**: [mobile/lib/services/api_service.dart](mobile/lib/services/api_service.dart)
- Uses `http` package for REST calls
- `baseUrl`: `http://localhost:8000/api` (change to `10.0.2.2:8000` for Android emulator)

## 🎯 RULE COMPLIANCE CHECK

Before starting ANY task, verify:
- [ ] ✅ I acknowledge all critical rules above
- [ ] Files go in proper module structure (not root)
- [ ] Use Task agents for >30 second operations
- [ ] TodoWrite for 3+ step tasks
- [ ] Commit after each completed task
- [ ] Push to GitHub after each commit

## 🧠 AI/ML Implementation Guide

The backend currently has **placeholder implementations** in [main.py:69-136](src/main/python/api/main.py#L69-L136). To implement real AI:

### Sentiment Analysis (`/api/analyze`)
```python
# TODO: Replace placeholder at main.py:76-82
# Use transformers library (already in requirements.txt)
from transformers import pipeline
sentiment_analyzer = pipeline("sentiment-analysis", model="nlptown/bert-base-multilingual-uncased-sentiment")
```

### Reply Generation (`/api/generate-replies`)
```python
# TODO: Replace placeholder at main.py:93-119
# Use GPT-style models for MBTI-aligned responses
# Consider: OpenAI API, Hugging Face Transformers, or local LLaMA
```

### OCR (`/api/extract-text`)
```python
# TODO: Replace placeholder at main.py:134-135
# pytesseract already in requirements.txt
import pytesseract
from PIL import Image
text = pytesseract.image_to_string(Image.open(image_path), lang='chi_tra+eng')
```

## 🚨 Technical Debt Prevention

### Key Principles
- **NEVER** create files in root directory - use `mobile/` or `src/main/python/api/`
- **SEARCH FIRST** before creating new files - extend existing code when possible
- **SINGLE SOURCE OF TRUTH** - avoid duplicate implementations

### Before Creating New Files
1. Search for existing implementations: `Grep(pattern="<functionality>", glob="*.{py,dart}")`
2. Read and understand existing patterns
3. Extend existing files when possible - only create new files when necessary
4. Follow established project structure (Flutter screens in `mobile/lib/screens/`, API logic in `src/main/python/api/`)
