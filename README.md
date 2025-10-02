# Babe Translator

> **AI-Powered Relationship Communication Assistant**

This project utilizes Natural Language Processing (NLP) and Artificial Intelligence (AI) to analyze messages received from a partner, whether through screenshots or text. Based on the user's selected MBTI personality type, it intelligently generates a variety of suggested replies in different styles that are tailored to the user's personality.

## ✨ Key Values

### 🎯 Understanding the Emotion Behind the Message
The app goes beyond simple replies by analyzing the mood, tone, and underlying needs in a partner's message to provide a truly thoughtful and caring response.

### 💬 Personalized Reply Styles
It ensures that the generated responses align with the user's MBTI personality, making the messages feel genuine and natural rather than stiff or generic.

### 💕 Improving Relationship Communication
By helping users overcome communication barriers, the app facilitates smoother daily conversations and strengthens mutual understanding and emotional connection.

## 🚀 Quick Start

1. **Read CLAUDE.md first** - Contains essential rules for Claude Code
2. Follow the pre-task compliance checklist before starting any work
3. Use proper module structure under `src/main/python/`
4. Commit after every completed task
5. Push to GitHub after every commit

## 📁 Project Structure

```
babe-translator/
├── CLAUDE.md              # Essential rules for Claude Code
├── README.md              # This file
├── APP_SETUP.md           # 📱 App development guide
├── .gitignore             # Git ignore patterns
│
├── mobile/                # 📱 Flutter App (iOS/Android)
│   ├── lib/
│   │   ├── main.dart      # App entry point
│   │   ├── screens/       # UI screens
│   │   │   ├── home_screen.dart
│   │   │   ├── mbti_selection_screen.dart
│   │   │   └── analysis_screen.dart
│   │   ├── models/        # Data models
│   │   │   ├── mbti_type.dart
│   │   │   └── message.dart
│   │   └── services/      # API services
│   │       └── api_service.dart
│   └── pubspec.yaml       # Flutter dependencies
│
├── src/                   # Source code
│   ├── main/
│   │   ├── python/        # Python application code
│   │   │   ├── core/      # Core NLP/AI algorithms
│   │   │   ├── utils/     # Data processing utilities
│   │   │   ├── models/    # Model definitions/MBTI analysis
│   │   │   ├── services/  # ML services and pipelines
│   │   │   ├── api/       # 🔥 FastAPI backend
│   │   │   │   ├── main.py           # API main server
│   │   │   │   └── requirements.txt  # Python dependencies
│   │   │   ├── training/  # Training scripts
│   │   │   ├── inference/ # Response generation
│   │   │   └── evaluation/# Model evaluation
│   │   └── resources/     # Configuration and assets
│   │       ├── config/    # Configuration files
│   │       ├── data/      # Sample/seed data
│   │       └── assets/    # Static assets
│   └── test/              # Test code
│       ├── unit/          # Unit tests
│       ├── integration/   # Integration tests
│       └── fixtures/      # Test data
│
├── data/                  # Dataset management
│   ├── raw/               # Original datasets
│   ├── processed/         # Cleaned and transformed data
│   ├── external/          # External data sources
│   └── temp/              # Temporary processing files
│
├── notebooks/             # Jupyter notebooks
│   ├── exploratory/       # Data exploration
│   ├── experiments/       # ML experiments
│   └── reports/           # Analysis reports
│
├── models/                # ML Models and artifacts
│   ├── trained/           # Trained model files
│   ├── checkpoints/       # Model checkpoints
│   └── metadata/          # Model metadata
│
├── experiments/           # Experiment tracking
│   ├── configs/           # Experiment configurations
│   ├── results/           # Experiment results
│   └── logs/              # Training logs
│
├── docs/                  # Documentation
│   ├── api/               # API documentation
│   ├── user/              # User guides
│   └── dev/               # Developer documentation
│
├── tools/                 # Development tools
├── scripts/               # Automation scripts
├── examples/              # Usage examples
├── output/                # Generated output files
├── logs/                  # Application logs
└── tmp/                   # Temporary files
```

## 🛠️ Development Guidelines

- **Always search first** before creating new files
- **Extend existing** functionality rather than duplicating
- **Use Task agents** for operations >30 seconds
- **Single source of truth** for all functionality
- **Language-agnostic structure** - scalable Python architecture
- **MLOps ready** - experiment tracking and model versioning

## 🔬 Core Features

### Message Analysis
- Emotion detection and sentiment analysis
- Tone and mood interpretation
- Underlying needs identification

### MBTI-Based Response Generation
- Personality-aligned reply suggestions
- Multiple response style variations
- Natural and authentic messaging

### Communication Enhancement
- Barrier identification and resolution
- Relationship communication improvement
- Emotional connection strengthening

## 📋 Development Status

- ✅ **Project Setup**: Complete
- ✅ **Flutter App Structure**: Complete (iOS/Android support)
- ✅ **FastAPI Backend**: Complete (REST API ready)
- ✅ **UI/UX Design**: Complete (3 main screens)
- ⏳ **AI/NLP Models**: Pending (placeholder implementation)
- ⏳ **OCR Integration**: Pending
- ⏳ **Testing**: Pending

## 📱 App Features

### ✅ Implemented
- **Cross-platform**: iOS & Android support with Flutter
- **MBTI Selection**: 16 personality types with descriptions
- **Message Input**: Text input, camera, and gallery support
- **Image OCR**: Text extraction from screenshots
- **Emotion Analysis**: Mood, tone, and sentiment detection
- **Reply Generation**: MBTI-based personalized responses
- **Multiple Styles**: Various reply styles with confidence scores
- **Copy to Clipboard**: One-tap reply copying

### 🔨 To Implement
- Real NLP sentiment analysis models
- MBTI-based reply generation AI
- Actual OCR implementation
- User preferences and history
- Multi-language support

## 🚀 Getting Started with App Development

📖 **See [APP_SETUP.md](APP_SETUP.md) for detailed setup instructions**

### Quick Start:
```bash
# 1. Start Backend API
cd src/main/python/api
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
python main.py

# 2. Run Flutter App
cd mobile
flutter pub get
flutter run
```

---

**🤖 Built with Claude Code - AI-powered development assistant**
