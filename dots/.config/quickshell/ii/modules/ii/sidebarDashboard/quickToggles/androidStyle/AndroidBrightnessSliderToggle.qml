import QtQuick
import Quickshell
import qs.services

AndroidSliderWidgetBase {
    id: root

    property var screen: root.QsWindow.window?.screen
    property var brightnessMonitor: Brightness.getMonitorForScreen(screen)

    tooltipText: Translation.tr("Brightness")
    materialSymbol: "brightness_6"
    sliderValue: brightnessMonitor?.brightness ?? 0
    onMoved: function(value) {
        brightnessMonitor?.setBrightness(value);
    }
}
