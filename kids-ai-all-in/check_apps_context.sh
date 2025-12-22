#!/bin/bash

# Prüft alle Apps auf Li KI Train Features, Lianko/LinKi Context und App-Größen

LOG_FILE="/Users/dsselmanovic/cursor project/kids-ai-all-in/.cursor/debug.log"
REPORT_FILE="/Users/dsselmanovic/cursor project/kids-ai-all-in/app_context_report_$(date +%Y%m%d_%H%M%S).txt"

# Logging-Funktion
log() {
    local message="$1"
    local data="$2"
    local timestamp=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || date +%s000)
    local log_entry="{\"id\":\"log_${timestamp}_$$\",\"timestamp\":${timestamp},\"location\":\"check_apps_context.sh\",\"message\":\"${message}\",\"data\":${data},\"sessionId\":\"app-context-check\",\"runId\":\"run1\"}"
    echo "$log_entry" >> "$LOG_FILE"
}

echo "=========================================="
echo "  APP CONTEXT & FEATURE ANALYSE"
echo "=========================================="
echo "Report: $REPORT_FILE"
echo ""

log "App Context Check gestartet" "{}"

# ============================================
# 1. Finde alle App-Verzeichnisse
# ============================================
echo "=== 1. APP-VERZEICHNISSE FINDEN ===" | tee -a "$REPORT_FILE"
echo ""

# Suche nach apps-Verzeichnissen
BASE_DIR="/Users/dsselmanovic/cursor project"
APPS_DIRS=()

# Verschiedene mögliche Pfade
POSSIBLE_PATHS=(
    "$BASE_DIR"
    "$BASE_DIR/kids-ai-all-in"
    "$BASE_DIR/../apps"
    "$BASE_DIR/apps"
    "/Users/dsselmanovic/.cursor/worktrees/kids-ai-all-in/jdb"
    "/Users/dsselmanovic/.cursor/worktrees/kids-ai-all-in/ktk"
    "/Users/dsselmanovic/.cursor/worktrees/kids-ai-all-in/aqs"
    "/Users/dsselmanovic/.cursor/worktrees/kids-ai-all-in/sbf"
    "/Users/dsselmanovic/.cursor/worktrees/kids-ai-all-in/dsx"
    "/Users/dsselmanovic/activi-dev-repos/kids-ai-all-in-build"
    "/Users/dsselmanovic/activi-dev-repos/Kids-AI-Train-Lianko"
)

for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$path/apps" ]; then
        APPS_DIRS+=("$path/apps")
        echo "✓ Gefunden: $path/apps" | tee -a "$REPORT_FILE"
    fi
done

# Suche auch direkt nach App-Namen
for app_name in "lianko" "likitrain" "alanko" "parent" "om"; do
    found=$(find "$BASE_DIR" -type d -iname "*$app_name*" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | head -5)
    if [ ! -z "$found" ]; then
        echo "✓ Gefunden: $app_name - $found" | tee -a "$REPORT_FILE"
    fi
done

echo "" | tee -a "$REPORT_FILE"

# ============================================
# 2. Prüfe App-Größen
# ============================================
echo "=== 2. APP-GRÖSSEN PRÜFEN ===" | tee -a "$REPORT_FILE"
echo ""

