#!/bin/bash
# =========================================================================
# PROYECTO FINAL - SCRIPT GRUPAL
# =========================================================================
# Curso: Sistemas Operativos
# Grupo: Grupo1
# 
# INTEGRANTES Y CONTRIBUCIONES:
# • Ruben Alonzo - Opción 1: Comparación de cambios (Git o diff)
# • [Miembro 2] - Opción 2: [Pendiente de asignar]
# • [Miembro 3] - Opción 3: [Pendiente de asignar]  
# • [Miembro 4] - Opción 4: [Pendiente de asignar]
# • [Miembro 5] - Opción 5: [Pendiente de asignar]
#
# DESCRIPCIÓN GENERAL:
# Este script implementa un menú interactivo que agrupa diferentes
# funcionalidades desarrolladas por los miembros del grupo. Cada
# funcionalidad muestra información del estudiante autor, descripción
# de la funcionalidad y directorio de ejecución.
# =========================================================================

# =========================
# Variables generales del proyecto
# =========================
DIRECTORIO_ACTUAL=$(pwd)
FECHA=$(date +%F_%H-%M-%S)

# =========================
# Función: Comparar cambios (Git o diff)
# Autor: Ruben Alonzo
# Descripción: Permite comparar cambios entre ramas de Git o archivos/directorios
# usando herramientas diff. Genera reportes detallados y archivos patch.
# =========================
comparar_cambios() {
    echo "========================================="
    echo "  FUNCIONALIDAD: COMPARACIÓN DE CAMBIOS"
    echo "========================================="
    echo "Estudiante: Ruben Alonzo"
    echo "Descripción: Herramienta para comparar cambios entre ramas de Git"
    echo "             o archivos/directorios usando diff, con generación"
    echo "             de reportes detallados y archivos patch."
    echo "Directorio actual: $(pwd)"
    echo "========================================="
    echo ""
    echo "=== Comparación de Cambios (Git o diff) ==="
    echo "Seleccione el modo:"
    echo "1) Modo Git (comparar ramas)"
    echo "2) Modo diff (comparar archivos o directorios)"
    read -p "Opción: " MODO

    # Preguntar por directorio de salida personalizado
    echo "¿Desea usar el directorio de salida por defecto ($HOME) o especificar uno personalizado?"
    echo "1) Usar directorio por defecto ($HOME)"
    echo "2) Especificar directorio personalizado"
    read -p "Opción: " OUTPUT_OPTION
    
    if [ "$OUTPUT_OPTION" = "2" ]; then
        read -p "Ingrese la ruta del directorio de salida: " OUTPUT_DIR
        if [ ! -d "$OUTPUT_DIR" ]; then
            echo "❌ Error: El directorio '$OUTPUT_DIR' no existe."
            return
        fi
        if [ ! -w "$OUTPUT_DIR" ]; then
            echo "❌ Error: No tiene permisos de escritura en '$OUTPUT_DIR'."
            return
        fi
    else
        OUTPUT_DIR="$HOME"
    fi

    if [ "$MODO" = "1" ]; then
        # Preguntar por el directorio del repositorio
        echo "¿Desea analizar el directorio actual o especificar una ruta diferente?"
        echo "1) Directorio actual ($DIRECTORIO_ACTUAL)"
        echo "2) Especificar ruta diferente"
        read -p "Opción: " REPO_OPTION
        
        if [ "$REPO_OPTION" = "2" ]; then
            read -p "Ingrese la ruta del repositorio: " REPO_PATH
            if [ ! -d "$REPO_PATH" ]; then
                echo "❌ Error: El directorio '$REPO_PATH' no existe."
                return
            fi
            if ! git -C "$REPO_PATH" rev-parse --is-inside-work-tree &>/dev/null; then
                echo "❌ Error: '$REPO_PATH' no es un repositorio Git válido."
                return
            fi
        else
            REPO_PATH="$DIRECTORIO_ACTUAL"
            if ! git rev-parse --is-inside-work-tree &>/dev/null; then
                echo "❌ Error: No está dentro de un repositorio Git."
                return
            fi
        fi
        read -p "Ingrese la rama base: " BASE
        read -p "Ingrese la rama a comparar: " COMPARE

        if ! git -C "$REPO_PATH" rev-parse --verify "$BASE" &>/dev/null; then
            echo "Error: La rama '$BASE' no existe en el repositorio."
            return
        fi
        if ! git -C "$REPO_PATH" rev-parse --verify "$COMPARE" &>/dev/null; then
            echo "Error: La rama '$COMPARE' no existe en el repositorio."
            return
        fi

        PATCH_FILE="$OUTPUT_DIR/diff_${BASE}vs${COMPARE}_$FECHA.patch"
        git -C "$REPO_PATH" diff "$BASE" "$COMPARE" > "$PATCH_FILE"

        if [ ! -s "$PATCH_FILE" ]; then
            echo "✅ No hay diferencias entre '$BASE' y '$COMPARE'."
            return
        fi

        echo "Patch generado en: $PATCH_FILE"
        
        # Generar estadísticas
        STATS_OUTPUT=$(git -C "$REPO_PATH" diff --stat "$BASE" "$COMPARE")
        COMMIT_INFO=$(git -C "$REPO_PATH" log --oneline "$BASE..$COMPARE" | head -10)
        FILES_CHANGED=$(echo "$STATS_OUTPUT" | tail -1 | grep -o '[0-9]\+ file' | grep -o '[0-9]\+' || echo "0")
        INSERTIONS=$(echo "$STATS_OUTPUT" | tail -1 | grep -o '[0-9]\+ insertion' | grep -o '[0-9]\+' || echo "0")
        DELETIONS=$(echo "$STATS_OUTPUT" | tail -1 | grep -o '[0-9]\+ deletion' | grep -o '[0-9]\+' || echo "0")
        
        REPORTE="$OUTPUT_DIR/diff_comparison_report_$FECHA.txt"
        echo "=== Reporte de cambios (Git) - $(date) ===" > "$REPORTE"
        echo "Repositorio: $REPO_PATH" >> "$REPORTE"
        echo "Comparación entre ramas: $BASE vs $COMPARE" >> "$REPORTE"
        echo "Archivo patch: $PATCH_FILE" >> "$REPORTE"
        echo "" >> "$REPORTE"
        echo "=== ESTADÍSTICAS RESUMEN ===" >> "$REPORTE"
        echo "Archivos modificados: $FILES_CHANGED" >> "$REPORTE"
        echo "Líneas agregadas: $INSERTIONS" >> "$REPORTE"
        echo "Líneas eliminadas: $DELETIONS" >> "$REPORTE"
        echo "" >> "$REPORTE"
        if [ -n "$COMMIT_INFO" ]; then
            echo "=== COMMITS EN LA RAMA $COMPARE (últimos 10) ===" >> "$REPORTE"
            echo "$COMMIT_INFO" >> "$REPORTE"
            echo "" >> "$REPORTE"
        fi
        echo "=== ESTADÍSTICAS DETALLADAS ===" >> "$REPORTE"
        echo "$STATS_OUTPUT" >> "$REPORTE"
        echo "" >> "$REPORTE"
        echo "=== DIFERENCIAS COMPLETAS ===" >> "$REPORTE"
        cat "$PATCH_FILE" >> "$REPORTE"
        
        # Mostrar resumen en consola
        echo ""
        echo "=== RESUMEN DE CAMBIOS ==="
        echo "📁 Repositorio: $REPO_PATH"
        echo "🔀 Comparación: $BASE vs $COMPARE"
        echo "📊 Archivos modificados: $FILES_CHANGED"
        echo "➕ Líneas agregadas: $INSERTIONS"
        echo "➖ Líneas eliminadas: $DELETIONS"
        echo "📄 Archivo patch: $PATCH_FILE"

    elif [ "$MODO" = "2" ]; then
        read -p "Ingrese la ruta del primer archivo/directorio: " FILE1
        read -p "Ingrese la ruta del segundo archivo/directorio: " FILE2

        if [ ! -e "$FILE1" ] || [ ! -e "$FILE2" ]; then
            echo "Error: Uno de los elementos no existe."
            return
        fi

        DIFF_FILE="$OUTPUT_DIR/diff_$FECHA.txt"
        diff -ru "$FILE1" "$FILE2" > "$DIFF_FILE"

        if [ ! -s "$DIFF_FILE" ]; then
            echo "✅ No hay diferencias."
            return
        fi

        echo "Diferencias guardadas en: $DIFF_FILE"
        
        # Generar estadísticas para diff
        TOTAL_LINES=$(wc -l < "$DIFF_FILE")
        ADDED_LINES=$(grep -c '^+' "$DIFF_FILE" || echo "0")
        REMOVED_LINES=$(grep -c '^-' "$DIFF_FILE" || echo "0")
        MODIFIED_FILES=$(grep -c '^diff' "$DIFF_FILE" || echo "0")
        
        REPORTE="$OUTPUT_DIR/diff_comparison_report_$FECHA.txt"
        echo "=== Reporte de cambios (diff) - $(date) ===" > "$REPORTE"
        echo "Comparación entre: $FILE1 y $FILE2" >> "$REPORTE"
        echo "Archivo diff: $DIFF_FILE" >> "$REPORTE"
        echo "" >> "$REPORTE"
        echo "=== ESTADÍSTICAS RESUMEN ===" >> "$REPORTE"
        echo "Archivos/directorios modificados: $MODIFIED_FILES" >> "$REPORTE"
        echo "Líneas agregadas: $ADDED_LINES" >> "$REPORTE"
        echo "Líneas eliminadas: $REMOVED_LINES" >> "$REPORTE"
        echo "Total de líneas en diff: $TOTAL_LINES" >> "$REPORTE"
        echo "" >> "$REPORTE"
        echo "=== DIFERENCIAS COMPLETAS ===" >> "$REPORTE"
        cat "$DIFF_FILE" >> "$REPORTE"
        
        # Mostrar resumen en consola
        echo ""
        echo "=== RESUMEN DE CAMBIOS ==="
        echo "📁 Comparación entre: $FILE1 vs $FILE2"
        echo "📊 Archivos/directorios modificados: $MODIFIED_FILES"
        echo "➕ Líneas agregadas: $ADDED_LINES"
        echo "➖ Líneas eliminadas: $REMOVED_LINES"
        echo "📏 Total líneas en diff: $TOTAL_LINES"
        echo "📄 Archivo diff: $DIFF_FILE"
    else
        echo "Opción inválida."
        return
    fi


    echo "✅ Reporte final guardado en: $REPORTE"
}

