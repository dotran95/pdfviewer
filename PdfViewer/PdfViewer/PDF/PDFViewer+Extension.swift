//
//  PDFViewer+Extemsiom.swift
//  PdfViewer
//
//  Created by dotn on 11/9/24.
//

import UIKit
import PDFKit

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
    
    var center: CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }
}

extension CGPoint {
    func scale(_ scaleFactor: CGFloat) -> CGPoint {
        return CGPoint(x: x * scaleFactor, y: y * scaleFactor)
    }

    static func + (point: CGPoint, value: CGFloat) -> CGPoint {
        return CGPoint(x: point.x + value, y: point.y + value)
    }

    static func + (value: CGFloat, point: CGPoint) -> CGPoint { point + value }
    
    static func - (point: CGPoint, value: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - value.x, y: point.y - value.y)
    }

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

extension String{

    func sizeWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)

        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return boundingBox.size
    }

    func sizeWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return boundingBox.size
    }

    func sizeToFit(_ maxWidth: CGFloat, font: UIFont) -> CGSize {
        let size = sizeWithConstrainedHeight(font.pointSize, font: font)
        if size.width <= maxWidth {
            return size
        }

        return sizeWithConstrainedWidth(maxWidth, font: font)
    }

}

extension PDFView {
    func disableScroll(_ isDisable: Bool) {
        for subView in subviews {
            scrollDisable(subView, isDisable: isDisable)
        }
    }

    private func scrollDisable(_ target: UIView, isDisable: Bool) {
        if let scrollView = target as? UIScrollView {
            scrollView.isScrollEnabled = !isDisable
        }

        for subView in target.subviews {
            scrollDisable(subView, isDisable: isDisable)
        }
    }

    func convertBounds(_ annotaion: CGRect) -> CGRect {
        guard let pageBounds = currentPage?.bounds(for: .cropBox) else { return .zero }

        let newPageBounds = pageBounds * scaleFactor

        var newBounds = annotaion * scaleFactor

        newBounds.origin.y += (bounds.height - newPageBounds.height) / 2
        newBounds.origin.x += (bounds.width - newPageBounds.width) / 2
        newBounds.origin.y = bounds.maxY - newBounds.origin.y - newBounds.height

        return newBounds
    }


}

extension UIFont {
    func copyWith(fontSize: CGFloat) -> UIFont? {
        return UIFont.init(name: fontName, size: fontSize)
    }

    func copyWith(scale: CGFloat) -> UIFont? {
        return copyWith(fontSize: pointSize * scale)
    }
}

extension UITextView {
    static func calculateContentSize(for text: String, 
                                     with font: UIFont,
                                     maxWidth: CGFloat) -> CGSize {
        let textView = UITextView()
        textView.text = text
        textView.font = font
        textView.frame = CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        textView.isScrollEnabled = false
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.textContainerInset = .init(top: 3, left: 12, bottom: 6, right: 12)
        // Force the textView to layout its content to get the correct contentSize
        textView.sizeToFit()
        
        return textView.contentSize
    }
}
