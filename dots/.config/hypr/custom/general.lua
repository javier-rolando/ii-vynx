-- Monitor
hl.monitor({
    output = "DP-2",
    mode = "5120x1440@144",
    position = "0x0",
    scale = "1"
})

hl.config({
    general = {
        border_size = 2,
        layout = "master"
    },
    input = {
        kb_layout = "latam",
        kb_options = "caps:swapescape",
        accel_profile = "flat"
    },
    dwindle = {
        special_scale_factor = 0.80
    },
    master = {
        mfact = 0.47142,
        orientation = "center",
        slave_count_for_center_master = 0,
        special_scale_factor = 0.80,
        smart_resizing = false
    },
    scrolling = {
        fullscreen_on_one_column = false,
        column_width = 0.47142,
        focus_fit_method = 0
    },
    cursor = {
        hide_on_key_press = true,
        no_warps = true
    },
    misc = {
        vrr = 0
    },
    animations = {
        enabled = true
    },
    decoration = {
        dim_inactive = false
    }
})

-- Theme colors (override upstream colors.lua)
hl.config({
    general = {
        col = {
            active_border   = "rgba(cac8adFF)",
            inactive_border = "rgba(48474455)",
        },
    },
    misc = {
        background_color = "rgba(141311FF)",
    },
    plugin = {
        hyprbars = {
            bar_text_font               = "Google Sans Flex Medium, Rubik, Geist, AR One Sans, Reddit Sans, Inter, Roboto, Ubuntu, Noto Sans, sans-serif",
            bar_height                  = 38,
            bar_padding                 = 10,
            bar_button_padding          = 12,
            bar_buttons_alignment       = "left",
            bar_text_size               = 12,
            bar_part_of_window          = true,
            bar_precedence_over_border  = true,
            bar_title_enabled           = false,
            bar_color                   = "rgba(141311FF)",
            ["col.text"]                = "rgba(e6e2ddFF)",
            on_double_click             = "hyprctl dispatch togglefloating",
        },
    },
})

-- Custom animation curves
hl.curve("expressiveFastSpatial",    { type = "bezier", points = {{0.42, 1.67}, {0.21, 0.90}} })
hl.curve("expressiveSlowSpatial",    { type = "bezier", points = {{0.39, 1.29}, {0.35, 0.98}} })
hl.curve("expressiveDefaultSpatial", { type = "bezier", points = {{0.38, 1.21}, {0.22, 1.00}} })
hl.curve("emphasizedDecel",          { type = "bezier", points = {{0.05, 0.7},  {0.1,  1}}    })
hl.curve("emphasizedAccel",          { type = "bezier", points = {{0.3,  0},    {0.8,  0.15}} })
hl.curve("standardDecel",            { type = "bezier", points = {{0,    0},    {0,    1}}    })
hl.curve("menu_decel",               { type = "bezier", points = {{0.1,  1},    {0,    1}}    })
hl.curve("menu_accel",               { type = "bezier", points = {{0.52, 0.03}, {0.72, 0.08}} })
hl.curve("specialWorkSwitch",        { type = "bezier", points = {{0.05, 0.7},  {0.1,  1}}    })
hl.curve("standard",                 { type = "bezier", points = {{0.2,  0},    {0,    1}}    })

hl.animation({ leaf = "windowsIn",          enabled = true,  speed = 2.5, bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsOut",         enabled = true,  speed = 1.5, bezier = "emphasizedAccel" })
hl.animation({ leaf = "windowsMove",        enabled = true,  speed = 3,   bezier = "standard" })
hl.animation({ leaf = "workspaces",         enabled = true,  speed = 3.5, bezier = "menu_decel",    style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true,  speed = 1.4, bezier = "emphasizedDecel", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut",enabled = true,  speed = 0.6, bezier = "emphasizedAccel", style = "slidevert" })
hl.animation({ leaf = "fade",               enabled = false, speed = 3,   bezier = "standard" })
hl.animation({ leaf = "fadeDim",            enabled = false, speed = 3,   bezier = "standard" })
hl.animation({ leaf = "border",             enabled = true,  speed = 2.5, bezier = "emphasizedDecel" })
