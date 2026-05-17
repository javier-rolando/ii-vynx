#!/usr/bin/env bash

# Script para intercambiar ventanas de forma inteligente en Hyprland (v3).
# Este script captura la salida estándar (stdout) de hyprctl y reacciona
# si la salida no es "ok", lo que indica un fallo.

DIRECTION=$1

if [ -z "$DIRECTION" ]; then
    echo "Uso: $0 <l|r|u|d>"
    exit 1
fi

# Ejecuta el swap en Lua. Si falla (swap returns falsy), hace fallback con layoutmsg.
hyprctl eval "
local ok = hl.dispatch(hl.dsp.window.swap({ direction = '$DIRECTION' }))
if not ok then
    if '$DIRECTION' == 'l' then
        hl.dispatch(hl.dsp.layout('swapnext'))
    elseif '$DIRECTION' == 'r' then
        hl.dispatch(hl.dsp.layout('swapprev'))
    end
end
"