# =========================
# Función: Funcionalidad 2
# Autor: [Miembro 2] - Pendiente de asignar
# Descripción: [Pendiente de definir funcionalidad]
# =========================
funcionalidad_2() {
    echo "========================================="
    echo "     FUNCIONALIDAD 2: [PENDIENTE]"
    echo "========================================="
    echo "Estudiante: [Miembro 2 - Pendiente de asignar]"
    echo "Descripción: [Pendiente de definir la funcionalidad]"
    echo "Directorio actual: $(pwd)"
    echo "========================================="
    echo ""
    echo "Esta funcionalidad está pendiente de implementación."
    echo "El estudiante asignado debe:"
    echo "1. Definir qué funcionalidad implementará"
    echo "2. Actualizar la información del estudiante"
    echo "3. Implementar la funcionalidad"
    echo "4. Actualizar los comentarios del código"
}
# =========================
# Función: Funcionalidad 3
# Autor: [Miembro 3] - Pendiente de asignar
# Descripción: [Pendiente de definir funcionalidad]
# =========================
funcionalidad_3() {
    echo "========================================="
    echo "     FUNCIONALIDAD 3: [PENDIENTE]"
    echo "========================================="
    echo "Estudiante: [Miembro 3 - Pendiente de asignar]"
    echo "Descripción: [Pendiente de definir la funcionalidad]"
    echo "Directorio actual: $(pwd)"
    echo "========================================="
    echo ""
    echo "Esta funcionalidad está pendiente de implementación."
    echo "El estudiante asignado debe:"
    echo "1. Definir qué funcionalidad implementará"
    echo "2. Actualizar la información del estudiante"
    echo "3. Implementar la funcionalidad"
    echo "4. Actualizar los comentarios del código"
}
# =========================
# Función: Funcionalidad 4
# Autor: [Miembro 4] - Pendiente de asignar
# Descripción: [Pendiente de definir funcionalidad]
# =========================
funcionalidad_4() {
    echo "========================================="
    echo "     FUNCIONALIDAD 4: [PENDIENTE]"
    echo "========================================="
    echo "Estudiante: [Miembro 4 - Pendiente de asignar]"
    echo "Descripción: [Pendiente de definir la funcionalidad]"
    echo "Directorio actual: $(pwd)"
    echo "========================================="
    echo ""
    echo "Esta funcionalidad está pendiente de implementación."
    echo "El estudiante asignado debe:"
    echo "1. Definir qué funcionalidad implementará"
    echo "2. Actualizar la información del estudiante"
    echo "3. Implementar la funcionalidad"
    echo "4. Actualizar los comentarios del código"
}
# =========================
# Función: Funcionalidad 5
# Autor: [Miembro 5] - Pendiente de asignar
# Descripción: [Pendiente de definir funcionalidad]
# =========================
funcionalidad_5() {
    echo "========================================="
    echo "     FUNCIONALIDAD 5: [PENDIENTE]"
    echo "========================================="
    echo "Estudiante: [Miembro 5 - Pendiente de asignar]"
    echo "Descripción: [Pendiente de definir la funcionalidad]"
    echo "Directorio actual: $(pwd)"
    echo "========================================="
    echo ""
    echo "Esta funcionalidad está pendiente de implementación."
    echo "El estudiante asignado debe:"
    echo "1. Definir qué funcionalidad implementará"
    echo "2. Actualizar la información del estudiante"
    echo "3. Implementar la funcionalidad"
    echo "4. Actualizar los comentarios del código"
}

