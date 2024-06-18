import Foundation
import UIKit

open class MMCQ {
    private static let signalBits = 5
    private static let rightShift = 8 - signalBits
    private static let multiplier = 1 << rightShift
    private static let histogramSize = 1 << (3 * signalBits)
    private static let vboxLength = 1 << signalBits
    private static let fractionByPopulation = 0.75
    private static let maxIterations = 1000

    static func makeColorIndexOf(red: Int, green: Int, blue: Int) -> Int {
        (red << (2 * signalBits)) + (green << signalBits) + blue
    }

    public struct Color {
        public var r: UInt8
        public var g: UInt8
        public var b: UInt8

        init(r: UInt8, g: UInt8, b: UInt8) {
            self.r = r
            self.g = g
            self.b = b
        }

        public func makeUIColor() -> UIColor {
            UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
        }
    }

    enum ColorChannel {
        case r, g, b
    }

    class VBox {
        var rMin: UInt8
        var rMax: UInt8
        var gMin: UInt8
        var gMax: UInt8
        var bMin: UInt8
        var bMax: UInt8

        let histogram: [Int]
        private var average: Color?
        private var volume: Int?
        private var count: Int?

        init(rMin: UInt8, rMax: UInt8, gMin: UInt8, gMax: UInt8, bMin: UInt8, bMax: UInt8, histogram: [Int]) {
            self.rMin = rMin
            self.rMax = rMax
            self.gMin = gMin
            self.gMax = gMax
            self.bMin = bMin
            self.bMax = bMax
            self.histogram = histogram
        }

        func rRange() -> CountableRange<Int> { Int(rMin) ..< Int(rMax + 1) }
        func gRange() -> CountableRange<Int> { Int(gMin) ..< Int(gMax + 1) }
        func bRange() -> CountableRange<Int> { Int(bMin) ..< Int(bMax + 1) }

        func getVolume(forceRecalculate: Bool = false) -> Int {
            if let volume, !forceRecalculate {
                return volume
            }
            let volume = (Int(rMax) - Int(rMin) + 1) * (Int(gMax) - Int(gMin) + 1) * (Int(bMax) - Int(bMin) + 1)
            self.volume = volume
            return volume
        }

        func getCount(forceRecalculate: Bool = false) -> Int {
            if let count, !forceRecalculate {
                return count
            }
            let count = rRange().reduce(0) { acc, r in
                acc + gRange().reduce(0) { acc, g in
                    acc + bRange().reduce(0) { acc, b in
                        acc + histogram[MMCQ.makeColorIndexOf(red: r, green: g, blue: b)]
                    }
                }
            }
            self.count = count
            return count
        }

        func getAverage(forceRecalculate: Bool = false) -> Color {
            if let average, !forceRecalculate {
                return average
            }
            var ntot = 0
            var rSum = 0, gSum = 0, bSum = 0

            for r in rRange() {
                for g in gRange() {
                    for b in bRange() {
                        let index = MMCQ.makeColorIndexOf(red: r, green: g, blue: b)
                        let hval = histogram[index]
                        ntot += hval
                        rSum += Int(Double(hval) * (Double(r) + 0.5) * Double(MMCQ.multiplier))
                        gSum += Int(Double(hval) * (Double(g) + 0.5) * Double(MMCQ.multiplier))
                        bSum += Int(Double(hval) * (Double(b) + 0.5) * Double(MMCQ.multiplier))
                    }
                }
            }

            let average = if ntot > 0 {
                Color(r: UInt8(rSum / ntot), g: UInt8(gSum / ntot), b: UInt8(bSum / ntot))
            } else {
                Color(r: UInt8(min(MMCQ.multiplier * (Int(rMin) + Int(rMax) + 1) / 2, 255)),
                      g: UInt8(min(MMCQ.multiplier * (Int(gMin) + Int(gMax) + 1) / 2, 255)),
                      b: UInt8(min(MMCQ.multiplier * (Int(bMin) + Int(bMax) + 1) / 2, 255)))
            }

            self.average = average
            return average
        }

        func widestColorChannel() -> ColorChannel {
            let rWidth = rMax - rMin
            let gWidth = gMax - gMin
            let bWidth = bMax - bMin
            return [rWidth, gWidth, bWidth].max() == rWidth ? .r : gWidth == bWidth ? .g : .b
        }
    }

    open class ColorMap {
        var vboxes = [VBox]()

        func push(_ vbox: VBox) {
            vboxes.append(vbox)
        }

        open func makePalette() -> [Color] {
            vboxes.map { $0.getAverage() }
        }

        open func makeNearestColor(to color: Color) -> Color {
            var nearestColor = Color(r: 0, g: 0, b: 0)
            var nearestDistance = Int.max

            for vbox in vboxes {
                let vbColor = vbox.getAverage()
                let distance = abs(Int(color.r) - Int(vbColor.r)) +
                    abs(Int(color.g) - Int(vbColor.g)) +
                    abs(Int(color.b) - Int(vbColor.b))

                if distance < nearestDistance {
                    nearestDistance = distance
                    nearestColor = vbColor
                }
            }

            return nearestColor
        }
    }

