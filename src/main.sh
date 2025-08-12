#!/bin/bash

# PROYECTO FINAL – SCRIPT GRUPAL
# Curso: Sistemas Operativos | Grupo: Grupo1
# Integrantes:
#  • Ruben Alonzo – Comparación de cambios (Git/diff)
#  • Rafael Emilio Abreu – Encontrar archivos grandes
#  • Nasser Emil Issa Tavares – Generar calendario anual
#  • Bradhelyn Poueriet – Sincronizar carpetas
#  • Katherine Langumás - Limpiar archivos antiguos

GRUPO="Grupo-Anterior"
FECHA=$(date +%F_%H-%M-%S)
mkdir -p "${HOME}/backups"
REPORTE="${HOME}/backups/${GRUPO}-reporte-$(date +%F).txt"
log(){ echo "[$(date +%T)] $*" | tee -a "$REPORTE" >/dev/null; }

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
  echo "  - Bradhelyn Poueriet: Sincronizar carpetas"
  echo "  - Katherine Langumás: Limpiar archivos antiguos"
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

# ==========================================
# Nasser Emil Issa Tavares
# Funcionalidad 3: generar_calendario_anual
# Crea automáticamente la estructura de un año con sus meses, días y 7 subcarpetas por día, ajustando años bisiestos y guardando un reporte con métricas y el árbol de directorios.
# ==========================================
generar_calendario_anual() {
echo "======================================"
echo "Estudiante: Nasser Emil Issa Tavares"
echo "Descripción: Crea Año→Meses→Días→7 subcarpetas por día (ajusta bisiestos)."
echo "Directorio de ejecución: $(pwd)"
echo "======================================"
log "Inicio del proceso crear_calendario.sh en $(pwd)"

read -r -p "Año a crear [$(date +%Y)]: " year
[[ "$year" =~ ^[0-9]{4}$ ]] || year=$(date +%Y)

read -r -p "Directorio base [$(pwd)]: " base_dir
base_dir=${base_dir:-"$(pwd)"}

read -r -p "Nombres de las 7 subcarpetas por día (separadas por coma) [1,2,3,4,5,6,7]: " subs_input
subs_input=${subs_input:-"1,2,3,4,5,6,7"}

log "Parámetros -> Año: $year | Base: $base_dir | Subs: $subs_input"

# ===== Procesar nombres de subcarpetas =====
IFS=',' read -r -a SUBS <<< "$subs_input"
while [ ${#SUBS[@]} -lt 7 ]; do SUBS+=("$(( ${#SUBS[@]} + 1 ))"); done
[ ${#SUBS[@]} -gt 7 ] && SUBS=("${SUBS[@]:0:7}")

# ===== Meses y días (ajuste de bisiesto) =====
MESES=(Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre)
DIAS=(31 28 31 30 31 30 31 31 30 31 30 31)
if (( (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) )); then
  DIAS[1]=29
  BISIESTO="sí"
else
  BISIESTO="no"
fi
log "Año bisiesto: $BISIESTO"

# ===== Crear estructura =====
DEST="${base_dir}/${year}"
mkdir -p "$DEST" || { log "ERROR: No se pudo crear $DEST"; echo "Error creando $DEST"; exit 1; }

total_subs=0
for i in {0..11}; do
  mnum=$(printf "%02d" $((i+1)))
  mdir="${DEST}/${mnum}_${MESES[$i]}"
  mkdir -p "$mdir"

  for d in $(seq -w 1 "${DIAS[$i]}"); do
    ddir="${mdir}/${d}"
    mkdir -p "$ddir"
    for idx in {0..6}; do
      sname=$(printf "%02d_%s" $((idx+1)) "${SUBS[$idx]// /_}")
      mkdir -p "${ddir}/${sname}"
      total_subs=$((total_subs+1))
    done
  done
done
log "Estructura de directorios creada en: $DEST"

# ===== Métricas con tuberías y redirecciones =====
total_dirs=$(find "$DEST" -type d | wc -l)   # tubería: find | wc -l
total_dias=$(( DIAS[0]+DIAS[1]+DIAS[2]+DIAS[3]+DIAS[4]+DIAS[5]+DIAS[6]+DIAS[7]+DIAS[8]+DIAS[9]+DIAS[10]+DIAS[11] ))

log "Métricas -> Días: $total_dias | Subcarpetas (días x 7): $total_subs | Carpetas totales: $total_dirs"

# ===== Guardar árbol de la estructura (tree si existe; si no, find) =====
ARBOL="${DEST}/estructura_${year}.txt"
if command -v tree >/dev/null 2>&1; then
  tree "$DEST" | tee "$ARBOL" >> "$REPORTE"
else
  find "$DEST" -type d | sed "s|$base_dir/||" | tee "$ARBOL" >> "$REPORTE"
fi
log "Árbol de directorios guardado en: $ARBOL"

log "===== FIN crear_calendario.sh ====="

# ===== Resumen en pantalla =====
echo
echo "✅ Estructura creada en: $DEST"
echo "   - Días del año: $total_dias"
echo "   - Subcarpetas creadas (días x 7): $total_subs"
echo "   - Carpetas totales: $total_dirs"
echo "   - Archivo con la estructura: $ARBOL"
echo "   - Reporte del proceso: $REPORTE"
}

# ==========================================
# Funcionalidad 4: Sincronizar carpetas con rsync
# Autor: Bradhelyn Poueriet
# Permite sincronizar de LOCAL → REMOTO o REMOTO → LOCAL.
# Soporta modo simulación (--dry) y crea las carpetas si no existen.
# ==========================================
sincronizar_carpetas() {
  echo "======================================"
  echo "Funcionalidad 4: Sincronizar carpetas"
  echo "Autor: Bradhelyn Poueriet"
  echo "======================================"

read -p "Ruta carpeta LOCAL: " local_path
read -p "Ruta carpeta REMOTA: " remote_path
read -p "Dirección (1=Local→Remoto, 2=Remoto→Local): " direction

# Crear carpetas si no existen
mkdir -p "$local_path" "$remote_path"

flags="-avh --progress"

if [ "$direction" = "1" ]; then
  echo "➡️  Sincronizando de LOCAL → REMOTO..."
  rsync $flags "$local_path"/ "$remote_path"/
elif [ "$direction" = "2" ]; then
  echo "⬅️  Sincronizando de REMOTO → LOCAL..."
  rsync $flags "$remote_path"/ "$local_path"/
else
  echo "Opción inválida."
  exit 1
fi
}

# =============================================================================
# Funcionalidad 5: Limpieza de Archivos Antiguos.
# Autor: Katherine Langumás
# Descripción: Este script ofrece un menú interactivo para limpiar archivos que tengan más de 30 días en un directorio específico.
#              Permite elegir entre una ruta por defecto o una personalizada.
# =============================================================================
limpieza_archivos_antiguos() {
  DEFAULT_DIR="/tmp"
  DAYS_TO_DELETE=30

  # Mostrar información inicial
  echo "================================================="
  echo "Funcionalidad 5 - Limpieza de Archivos Antiguos"
  echo "Creado por: Katherine Langumás"
  echo "================================================="

  function cleanup_directory() {
    local target_dir=$1
    if [ ! -d "$target_dir" ]; then
      echo "Error: El directorio '$target_dir' no existe."
      return 1
    fi
    echo "Eliminando archivos > $DAYS_TO_DELETE días en '$target_dir'..."
    find "$target_dir" -type f -mtime "+$DAYS_TO_DELETE" -delete 2>/dev/null
    echo "Proceso completado."
    return 0
  }

  echo "--- Menú de Opciones ---"
  echo "1) Limpiar directorio por defecto ($DEFAULT_DIR)"
  echo "2) Ingresar ruta personalizada"
  echo "3) Volver al menú principal"

  while true; do
    read -p "Elija opción: " choice
    case $choice in
      1)
        cleanup_directory "$DEFAULT_DIR"
        break
        ;;
      2)
        read -p "Ingrese la ruta: " custom_dir
        cleanup_directory "$custom_dir"
        break
        ;;
      3)
        echo "Volviendo al menú principal."
        break
        ;;
      *)
        echo "Opción no válida. Intente de nuevo."
        ;;
    esac
  done
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
    echo " 4) Sincronizar carpetas"
    echo " 5) Limpieza de archivos antiguos"
    echo " 0) Salir"
    read -p "Opción [0-5]: " opt

    case "$opt" in
      1) comparar_cambios ;;
      2) encontrar_archivos_grandes ;;
      3) generar_calendario_anual ;;
      4) sincronizar_carpetas ;;
      5) limpieza_archivos_antiguos ;;
      *) echo "Elija una opción válida." ;;
    esac
  done
fi