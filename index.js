import { NativeModules, Platform } from 'react-native';

let RNColorThief;

if (Platform.OS === 'web') {
    const ColorThief = require('@pioug/colorthief');

    RNColorThief = {
        getColor: async (imgElement, quality = 10, ignoreWhite = false) => {
            const colorThief = new ColorThief();
            const [r, g, b] = await colorThief.getColor(imgElement, quality, ignoreWhite);
            return { r, g, b };
        },
        getPalette: async (imgElement, colorCount = 10, quality = 10, ignoreWhite = false) => {
            const colorThief = new ColorThief();
            const palette = await colorThief.getPalette(imgElement, colorCount, quality, ignoreWhite);
            return palette.map(([r, g, b]) => ({ r, g, b }));
        },
    };
} else {
    const { RNColorThief: NativeColorThief } = NativeModules;

    RNColorThief = {
        getColor: async (source, quality = 10, ignoreWhite = false) => {
            const color = await NativeColorThief.getColor(source, quality, ignoreWhite);
            return color;
        },
        getPalette: async (source, colorCount = 10, quality = 10, ignoreWhite = false) => {
            const palette = await NativeColorThief.getPalette(source, colorCount, quality, ignoreWhite);
            return palette;
        },
    };
}

export default RNColorThief;
