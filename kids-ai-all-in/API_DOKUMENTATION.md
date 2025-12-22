# 📡 API-Dokumentation - Alle Apps

**Base URLs:**
- **Alanko:** `http://localhost:3001` / `https://alanko.railway.app`
- **Lianko:** `http://localhost:3002` / `https://lianko.railway.app`
- **MakerHub:** `http://localhost:3003` / `https://makerhub.railway.app`

---

## 🔵 1. ALANKO APP API (7-jähriger Sohn)

### Health & Status

#### GET `/api/health`
**Beschreibung:** Server-Status prüfen

**Response:**
```json
{
  "status": "ok",
  "version": "1.0.0",
  "timestamp": "2024-12-19T10:00:00Z"
}
```

---

### User Management

#### POST `/api/v1/users`
**Beschreibung:** Neuen Benutzer erstellen

**Request Body:**
```json
{
  "name": "Max Mustermann",
  "age": 7,
  "parentEmail": "parent@example.com"
}
```

**Response:**
```json
{
  "userId": "uuid-123",
  "name": "Max Mustermann",
  "age": 7,
  "createdAt": "2024-12-19T10:00:00Z"
}
```

#### GET `/api/v1/users/:userId`
**Beschreibung:** Benutzer-Daten abrufen

**Response:**
```json
{
  "userId": "uuid-123",
  "name": "Max Mustermann",
  "age": 7,
  "level": 3,
  "xp": 1250,
  "badges": ["first-lesson", "math-master"],
  "createdAt": "2024-12-19T10:00:00Z"
}
```

---

### Lessons (Lektionen)

#### GET `/api/v1/lessons`
**Beschreibung:** Alle Lektionen abrufen

**Query Parameters:**
- `age` (optional): Filter nach Alter (default: 7)
- `category` (optional): Filter nach Kategorie (math, reading, science, etc.)
- `difficulty` (optional): Filter nach Schwierigkeit (easy, medium, hard)

**Response:**
```json
{
  "lessons": [
    {
      "lessonId": "math-001",
      "title": "Zahlen lernen",
      "description": "Lerne die Zahlen von 1-10",
      "category": "math",
      "difficulty": "easy",
      "duration": 15,
      "ageRange": [6, 8],
      "thumbnail": "https://..."
    }
  ]
}
```

#### GET `/api/v1/lessons/:lessonId`
**Beschreibung:** Detaillierte Lektion abrufen

**Response:**
```json
{
  "lessonId": "math-001",
  "title": "Zahlen lernen",
  "description": "Lerne die Zahlen von 1-10",
  "steps": [
    {
      "stepId": 1,
      "type": "interactive",
      "content": "...",
      "questions": [...]
    }
  ],
  "xpReward": 50
}
```

#### POST `/api/v1/lessons/start`
**Beschreibung:** Lektion starten

**Request Body:**
```json
{
  "lessonId": "math-001",
  "userId": "uuid-123"
}
```

**Response:**
```json
{
  "sessionId": "session-uuid",
  "lessonId": "math-001",
  "userId": "uuid-123",
  "startedAt": "2024-12-19T10:00:00Z"
}
```

#### POST `/api/v1/lessons/:lessonId/complete`
**Beschreibung:** Lektion abschließen

**Request Body:**
```json
{
  "userId": "uuid-123",
  "sessionId": "session-uuid",
  "score": 85,
  "timeSpent": 1200
}
```

**Response:**
```json
{
  "completed": true,
  "xpEarned": 50,
  "badgeUnlocked": "math-master",
  "levelUp": false
}
```

---

### Progress (Fortschritt)

#### GET `/api/v1/progress?userId=:userId`
**Beschreibung:** Benutzer-Fortschritt abrufen

**Response:**
```json
{
  "userId": "uuid-123",
  "totalLessons": 50,
  "completedLessons": 12,
  "totalXP": 1250,
  "currentLevel": 3,
  "streak": 5,
  "lastActivity": "2024-12-19T10:00:00Z"
}
```

#### POST `/api/v1/progress`
**Beschreibung:** Fortschritt speichern

