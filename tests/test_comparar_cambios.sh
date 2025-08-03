#!/bin/bash
# Script de tests para la función comparar_cambios

# Ruta relativa al script principal
SCRIPT_PATH="$(dirname "$0")/../src/main_script.sh"
TEMP_DIR=$(mktemp -d)
TEST_REPO="$TEMP_DIR/repo_test"

# Source the main script to get GRUPO and FECHA variables
source "$SCRIPT_PATH"

# =============================
# FUNCIONES AUXILIARES
# =============================

assert_file_exists() {
    if [ ! -f "$1" ]; then
        echo "❌ ERROR: No se generó el archivo esperado: $1"
        exit 1
    else
        echo "✅ OK: Archivo generado: $1"
    fi
}

assert_file_contains() {
    if ! grep -q "$2" "$1"; then
        echo "❌ ERROR: El archivo $1 no contiene '$2'"
        exit 1
    else
        echo "✅ OK: Contenido encontrado en $1"
    fi
}

assert_output_contains() {
    local output="$1"
    local expected="$2"
    local test_name="$3"
    if ! echo "$output" | grep -q "$expected"; then
        echo "❌ ERROR: $test_name - Output no contiene '$expected'"
        echo "Output actual: $output"
        exit 1
    else
        echo "✅ OK: $test_name - Output contiene '$expected'"
    fi
}

assert_directory_exists() {
    if [ ! -d "$1" ]; then
        echo "❌ ERROR: Directorio no existe: $1"
        exit 1
    else
        echo "✅ OK: Directorio existe: $1"
    fi
}

assert_file_not_exists() {
    if [ -f "$1" ]; then
        echo "❌ ERROR: El archivo no debería existir: $1"
        exit 1
    else
        echo "✅ OK: Archivo no existe (como se esperaba): $1"
    fi
}

# Array to track all created files for cleanup
CREATED_FILES=()
# Array to store existing files before test starts
EXISTING_FILES=()

# Enhanced cleanup function
cleanup_files() {
    local pattern="$1"
    find "$HOME" -name "$pattern" -type f -delete 2>/dev/null || true
}

# Function to track created files
track_file() {
    local file="$1"
    if [ -n "$file" ]; then
        CREATED_FILES+=("$file")
    fi
}

# Function to detect and track files created after function execution
detect_new_files() {
    echo "🔍 Detectando archivos nuevos creados..."
    local current_files=()
    mapfile -t current_files < <(find "$HOME" -maxdepth 1 \( \
        -name "${GRUPO}_diff_*" -o \
        -name "${GRUPO}_comparison_*" -o \
        -name "diff_*.patch" -o \
        -name "diff_*.txt" \
    \) -type f 2>/dev/null || true)
    
    # Track any new files that weren't there before
    for file in "${current_files[@]}"; do
        local was_existing=false
        for existing_file in "${EXISTING_FILES[@]}"; do
            if [[ "$file" == "$existing_file" ]]; then
                was_existing=true
                break
            fi
        done
        
        if [[ "$was_existing" == false ]]; then
            # Check if not already tracked
            local already_tracked=false
            for tracked_file in "${CREATED_FILES[@]}"; do
                if [[ "$file" == "$tracked_file" ]]; then
                    already_tracked=true
                    break
                fi
            done
            
            if [[ "$already_tracked" == false ]]; then
                echo "  Nuevo archivo detectado: $file"
                CREATED_FILES+=("$file")
            fi
        fi
    done
}

# Function to clean all tracked files
cleanup_tracked_files() {
    echo "🧹 Limpiando archivos rastreados..."
    for file in "${CREATED_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo "  Eliminando: $file"
            rm -f "$file" 2>/dev/null || true
        fi
    done
    CREATED_FILES=()
}

# Function to capture existing files before test starts
capture_existing_files() {
    echo "📋 Capturando archivos existentes..."
    # Capture files matching potential output patterns that already exist
    mapfile -t EXISTING_FILES < <(find "$HOME" -maxdepth 1 \( \
        -name "${GRUPO}_diff_*" -o \
        -name "${GRUPO}_comparison_*" -o \
        -name "diff_*.patch" -o \
        -name "diff_*.txt" -o \
        -name "*comparison*.txt" -o \
        -name "*_diff_*vs*_*.patch" -o \
        -name "*_comparison_report_*.txt" \
    \) -type f 2>/dev/null || true)
}

