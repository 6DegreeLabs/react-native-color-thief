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

import java.net.URL;
import java.io.IOException;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

public class RNColorThief {

    public static int[] getColor(String imageUrl) {
        Bitmap sourceImage = RNColorThief.retrieveImageFromUrl(imageUrl);
        if (sourceImage == null) {
            return null;
        }

		return ColorThief.getColor(sourceImage);
    }

    public static int[] getColor(String imageUrl, int quality, boolean ignoreWhite) {
        Bitmap sourceImage = RNColorThief.retrieveImageFromUrl(imageUrl);
        if (sourceImage == null) {
            return null;
        }

		return ColorThief.getColor(sourceImage, quality, ignoreWhite);
    }

    public static int[][] getPalette(String imageUrl, int colorCount) {
        Bitmap sourceImage = RNColorThief.retrieveImageFromUrl(imageUrl);
        if (sourceImage == null) {
            return null;
        }

		return ColorThief.getPalette(sourceImage, colorCount);
    }

    public static int[][] getPalette(
			String imageUrl,
            int colorCount,
            int quality,
            boolean ignoreWhite) {

		Bitmap sourceImage = RNColorThief.retrieveImageFromUrl(imageUrl);
        if (sourceImage == null) {
            return null;
        }

		return ColorThief.getPalette(sourceImage, colorCount, quality, ignoreWhite);
    }

    /**
     * Retrieve image source from remote url.
     *
     * @param imageUrl
     *          the image url
     *
     * @return the image as a Bitmap
     */
    private static Bitmap retrieveImageFromUrl(String imageUrl) {
        if ((imageUrl instanceof String) == false) {
            System.out.println("Must pass a String for the imageUrl.");
            return null;
        }

        if (imageUrl.startsWith("data:image")) {
            String base64Image = imageUrl.split(",")[1];

            byte[] decodedString = Base64.decode(base64Image, Base64.DEFAULT);
            Bitmap image = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
            return image;
        }
        else {
            try {
                URL url = new URL(imageUrl);
                Bitmap image = BitmapFactory.decodeStream(url.openConnection().getInputStream());
                return image;
            } catch (IOException e) {
                System.out.println(e);
                return null;
            }
        }
    }
}