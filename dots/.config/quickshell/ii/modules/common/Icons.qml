pragma Singleton
import Quickshell
Singleton {
    id: root

    function getBluetoothDeviceMaterialSymbol(systemIconName: string): string {
        if (systemIconName.includes("headset") || systemIconName.includes("headphones"))
            return "headphones";
        if (systemIconName.includes("audio"))
            return "speaker";
        if (systemIconName.includes("phone"))
            return "smartphone";
        if (systemIconName.includes("mouse"))
            return "mouse";
        if (systemIconName.includes("keyboard"))
            return "keyboard";
        return "bluetooth";
    }

    function getWeatherIcon(code, iconCode: string): string {
        const id = Number(code);
        const isNight = iconCode ? iconCode.endsWith("n") : false;

        if (id === 800)
            return isNight ? "bedtime" : "sunny";

        if (id === 801)
            return isNight ? "partly_cloudy_night" : "partly_cloudy_day";


        if (id === 802)
            return isNight ? "partly_cloudy_night" : "partly_cloudy_day";


        if (id >= 803 && id <= 804)
            return "cloud";


        if (id >= 200 && id <= 232)
            return "thunderstorm";

        if (id >= 300 && id <= 321)
            return "grain"; 

        if (id >= 500 && id <= 504)
            return isNight ? "rainy" : "rainy";

        if (id === 511)
            return "weather_mix"; 

        if (id >= 520 && id <= 531)
            return "rainy";

        if (id >= 600 && id <= 622)
            return "ac_unit"; 

        if (id === 781)
            return "tornado";
        if (id === 762)
            return "volcano"; 
        if (id === 771)
            return "air"; 
        if (id >= 700 && id <= 781)
            return "foggy";

        return "cloud"; 
    }
}
