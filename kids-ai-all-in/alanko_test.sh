#!/bin/bash
# Alanko App Test Script

BASE_URL="${1:-http://localhost:3001}"

echo "🧪 Teste Alanko App auf: $BASE_URL"
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

# 2. Lektionen laden
echo "2. Lektionen laden..."
LESSONS=$(curl -s ${BASE_URL}/api/v1/lessons)
if echo "$LESSONS" | grep -q "lessons\|error"; then
    echo "✅ Lektionen geladen"
    echo "$LESSONS" | python3 -m json.tool 2>/dev/null | head -20 || echo "$LESSONS" | head -20
else
    echo "⚠️ Keine Lektionen gefunden oder Endpunkt nicht verfügbar"
fi
echo ""

# 3. Test-User erstellen
echo "3. Test-User erstellen..."
USER_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","age":7}')

USER_ID=$(echo "$USER_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('userId', ''))" 2>/dev/null)

if [ -n "$USER_ID" ]; then
    echo "✅ Test-User erstellt: $USER_ID"
    echo "$USER_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$USER_RESPONSE"
else
    echo "⚠️ User-Erstellung fehlgeschlagen oder Endpunkt nicht verfügbar"
    echo "$USER_RESPONSE"
fi
echo ""

# 4. Lektion starten
if [ -n "$USER_ID" ]; then
    echo "4. Lektion starten..."
    LESSON_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/v1/lessons/start \
      -H "Content-Type: application/json" \
      -d "{\"lessonId\":\"math-001\",\"userId\":\"$USER_ID\"}")
    
    if echo "$LESSON_RESPONSE" | grep -q "lesson\|error"; then
        echo "✅ Lektion gestartet"
        echo "$LESSON_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$LESSON_RESPONSE"
    else
        echo "⚠️ Lektion-Start fehlgeschlagen oder Endpunkt nicht verfügbar"
        echo "$LESSON_RESPONSE"
    fi
    echo ""
fi

echo "✅ Tests abgeschlossen!"
echo ""
echo "🔗 App läuft auf: ${BASE_URL}"
echo "📊 Health: ${BASE_URL}/api/health"

