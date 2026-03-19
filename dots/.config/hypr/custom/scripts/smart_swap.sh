#!/bin/bash

# Script para intercambiar ventanas de forma inteligente en Hyprland (v3).
# Este script captura la salida estándar (stdout) de hyprctl y reacciona
# si la salida no es "ok", lo que indica un fallo.

DIRECTION=$1

if [ -z "$DIRECTION" ]; then
    echo "Uso: $0 <l|r|u|d>"
    exit 1
fi

# Ejecuta el comando y captura su salida estándar.
# Redirigimos stderr a /dev/null por si acaso.
OUTPUT=$(hyprctl dispatch swapwindow "$DIRECTION" 2>/dev/null)

# Comprueba si la salida NO es la cadena "ok".
# El trim de espacios es por si hyprctl añade saltos de línea.
if [[ "$(echo -n "$OUTPUT" | tr -d '[:space:]')" != "ok" ]]; then
    # El swap por defecto falló. Verificamos si fue un intento de swap horizontal.
    case "$DIRECTION" in
        l)
            # Si el swap a la izquierda falló, usamos 'swapnext'.
            hyprctl dispatch layoutmsg swapnext
            ;;
        r)
            # Si el swap a la derecha falló, usamos 'swapprev'.
            hyprctl dispatch layoutmsg swapprev
            ;;
        *)
            # Para fallos con 'u' o 'd', no hacemos nada.
            ;;
    esac
fi