**Request Body:**
```json
{
  "userId": "uuid-123",
  "lessonId": "math-001",
  "completed": true,
  "score": 85,
  "timeSpent": 1200
}
```

---

### AI Assistant

#### POST `/api/v1/ai/chat`
**Beschreibung:** Mit KI-Assistenten chatten

**Request Body:**
```json
{
  "message": "Was ist 2+2?",
  "userId": "uuid-123",
  "context": "math-001"
}
```

**Response:**
```json
{
  "response": "2+2 ist 4! Das ist super einfach. Möchtest du noch mehr Rechenaufgaben üben?",
  "suggestions": [
    "Was ist 3+3?",
    "Zeige mir mehr Aufgaben"
  ]
}
```

#### GET `/api/v1/ai/recommendations?userId=:userId`
**Beschreibung:** Personalisierte Lektions-Empfehlungen

**Response:**
```json
{
  "recommendations": [
    {
      "lessonId": "math-002",
      "title": "Plus-Aufgaben",
      "reason": "Du hast Zahlen lernen abgeschlossen",
      "priority": "high"
    }
  ]
}
```

---

### Gamification

#### GET `/api/v1/gamification/xp?userId=:userId`
**Beschreibung:** XP-Punkte abrufen

**Response:**
```json
{
  "userId": "uuid-123",
  "totalXP": 1250,
  "currentLevel": 3,
  "xpToNextLevel": 250
}
```

#### GET `/api/v1/gamification/badges?userId=:userId`
**Beschreibung:** Badges abrufen

**Response:**
```json
{
  "userId": "uuid-123",
  "unlockedBadges": [
    {
      "badgeId": "first-lesson",
      "name": "Erste Lektion",
      "description": "Erste Lektion abgeschlossen",
      "unlockedAt": "2024-12-15T10:00:00Z"
    }
  ],
  "availableBadges": [...]
}
```

#### GET `/api/v1/gamification/leaderboard`
**Beschreibung:** Leaderboard abrufen

**Query Parameters:**
- `limit` (optional): Anzahl der Einträge (default: 10)

**Response:**
```json
{
  "leaderboard": [
    {
      "rank": 1,
      "userId": "uuid-123",
      "name": "Max",
      "totalXP": 5000,
      "level": 10
    }
  ]
}
```

---

### Parent Dashboard

#### GET `/api/v1/parent/progress?userId=:userId`
**Beschreibung:** Fortschritt für Eltern anzeigen

**Response:**
```json
{
  "userId": "uuid-123",
  "childName": "Max",
  "totalLessons": 50,
  "completedLessons": 12,
  "totalXP": 1250,
  "currentLevel": 3,
  "streak": 5,
  "weeklyActivity": [
    {"date": "2024-12-15", "lessons": 3},
    {"date": "2024-12-16", "lessons": 2}
  ],
  "achievements": [...]
}
```

#### GET `/api/v1/parent/settings?userId=:userId`
**Beschreibung:** Eltern-Einstellungen abrufen

**Response:**
```json
{
  "userId": "uuid-123",
  "dailyTimeLimit": 3600,
  "allowedCategories": ["math", "reading"],
  "notifications": true
}
```

---

## 🟢 2. LIANKO APP API (4-jähriger Sohn, Hörbehinderung)

### Health & Status

#### GET `/api/health`
**Beschreibung:** Server-Status prüfen

**Response:**
```json
{
  "status": "ok",
  "version": "1.0.0",
  "timestamp": "2024-12-19T10:00:00Z"
}
```

---

### User Management

#### POST `/api/v1/users`
**Beschreibung:** Neuen Benutzer erstellen

**Request Body:**
```json
{
  "name": "Lukas Mustermann",
  "age": 4,
  "hearingImpairment": true,
  "hearingLevel": "moderate",
  "preferredCommunication": "visual",
  "parentEmail": "parent@example.com"
}
```

**Response:**
```json
{
  "userId": "uuid-456",
  "name": "Lukas Mustermann",
  "age": 4,
  "hearingImpairment": true,
  "createdAt": "2024-12-19T10:00:00Z"
}
```

---

### Lessons (Lektionen)

#### GET `/api/v1/lessons?age=:age`
**Beschreibung:** Lektionen abrufen (visuell)

