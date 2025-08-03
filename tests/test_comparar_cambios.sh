#!/bin/bash
# Script de tests para la función comparar_cambios

# Ruta relativa al script principal
SCRIPT_PATH="$(dirname "$0")/../src/main_script.sh"
TEMP_DIR=$(mktemp -d)
TEST_REPO="$TEMP_DIR/repo_test"
FECHA=$(date +%F)
PATCH_OUTPUT="$HOME/diff_mastervstest-$FECHA.patch"
REPORT_OUTPUT="$HOME/Grupo1_comparacion-$FECHA.txt"

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

git checkout -q -b test
echo "Linea nueva" >> archivo.txt
git commit -q -am "Cambio en rama test"
git checkout -q master

# Simular entrada de usuario para modo Git
(
    echo "1"            # Seleccionar modo Git
    echo "master"       # Rama base
    echo "test"         # Rama comparar
    echo "n"            # No usar Ollama
) | comparar_cambios

assert_file_exists "$PATCH_OUTPUT"
assert_file_exists "$REPORT_OUTPUT"
assert_file_contains "$REPORT_OUTPUT" "Comparación entre ramas: master vs test"
assert_file_contains "$REPORT_OUTPUT" "Linea nueva"

# =============================
# TEST 2: Comparación con diff
# =============================
echo "=== TEST 2: Comparación con diff ==="
DIR1="$TEMP_DIR/dir1"
DIR2="$TEMP_DIR/dir2"
mkdir "$DIR1" "$DIR2"
echo "uno" > "$DIR1/archivo.txt"
echo "dos" > "$DIR2/archivo.txt"

(
    echo "2"          # Modo diff
    echo "$DIR1"      # Primer archivo/directorio
    echo "$DIR2"      # Segundo archivo/directorio
    echo "n"          # No usar Ollama
) | comparar_cambios

assert_file_contains "$REPORT_OUTPUT" "Comparación entre: $DIR1 y $DIR2"

# =============================
# LIMPIEZA
# =============================
echo "🧹 Limpiando archivos temporales..."
rm -rf "$TEMP_DIR"
rm -f "$PATCH_OUTPUT" "$REPORT_OUTPUT" "$HOME/diff_${FECHA}.txt"

echo "🎉 Todos los tests pasaron correctamente."