# Function to clean only files created during this test run
cleanup_test_created_files() {
    echo "🧹 Limpieza selectiva de archivos creados en esta ejecución..."
    
    # Find current files matching our patterns
    local current_files=()
    mapfile -t current_files < <(find "$HOME" -maxdepth 1 \( \
        -name "${GRUPO}_diff_*" -o \
        -name "${GRUPO}_comparison_*" -o \
        -name "diff_*.patch" -o \
        -name "diff_*.txt" -o \
        -name "*comparison*.txt" -o \
        -name "*_diff_*vs*_*.patch" -o \
        -name "*_comparison_report_*.txt" \
    \) -type f 2>/dev/null || true)
    
    # Remove only files that weren't there before the test
    for file in "${current_files[@]}"; do
        local was_existing=false
        for existing_file in "${EXISTING_FILES[@]}"; do
            if [[ "$file" == "$existing_file" ]]; then
                was_existing=true
                break
            fi
        done
        
        if [[ "$was_existing" == false ]]; then
            echo "  Eliminando archivo creado en test: $file"
            rm -f "$file" 2>/dev/null || true
        else
            echo "  Preservando archivo existente: $file"
        fi
    done
}

# =============================
# LIMPIEZA INICIAL
# =============================
echo "🧹 Realizando limpieza inicial..."
# Capture existing files before we start
capture_existing_files

# =============================
# Cargar función desde script original
# =============================
source "$SCRIPT_PATH"

# Define expected output files using the GRUPO and FECHA variables from main script
PATCH_OUTPUT="$HOME/${GRUPO}_diff_mainvstest_$FECHA.patch"
REPORT_OUTPUT="$HOME/${GRUPO}_comparison_report_$FECHA.txt"

# Track expected output files
track_file "$PATCH_OUTPUT"
track_file "$REPORT_OUTPUT"

# =============================
# TEST 1: Comparación de ramas Git
# =============================
echo "=== TEST 1: Comparación de ramas con Git ==="
mkdir "$TEST_REPO" && cd "$TEST_REPO" || exit 1
git init -q
git config user.email "test@example.com"
git config user.name "Test User"
echo "Linea original" > archivo.txt
git add archivo.txt
git commit -q -m "Commit inicial"

# Cambiar el nombre de la rama principal a main si es necesario
git branch -m master main 2>/dev/null || true

git checkout -q -b test
echo "Linea nueva" >> archivo.txt
git commit -q -am "Cambio en rama test"
git checkout -q main

# Simular entrada de usuario para modo Git (especificando ruta del repo temporal)
OUTPUT=$(
    (
        echo "1"            # Seleccionar modo Git
        echo "1"            # Usar directorio por defecto
        echo "2"            # Especificar ruta diferente
        echo "$TEST_REPO"   # Ruta del repositorio temporal
        echo "main"         # Rama base
        echo "test"         # Rama comparar
    ) | comparar_cambios 2>&1
)

# Detect any files created during the test
detect_new_files

assert_file_exists "$PATCH_OUTPUT"
assert_file_exists "$REPORT_OUTPUT"
assert_file_contains "$REPORT_OUTPUT" "Comparación entre ramas: main vs test"
assert_file_contains "$REPORT_OUTPUT" "Linea nueva"
assert_file_contains "$REPORT_OUTPUT" "ESTADÍSTICAS RESUMEN"
assert_file_contains "$REPORT_OUTPUT" "Archivos modificados:"

# Verificar que el resumen aparece en consola
assert_output_contains "$OUTPUT" "=== RESUMEN DE CAMBIOS ===" "Console summary display"
assert_output_contains "$OUTPUT" "📁 Repositorio:" "Console repository info"
assert_output_contains "$OUTPUT" "🔀 Comparación: main vs test" "Console branch comparison"
assert_output_contains "$OUTPUT" "📊 Archivos modificados:" "Console files changed"
assert_output_contains "$OUTPUT" "📄 Archivo patch:" "Console patch file location"

# =============================
# TEST 2: Comparación con diff
# =============================
echo "=== TEST 2: Comparación con diff ==="
DIR1="$TEMP_DIR/dir1"
DIR2="$TEMP_DIR/dir2"
mkdir "$DIR1" "$DIR2"
echo "uno" > "$DIR1/archivo.txt"
echo "dos" > "$DIR2/archivo.txt"

