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
