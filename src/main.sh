#!/bin/bash

# PROYECTO FINAL – SCRIPT GRUPAL
# Curso: Sistemas Operativos | Grupo: El grupo anterior
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
  
  # Creamos un archivo temporal para procesmiento
  temp_file=$(mktemp)
  
  find "$directorio" -type f -size +100M -exec ls -lh {} + 2>/dev/null | while read -r permisos enlaces usuario grupo tamano mes dia hora archivo; do
    echo "Tamaño: $tamano | Archivo: $archivo"
  done > "$temp_file"
  
  if [ -s "$temp_file" ]; then
    echo "========================================" > "$salida"
    echo "ARCHIVOS MAYORES A 100MB" >> "$salida"
    echo "Directorio buscado: $directorio" >> "$salida"
    echo "Fecha de búsqueda: $FECHA" >> "$salida"
    echo "========================================" >> "$salida"
    echo "" >> "$salida"
    
    cat "$temp_file" >> "$salida"
    
    # Contamos el número de archivos encontrados
    num_archivos=$(wc -l < "$temp_file")
    echo "" >> "$salida"
    echo "========================================" >> "$salida"
    echo "Total de archivos encontrados: $num_archivos" >> "$salida"
    
    echo "Se encontraron $num_archivos archivos mayores a 100MB."
  else
    echo "No se encontraron archivos mayores a 100MB en el directorio especificado." > "$salida"
    echo "No se encontraron archivos mayores a 100MB."
  fi
  
  # Eliminamos el archivo temporal
  rm -f "$temp_file"
  
  echo "Resultados guardados en: $salida"
  echo
}

# ==========================================
# Nasser Emil Issa Tavares
# Funcionalidad 3: generar_calendario_anual
# Crea automáticamente la estructura de un año con sus meses, días y 7 subcarpetas por día, 
# ajustando años bisiestos y guardando un reporte con métricas y el árbol de directorios.
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
  read -p "Ruta carpeta Destino: " destiny_path
  read -p "Dirección (1=Local→Destino, 2=Destino→Local): " direction
  read -p "¿Modo simulación? (s/n): " dry_mode

  mkdir -p "$local_path" "$destiny_path"

  flags="-avh"
  if [[ "$dry_mode" =~ ^[sS]$ ]]; then
    flags="$flags --dry-run"
    echo "Modo simulación activado: No se harán cambios reales."
  fi

  if [ "$direction" = "1" ]; then
    echo "➡️  Sincronizando de LOCAL → DESTINO"
    rsync $flags "$local_path"/ "$destiny_path"/
  elif [ "$direction" = "2" ]; then
    echo "⬅️  Sincronizando de DESTINO → LOCAL"
    rsync $flags "$destiny_path"/ "$local_path"/
  else
    echo "Opción inválida."
    exit 1
  fi

  fecha=$(date +"%Y-%m-%d")
  hora=$(date +"%H:%M:%S")
  reporte="El_Grupo_Anterior-${fecha}.txt"

  echo "DEBUG: fecha='$fecha', hora='$hora', local_path='$local_path', destiny_path='$destiny_path', direction='$direction', dry_mode='$dry_mode'"

  {
    echo "======================================"
    echo "REPORTE DE SINCRONIZACIÓN - El Grupo Anterior"
    echo "Fecha: $fecha"
    echo "Hora: $hora"
    echo "Local: $local_path"
    echo "Destino: $destiny_path"
    if [ "$direction" = "1" ]; then
      echo "Dirección: LOCAL → DESTINO"
    else
      echo "Dirección: DESTINO → LOCAL"
    fi
    if [[ "$dry_mode" =~ ^[sS]$ ]]; then
      echo "Modo: Simulación"
    else
      echo "Modo: Ejecución real"
    fi
    echo "Estado: ✅ Sincronización ejecutada correctamente"
    echo "======================================"
  } > "$reporte"

  echo "📄 Reporte generado: $reporte"
}


# =============================================================================
# Funcionalidad 5: Limpieza de Archivos Antiguos.
# Autor: Katherine Langumás
# Descripción: Limpia archivos con más de 30 días de antigüedad en un directorio.
# =============================================================================
limpieza_archivos_antiguos() {
# Define el directorio por defecto y la antigüedad de los archivos a eliminar.
DEFAULT_DIR="/tmp"
DAYS_TO_DELETE=30

# Define el directorio donde se guardarán los reportes.
REPORT_DIR="{HOME}/backups/"
# Define la ruta del reporte con el nombre del grupo, fecha y hora.
REPORT_PATH="${REPORT_DIR}/${GRUPO}-reporte-$(date +%F_%H-%M-%S).txt"

# Muestra la cabecera de la funcionalidad en la terminal.
echo "================================================="
echo "Funcionalidad 5 - Limpieza de Archivos Antiguos"
echo "Creado por: Katherine Langumás"
echo "Descripción: Limpia archivos con más de $DAYS_TO_DELETE días de antigüedad."
echo "Ruta de ejecución: $(pwd)"
echo "================================================="
echo "El reporte de la ejecución se guardará en: $REPORT_PATH"

# Función interna para buscar y eliminar archivos.
function cleanup_directory() {
    local target_dir=$1
   
    # Escribe el encabezado del reporte.
    echo "==========================================" > "$REPORT_PATH"
    echo "Reporte de Limpieza - $(date)" >> "$REPORT_PATH"
    echo "Directorio analizado: '$target_dir'" >> "$REPORT_PATH"
    echo "------------------------------------------" >> "$REPORT_PATH"

    # Verifica si el directorio existe y registra el resultado en el reporte.
    if [ ! -d "$target_dir" ]; then
        echo "Error: El directorio '$target_dir' no existe." | tee -a "$REPORT_PATH"
        return 1
    fi
   
    # Registra el inicio del proceso en el reporte.
    echo "Iniciando la búsqueda y eliminación de archivos." | tee -a "$REPORT_PATH"
    echo "Buscando archivos con más de $DAYS_TO_DELETE días..." | tee -a "$REPORT_PATH"
   
    # Ejecuta el comando find y registra la lista de archivos eliminados en el reporte.
    find "$target_dir" -type f -mtime "+$DAYS_TO_DELETE" -delete -print >> "$REPORT_PATH" 2>> "$REPORT_PATH"
   
    # Registra el fin del proceso en el reporte.
    echo "Proceso de eliminación completado." | tee -a "$REPORT_PATH"
   
    # Muestra un mensaje final en pantalla.
    echo "Proceso completado. Revisa el reporte para más detalles."
    return 0
}

# Muestra el menú de opciones para la interacción.
echo "--- Menú de Opciones ---"
echo "1) Limpiar directorio por defecto ($DEFAULT_DIR)"
echo "2) Ingresar ruta personalizada"
echo "3) Volver al menú principal"

# Lee la elección del usuario y ejecuta la acción correspondiente.
read -p "Ingresa tu elección (1, 2 o 3): " choice

case $choice in
    1)
        cleanup_directory "$DEFAULT_DIR"
        ;;
    2)
        read -p "Ingresa la ruta del directorio a limpiar: " custom_dir
        cleanup_directory "$custom_dir"
        ;;
    3)
        echo "Volviendo al menú principal."
        ;;
    *)
        echo "Opción no válida. Volviendo al menú principal."
        ;;
esac
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
      0) exit 0 ;;
      *) echo "Elija una opción válida." ;;
    esac
  done
fi