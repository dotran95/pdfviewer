//
//  PDFTextAnnotation.swift
//  PdfViewer
//
//  Created by VTIT on 17/9/24.
//

import PDFKit

class Annotation: PDFAnnotation {

    var borderColor: UIColor = .blue
    var borderWidth: CGFloat = 1.0
    var circleRadius: CGFloat = 3
    var selected: Bool = false

    var contentInset: UIEdgeInsets = .init(top: 5, left: 12, bottom: 5, right: 12)
    
    var horizontalPadding : CGFloat {
        return contentInset.left + contentInset.right
    }
    var verizontalPadding : CGFloat {
        return contentInset.top + contentInset.bottom
    }

    var scaleFactor: CGFloat = 1

    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        super.draw(with: box, in: context)

        if selected {
            context.setStrokeColor(borderColor.cgColor)
            context.setLineWidth(borderWidth)
            let borderRect = self.bounds.insetBy(dx: circleRadius, dy: circleRadius)

            context.stroke(borderRect)

            drawCircle(at: CGPoint(x: self.bounds.minX, y: self.bounds.midY - circleRadius), in: context)
            drawCircle(at: CGPoint(x: self.bounds.maxX - 2 * circleRadius, y: self.bounds.midY - circleRadius), in: context)
        }
    }

    func drawCircle(at point: CGPoint, in context: CGContext) {
        context.setFillColor(borderColor.cgColor) // Circle color
        context.addEllipse(in: CGRect(x: point.x , y: point.y , width: circleRadius * 2, height: circleRadius * 2))
        context.fillPath()
    }

    var resizeLeadingBounds: CGRect {
        let point = CGPoint(x: bounds.origin.x - 2 * circleRadius, y: bounds.origin.y)
        return CGRect(origin: point, size: .init(width: circleRadius * 4, height: bounds.height))
    }

    var resizeTrailingBounds: CGRect {
        let point = CGPoint(x: bounds.maxX - circleRadius * 2, y: bounds.origin.y)
        return CGRect(origin: point, size: .init(width: circleRadius * 4, height: bounds.height))
    }

    func resizeLeading(_ translation: CGPoint) {
        let newWidth = bounds.width - translation.x
        let centerPoint = CGPoint(x: bounds.midX + translation.x * 0.5, y: bounds.midY)
        calculateBounds(centerPoint, width: newWidth)
    }

    func resizeTrailing(_ translation: CGPoint) {
        let newWidth = bounds.width + translation.x
        let centerPoint = CGPoint(x: bounds.midX + translation.x * 0.5, y: bounds.midY)
        calculateBounds(centerPoint, width: newWidth)
    }
    
    func move(_ translation: CGPoint) {
        bounds = bounds.offsetBy(dx: translation.x, dy: -translation.y)
    }

    func calculateBounds(_ centerPoint: CGPoint, width: CGFloat = .zero) {}
}

class PDFTextAnnotation: Annotation {
    
    var attributedString: NSAttributedString? {
        guard let text = contents, let font = font, let fontColor = fontColor else {
            return nil
        }
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: fontColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        return NSMutableAttributedString(string: text, attributes: attributes)
    }
    
    init(bounds: CGRect) {
        super.init(bounds: bounds, forType: .widget, withProperties: nil)
        color = .clear
    }
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        super.draw(with: box, in: context)
        guard let attributedString = attributedString else { return }
        
        let necessarySize = attributedString.size()
        
        let widthForText = bounds.width - horizontalPadding
        let sizeForText: CGSize = getTextSize(width: max(widthForText, .zero))

        let maxWidth = sizeForText.width
        
        let textBounds: CGRect
        
        if necessarySize.width < maxWidth {
            let x = bounds.minX + (bounds.width - necessarySize.width) / 2
            let y = bounds.minY + (bounds.height - necessarySize.height) / 2
            textBounds = CGRect(origin: CGPoint(x: x, y: y), size: necessarySize)
        } else {
            let origin = CGPoint(x: bounds.minX +  contentInset.left,
                                 y: bounds.minY + contentInset.top)
            textBounds = CGRect(origin: origin, size: sizeForText)
        }
        
        context.saveGState()
        
        if let pagebounds = page?.bounds(for: .cropBox) {
            context.translateBy(x: 0, y: pagebounds.height)
            context.scaleBy(x: 1.0, y: -1.0)
            UIGraphicsPushContext(context)
            attributedString.draw(in: CGRect(x: textBounds.origin.x,
                                             y: pagebounds.maxY - textBounds.origin.y - textBounds.height,
                                             width: textBounds.width,
                                             height: textBounds.height))
            UIGraphicsPopContext()
        }
        context.restoreGState()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func calculateBounds(_ centerPoint: CGPoint, width: CGFloat = .zero) {
        let widthForText = width - horizontalPadding
        let sizeForText: CGSize = getTextSize(width: max(widthForText, .zero))
        
        print(sizeForText, centerPoint)
        
        let sizeForAnnotaion = CGSize(width: sizeForText.width + horizontalPadding,
                                      height: sizeForText.height + verizontalPadding)
        
        let newOrigin: CGPoint = CGPoint(x: centerPoint.x - sizeForAnnotaion.width / 2,
                                         y: centerPoint.y - sizeForAnnotaion.height / 2)
        
        bounds = CGRect(origin: newOrigin, size: sizeForAnnotaion)
    }
    
    private func getTextSize(width: CGFloat = .zero) -> CGSize {
        guard let attributedString = attributedString else { return .zero }
        if width > 0 {
            let heightForText = attributedString.height(withConstrainedWidth: width)
            return CGSize(width: width, height: heightForText)
        } else {
            return attributedString.size()
        }

    }
}
