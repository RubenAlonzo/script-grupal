#!/bin/bash
# Script de tests para la función comparar_cambios

# Ruta relativa al script principal
SCRIPT_PATH="$(dirname "$0")/../src/main_script.sh"
TEMP_DIR=$(mktemp -d)
TEST_REPO="$TEMP_DIR/repo_test"
FECHA=$(date +%F_%H-%M-%S)
PATCH_OUTPUT="$HOME/diff_mainvstest_$FECHA.patch"
REPORT_OUTPUT="$HOME/diff_comparison_report_$FECHA.txt"

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

cleanup_files() {
    local pattern="$1"
    find "$HOME" -name "$pattern" -type f -delete 2>/dev/null || true
}

# =============================
# Cargar función desde script original
# =============================
source "$SCRIPT_PATH"

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
CUSTOM_PATCH="$CUSTOM_OUTPUT_DIR/diff_mainvstest_$FECHA.patch"
CUSTOM_REPORT="$CUSTOM_OUTPUT_DIR/diff_comparison_report_$FECHA.txt"

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
rm -rf "$TEMP_DIR"
rm -f "$PATCH_OUTPUT" "$REPORT_OUTPUT" "$HOME/diff_$FECHA.txt"
cleanup_files "diff_*_${FECHA}.patch"
cleanup_files "diff_comparison_report_${FECHA}.txt"
cleanup_files "diff_$FECHA.txt"

echo "🎉 Todos los tests pasaron correctamente."