**Query Parameters:**
- `age` (required): Alter des Kindes
- `category` (optional): Kategorie

**Response:**
```json
{
  "lessons": [
    {
      "lessonId": "visual-001",
      "title": "Farben lernen",
      "description": "Lerne Farben durch Bilder",
      "category": "colors",
      "difficulty": "easy",
      "ageRange": [3, 5],
      "visualOnly": true,
      "hasSignLanguage": true,
      "thumbnail": "https://..."
    }
  ]
}
```

#### GET `/api/v1/lessons/sign-language`
**Beschreibung:** Gebärdensprache-Videos abrufen

**Response:**
```json
{
  "videos": [
    {
      "videoId": "sign-001",
      "word": "Hallo",
      "language": "DGS",
      "videoUrl": "https://...",
      "thumbnail": "https://..."
    }
  ]
}
```

#### POST `/api/v1/lessons/start`
**Beschreibung:** Visuelle Lektion starten

**Request Body:**
```json
{
  "lessonId": "visual-001",
  "userId": "uuid-456"
}
```

---

### Sign Language (Gebärdensprache)

#### POST `/api/v1/translate/sign`
**Beschreibung:** Text zu Gebärdensprache konvertieren

**Request Body:**
```json
{
  "text": "Hallo",
  "language": "DGS"
}
```

**Response:**
```json
{
  "text": "Hallo",
  "signLanguage": "DGS",
  "videoUrl": "https://...",
  "animation": "https://..."
}
```

---

### Visual Learning

#### GET `/api/v1/visual/activities?userId=:userId`
**Beschreibung:** Visuelle Aktivitäten abrufen

**Response:**
```json
{
  "activities": [
    {
      "activityId": "visual-001",
      "type": "drag-drop",
      "title": "Farben zuordnen",
      "visualInstructions": true,
      "hapticFeedback": true
    }
  ]
}
```

---

### AI Assistant (Visuell)

#### POST `/api/v1/ai/chat`
**Beschreibung:** KI-Assistent mit visueller Unterstützung

**Request Body:**
```json
{
  "message": "Was ist das?",
  "userId": "uuid-456",
  "includeVisuals": true
}
```

**Response:**
```json
{
  "response": "Das ist ein Apfel! 🍎",
  "visualAid": "https://...",
  "signLanguageVideo": "https://...",
  "suggestions": [...]
}
```

---

### Parent Dashboard

#### GET `/api/v1/parent/progress?userId=:userId`
**Beschreibung:** Fortschritt für Eltern

**Response:**
```json
{
  "userId": "uuid-456",
  "childName": "Lukas",
  "hearingImpairment": true,
  "preferredCommunication": "visual",
  "totalLessons": 30,
  "completedLessons": 8,
  "signLanguageProgress": {
    "wordsLearned": 25,
    "videosWatched": 15
  },
  "visualActivityProgress": {
    "activitiesCompleted": 12,
    "averageScore": 90
  }
}
```

#### GET `/api/v1/parent/settings?userId=:userId`
**Beschreibung:** Hörbehinderung-Einstellungen

**Response:**
```json
{
  "userId": "uuid-456",
  "hearingLevel": "moderate",
  "preferredCommunication": "visual",
  "signLanguageEnabled": true,
  "hapticFeedbackEnabled": true,
  "visualOnlyMode": true
}
```

---

## 🟡 3. MAKERHUB APP API (14-jähriger Sohn)

### Health & Status

#### GET `/api/health`
**Beschreibung:** Server-Status prüfen

**Response:**
```json
{
  "status": "ok",
  "version": "1.0.0",
  "timestamp": "2024-12-19T10:00:00Z"
}
```

---

### User Management

#### POST `/api/v1/users`
**Beschreibung:** Neuen Benutzer erstellen

**Request Body:**
```json
{
  "name": "Tom Mustermann",
  "age": 14,
  "interests": ["bike", "gaming", "building"],
  "parentEmail": "parent@example.com"
}
```

**Response:**
```json
{
  "userId": "uuid-789",
  "name": "Tom Mustermann",
  "age": 14,
  "interests": ["bike", "gaming", "building"],
  "createdAt": "2024-12-19T10:00:00Z"
}
```

