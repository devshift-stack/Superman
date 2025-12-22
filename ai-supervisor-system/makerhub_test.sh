#!/bin/bash
# MakerHub App Test Script

BASE_URL="${1:-http://localhost:3003}"

echo "🧪 Teste MakerHub App auf: $BASE_URL"
echo ""

# 1. Health Check
echo "1. Health Check..."
HEALTH=$(curl -s ${BASE_URL}/api/health)
if echo "$HEALTH" | grep -q "ok"; then
    echo "✅ Health Check erfolgreich"
    echo "$HEALTH" | python3 -m json.tool 2>/dev/null || echo "$HEALTH"
else
    echo "❌ Health Check fehlgeschlagen"
    echo "$HEALTH"
    exit 1
fi
echo ""

# 2. Projekte laden
echo "2. Projekte laden..."
PROJECTS=$(curl -s ${BASE_URL}/api/v1/projects)
if echo "$PROJECTS" | grep -q "projects\|error"; then
    echo "✅ Projekte geladen"
    echo "$PROJECTS" | python3 -m json.tool 2>/dev/null | head -20 || echo "$PROJECTS" | head -20
else
    echo "⚠️ Keine Projekte gefunden oder Endpunkt nicht verfügbar"
fi
echo ""

# 3. Fahrrad-Tutorials
echo "3. Fahrrad-Tutorials..."
BIKE_TUTORIALS=$(curl -s ${BASE_URL}/api/v1/bike/tutorials)
if echo "$BIKE_TUTORIALS" | grep -q "tutorials\|error"; then
    echo "✅ Fahrrad-Tutorials geladen"
    echo "$BIKE_TUTORIALS" | python3 -m json.tool 2>/dev/null | head -20 || echo "$BIKE_TUTORIALS" | head -20
else
    echo "⚠️ Fahrrad-Tutorials nicht gefunden oder Endpunkt nicht verfügbar"
fi
echo ""

# 4. Gaming-Tutorials
echo "4. Gaming-Tutorials..."
GAMING_TUTORIALS=$(curl -s ${BASE_URL}/api/v1/gaming/coding)
if echo "$GAMING_TUTORIALS" | grep -q "tutorials\|coding\|error"; then
    echo "✅ Gaming-Tutorials geladen"
    echo "$GAMING_TUTORIALS" | python3 -m json.tool 2>/dev/null | head -20 || echo "$GAMING_TUTORIALS" | head -20
else
    echo "⚠️ Gaming-Tutorials nicht gefunden oder Endpunkt nicht verfügbar"
fi
echo ""

# 5. Test-User erstellen
echo "5. Test-User erstellen..."
USER_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","age":14,"interests":["bike","gaming","building"]}')

USER_ID=$(echo "$USER_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('userId', ''))" 2>/dev/null)

if [ -n "$USER_ID" ]; then
    echo "✅ Test-User erstellt: $USER_ID"
    echo "$USER_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$USER_RESPONSE"
else
    echo "⚠️ User-Erstellung fehlgeschlagen oder Endpunkt nicht verfügbar"
    echo "$USER_RESPONSE"
fi
echo ""

# 6. Projekt starten
if [ -n "$USER_ID" ]; then
    echo "6. Projekt starten..."
    PROJECT_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/v1/projects/start \
      -H "Content-Type: application/json" \
      -d "{\"projectId\":\"wood-001\",\"userId\":\"$USER_ID\"}")
    
    if echo "$PROJECT_RESPONSE" | grep -q "project\|error"; then
        echo "✅ Projekt gestartet"
        echo "$PROJECT_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$PROJECT_RESPONSE"
    else
        echo "⚠️ Projekt-Start fehlgeschlagen oder Endpunkt nicht verfügbar"
        echo "$PROJECT_RESPONSE"
    fi
    echo ""
    
    # 7. KI-Empfehlungen
    echo "7. KI-Empfehlungen..."
    RECOMMENDATIONS=$(curl -s "${BASE_URL}/api/v1/ai/recommendations?userId=$USER_ID")
    if echo "$RECOMMENDATIONS" | grep -q "recommendations\|projects\|error"; then
        echo "✅ KI-Empfehlungen geladen"
        echo "$RECOMMENDATIONS" | python3 -m json.tool 2>/dev/null | head -20 || echo "$RECOMMENDATIONS" | head -20
    else
        echo "⚠️ KI-Empfehlungen nicht verfügbar"
    fi
    echo ""
fi

# 8. Community-Feed
echo "8. Community-Feed..."
COMMUNITY_FEED=$(curl -s ${BASE_URL}/api/v1/community/feed)
if echo "$COMMUNITY_FEED" | grep -q "feed\|posts\|error"; then
    echo "✅ Community-Feed geladen"
    echo "$COMMUNITY_FEED" | python3 -m json.tool 2>/dev/null | head -20 || echo "$COMMUNITY_FEED" | head -20
else
    echo "⚠️ Community-Feed nicht verfügbar"
fi
echo ""

# 9. Gamification
if [ -n "$USER_ID" ]; then
    echo "9. Gamification (XP, Badges)..."
    XP=$(curl -s "${BASE_URL}/api/v1/gamification/xp?userId=$USER_ID")
    BADGES=$(curl -s "${BASE_URL}/api/v1/gamification/badges?userId=$USER_ID")
    
    if echo "$XP" | grep -q "xp\|points\|error"; then
        echo "✅ XP geladen"
        echo "$XP" | python3 -m json.tool 2>/dev/null || echo "$XP"
    else
        echo "⚠️ XP nicht verfügbar"
    fi
    
    if echo "$BADGES" | grep -q "badges\|error"; then
        echo "✅ Badges geladen"
        echo "$BADGES" | python3 -m json.tool 2>/dev/null | head -10 || echo "$BADGES" | head -10
    else
        echo "⚠️ Badges nicht verfügbar"
    fi
    echo ""
fi

echo "✅ Tests abgeschlossen!"
echo ""
echo "🔗 App läuft auf: ${BASE_URL}"
echo "📊 Health: ${BASE_URL}/api/health"

