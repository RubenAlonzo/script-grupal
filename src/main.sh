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
  echo "  - Miembro 2–5:  Funcionalidades pendientes"
  echo "======================================="
  echo
}

# Función para comparar cambios: Git o diff
comparar_cambios() {
  echo "-- COMPARAR CAMBIOS --"
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
    echo " 2) Funcionalidad 2"
    echo " 3) Funcionalidad 3"
    echo " 4) Funcionalidad 4"
    echo " 5) Funcionalidad 5"
    echo " 0) Salir"
    read -p "Opción [0-5]: " opt

    case "$opt" in
      1) comparar_cambios ;;
      2|3|4|5) func_pendiente ;;
      0) echo "¡Hasta luego!"; exit 0 ;;
      *) echo "Elija una opción válida." ;;
    esac
  done
fi
