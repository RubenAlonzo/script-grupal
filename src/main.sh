#!/bin/bash

# PROYECTO FINAL – SCRIPT GRUPAL
# Curso: Sistemas Operativos | Grupo: Grupo1
# Integrantes:
#  • Ruben Alonzo – Comparación de cambios (Git/diff)
#  • Rafael Emilio Abreu – Encontrar archivos grandes
#  • Nasser Emil Issa Tavares – Generar calendario anual
#  • Miembro 4 – Func. 4 (pendiente)
#  • Miembro 5 – Func. 5 (pendiente)

GRUPO="Grupo1"
FECHA=$(date +%F_%H-%M-%S)

# Muestra la cabecera con datos del script
mostrar_info() {
  echo "======================================="
  echo "Grupo:      $GRUPO"
  echo "Fecha:      $FECHA"
  echo "Directorio: $(pwd)"
  echo "Integrantes y funciones:"
  echo "  - Ruben Alonzo: Comparar cambios"
  echo "  - Rafael Emilio Abreu: Encontrar archivos grandes"
  echo "  - Nasser Emil Issa Tavares: Generar calendario anual"
  echo "  - Miembro 3–5:  Funcionalidades pendientes"
  echo "======================================="
  echo
}

# Ruben Alonzo.
# Función para comparar cambios: Git o diff
# Esta función permite al usuario elegir entre comparar ramas de un repositorio Git o comparar archivos/carpetas usando diff.
# Genera un patch o diff según la opción elegida y lo guarda en el directorio del usuario.
comparar_cambios() {
  echo "========================="
  echo "-- COMPARAR CAMBIOS --"
  echo -e "By: Ruben Alonzo\n"
  echo "Esta función permite al usuario elegir entre comparar ramas de un repositorio Git o comparar archivos/carpetas usando diff."
  echo "Genera un patch o diff según la opción elegida y lo guarda en el directorio del usuario."
  echo "========================="
  echo "1) Usar Git (ramas)"
  echo "2) Usar diff (archivos/carpetas)"
  read -p "Elija modo [1-2]: " modo

  if [ "$modo" = "1" ]; then
    read -p "Ruta del repo: " repo
    read -p "Rama base: " base
    read -p "Rama a comparar: " comp
    salida="${HOME}/${GRUPO}_diff_${base}vs${comp}_$FECHA.patch"
    git -C "$repo" diff "$base" "$comp" > "$salida"
    echo "Patch generado en: $salida"
  elif [ "$modo" = "2" ]; then
    read -p "Archivo/carpeta 1: " f1
    read -p "Archivo/carpeta 2: " f2
    salida="${HOME}/${GRUPO}_diff_$FECHA.txt"
    diff -ru "$f1" "$f2" > "$salida"
    echo "Diff generado en: $salida"
  else
    echo "Opción inválida."
  fi
  echo
}

# Rafael Emilio Abreu.
# Función para encontrar archivos grandes en el sistema
# Esta función busca archivos mayores a 100MB en el directorio especificado por el usuario.
# Guarda los resultados en el directorio del usuario.
encontrar_archivos_grandes() {
  echo "=============================="
  echo "-- ENCONTRAR ARCHIVOS GRANDES --"
  echo -e "By: Rafael Emilio Abreu\n"
  echo "Esta función busca archivos mayores a 100MB en el directorio especificado."
  echo "Los resultados se guardan en el directorio del usuario."
  echo "=============================="
  read -p "Directorio a buscar: " directorio
  salida="${HOME}/${GRUPO}_archivos_grandes_100M_$FECHA.txt"
  echo "Buscando archivos mayores a 100MB en $directorio..."
  
  # Create a temporary file for processing
  temp_file=$(mktemp)
  
  # Find files and format output
  find "$directorio" -type f -size +100M -exec ls -lh {} + 2>/dev/null | while read -r permisos enlaces usuario grupo tamano mes dia hora archivo; do
    echo "Tamaño: $tamano | Archivo: $archivo"
  done > "$temp_file"
  
  # Check if any files were found
  if [ -s "$temp_file" ]; then
    # Add header to output file
    echo "========================================" > "$salida"
    echo "ARCHIVOS MAYORES A 100MB" >> "$salida"
    echo "Directorio buscado: $directorio" >> "$salida"
    echo "Fecha de búsqueda: $FECHA" >> "$salida"
    echo "========================================" >> "$salida"
    echo "" >> "$salida"
    
    # Add formatted results
    cat "$temp_file" >> "$salida"
    
    # Count files found
    num_archivos=$(wc -l < "$temp_file")
    echo "" >> "$salida"
    echo "========================================" >> "$salida"
    echo "Total de archivos encontrados: $num_archivos" >> "$salida"
    
    echo "Se encontraron $num_archivos archivos mayores a 100MB."
  else
    echo "No se encontraron archivos mayores a 100MB en el directorio especificado." > "$salida"
    echo "No se encontraron archivos mayores a 100MB."
  fi
  
  # Clean up temp file
  rm -f "$temp_file"
  
  echo "Resultados guardados en: $salida"
  echo
}

# Placeholder genérico para las demás funciones
func_pendiente() {
  echo "Funcionalidad pendiente de implementación."
  echo
}