check_app_size() {
    local app_dir="$1"
    local app_name=$(basename "$app_dir")
    
    if [ -d "$app_dir" ]; then
        # Prüfe verschiedene Größen
        local total_size=$(du -sh "$app_dir" 2>/dev/null | awk '{print $1}')
        local lib_size=$(du -sh "$app_dir/lib" 2>/dev/null | awk '{print $1}' || echo "N/A")
        local assets_size=$(du -sh "$app_dir/assets" 2>/dev/null | awk '{print $1}' || echo "N/A")
        local android_size=$(du -sh "$app_dir/android" 2>/dev/null | awk '{print $1}' || echo "N/A")
        
        # Prüfe auf .aab oder .apk Dateien
        local build_files=$(find "$app_dir" -name "*.aab" -o -name "*.apk" 2>/dev/null | head -5)
        
        echo "📱 $app_name:" | tee -a "$REPORT_FILE"
        echo "   Gesamt: $total_size" | tee -a "$REPORT_FILE"
        echo "   lib/: $lib_size" | tee -a "$REPORT_FILE"
        echo "   assets/: $assets_size" | tee -a "$REPORT_FILE"
        echo "   android/: $android_size" | tee -a "$REPORT_FILE"
        
        if [ ! -z "$build_files" ]; then
            echo "   Build-Dateien:" | tee -a "$REPORT_FILE"
            while IFS= read -r file; do
                local file_size=$(du -sh "$file" 2>/dev/null | awk '{print $1}')
                echo "     - $(basename "$file"): $file_size" | tee -a "$REPORT_FILE"
            done <<< "$build_files"
        fi
        
        # Warnung bei Größenänderung
        if echo "$total_size" | grep -qE "M|G"; then
            local size_num=$(echo "$total_size" | sed 's/[^0-9.]//g')
            if (( $(echo "$size_num > 200" | bc -l 2>/dev/null || echo 0) )); then
                echo "   ⚠️  GROSSE APP: $total_size" | tee -a "$REPORT_FILE"
            fi
        fi
        
        echo "" | tee -a "$REPORT_FILE"
    fi
}

