import { NativeModules } from 'react-native';
import { ColorObject } from '../types/colorobject';

const { RNColorThief: NativeColorThief } = NativeModules;

const RNColorThief = {
    getColor: async (source: string, quality = 10, ignoreWhite = false): Promise<ColorObject> => {
        return await NativeColorThief.getColor(source, quality, ignoreWhite);
    },
    getPalette: async (source: string, colorCount = 10, quality = 10, ignoreWhite = false): Promise<ColorObject[]> => {
        return await NativeColorThief.getPalette(source, colorCount, quality, ignoreWhite);
    },
};

export default RNColorThief;
