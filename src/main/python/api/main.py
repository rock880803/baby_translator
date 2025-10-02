from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from enum import Enum
import uvicorn

app = FastAPI(title="Babe Translator API")

# CORS middleware for mobile app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class MBTIType(str, Enum):
    INTJ = "INTJ"
    INTP = "INTP"
    ENTJ = "ENTJ"
    ENTP = "ENTP"
    INFJ = "INFJ"
    INFP = "INFP"
    ENFJ = "ENFJ"
    ENFP = "ENFP"
    ISTJ = "ISTJ"
    ISFJ = "ISFJ"
    ESTJ = "ESTJ"
    ESFJ = "ESFJ"
    ISTP = "ISTP"
    ISFP = "ISFP"
    ESTP = "ESTP"
    ESFP = "ESFP"

class MessageRequest(BaseModel):
    content: str

class AnalysisResponse(BaseModel):
    emotion: str
    tone: str
    mood: str
    underlying_needs: List[str]
    sentiment_score: float

class ReplyStyle(BaseModel):
    name: str
    description: str

class GeneratedReply(BaseModel):
    content: str
    style: ReplyStyle
    confidence: float

class GenerateRepliesRequest(BaseModel):
    message: str
    mbti_type: MBTIType
    analysis: dict

class GenerateRepliesResponse(BaseModel):
    replies: List[GeneratedReply]

@app.get("/")
async def root():
    return {"message": "Babe Translator API", "version": "1.0.0"}

@app.post("/api/analyze", response_model=AnalysisResponse)
async def analyze_message(request: MessageRequest):
    """
    Analyze the emotional content of a message
    TODO: Implement actual NLP analysis
    """
    # Placeholder implementation
    # TODO: Replace with actual sentiment analysis, emotion detection
    return AnalysisResponse(
        emotion="關心",
        tone="溫柔",
        mood="想念",
        underlying_needs=["陪伴", "關注", "情感連結"],
        sentiment_score=0.75
    )

@app.post("/api/generate-replies", response_model=GenerateRepliesResponse)
async def generate_replies(request: GenerateRepliesRequest):
    """
    Generate MBTI-based reply suggestions
    TODO: Implement actual AI reply generation
    """
    # Placeholder implementation
    # TODO: Replace with actual MBTI-based reply generation

    replies = [
        GeneratedReply(
            content="我也很想你 ❤️ 今天過得怎麼樣？",
            style=ReplyStyle(
                name="溫暖回應",
                description="表達同樣的情感並關心對方"
            ),
            confidence=0.92
        ),
        GeneratedReply(
            content="抱歉讓你想我了 😊 晚點視訊好嗎？",
            style=ReplyStyle(
                name="主動安排",
                description="回應想念並提出具體行動"
            ),
            confidence=0.88
        ),
        GeneratedReply(
            content="收到！馬上就回去陪你 💕",
            style=ReplyStyle(
                name="立即回應",
                description="展現積極態度和行動力"
            ),
            confidence=0.85
        ),
    ]

    return GenerateRepliesResponse(replies=replies)

@app.post("/api/extract-text")
async def extract_text(image: UploadFile = File(...)):
    """
    Extract text from image using OCR
    TODO: Implement actual OCR
    """
    # Placeholder implementation
    # TODO: Replace with actual OCR (e.g., Tesseract, Google Vision API)

    if not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    # For now, return placeholder text
    return {"text": "這是從圖片中提取的文字範例"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