OUTPUT2=$(
    (
        echo "2"          # Modo diff
        echo "1"          # Usar directorio por defecto
        echo "$DIR1"      # Primer archivo/directorio
        echo "$DIR2"      # Segundo archivo/directorio
    ) | comparar_cambios 2>&1
)

# Detect any files created during diff test
detect_new_files

assert_file_contains "$REPORT_OUTPUT" "Comparación entre: $DIR1 y $DIR2"
assert_file_contains "$REPORT_OUTPUT" "ESTADÍSTICAS RESUMEN"
assert_file_contains "$REPORT_OUTPUT" "Total de líneas en diff:"

# Verificar que el resumen aparece en consola para diff
assert_output_contains "$OUTPUT2" "=== RESUMEN DE CAMBIOS ===" "Console summary display diff"
assert_output_contains "$OUTPUT2" "📁 Comparación entre:" "Console diff comparison"
assert_output_contains "$OUTPUT2" "📊 Archivos/directorios modificados:" "Console diff files modified"
assert_output_contains "$OUTPUT2" "📄 Archivo diff:" "Console diff file location"

# =============================
# TEST 3: Custom output path
# =============================
echo "=== TEST 3: Custom output path ==="
CUSTOM_OUTPUT_DIR="$TEMP_DIR/custom_output"
mkdir "$CUSTOM_OUTPUT_DIR"
CUSTOM_PATCH="$CUSTOM_OUTPUT_DIR/${GRUPO}_diff_mainvstest_$FECHA.patch"
CUSTOM_REPORT="$CUSTOM_OUTPUT_DIR/${GRUPO}_comparison_report_$FECHA.txt"

# Track custom output files
track_file "$CUSTOM_PATCH"
track_file "$CUSTOM_REPORT"

# Test Git mode with custom output path
cd "$TEST_REPO"
OUTPUT3=$(
    (
        echo "1"                      # Seleccionar modo Git
        echo "2"                      # Especificar directorio personalizado
        echo "$CUSTOM_OUTPUT_DIR"     # Directorio personalizado
        echo "2"                      # Especificar ruta diferente
        echo "$TEST_REPO"             # Ruta del repositorio temporal
        echo "main"                   # Rama base
        echo "test"                   # Rama comparar
    ) | comparar_cambios 2>&1
)

# Detect any files created during custom output test
detect_new_files

assert_file_exists "$CUSTOM_PATCH"
assert_file_exists "$CUSTOM_REPORT"
assert_output_contains "$OUTPUT3" "$CUSTOM_PATCH" "Custom output path in console"
assert_output_contains "$OUTPUT3" "$CUSTOM_REPORT" "Custom report path in console"

# =============================
# TEST 4: Error scenarios
# =============================
echo "=== TEST 4: Error scenarios ==="

# Test invalid output directory
INVALID_OUTPUT=$(
    (
        echo "1"                          # Seleccionar modo Git
        echo "2"                          # Especificar directorio personalizado
        echo "/nonexistent/directory"     # Directorio que no existe
    ) | comparar_cambios 2>&1
)
assert_output_contains "$INVALID_OUTPUT" "Error: El directorio '/nonexistent/directory' no existe" "Invalid output directory error"

# Test invalid repository path
INVALID_REPO_OUTPUT=$(
    (
        echo "1"                          # Seleccionar modo Git
        echo "1"                          # Usar directorio por defecto
        echo "2"                          # Especificar ruta diferente
        echo "/nonexistent/repo"          # Repositorio que no existe
    ) | comparar_cambios 2>&1
)
assert_output_contains "$INVALID_REPO_OUTPUT" "Error: El directorio '/nonexistent/repo' no existe" "Invalid repo path error"

# Test non-git directory
NON_GIT_DIR="$TEMP_DIR/not_git"
mkdir "$NON_GIT_DIR"
NON_GIT_OUTPUT=$(
    (
        echo "1"                          # Seleccionar modo Git
        echo "1"                          # Usar directorio por defecto
        echo "2"                          # Especificar ruta diferente
        echo "$NON_GIT_DIR"               # Directorio que no es repo git
    ) | comparar_cambios 2>&1
)
assert_output_contains "$NON_GIT_OUTPUT" "no es un repositorio Git válido" "Non-git directory error"

