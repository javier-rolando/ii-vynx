hl.config({
    general = {
        col = {
            active_border   = "rgba({{colors.primary.default.hex_stripped}}FF)",
            inactive_border = "rgba({{colors.outline_variant.default.hex_stripped}}55)",
        },
    },
    misc = {
        background_color = "rgba({{colors.surface.dark.hex_stripped}}FF)",
    },
})

hl.window_rule({
    match        = { pin = 1 },
    border_color = "rgba({{colors.primary.default.hex_stripped}}AA) rgba({{colors.primary.default.hex_stripped}}77)",
})

hl.config({
    plugin = {
        hyprbars = {
            bar_color                  = "rgba({{colors.background.default.hex_stripped}}FF)",
            bar_height                 = 38,
            bar_padding                = 10,
            bar_text_font              = "Google Sans Flex Medium, Rubik, Geist, AR One Sans, Reddit Sans, Inter, Roboto, Ubuntu, Noto Sans, sans-serif",
            bar_button_padding         = 12,
            bar_buttons_alignment      = "left",
            bar_text_size              = 12,
            bar_part_of_window         = true,
            bar_precedence_over_border = true,
            bar_title_enabled          = false,
            ["col.text"]               = "rgba({{colors.on_background.default.hex_stripped}}FF)",
            on_double_click            = "hyprctl dispatch togglefloating",
        },
    },
})

hl.config({ plugin = { hyprbars = { ["hyprbars-button"] = "rgba({{colors.inverse_primary.default.hex_stripped}}FF), 15, , hyprctl dispatch killactive, rgb(000000)" } } })
hl.config({ plugin = { hyprbars = { ["hyprbars-button"] = "rgba({{colors.primary.default.hex_stripped}}FF), 15, , hyprctl dispatch fullscreen 1, rgb(000000)" } } })
hl.config({ plugin = { hyprbars = { ["hyprbars-button"] = "rgba({{colors.tertiary.default.hex_stripped}}FF), 15, , if [[ $(hyprctl activewindow -j | jq -r '.workspace.name | startswith(\"special\")') == true ]]; then hyprctl -q dispatch togglespecialworkspace $(hyprctl activewindow -j | jq -r '.workspace.name' | sed 's/^special://'); else hyprctl -q dispatch movetoworkspacesilent special; fi, rgb(000000)" } } })
