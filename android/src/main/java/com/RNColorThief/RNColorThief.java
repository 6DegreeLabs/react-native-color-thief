/*
 * React Native Color Thief
 * Created by Jimin Cutrell on 08/06/2019
 * Copyright © 2019 Likewise, Inc
 *
 * License
 * -------
 * Creative Commons Attribution 2.5 License:
 * http://creativecommons.org/licenses/by/2.5/
 *
 * Thanks
 * ------
 * Lokesh Dhakar - for the original Color Thief JavaScript version
 * available at http://lokeshdhakar.com/projects/color-thief/
 *
 * Sven Woltmann - for the fast Java Implementation of Color Thief
 * available at https://github.com/SvenWoltmann/color-thief-java
 */

package com.RNColorThief;

import android.graphics.Bitmap;
import java.util.Arrays;

import com.RNColorThief.MMCQ.CMap;

public class ColorThief {

    private static final int DEFAULT_QUALITY = 10;
    private static final boolean DEFAULT_IGNORE_WHITE = true;

    /**
     * Use the median cut algorithm to cluster similar colors and return the base color from the
     * largest cluster.
     *
     * @param sourceImage
     *            the source image
     *
     * @return the dominant color as RGB array
     */
    public static int[] getColor(Bitmap sourceImage) {
        int[][] palette = getPalette(sourceImage, 5);
        if (palette == null) {
            return null;
        }
        int[] dominantColor = palette[0];
        return dominantColor;
    }

    /**
     * Use the median cut algorithm to cluster similar colors and return the base color from the
     * largest cluster.
     *
     * @param sourceImage
     *            the source image
     * @param quality
     *            1 is the highest quality settings. 10 is the default. There is a trade-off between
     *            quality and speed. The bigger the number, the faster a color will be returned but
     *            the greater the likelihood that it will not be the visually most dominant color.
     * @param ignoreWhite
     *            if <code>true</code>, white pixels are ignored
     *
     * @return the dominant color as RGB array
     * @throws IllegalArgumentException
     *             if quality is &lt; 1
     */
    public static int[] getColor(Bitmap sourceImage, int quality, boolean ignoreWhite) {
        int[][] palette = getPalette(sourceImage, 5, quality, ignoreWhite);
        if (palette == null) {
            return null;
        }
        int[] dominantColor = palette[0];
        return dominantColor;
    }

    /**
     * Use the median cut algorithm to cluster similar colors.
     *
     * @param sourceImage
     *            the source image
     * @param colorCount
     *            the size of the palette; the number of colors returned
     *
     * @return the palette as array of RGB arrays
     */
    public static int[][] getPalette(Bitmap sourceImage, int colorCount) {
        CMap cmap = getColorMap(sourceImage, colorCount);
        if (cmap == null) {
            return null;
        }
        return cmap.palette();
    }

    /**
     * Use the median cut algorithm to cluster similar colors.
     *
     * @param sourceImage
     *            the source image
     * @param colorCount
     *            the size of the palette; the number of colors returned
     * @param quality
     *            1 is the highest quality settings. 10 is the default. There is a trade-off between
     *            quality and speed. The bigger the number, the faster the palette generation but
     *            the greater the likelihood that colors will be missed.
     * @param ignoreWhite
     *            if <code>true</code>, white pixels are ignored
     *
     * @return the palette as array of RGB arrays
     * @throws IllegalArgumentException
     *             if quality is &lt; 1
     */
    public static int[][] getPalette(
            Bitmap sourceImage,
            int colorCount,
            int quality,
            boolean ignoreWhite) {
        CMap cmap = getColorMap(sourceImage, colorCount, quality, ignoreWhite);
        if (cmap == null) {
            return null;
        }
        return cmap.palette();
    }

    /**
     * Use the median cut algorithm to cluster similar colors.
     *
     * @param sourceImage
     *            the source image
     * @param colorCount
     *            the size of the palette; the number of colors returned (minimum 2, maximum 256)
     *
     * @return the color map
     */
    public static CMap getColorMap(Bitmap sourceImage, int colorCount) {
        return getColorMap(sourceImage, colorCount, DEFAULT_QUALITY, DEFAULT_IGNORE_WHITE);
    }

    /**
     * Use the median cut algorithm to cluster similar colors.
     *
     * @param sourceImage
     *            the source image
     * @param colorCount
     *            the size of the palette; the number of colors returned (minimum 2, maximum 256)
     * @param quality
     *            1 is the highest quality settings. 10 is the default. There is a trade-off between
     *            quality and speed. The bigger the number, the faster the palette generation but
     *            the greater the likelihood that colors will be missed.
     * @param ignoreWhite
     *            if <code>true</code>, white pixels are ignored
     *
     * @return the color map
     * @throws IllegalArgumentException
     *             if quality is &lt; 1
     */
    public static CMap getColorMap(
            Bitmap sourceImage,
            int colorCount,
            int quality,
            boolean ignoreWhite) {
        if (colorCount < 2 || colorCount > 256) {
            throw new IllegalArgumentException("Specified colorCount must be between 2 and 256.");
        }
        if (quality < 1) {
            throw new IllegalArgumentException("Specified quality should be greater then 0.");
        }

        int[][] pixelArray = getPixels(sourceImage, quality, ignoreWhite);

        // Send array to quantize function which clusters values using median cut algorithm
        CMap cmap = MMCQ.quantize(pixelArray, colorCount);
        return cmap;
    }

    /**
     * Gets the image's pixels via Bitmap.getPixels(..).
     *
     * @param sourceImage
     *            the source image
     * @param quality
     *            1 is the highest quality settings. 10 is the default. There is a trade-off between
     *            quality and speed. The bigger the number, the faster the palette generation but
     *            the greater the likelihood that colors will be missed.
     * @param ignoreWhite
     *            if <code>true</code>, white pixels are ignored
     *
     * @return an array of pixels (each an RGB int array)
     */
    private static int[][] getPixels(
            Bitmap sourceImage,
            int quality,
            boolean ignoreWhite) {
        int width = sourceImage.getWidth();
        int height = sourceImage.getHeight();

        int pixelCount = width * height;

        // numRegardedPixels must be rounded up to avoid an ArrayIndexOutOfBoundsException if all
        // pixels are good.
        int numRegardedPixels = (pixelCount + quality - 1) / quality;

        int numUsedPixels = 0;

        int[][] res = new int[numRegardedPixels][];
        int r, g, b;

        int[] pixels = new int[pixelCount];
        sourceImage.getPixels(pixels, 0, width, 0, 0, width, height);

        for (int i = 0; i < pixelCount; i += quality) {
            int argb = pixels[i];

            r = (argb >> 16) & 0xFF;
            g = (argb >> 8) & 0xFF;
            b = (argb) & 0xFF;
            if (!(ignoreWhite && r > 250 && g > 250 && b > 250)) {
                res[numUsedPixels] = new int[] {r, g, b};
                numUsedPixels++;
            }
        }

        return Arrays.copyOfRange(res, 0, numUsedPixels);
    }

}