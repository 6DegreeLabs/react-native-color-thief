export interface ColorObject {
    r: number;
    g: number;
    b: number;
}

export function getColor(source: string, quality: number, ignoreWhite: boolean): Promise<ColorObject>;
export function getPalette(source: string, colorCount: number, quality: number, ignoreWhite: boolean): Promise<ColorObject[]>;
