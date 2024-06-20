import Foundation
import UIKit

@objc(RNColorThief)
public class RNColorThief: NSObject {
    public static let defaultColorCount = 5

    private let defaultQuality = 10
    private let defaultIgnoreWhite = true

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
    public func getColor(_ source: String,
                         quality: Int = 10,
                         ignoreWhite: Bool = true,
                         resolve: @escaping RCTPromiseResolveBlock,
                         reject: @escaping RCTPromiseRejectBlock) {
        Task {
            guard let image = await getUIImage(from: source) else {
                reject("Error", "Error getting image", nil)
                return
            }

            guard let dominantColor = ColorThief.getColor(from: image, quality: quality, ignoreWhite: ignoreWhite) else {
                reject("Error", "Error getting dominant color", nil)
                return
            }

            resolve(self.getRGBDict(from: dominantColor))
        }
    }

    /**
      Use the median cut algorithm to cluster similar colors.
      - Parameters:
         - source: the image source
         - colorCount: the size of the palette; the number of colors returned.
                       defaults to 5. The actual size of array may be smaller to align with the original Java version.
         - quality: 1 is the highest quality settings. 10 is the default. There is
                    a trade-off between quality and speed. The bigger the number,
                    the faster the palette generation but the greater the
                    likelihood that colors will be missed.
         - ignoreWhite: if true, white pixels are ignored
      - Returns: Promise: resolves array of rgba color strings
     */
    @objc
    public func getPalette(_ source: String,
                           colorCount: Int = defaultColorCount,
                           quality: Int = 10,
                           ignoreWhite: Bool = true,
                           resolve: @escaping RCTPromiseResolveBlock,
                           reject: @escaping RCTPromiseRejectBlock) {
        Task {
            guard let image = await getUIImage(from: source) else {
                reject("Error", "Error getting image", nil)
                return
            }

            guard let palette = ColorThief.getPalette(from: image, colorCount: colorCount, quality: quality, ignoreWhite: ignoreWhite) else {
                reject("Error", "Error getting palette", nil)
                return
            }

            resolve(palette.map { self.getRGBDict(from: $0) })
        }
    }

    /**
     ========================
     Private Methods
     ========================
     */
    private func getUIImage(from path: String) async -> UIImage? {
        guard let endcodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let imageURL = URL(string: endcodedPath) else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            let image = UIImage(data: data)
            return image
        } catch {
            return nil
        }
    }

    private func getRGBA(from color: MMCQ.Color) -> String {
        "rgba(\(color.r),\(color.g),\(color.b),1.0)"
    }

    private func getRGBDict(from color: MMCQ.Color) -> [String: UInt8] {
        ["r": color.r, "g": color.g, "b": color.b]
    }

    /**
     ========================
     React Native
     ========================
     */
    @objc static func requiresMainQueueSetup() -> Bool {
        true
    }
}
