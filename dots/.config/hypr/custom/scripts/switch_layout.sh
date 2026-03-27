#!/usr/bin/env bash

# This script changes the Hyprland layout for the current workspace and dynamically updates 
# the workspace rule for a centered single window on this workspace.

LAYOUT=$1

if [ -z "$LAYOUT" ]; then
    echo "Usage: $0 <layout_name>"
    echo "Example: $0 dwindle"
    exit 1
fi

# 1. Get the current workspace name
WS_NAME=$(hyprctl activeworkspace -j | jq -r '.name')

# 2. Update the layout for the current workspace persistently
# Using name:$WS_NAME ensures it applies specifically to this workspace.
# We apply this FIRST to override any generic defaults.
hyprctl keyword workspace "name:$WS_NAME, layout:$LAYOUT"

# 3. Update the centering rule specifically for the current workspace
# Selector: name:$WS_NAME w[t1]f[-1] targets this workspace when it has exactly 1 tiled window.

if [ "$LAYOUT" == "dwindle" ]; then
    # Apply centering rule for dwindle layout on this workspace
    hyprctl keyword workspace "name:$WS_NAME w[t1]f[-1], gapsout:5 1360 5 1360"
else
    # For other layouts, reset to standard gaps for this workspace.
    # Setting it to 5 5 5 5 (the default gaps_out) effectively "unsets" it.
    hyprctl keyword workspace "name:$WS_NAME w[t1]f[-1], gapsout:5 5 5 5"
fi

# 4. Immediately apply layout for CURRENT workspace to existing windows
hyprctl dispatch layoutmsg setlayout "$LAYOUT"