# =========================
# Información inicial del script
# =========================
mostrar_info_inicial() {
    echo "========================================"
    echo "    PROYECTO FINAL - SCRIPT GRUPAL"
    echo "========================================"
    echo "Integrantes del grupo:"
    echo "  • Ruben Alonzo - Comparación de cambios (Git/diff)"
    echo "  • [Miembro 2] - Funcionalidad 2 (pendiente)"
    echo "  • [Miembro 3] - Funcionalidad 3 (pendiente)"
    echo "  • [Miembro 4] - Funcionalidad 4 (pendiente)"
    echo "  • [Miembro 5] - Funcionalidad 5 (pendiente)"
    echo ""
    echo "Descripción: Este script agrupa diversas funcionalidades"
    echo "desarrolladas por los miembros del grupo para el proyecto final."
    echo ""
    echo "Directorio de ejecución: $(pwd)"
    echo "========================================"
    echo ""
}

# =========================
# Menú principal
# =========================
main_menu() {
    mostrar_info_inicial
    
    while true; do
        echo "=== Proyecto Final - Menú Principal ==="
        echo "1) Comparar cambios (Git o diff) - Ruben Alonzo"
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
}

# Solo ejecutar el menú si el script se ejecuta directamente (no cuando se hace source)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_menu
fi