---

### Projects (Projekte)

#### GET `/api/v1/projects`
**Beschreibung:** Projekt-Bibliothek abrufen

**Query Parameters:**
- `category` (optional): Kategorie (wood, electronics, metal, 3d-printing)
- `difficulty` (optional): Schwierigkeit (beginner, intermediate, advanced)
- `duration` (optional): Zeitaufwand (short, medium, long)

**Response:**
```json
{
  "projects": [
    {
      "projectId": "wood-001",
      "title": "Holzregal bauen",
      "description": "Einfaches Regal aus Holz",
      "category": "wood",
      "difficulty": "beginner",
      "duration": 120,
      "estimatedCost": 25.00,
      "thumbnail": "https://...",
      "rating": 4.5
    }
  ]
}
```

#### GET `/api/v1/projects/:projectId`
**Beschreibung:** Detailliertes Projekt abrufen

**Response:**
```json
{
  "projectId": "wood-001",
  "title": "Holzregal bauen",
  "description": "...",
  "steps": [
    {
      "stepId": 1,
      "title": "Material besorgen",
      "instructions": "...",
      "images": ["https://..."],
      "videos": ["https://..."]
    }
  ],
  "materials": [
    {
      "name": "Holzbrett",
      "quantity": 2,
      "unit": "Stück",
      "buyLink": "https://..."
    }
  ],
  "tools": ["Säge", "Schraubenzieher"],
  "xpReward": 100
}
```

#### GET `/api/v1/projects/:projectId/steps`
**Beschreibung:** Schritt-für-Schritt Anleitung

**Response:**
```json
{
  "projectId": "wood-001",
  "steps": [
    {
      "stepId": 1,
      "title": "Material besorgen",
      "instructions": "...",
      "estimatedTime": 30,
      "images": ["https://..."]
    }
  ]
}
```

#### GET `/api/v1/projects/:projectId/materials`
**Beschreibung:** Material-Liste abrufen

**Response:**
```json
{
  "projectId": "wood-001",
  "materials": [
    {
      "name": "Holzbrett",
      "quantity": 2,
      "unit": "Stück",
      "price": 12.50,
      "buyLink": "https://...",
      "available": true
    }
  ],
  "totalCost": 25.00
}
```

#### POST `/api/v1/projects/start`
**Beschreibung:** Projekt starten

**Request Body:**
```json
{
  "projectId": "wood-001",
  "userId": "uuid-789"
}
```

**Response:**
```json
{
  "sessionId": "session-uuid",
  "projectId": "wood-001",
  "userId": "uuid-789",
  "startedAt": "2024-12-19T10:00:00Z",
  "currentStep": 1
}
```

#### POST `/api/v1/projects/progress`
**Beschreibung:** Projekt-Fortschritt speichern

**Request Body:**
```json
{
  "userId": "uuid-789",
  "projectId": "wood-001",
  "step": 3,
  "completed": true,
  "photos": ["https://..."]
}
```

#### POST `/api/v1/projects/:projectId/complete`
**Beschreibung:** Projekt abschließen

**Request Body:**
```json
{
  "userId": "uuid-789",
  "sessionId": "session-uuid",
  "photos": ["https://..."],
  "video": "https://..."
}
```

**Response:**
```json
{
  "completed": true,
  "xpEarned": 100,
  "badgeUnlocked": "wood-master",
  "shareUrl": "https://..."
}
```

---

### Bike (Fahrrad)

#### GET `/api/v1/bike/tutorials`
**Beschreibung:** Fahrrad-Reparatur-Tutorials

**Query Parameters:**
- `category` (optional): Kategorie (repair, maintenance, upgrade)

**Response:**
```json
{
  "tutorials": [
    {
      "tutorialId": "bike-001",
      "title": "Platten Reifen reparieren",
      "description": "...",
      "category": "repair",
      "difficulty": "beginner",
      "duration": 30,
      "videoUrl": "https://...",
      "thumbnail": "https://..."
    }
  ]
}
```

#### POST `/api/v1/bike/routes`
**Beschreibung:** Route planen

