from fastapi import FastAPI, UploadFile, File, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from enum import Enum
import uvicorn
from datetime import datetime

# OCR dependencies (graceful fallback if not installed at runtime)
try:
    from PIL import Image
    import pytesseract
    _OCR_AVAILABLE = True
except Exception:
    _OCR_AVAILABLE = False

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


# ------------------------------
# User & Conversation Models
# ------------------------------
class User(BaseModel):
    user_id: str
    mbti_type: Optional[MBTIType] = None
    is_member: bool = False
    daily_reply_count: int = 0

class ConversationMessage(BaseModel):
    content: str
    source: str  # 'text' | 'screenshot'
    timestamp: datetime

class ConversationRecord(BaseModel):
    user_id: str
    messages: List[ConversationMessage]


# In-memory stores (replace with DB in production)
USERS: Dict[str, User] = {}
CONVERSATIONS: Dict[str, ConversationRecord] = {}

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

    # 暫時跳過圖片類型檢查，直接返回模擬資料
    import random

    # 模擬 OCR 擷取的對話範例
    sample_messages = [
        "我想你了 ❤️",
        "今天工作好累，想抱抱你",
        "你在做什麼呢？想你~",
        "晚上一起吃飯好嗎？",
        "謝謝你一直陪著我 💕",
        "今天心情不太好...可以聊聊嗎？",
        "看到這個想到你 😊",
        "明天有空嗎？我們出去走走",
    ]

    # 隨機返回一個範例訊息
    return {"text": random.choice(sample_messages)}


# ------------------------------
# Users API
# ------------------------------
@app.post("/api/users", response_model=User)
async def upsert_user(user: User):
    USERS[user.user_id] = user
    if user.user_id not in CONVERSATIONS:
        CONVERSATIONS[user.user_id] = ConversationRecord(user_id=user.user_id, messages=[])
    return USERS[user.user_id]


@app.get("/api/users/{user_id}", response_model=User)
async def get_user(user_id: str):
    if user_id not in USERS:
        raise HTTPException(status_code=404, detail="User not found")
    return USERS[user_id]


@app.get("/api/users/{user_id}/conversations", response_model=ConversationRecord)
async def get_conversations(user_id: str):
    if user_id not in CONVERSATIONS:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return CONVERSATIONS[user_id]


# ------------------------------
# Upload screenshot with OCR and store to conversation
# ------------------------------
@app.post("/api/upload-screenshot")
async def upload_screenshot(user_id: str = Form(...), image: UploadFile = File(...)):
    if not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    # Ensure user exists (create minimal record if missing)
    if user_id not in USERS:
        USERS[user_id] = User(user_id=user_id)
    if user_id not in CONVERSATIONS:
        CONVERSATIONS[user_id] = ConversationRecord(user_id=user_id, messages=[])

    # OCR processing
    extracted_text = ""
    try:
        if _OCR_AVAILABLE:
            image_bytes = await image.read()
            from io import BytesIO
            pil_image = Image.open(BytesIO(image_bytes))
            extracted_text = pytesseract.image_to_string(pil_image, lang="chi_tra+eng")
        else:
            # Fallback placeholder when OCR runtime deps not available
            extracted_text = "[OCR 未啟用] 這是從圖片中提取的文字範例"
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OCR failed: {e}")

    # Store in conversation
    message = ConversationMessage(
        content=extracted_text.strip(),
        source="screenshot",
        timestamp=datetime.utcnow(),
    )
    CONVERSATIONS[user_id].messages.append(message)

    return {
        "user_id": user_id,
        "text": message.content,
        "saved": True,
        "messages_count": len(CONVERSATIONS[user_id].messages),
    }


# ------------------------------
# Generate single reply with membership gating
# ------------------------------
class GenerateReplyRequest(BaseModel):
    user_id: str
    message: str

class ReplyOption(BaseModel):
    content: str
    style: str
    reason: str

class GenerateReplyResponse(BaseModel):
    options: List[ReplyOption]


@app.post("/api/generate-reply", response_model=GenerateReplyResponse)
async def generate_reply(payload: GenerateReplyRequest):
    user_id = payload.user_id
    message = payload.message.strip()

    if not message:
        raise HTTPException(status_code=400, detail="message 不可為空")

    # Ensure user and conversation exist
    if user_id not in USERS:
        USERS[user_id] = User(user_id=user_id)
    if user_id not in CONVERSATIONS:
        CONVERSATIONS[user_id] = ConversationRecord(user_id=user_id, messages=[])

    user = USERS[user_id]

    # Membership gating: non-member limited to 3 per day
    if not user.is_member and user.daily_reply_count >= 3:
        raise HTTPException(
            status_code=402,
            detail="此功能為會員限定，請升級以解鎖更多次數",
        )

    # Store incoming message into conversation as text message
    CONVERSATIONS[user_id].messages.append(
        ConversationMessage(
            content=message,
            source="text",
            timestamp=datetime.utcnow(),
        )
    )

    # Default AI reply generation (placeholder logic)
    mbti = (user.mbti_type.value if isinstance(user.mbti_type, MBTIType) else user.mbti_type) or "INFP"

    # Two stylistically different replies with brief reasons
    option_a = ReplyOption(
        content=f"我懂你的感受，也一直在意著你。要不要聊聊剛剛發生了什麼？",
        style="溫柔體貼",
        reason=f"這個回覆展現了你 {mbti} 的溫柔體貼",
    )
    option_b = ReplyOption(
        content=f"收到！我在，給我十分鐘整理一下就回你，我們一起想辦法。",
        style="務實支持",
        reason=f"這個回覆展現了你 {mbti} 的主動與支持",
    )

    # Increment daily usage count for non-member
    if not user.is_member:
        user.daily_reply_count += 1
        USERS[user_id] = user

    return GenerateReplyResponse(options=[option_a, option_b])

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
