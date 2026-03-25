import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common.models.hyprland
import qs.services

QuickToggleModel {
    id: root
    name: Translation.tr("Game mode")
    toggled: !confOpt.value
    icon: "gamepad"

    mainAction: () => {
        root.toggled = !root.toggled;
        if (root.toggled) {
            // HyprlandConfig.setMany({
            //     "animations:enabled": 0,
            //     "decoration:shadow:enabled": 0,
            //     "decoration:blur:enabled": 0,
            //     "general:gaps_in": 0,
            //     "general:gaps_out": 0,
            //     "general:border_size": 1,
            //     "decoration:rounding": 0,
            //     "general:allow_tearing": 1
            // });

            Quickshell.execDetached(["bash", "-c", `hyprctl --batch "keyword animations:enabled 0; keyword decoration:shadow:enabled 0; keyword decoration:blur:enabled 0; keyword general:gaps_in 0; keyword general:gaps_out 0; keyword general:border_size 1; keyword decoration:rounding 0; keyword general:allow_tearing 1; keyword input:kb_options ''"; warp-cli disconnect`])
        } else {
            // HyprlandConfig.resetMany([ //
            //     "animations:enabled", //
            //     "decoration:shadow:enabled", //
            //     "decoration:blur:enabled", //
            //     "general:gaps_in", //
            //     "general:gaps_out", //
            //     "general:border_size", //
            //     "decoration:rounding", //
            //     "general:allow_tearing", //
            // ]);

            Quickshell.execDetached(["bash", "-c", "hyprctl reload; warp-cli connect"])
        }
    }

    HyprlandConfigOption {
        id: confOpt
        key: "animations:enabled"
    }

    tooltipText: Translation.tr("Game mode")
}