**Request Body:**
```json
{
  "start": "Berlin",
  "end": "Potsdam",
  "distance": 30,
  "preferences": {
    "avoidHighways": true,
    "scenic": true
  }
}
```

**Response:**
```json
{
  "routeId": "route-uuid",
  "start": "Berlin",
  "end": "Potsdam",
  "distance": 30.5,
  "duration": 7200,
  "elevation": 150,
  "waypoints": [
    {"lat": 52.5200, "lng": 13.4050},
    {"lat": 52.4000, "lng": 13.0660}
  ],
  "mapUrl": "https://..."
}
```

#### POST `/api/v1/bike/track`
**Beschreibung:** Fahrrad-Fahrt tracken

**Request Body:**
```json
{
  "userId": "uuid-789",
  "distance": 15.5,
  "duration": 3600,
  "elevation": 120,
  "route": [...],
  "calories": 450
}
```

**Response:**
```json
{
  "trackId": "track-uuid",
  "userId": "uuid-789",
  "distance": 15.5,
  "duration": 3600,
  "averageSpeed": 15.5,
  "xpEarned": 50,
  "recordedAt": "2024-12-19T10:00:00Z"
}
```

#### GET `/api/v1/bike/maintenance?userId=:userId`
**Beschreibung:** Wartungs-Erinnerungen

**Response:**
```json
{
  "userId": "uuid-789",
  "maintenanceItems": [
    {
      "item": "Kette ölen",
      "lastDone": "2024-12-01",
      "nextDue": "2024-12-20",
      "overdue": false
    }
  ]
}
```

---

### Gaming & Coding

#### GET `/api/v1/gaming/coding`
**Beschreibung:** Coding-Tutorials

**Response:**
```json
{
  "tutorials": [
    {
      "tutorialId": "code-001",
      "title": "Erstes Spiel programmieren",
      "description": "...",
      "language": "JavaScript",
      "difficulty": "beginner",
      "duration": 120,
      "videoUrl": "https://..."
    }
  ]
}
```

#### GET `/api/v1/gaming/design`
**Beschreibung:** Game-Design-Tutorials

**Response:**
```json
{
  "tutorials": [
    {
      "tutorialId": "design-001",
      "title": "Spiel-Charaktere designen",
      "description": "...",
      "tools": ["Blender", "Photoshop"],
      "difficulty": "intermediate"
    }
  ]
}
```

#### GET `/api/v1/gaming/modding`
**Beschreibung:** Modding-Anleitungen

**Response:**
```json
{
  "tutorials": [
    {
      "tutorialId": "mod-001",
      "title": "Minecraft Mod erstellen",
      "game": "Minecraft",
      "difficulty": "advanced",
      "duration": 180
    }
  ]
}
```

#### POST `/api/v1/gaming/share`
**Beschreibung:** Code-Projekt teilen

**Request Body:**
```json
{
  "userId": "uuid-789",
  "projectName": "My Game",
  "code": "...",
  "language": "JavaScript",
  "description": "...",
  "screenshot": "https://..."
}
```

**Response:**
```json
{
  "projectId": "code-uuid",
  "shareUrl": "https://...",
  "createdAt": "2024-12-19T10:00:00Z"
}
```

---

### Community

#### GET `/api/v1/community/feed`
**Beschreibung:** Community-Feed abrufen

**Query Parameters:**
- `limit` (optional): Anzahl der Posts (default: 20)
- `offset` (optional): Offset für Pagination

**Response:**
```json
{
  "posts": [
    {
      "postId": "post-uuid",
      "userId": "uuid-789",
      "userName": "Tom",
      "type": "project",
      "projectId": "wood-001",
      "title": "Mein erstes Regal",
      "description": "...",
      "photos": ["https://..."],
      "video": "https://...",
      "likes": 25,
      "comments": 5,
      "createdAt": "2024-12-19T10:00:00Z"
    }
  ],
  "hasMore": true
}
```

#### POST `/api/v1/community/video`
**Beschreibung:** Projekt-Video erstellen/teilen

**Request Body:**
```json
{
  "userId": "uuid-789",
  "projectId": "wood-001",
  "videoUrl": "https://...",
  "title": "Mein Regal-Projekt",
  "description": "...",
  "tiktokUrl": "https://..."
}
```

