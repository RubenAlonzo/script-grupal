#!/bin/bash

# PROYECTO FINAL – SCRIPT GRUPAL
# Curso: Sistemas Operativos | Grupo: Grupo1
# Integrantes:
#  • Ruben Alonzo – Comparación de cambios (Git/diff)
#  • Miembro 2 – Func. 2 (pendiente)
#  • Miembro 3 – Func. 3 (pendiente)
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
    echo " 3) Funcionalidad 3"
    echo " 4) Funcionalidad 4"
    echo " 5) Funcionalidad 5"
    echo " 0) Salir"
    read -p "Opción [0-5]: " opt

    case "$opt" in
      1) comparar_cambios ;;
      2) encontrar_archivos_grandes ;;
      3|4|5) func_pendiente ;;
      0) echo "¡Hasta luego!"; exit 0 ;;
      *) echo "Elija una opción válida." ;;
    esac
  done
fi
