#!/bin/bash

# Get active window information in JSON format
ACTIVE_WINDOW_INFO=$(hyprctl activewindow -j)

# Check if the window is floating
IS_FLOATING=$(echo "$ACTIVE_WINDOW_INFO" | jq -r '.floating')

if [ "$IS_FLOATING" = "false" ]; then
  # It's a tiled window, so make it floating, resize, center and dim around
  # hyprctl --batch "dispatch togglefloating; dispatch resizeactive exact 80% 80%; dispatch centerwindow; keyword decoration:dim_around 0.4"
  hyprctl --batch "dispatch togglefloating; dispatch resizeactive exact 80% 80%; dispatch centerwindow"
else
  # It's a floating window, so just toggle it back to tiled and remove dim
  hyprctl dispatch togglefloating
fi
