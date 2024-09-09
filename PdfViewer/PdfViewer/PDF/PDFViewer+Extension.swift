//
//  PDFViewer+Extemsiom.swift
//  PdfViewer
//
//  Created by dotn on 11/9/24.
//

import Foundation

extension CGRect {
    func scale(_ scaleFactor: CGFloat) -> CGRect {
        return CGRect(origin: origin.scale(scaleFactor), size: size.scale(scaleFactor))
    }

    static func * (point: CGRect, value: CGFloat) -> CGRect {
        return CGRect(origin: point.origin * value, size: point.size * value)
    }

    static func * (value: CGFloat, point: CGRect) -> CGRect { point * value }

    static func + (point: CGRect, value: CGFloat) -> CGRect {
        return CGRect(origin: point.origin + value, size: point.size + value)
    }

    static func + (value: CGFloat, point: CGRect) -> CGRect { point + value}


    static func / (point: CGRect, value: CGFloat) -> CGRect {
        return CGRect(origin: point.origin / value, size: point.size / value)
    }

    static func / (value: CGFloat, point: CGRect) -> CGRect { point / value }
}

extension CGPoint {
    func scale(_ scaleFactor: CGFloat) -> CGPoint {
        return CGPoint(x: x * scaleFactor, y: y * scaleFactor)
    }

    static func + (point: CGPoint, value: CGFloat) -> CGPoint {
        return CGPoint(x: point.x + value, y: point.y + value)
    }

    static func + (value: CGFloat, point: CGPoint) -> CGPoint { point + value }

    static func * (point: CGPoint, value: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * value, y: point.y * value)
    }

    static func * (value: CGFloat, point: CGPoint) -> CGPoint { point * value }

    static func / (point: CGPoint, value: CGFloat) -> CGPoint {
        return CGPoint(x: point.x / value, y: point.y / value)
    }

    static func / (value: CGFloat, point: CGPoint) -> CGPoint { point / value }

}

extension CGSize {
    func scale(_ scaleFactor: CGFloat) -> CGSize {
        return CGSize(width: width * scaleFactor, height: height * scaleFactor)
    }

    func toPoint() -> CGPoint {
        return CGPoint(x: width, y: height)
    }

    static func + (point: CGSize, value: CGFloat) -> CGSize {
        return CGSize(width: point.width + value, height: point.height + value)
    }

    static func + (value: CGFloat, point: CGSize) -> CGSize { point + value }

    static func * (point: CGSize, value: CGFloat) -> CGSize {
        return CGSize(width: point.width * value, height: point.height * value)
    }

    static func * (value: CGFloat, point: CGSize) -> CGSize { point * value }

    static func / (point: CGSize, value: CGFloat) -> CGSize {
        return CGSize(width: point.width / value, height: point.height / value)
    }

    static func / (value: CGFloat, point: CGSize) -> CGSize { point / value }

}