# Menú principal - solo ejecutar si el script es llamado directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  while true; do
    mostrar_info
    echo "Menú:"
    echo " 1) Comparar cambios"
    echo " 2) Encontrar archivos grandes"
    echo " 3) Generar calendario anual"
    echo " 4) Funcionalidad 4"
    echo " 5) Funcionalidad 5"
    echo " 0) Salir"
    read -p "Opción [0-5]: " opt

    case "$opt" in
      1) comparar_cambios ;;
      2) encontrar_archivos_grandes ;;
      3) generar_calendario_anual ;;
      0) echo "¡Hasta luego!"; exit 0 ;;
      *) echo "Elija una opción válida." ;;
    esac
  done
fi
# ==========================================
# Nasser Emil Issa Tavares
# Funcionalidad 3: generar_calendario_anual
# Crea automáticamente la estructura de un año con sus meses, días y 7 subcarpetas por día, ajustando años bisiestos y guardando un reporte con métricas y el árbol de directorios.
# ==========================================
generar_calendario_anual() {
  echo "======================================"
  echo "Funcionalidad 3: Generar calendario anual"
  echo "Autor: Nasser Emil Issa Tavares"
  echo "======================================"

  # ---- Entradas ----
  read -p "Año a crear [$(date +%Y)]: " ANIO
  ANIO=${ANIO:-$(date +%Y)}

  read -p "Directorio base donde crear la estructura [$(pwd)]: " BASE_DIR
  BASE_DIR=${BASE_DIR:-$(pwd)}

  read -p "Nombres de las 7 subcarpetas por día (separados por coma) [1,2,3,4,5,6,7]: " SUBS_INPUT
  SUBS_INPUT=${SUBS_INPUT:-"1,2,3,4,5,6,7"}

  # ---- Preparación ----
  mkdir -p "${HOME}/backups"
  local REPORTE="${HOME}/backups/${GRUPO}-reporte-$(date +%F).txt"
  local DEST="${BASE_DIR}/${ANIO}"

  # helper de log: muestra en pantalla y agrega al reporte
  log(){ echo "[$(date +%T)] $*" | tee -a "$REPORTE"; }

  # Arreglar/recortar a 7 nombres
  IFS=',' read -r -a SUBS <<< "$SUBS_INPUT"
  while [ ${#SUBS[@]} -lt 7 ]; do SUBS+=("$(( ${#SUBS[@]} + 1 ))"); done
  if [ ${#SUBS[@]} -gt 7 ]; then SUBS=("${SUBS[@]:0:7}"); fi

  # Meses y días (ajusta Febrero si es bisiesto)
  local MESES=(Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre)
  local DIAS=(31 28 31 30 31 30 31 31 30 31 30 31)
  if (( (ANIO % 4 == 0 && ANIO % 100 != 0) || (ANIO % 400 == 0) )); then
    DIAS[1]=29
  fi

  log "===== INICIO generar_calendario_anual ====="
  log "Grupo: $GRUPO | Fecha completa: $FECHA"
  log "Base: $BASE_DIR | Año: $ANIO | Subcarpetas: ${SUBS[*]}"

  # Crear raíz del año
  mkdir -p "$DEST" || { log "ERROR creando $DEST"; return 1; }

  # Contadores
  local total_subs=0

  # Crear meses, días y subcarpetas
  for i in {0..11}; do
    local mnum mdir mdays
    mnum=$(printf "%02d" $((i+1)))
    mdir="${DEST}/${mnum}_${MESES[$i]}"
    mdays=${DIAS[$i]}
    mkdir -p "$mdir"

    for d in $(seq -w 1 "$mdays"); do
      local ddir="${mdir}/${d}"
      mkdir -p "$ddir"
      # 7 subcarpetas por día
      for idx in {0..6}; do
        # Evitar espacios en nombre de carpeta
        local sname=$(printf "%02d_%s" $((idx+1)) "${SUBS[$idx]// /_}")
        mkdir -p "${ddir}/${sname}"
        total_subs=$((total_subs+1))
      done
    done
  done

  # Métricas con tuberías
  local total_dirs total_dias
  total_dirs=$(find "$DEST" -type d | wc -l)                         # tubería
  total_dias=$(( DIAS[0]+DIAS[1]+DIAS[2]+DIAS[3]+DIAS[4]+DIAS[5]+DIAS[6]+DIAS[7]+DIAS[8]+DIAS[9]+DIAS[10]+DIAS[11] ))

  log "Días del año: $total_dias"
  log "Subcarpetas creadas (días x 7): $total_subs"
  log "Carpetas totales (año+meses+días+subcarpetas): $total_dirs"

  # Guardar estructura visual a archivo (tree si existe; si no, fallback con find)
  local ARBOL="${DEST}/estructura_${ANIO}.txt"
  if command -v tree >/dev/null 2>&1; then
    tree "$DEST" | tee "$ARBOL" >> "$REPORTE"
  else
    find "$DEST" -type d | sed "s|$BASE_DIR/||" | tee "$ARBOL" >> "$REPORTE"
  fi
  log "Estructura guardada en: $ARBOL"
  log "===== FIN generar_calendario_anual ====="

  echo
  echo "Listo:"
  echo "  - Ruta: $DEST"
  echo "  - Reporte: $REPORTE"
  echo "  - Estructura: $ARBOL"
}
