#!/bin/bash

# Call-Test Script für Premium Sales Agents
# Testet Voice/TTS-Funktionalität

echo "📞 CALL-TEST - Premium Sales Agents"
echo "===================================="
echo ""

BASE_URL="http://localhost:3000"

# 1. Prüfe Server
echo "1. Prüfe Server..."
HEALTH=$(curl -s ${BASE_URL}/api/v1/health)
if echo "$HEALTH" | grep -q "ok"; then
    echo "✅ Server läuft"
else
    echo "❌ Server nicht erreichbar"
    exit 1
fi
echo ""

# 2. Erstelle Premium Session (Solar)
echo "2. Erstelle Premium Session (Solar)..."
SESSION_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{"productCategory":"solar","language":"german"}')

SESSION_ID=$(echo "$SESSION_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('sessionId', ''))" 2>/dev/null)
AGENT_NAME=$(echo "$SESSION_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('agentName', ''))" 2>/dev/null)

if [ -n "$SESSION_ID" ]; then
    echo "✅ Session erstellt"
    echo "   Session ID: $SESSION_ID"
    echo "   Agent: $AGENT_NAME"
    echo "   Begrüßung:"
    echo "$SESSION_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('greeting', ''))" 2>/dev/null
else
    echo "❌ Session-Erstellung fehlgeschlagen"
    exit 1
fi
echo ""

# 3. Teste Chat mit Voice
echo "3. Teste Chat mit Voice/TTS..."
CHAT_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/v1/premium/sessions/${SESSION_ID}/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hallo, ich interessiere mich für Solarmodule. Können Sie mir mehr erzählen?"}')

# Prüfe ob Audio vorhanden
AUDIO_BASE64=$(echo "$CHAT_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('audioContent', ''))" 2>/dev/null)
RESPONSE_TEXT=$(echo "$CHAT_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('response', ''))" 2>/dev/null)

if [ -n "$RESPONSE_TEXT" ]; then
    echo "✅ Chat erfolgreich"
    echo "   Antwort: $RESPONSE_TEXT"
    
    if [ -n "$AUDIO_BASE64" ] && [ "$AUDIO_BASE64" != "null" ]; then
        echo "✅ Audio generiert (Base64)"
        
        # Speichere Audio
        echo "$AUDIO_BASE64" | base64 -d > /tmp/call_test_audio.mp3 2>/dev/null
        if [ -f /tmp/call_test_audio.mp3 ]; then
            echo "✅ Audio gespeichert: /tmp/call_test_audio.mp3"
            echo "   Abspielen: open /tmp/call_test_audio.mp3 (macOS)"
            echo "   Abspielen: mpv /tmp/call_test_audio.mp3 (Linux)"
        fi
    else
        echo "⚠️ Kein Audio generiert (TTS möglicherweise nicht konfiguriert)"
    fi
else
    ERROR=$(echo "$CHAT_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('error', ''))" 2>/dev/null)
    if [ -n "$ERROR" ]; then
        echo "❌ Chat-Fehler: $ERROR"
    else
        echo "❌ Chat fehlgeschlagen"
    fi
fi
echo ""

# 4. Weitere Test-Nachrichten
echo "4. Weitere Test-Nachrichten..."
echo ""

echo "   Frage zu Kosten:"
COST_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/v1/premium/sessions/${SESSION_ID}/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Wie viel kostet das?"}')

COST_TEXT=$(echo "$COST_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('response', ''))" 2>/dev/null)
if [ -n "$COST_TEXT" ]; then
    echo "   ✅ Antwort: ${COST_TEXT:0:100}..."
else
    echo "   ❌ Fehler"
fi
echo ""

# 5. Zusammenfassung
echo "===================================="
echo "✅ CALL-TEST ABGESCHLOSSEN"
echo ""
echo "📋 Zusammenfassung:"
echo "   Session ID: $SESSION_ID"
echo "   Agent: $AGENT_NAME"
echo "   Produkt: Solar"
echo ""
echo "🔗 Weiter testen:"
echo "   curl -X POST ${BASE_URL}/api/v1/premium/sessions/${SESSION_ID}/chat \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"message\":\"Deine Nachricht\"}'"
echo ""
echo "📊 Statistiken:"
curl -s ${BASE_URL}/api/v1/stats | python3 -m json.tool 2>/dev/null | head -10