# Prüfe bekannte Apps
for app_dir in "${APPS_DIRS[@]}"; do
    if [ -d "$app_dir" ]; then
        for app in "$app_dir"/*; do
            if [ -d "$app" ]; then
                check_app_size "$app"
            fi
        done
    fi
done

# ============================================
# 3. Suche nach Li KI Train Features
# ============================================
echo "=== 3. LI KI TRAIN FEATURES SUCHEN ===" | tee -a "$REPORT_FILE"
echo ""

search_likitrain_features() {
    local search_dir="$1"
    
    echo "Suche in: $search_dir" | tee -a "$REPORT_FILE"
    
    # Suche nach Li KI Train spezifischen Begriffen
    local results=$(grep -r -iE "li.*ki.*train|likitrain|li-ki-train" "$search_dir" \
        --include="*.dart" \
        --include="*.ts" \
        --include="*.tsx" \
        --include="*.js" \
        --include="*.jsx" \
        --include="*.json" \
        --include="*.yaml" \
        --include="*.yml" \
        --exclude-dir=node_modules \
        --exclude-dir=.git \
        --exclude-dir=build \
        2>/dev/null | head -50)
    
    if [ ! -z "$results" ]; then
        echo "$results" | tee -a "$REPORT_FILE"
        echo "" | tee -a "$REPORT_FILE"
    else
        echo "   Keine Li KI Train Features gefunden" | tee -a "$REPORT_FILE"
        echo "" | tee -a "$REPORT_FILE"
    fi
}

for app_dir in "${APPS_DIRS[@]}"; do
    if [ -d "$app_dir" ]; then
        for app in "$app_dir"/*; do
            if [ -d "$app" ] && [ "$(basename "$app")" != "om" ]; then
                echo "Prüfe: $(basename "$app")" | tee -a "$REPORT_FILE"
                search_likitrain_features "$app"
            fi
        done
    fi
done

# ============================================
# 4. Suche nach Lianko/LinKi Context
# ============================================
echo "=== 4. LIANKO/LINKI CONTEXT IN KIDS-APPS ===" | tee -a "$REPORT_FILE"
echo ""

search_lianko_context() {
    local search_dir="$1"
    local app_name=$(basename "$search_dir")
    
    echo "Prüfe $app_name auf Lianko/LinKi Context..." | tee -a "$REPORT_FILE"
    
    # Suche nach Lianko/LinKi Referenzen
    local results=$(grep -r -iE "lianko|linki" "$search_dir" \
        --include="*.dart" \
        --include="*.ts" \
        --include="*.tsx" \
        --include="*.js" \
        --include="*.jsx" \
        --include="*.json" \
        --include="*.yaml" \
        --include="*.yml" \
        --exclude-dir=node_modules \
        --exclude-dir=.git \
        --exclude-dir=build \
        2>/dev/null | head -100)
    
    if [ ! -z "$results" ]; then
        local count=$(echo "$results" | wc -l)
        echo "   ⚠️  Gefunden: $count Referenzen zu Lianko/LinKi" | tee -a "$REPORT_FILE"
        echo "$results" | head -20 | tee -a "$REPORT_FILE"
        echo "" | tee -a "$REPORT_FILE"
        
        log "Lianko Context gefunden" "{\"app\":\"$app_name\",\"count\":$count}"
    else
        echo "   ✓ Kein Lianko/LinKi Context gefunden" | tee -a "$REPORT_FILE"
        echo "" | tee -a "$REPORT_FILE"
    fi
}

# Prüfe alle Kids-Apps
for app_dir in "${APPS_DIRS[@]}"; do
    if [ -d "$app_dir" ]; then
        for app in "$app_dir"/*; do
            if [ -d "$app" ]; then
                local app_name=$(basename "$app")
                # Prüfe nur Kids-Apps (nicht parent, backend, etc.)
                if [[ "$app_name" =~ ^(alanko|lianko|likitrain|om|kids|child) ]]; then
                    search_lianko_context "$app"
                fi
            fi
        done
    fi
done

# ============================================
# 5. Prüfe "om" App speziell
# ============================================
echo "=== 5. 'OM' APP SPEZIELL PRÜFEN ===" | tee -a "$REPORT_FILE"
echo ""

find_om_app() {
    local om_app=$(find "$BASE_DIR" -type d -iname "*om*" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | grep -E "apps/|app/" | head -1)
    
    if [ ! -z "$om_app" ] && [ -d "$om_app" ]; then
        echo "✓ OM App gefunden: $om_app" | tee -a "$REPORT_FILE"
        
        # Prüfe Größe
        check_app_size "$om_app"
        
        # Prüfe auf Li KI Train Features
        echo "Prüfe OM auf Li KI Train Features..." | tee -a "$REPORT_FILE"
        search_likitrain_features "$om_app"
        
        # Prüfe auf Lianko Context
        echo "Prüfe OM auf Lianko/LinKi Context..." | tee -a "$REPORT_FILE"
        search_lianko_context "$om_app"
        
        log "OM App geprüft" "{\"path\":\"$om_app\"}"
    else
        echo "❌ OM App nicht gefunden!" | tee -a "$REPORT_FILE"
        echo "" | tee -a "$REPORT_FILE"
    fi
}

find_om_app

# ============================================
# 6. Zusammenfassung
# ============================================
echo "==========================================" | tee -a "$REPORT_FILE"
echo "  ZUSAMMENFASSUNG" | tee -a "$REPORT_FILE"
echo "==========================================" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

SUMMARY=$(cat <<EOF
GEPRÜFT:
- App-Verzeichnisse gefunden
- App-Größen analysiert
- Li KI Train Features gesucht
- Lianko/LinKi Context in Kids-Apps geprüft
- OM App speziell untersucht

NÄCHSTE SCHRITTE:
1. Prüfe den Report: $REPORT_FILE
2. Vergleiche App-Größen (300 MB → 50 MB?)
3. Prüfe gefundene Li KI Train Features
4. Entferne Lianko/LinKi Context aus anderen Apps
EOF
)

echo "$SUMMARY" | tee -a "$REPORT_FILE"

log "App Context Check abgeschlossen" "{\"report\":\"$REPORT_FILE\"}"

echo ""
echo "=== Analyse abgeschlossen ==="
echo "Report: $REPORT_FILE"
echo ""

