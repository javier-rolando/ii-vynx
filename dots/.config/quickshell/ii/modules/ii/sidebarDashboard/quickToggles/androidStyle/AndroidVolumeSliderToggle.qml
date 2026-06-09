import QtQuick
import Quickshell
import qs.services

AndroidSliderWidgetBase {
    id: root

    tooltipText: Translation.tr("Volume")
    materialSymbol: "volume_up"
    sliderValue: (Audio.sink && Audio.sink.audio) ? Audio.sink.audio.volume : 0
    onMoved: function(value) {
        if (Audio.sink && Audio.sink.audio) {
            Audio.sink.audio.volume = value;
        }
    }
}
