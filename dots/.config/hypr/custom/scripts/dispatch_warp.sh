#!/usr/bin/env bash

# Script para ejecutar un dispatcher de Hyprland desactivando temporalmente cursor:no_warps
# Creado en el Laboratorio de Gadgets del Futuro.

# Si no se proporcionan argumentos, muestra cómo usarlo y sale.
if [ "$#" -eq 0 ]; then
  echo "¡Debes proporcionar un comando para el dispatcher!"
  echo "Uso: $0 <dispatcher> <argumentos...>"
  echo "Ejemplo: $0 movefocus d"
  exit 1
fi

# ¡La secuencia de activación!
hyprctl keyword cursor:no_warps false
hyprctl dispatch "$@" # "$@" pasa TODOS los argumentos que le diste al script directamente a "dispatch"
hyprctl keyword cursor:no_warps true
