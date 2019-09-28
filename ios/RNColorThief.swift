/*
 RNColorThief.swift
 RNColorThiefSwift

 Created by Brian DeWeese on 07/29/2019
 Copyright © 2019 Likewise, Inc

 License
 -------
 MIT License

 Thanks
 ------
 Kazuki Ohara - for ColorThiefSwift
 https://github.com/yamoridon/ColorThiefSwift
 Lokesh Dhakar - for the original Color Thief JavaScript version
 http://lokeshdhakar.com/projects/color-thief/
 Sven Woltmann - for the fast Java Implementation
 https://github.com/SvenWoltmann/color-thief-java

 **/

import UIKit
import Foundation

@objc(RNColorThief)
public class RNColorThief : NSObject {

    public static let defaultColorCount = 5

    /**
     ========================
     Public Methods
     ========================
     */

    /**
    Use the median cut algorithm to cluster similar colors and return the
     base color from the largest cluster.
     - Parameters:
        - source: the image source
        - quality:  1 is the highest quality settings. 10 is the default. There is
                    a trade-off between quality and speed. The bigger the number,
                    the faster a color will be returned but the greater the
                    likelihood that it will not be the visually most dominant color.
        - ignoreWhite: if true, white pixels are ignored
    - Returns: Promise: resolves dominant rgba color string
     */

    @objc
    public func getColor(_ source: String, quality: Int = ColorThief.defaultQuality, ignoreWhite: Bool = ColorThief.defaultIgnoreWhite, width: Int = 0, height: Int = 0, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        guard let image = RNColorThief.getUIImage(from: source, width: width, height: height) else {
            return reject("Error getting image", nil, nil);
        }

        guard let dominantColor = ColorThief.getColor(from: image, quality: quality, ignoreWhite: ignoreWhite) else {
             return reject("Error getting dominantColor", nil, nil)
        }

        let colorDict = RNColorThief.getRGBDict(from: dominantColor);
        //print(colorString)

        resolve(colorDict);
    }


    /**
     Use the median cut algorithm to cluster similar colors.
     - Parameters:
        - source: the image source
        - colorCount:   the size of the palette; the number of colors returned.
                        defaults to 5, *the actual size of array becomes smaller than this.
                        this is intended to align with the original Java version.*
        - quality:  1 is the highest quality settings. 10 is the default. There is
                    a trade-off between quality and speed. The bigger the number,
                    the faster the palette generation but the greater the
                    likelihood that colors will be missed.
        - ignoreWhite: if true, white pixels are ignored
     - Returns: Promise: resolves array rgba color strings
    */
    @objc
    func getPalette(_ source:String, colorCount: Int = defaultColorCount, quality: Int = ColorThief.defaultQuality, ignoreWhite: Bool = ColorThief.defaultIgnoreWhite, width: Int = 0, height: Int = 0, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {

        guard let image = RNColorThief.getUIImage(from: source, width: width, height: height) else {
            return reject("Error getting image", nil, nil);
        }

        guard let palette = ColorThief.getPalette(from: image, colorCount: colorCount, quality: quality, ignoreWhite: ignoreWhite) else {
            return reject("Error getting palette", nil, nil);
        }

        resolve(palette.map{RNColorThief.getRGBDict(from: $0)})
    }

    /**
     ========================
     Private Methods
     ========================
     */
    static private func getUIImage(from path:String, width:Int, height: Int) -> UIImage? {
        let image:UIImage;

        if (path.starts(with: "data:image")) {
            let temp = path.components(separatedBy: ",");
            let dataDecoded : Data = Data(base64Encoded: temp[1], options: .ignoreUnknownCharacters)!;
            image = UIImage(data: dataDecoded)!;
        } else {
            guard let imageURL = NSURL.init(string:path) else {
                return nil;
            }

            guard let imageData = NSData.init(contentsOf: imageURL as URL) else {
                return nil;
            }

            image = UIImage.init(data: imageData as Data)!;
        }

        if (width == 0 && height == 0) {
            return image;
        }

        let cgImage = image.cgImage!;
        let _width: Int;
        let _height: Int;

        if (width == 0) {
            _width = cgImage.width;
        } else {
            _width = width;
        }

        if (height == 0) {
            _height = cgImage.height;
        } else {
            _height = height;
        }

        let croppedCGImage = cgImage.cropping(to:
            CGRect(x: 0, y: 0, width: _width, height: _height)
        );

        return UIImage(cgImage: croppedCGImage!)
    }

    static private func getRGBA(from color: MMCQ.Color) -> String {
        return "rgba(\(color.r),\(color.g),\(color.b),1.0)"
    }

    static private func getRGBDict(from color: MMCQ.Color) -> Dictionary<String,UInt8> {
        return ["r": color.r, "g": color.g, "b": color.b];
    }


    /**
     ========================
     React Native
     ========================
     */
    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }

}