**Response:**
```json
{
  "postId": "post-uuid",
  "shareUrl": "https://...",
  "tiktokUrl": "https://..."
}
```

#### POST `/api/v1/community/like`
**Beschreibung:** Post liken

**Request Body:**
```json
{
  "userId": "uuid-789",
  "postId": "post-uuid"
}
```

#### POST `/api/v1/community/comment`
**Beschreibung:** Kommentar hinzufügen

**Request Body:**
```json
{
  "userId": "uuid-789",
  "postId": "post-uuid",
  "comment": "Super Projekt!"
}
```

---

### AI Assistant

#### POST `/api/v1/ai/chat`
**Beschreibung:** KI-Assistent für Projekte

**Request Body:**
```json
{
  "message": "Wie repariere ich einen platten Reifen?",
  "userId": "uuid-789",
  "context": "bike"
}
```

**Response:**
```json
{
  "response": "Hier ist eine Schritt-für-Schritt Anleitung...",
  "steps": [
    {"step": 1, "instruction": "..."},
    {"step": 2, "instruction": "..."}
  ],
  "videoUrl": "https://...",
  "suggestions": [...]
}
```

#### GET `/api/v1/ai/recommendations?userId=:userId`
**Beschreibung:** Projekt-Empfehlungen

**Response:**
```json
{
  "recommendations": [
    {
      "projectId": "wood-002",
      "title": "Holztisch bauen",
      "reason": "Basierend auf deinen Interessen",
      "priority": "high"
    }
  ]
}
```

#### POST `/api/v1/ai/help`
**Beschreibung:** Hilfe bei Problemen

**Request Body:**
```json
{
  "userId": "uuid-789",
  "projectId": "wood-001",
  "problem": "Schraube passt nicht"
}
```

**Response:**
```json
{
  "solution": "Versuche eine andere Schraubengröße...",
  "alternativeSolutions": [...],
  "videoUrl": "https://..."
}
```

---

### Gamification

#### GET `/api/v1/gamification/xp?userId=:userId`
**Beschreibung:** XP-Punkte abrufen

**Response:**
```json
{
  "userId": "uuid-789",
  "totalXP": 2500,
  "currentLevel": 5,
  "xpToNextLevel": 500
}
```

#### GET `/api/v1/gamification/badges?userId=:userId`
**Beschreibung:** Badges abrufen

**Response:**
```json
{
  "userId": "uuid-789",
  "unlockedBadges": [
    {
      "badgeId": "first-project",
      "name": "Erstes Projekt",
      "description": "Erstes Projekt abgeschlossen",
      "unlockedAt": "2024-12-15T10:00:00Z"
    }
  ]
}
```

#### GET `/api/v1/gamification/challenges`
**Beschreibung:** Aktuelle Challenges

**Response:**
```json
{
  "challenges": [
    {
      "challengeId": "challenge-001",
      "title": "Wöchentliche Challenge",
      "description": "Baue 3 Projekte diese Woche",
      "reward": 200,
      "deadline": "2024-12-26",
      "participants": 150
    }
  ]
}
```

#### GET `/api/v1/gamification/leaderboard`
**Beschreibung:** Leaderboard

**Response:**
```json
{
  "leaderboard": [
    {
      "rank": 1,
      "userId": "uuid-789",
      "name": "Tom",
      "totalXP": 10000,
      "level": 15,
      "projectsCompleted": 25
    }
  ]
}
```

---

## 🔐 Authentication

Alle APIs verwenden JWT-Token für Authentifizierung:

**Header:**
```
Authorization: Bearer <token>
```

**Token erhalten:**
```
POST /api/v1/auth/login
```

---

## 📊 Response Codes

- `200` - Erfolg
- `201` - Erstellt
- `400` - Ungültige Anfrage
- `401` - Nicht autorisiert
- `404` - Nicht gefunden
- `500` - Server-Fehler

---

## 🚀 Rate Limiting

- **Standard:** 100 Requests/Minute
- **Authentifiziert:** 1000 Requests/Minute
- **Premium:** 5000 Requests/Minute

---

**Letzte Aktualisierung:** 19. Dezember 2024