    private static func makeHistogramAndVBox(from pixels: [UInt8], quality: Int, ignoreWhite: Bool) -> ([Int], VBox) {
        var histogram = [Int](repeating: 0, count: histogramSize)
        var rMin = UInt8.max, rMax = UInt8.min
        var gMin = UInt8.max, gMax = UInt8.min
        var bMin = UInt8.max, bMax = UInt8.min

        let pixelCount = pixels.count / 4
        for i in stride(from: 0, to: pixelCount, by: quality) {
            let a = pixels[i * 4]
            let r = pixels[i * 4 + 1]
            let g = pixels[i * 4 + 2]
            let b = pixels[i * 4 + 3]

            guard a >= 125, !(ignoreWhite && r > 250 && g > 250 && b > 250) else {
                continue
            }

            let shiftedR = r >> UInt8(rightShift)
            let shiftedG = g >> UInt8(rightShift)
            let shiftedB = b >> UInt8(rightShift)

            rMin = min(rMin, shiftedR)
            rMax = max(rMax, shiftedR)
            gMin = min(gMin, shiftedG)
            gMax = max(gMax, shiftedG)
            bMin = min(bMin, shiftedB)
            bMax = max(bMax, shiftedB)

            histogram[MMCQ.makeColorIndexOf(red: Int(shiftedR), green: Int(shiftedG), blue: Int(shiftedB))] += 1
        }

        return (histogram, VBox(rMin: rMin, rMax: rMax, gMin: gMin, gMax: gMax, bMin: bMin, bMax: bMax, histogram: histogram))
    }

    private static func applyMedianCut(with histogram: [Int], vbox: VBox) -> [VBox] {
        guard vbox.getCount() > 1 else {
            return vbox.getCount() == 0 ? [] : [vbox]
        }

        var total = 0
        var partialSum = [Int](repeating: -1, count: vboxLength)
        let axis = vbox.widestColorChannel()

        switch axis {
        case .r:
            for r in vbox.rRange() {
                total += accumulateHistogram(r, vbox: vbox, axis: .r, histogram: histogram); partialSum[r - Int(vbox.rMin)] = total
            }
        case .g:
            for g in vbox.gRange() {
                total += accumulateHistogram(g, vbox: vbox, axis: .g, histogram: histogram); partialSum[g - Int(vbox.gMin)] = total
            }
        case .b:
            for b in vbox.bRange() {
                total += accumulateHistogram(b, vbox: vbox, axis: .b, histogram: histogram); partialSum[b - Int(vbox.bMin)] = total
            }
        }

        let splitPoint = findSplitPoint(partialSum: partialSum, total: total)
        let (leftBox, rightBox) = splitVBox(vbox: vbox, splitPoint: UInt8(splitPoint), axis: axis)

        return [leftBox, rightBox]
    }

    private static func accumulateHistogram(_ value: Int, vbox: VBox, axis: ColorChannel, histogram: [Int]) -> Int {
        vbox.gRange().reduce(0) { acc, g in
            acc + vbox.bRange().reduce(0) { acc, b in
                let index: Int = switch axis {
                case .r: MMCQ.makeColorIndexOf(red: value, green: g, blue: b)
                case .g: MMCQ.makeColorIndexOf(red: value, green: value, blue: b)
                case .b: MMCQ.makeColorIndexOf(red: value, green: g, blue: value)
                }
                return acc + histogram[index]
            }
        }
    }

    private static func findSplitPoint(partialSum: [Int], total: Int) -> Int {
        for i in 0 ..< partialSum.count {
            if partialSum[i] > total / 2 {
                return i
            }
        }
        return partialSum.count - 1
    }

    private static func splitVBox(vbox: VBox, splitPoint: UInt8, axis: ColorChannel) -> (VBox, VBox) {
        let leftBox: VBox, rightBox: VBox

        switch axis {
        case .r:
            leftBox = VBox(rMin: vbox.rMin, rMax: UInt8(vbox.rMin + splitPoint), gMin: vbox.gMin, gMax: vbox.gMax, bMin: vbox.bMin, bMax: vbox.bMax, histogram: vbox.histogram)
            rightBox = VBox(rMin: UInt8(vbox.rMin + splitPoint + 1), rMax: vbox.rMax, gMin: vbox.gMin, gMax: vbox.gMax, bMin: vbox.bMin, bMax: vbox.bMax, histogram: vbox.histogram)
        case .g:
            leftBox = VBox(rMin: vbox.rMin, rMax: vbox.rMax, gMin: vbox.gMin, gMax: UInt8(vbox.gMin + splitPoint), bMin: vbox.bMin, bMax: vbox.bMax, histogram: vbox.histogram)
            rightBox = VBox(rMin: vbox.rMin, rMax: vbox.rMax, gMin: UInt8(vbox.gMin + splitPoint + 1), gMax: vbox.gMax, bMin: vbox.bMin, bMax: vbox.bMax, histogram: vbox.histogram)
        case .b:
            leftBox = VBox(rMin: vbox.rMin, rMax: vbox.rMax, gMin: vbox.gMin, gMax: vbox.gMax, bMin: vbox.bMin, bMax: UInt8(vbox.bMin + splitPoint), histogram: vbox.histogram)
            rightBox = VBox(rMin: vbox.rMin, rMax: vbox.rMax, gMin: vbox.gMin, gMax: vbox.gMax, bMin: UInt8(vbox.bMin + splitPoint + 1), bMax: vbox.bMax, histogram: vbox.histogram)
        }

        return (leftBox, rightBox)
    }

    public static func quantize(pixels: [UInt8], colorCount: Int, quality: Int = 10, ignoreWhite: Bool = true) -> MMCQ.ColorMap {
        var (histogram, initialVBox) = makeHistogramAndVBox(from: pixels, quality: quality, ignoreWhite: ignoreWhite)
        var vboxPriorityQueue: [VBox] = [initialVBox]

        while vboxPriorityQueue.count < colorCount {
            vboxPriorityQueue.sort { $0.getVolume() > $1.getVolume() }
            guard let vbox = vboxPriorityQueue.popLast() else { break }
            vboxPriorityQueue.append(contentsOf: applyMedianCut(with: histogram, vbox: vbox))
        }

        let colorMap = ColorMap()
        vboxPriorityQueue.forEach { colorMap.push($0) }

        return colorMap
    }
}
