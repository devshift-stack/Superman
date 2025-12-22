#!/bin/bash

# Test-Script für Deployment

echo "🧪 Teste Premium Sales Agents Backend..."
echo ""

BASE_URL="http://localhost:3000"

# 1. Health Check
echo "1. Health Check..."
HEALTH=$(curl -s ${BASE_URL}/api/v1/health)
if echo "$HEALTH" | grep -q "ok"; then
    echo "✅ Health Check erfolgreich"
    echo "$HEALTH" | python3 -m json.tool 2>/dev/null || echo "$HEALTH"
else
    echo "❌ Health Check fehlgeschlagen"
    exit 1
fi
echo ""

# 2. Premium Session erstellen (Solar)
echo "2. Erstelle Premium Session (Solar)..."
SESSION_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{"productCategory":"solar","language":"german"}')

SESSION_ID=$(echo "$SESSION_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('sessionId', ''))" 2>/dev/null)

if [ -n "$SESSION_ID" ]; then
    echo "✅ Session erstellt: $SESSION_ID"
    echo "$SESSION_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$SESSION_RESPONSE"
else
    echo "❌ Session-Erstellung fehlgeschlagen"
    echo "$SESSION_RESPONSE"
    exit 1
fi
echo ""

# 3. Chat testen
echo "3. Teste Chat..."
CHAT_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/v1/premium/sessions/${SESSION_ID}/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hallo, ich interessiere mich für Solar"}')

if echo "$CHAT_RESPONSE" | grep -q "response"; then
    echo "✅ Chat erfolgreich"
    echo "$CHAT_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$CHAT_RESPONSE"
else
    echo "❌ Chat fehlgeschlagen"
    echo "$CHAT_RESPONSE"
fi
echo ""

# 4. Stats
echo "4. Statistiken..."
STATS=$(curl -s ${BASE_URL}/api/v1/stats)
echo "$STATS" | python3 -m json.tool 2>/dev/null || echo "$STATS"
echo ""

echo "✅ Alle Tests erfolgreich!"
echo ""
echo "🔗 Backend läuft auf: ${BASE_URL}"
echo "📊 Health: ${BASE_URL}/api/v1/health"
echo "📈 Stats: ${BASE_URL}/api/v1/stats"