# Test invalid branch names
cd "$TEST_REPO"
INVALID_BRANCH_OUTPUT=$(
    (
        echo "1"                          # Seleccionar modo Git
        echo "1"                          # Usar directorio por defecto
        echo "2"                          # Especificar ruta diferente
        echo "$TEST_REPO"                 # Ruta del repositorio temporal
        echo "nonexistent_branch"         # Rama que no existe
        echo "test"                       # Rama comparar
    ) | comparar_cambios 2>&1
)
assert_output_contains "$INVALID_BRANCH_OUTPUT" "Error: La rama 'nonexistent_branch' no existe" "Invalid branch error"

# Test invalid file paths for diff mode
INVALID_FILE_OUTPUT=$(
    (
        echo "2"                          # Modo diff
        echo "1"                          # Usar directorio por defecto
        echo "/nonexistent/file1"         # Archivo que no existe
        echo "/nonexistent/file2"         # Archivo que no existe
    ) | comparar_cambios 2>&1
)
assert_output_contains "$INVALID_FILE_OUTPUT" "Error: Uno de los elementos no existe" "Invalid file paths error"

# =============================
# TEST 5: Edge cases
# =============================
echo "=== TEST 5: Edge cases ==="

# Test when no differences exist (identical branches)
cd "$TEST_REPO"
NO_DIFF_OUTPUT=$(
    (
        echo "1"                          # Seleccionar modo Git
        echo "1"                          # Usar directorio por defecto
        echo "2"                          # Especificar ruta diferente
        echo "$TEST_REPO"                 # Ruta del repositorio temporal
        echo "main"                       # Rama base
        echo "main"                       # Misma rama (sin diferencias)
    ) | comparar_cambios 2>&1
)
assert_output_contains "$NO_DIFF_OUTPUT" "No hay diferencias entre 'main' y 'main'" "No differences message"

# Test identical files for diff mode
IDENTICAL_FILE1="$TEMP_DIR/identical1.txt"
IDENTICAL_FILE2="$TEMP_DIR/identical2.txt"
echo "same content" > "$IDENTICAL_FILE1"
echo "same content" > "$IDENTICAL_FILE2"

IDENTICAL_OUTPUT=$(
    (
        echo "2"                          # Modo diff
        echo "1"                          # Usar directorio por defecto
        echo "$IDENTICAL_FILE1"           # Primer archivo
        echo "$IDENTICAL_FILE2"           # Segundo archivo (idéntico)
    ) | comparar_cambios 2>&1
)
assert_output_contains "$IDENTICAL_OUTPUT" "No hay diferencias" "No differences in diff mode"

# Test invalid option selection
INVALID_OPTION_OUTPUT=$(
    (
        echo "99"                         # Opción inválida
    ) | comparar_cambios 2>&1
)
assert_output_contains "$INVALID_OPTION_OUTPUT" "Opción inválida" "Invalid option error"

# =============================
# TEST 6: Permissions test (if possible)
# =============================
echo "=== TEST 6: Write permissions test ==="
READONLY_DIR="$TEMP_DIR/readonly"
mkdir "$READONLY_DIR"
chmod 444 "$READONLY_DIR" 2>/dev/null || echo "Warning: Could not change permissions for readonly test"

if [ ! -w "$READONLY_DIR" ]; then
    READONLY_OUTPUT=$(
        (
            echo "1"                          # Seleccionar modo Git
            echo "2"                          # Especificar directorio personalizado
            echo "$READONLY_DIR"              # Directorio sin permisos de escritura
        ) | comparar_cambios 2>&1
    )
    assert_output_contains "$READONLY_OUTPUT" "No tiene permisos de escritura" "Write permissions error"
else
    echo "ℹ️ INFO: Skipping readonly test (permissions could not be restricted)"
fi

# Restore permissions for cleanup
chmod 755 "$READONLY_DIR" 2>/dev/null || true

# =============================
# LIMPIEZA
# =============================
echo "🧹 Limpiando archivos temporales..."

# Clean temp directory (includes custom output directories)
rm -rf "$TEMP_DIR"

# Clean tracked files
cleanup_tracked_files

# Perform selective cleanup of test-created files only
cleanup_test_created_files

echo "🎉 Todos los tests pasaron correctamente."
