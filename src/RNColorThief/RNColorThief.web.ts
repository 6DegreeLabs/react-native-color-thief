import ColorThief from 'colorthief';
import { ColorObject } from '../types/colorobject';

const RNColorThief = {
    getColor: async (imgElement: HTMLImageElement, quality = 10, ignoreWhite = false): Promise<ColorObject> => {
        const colorThief = new ColorThief();
        const [r, g, b] = colorThief.getColor(imgElement, quality);
        return { r, g, b };
    },
    getPalette: async (imgElement: HTMLImageElement, colorCount = 10, quality = 10, ignoreWhite = false): Promise<ColorObject[]> => {
        const colorThief = new ColorThief();
        const palette = colorThief.getPalette(imgElement, colorCount, quality);
        return palette.map(([r, g, b]: [number, number, number]) => ({ r, g, b }));
    },
};

export default RNColorThief;
