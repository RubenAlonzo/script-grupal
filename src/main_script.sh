#!/bin/bash
# Proyecto Final - Script Grupal
# Integrantes: [Lista de nombres]
# Opción 1: Comparación de cambios (Git o diff) - Aporte de: [Tu Nombre]

# =========================
# Variables generales
# =========================
ESTUDIANTE="[Tu Nombre]"
DESCRIPCION="Menú principal para ejecutar las funcionalidades del proyecto final."
DIRECTORIO_ACTUAL=$(pwd)
GRUPO="Grupo1"
FECHA=$(date +%F)

# =========================
# Función: Comparar cambios (Git o diff) - Tu aporte
# =========================
comparar_cambios() {
    echo "=== Comparación de Cambios (Git o diff) ==="
    echo "Seleccione el modo:"
    echo "1) Modo Git (comparar ramas)"
    echo "2) Modo diff (comparar archivos o directorios)"
    read -p "Opción: " MODO

    if [ "$MODO" -eq 1 ]; then
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo "❌ Error: No está dentro de un repositorio Git."
            return
        fi
        read -p "Ingrese la rama base: " BASE
        read -p "Ingrese la rama a comparar: " COMPARE

        if ! git rev-parse --verify "$BASE" &>/dev/null; then
            echo "Error: La rama '$BASE' no existe."
            return
        fi
        if ! git rev-parse --verify "$COMPARE" &>/dev/null; then
            echo "Error: La rama '$COMPARE' no existe."
            return
        fi

        PATCH_FILE="$HOME/diff_${BASE}vs${COMPARE}-$FECHA.patch"
        git diff "$BASE" "$COMPARE" > "$PATCH_FILE"

        if [ ! -s "$PATCH_FILE" ]; then
            echo "✅ No hay diferencias entre '$BASE' y '$COMPARE'."
            return
        fi

        echo "Patch generado en: $PATCH_FILE"
        REPORTE="$HOME/${GRUPO}_comparacion-$FECHA.txt"
        echo "=== Reporte de cambios (Git) - $(date) ===" > "$REPORTE"
        echo "Comparación entre ramas: $BASE vs $COMPARE" >> "$REPORTE"
        echo "Archivo patch: $PATCH_FILE" >> "$REPORTE"
        echo "" >> "$REPORTE"
        cat "$PATCH_FILE" >> "$REPORTE"

    elif [ "$MODO" -eq 2 ]; then
        read -p "Ingrese la ruta del primer archivo/directorio: " FILE1
        read -p "Ingrese la ruta del segundo archivo/directorio: " FILE2

        if [ ! -e "$FILE1" ] || [ ! -e "$FILE2" ]; then
            echo "Error: Uno de los elementos no existe."
            return
        fi

        DIFF_FILE="$HOME/diff_${FECHA}.txt"
        diff -ru "$FILE1" "$FILE2" > "$DIFF_FILE"

        if [ ! -s "$DIFF_FILE" ]; then
            echo "✅ No hay diferencias."
            return
        fi

        echo "Diferencias guardadas en: $DIFF_FILE"
        REPORTE="$HOME/${GRUPO}_comparacion-$FECHA.txt"
        echo "=== Reporte de cambios (diff) - $(date) ===" > "$REPORTE"
        echo "Comparación entre: $FILE1 y $FILE2" >> "$REPORTE"
        echo "" >> "$REPORTE"
        cat "$DIFF_FILE" >> "$REPORTE"
    else
        echo "Opción inválida."
        return
    fi

    # Preguntar si desea resumen con Ollama
    read -p "¿Desea generar un resumen con Ollama? (s/n): " RES
    if [[ "$RES" =~ ^[Ss]$ ]]; then
        if ! command -v ollama &>/dev/null; then
            echo "⚠ Ollama no está instalado. No se puede generar el resumen."
        else
            echo "Generando resumen con Ollama..."
            RESUMEN=$(ollama run llama3.1:latest "Resume estos cambios de forma simple:\n$(cat "$REPORTE")")
            echo -e "\n=== Resumen con LLM ===" >> "$REPORTE"
            echo "$RESUMEN" >> "$REPORTE"
        fi
    fi

    echo "✅ Reporte final guardado en: $REPORTE"
}

# =========================
# Funciones placeholder para los otros miembros
# =========================
funcionalidad_2() {
    echo "Funcionalidad 2: [Descripción pendiente]"
}
funcionalidad_3() {
    echo "Funcionalidad 3: [Descripción pendiente]"
}
funcionalidad_4() {
    echo "Funcionalidad 4: [Descripción pendiente]"
}
funcionalidad_5() {
    echo "Funcionalidad 5: [Descripción pendiente]"
}

# =========================
# Menú principal
# =========================
while true; do
    echo "=== Proyecto Final - Menú Principal ==="
    echo "1) Comparar cambios (Git o diff) - [Tu Nombre]"
    echo "2) Funcionalidad 2 - [Miembro 2]"
    echo "3) Funcionalidad 3 - [Miembro 3]"
    echo "4) Funcionalidad 4 - [Miembro 4]"
    echo "5) Funcionalidad 5 - [Miembro 5]"
    echo "0) Salir"
    read -p "Seleccione una opción: " OPCION

    case $OPCION in
        1) comparar_cambios ;;
        2) funcionalidad_2 ;;
        3) funcionalidad_3 ;;
        4) funcionalidad_4 ;;
        5) funcionalidad_5 ;;
        0) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción inválida. Intente de nuevo." ;;
    esac
    echo
done
