//
//  PDFTextAnnotation.swift
//  PdfViewer
//
//  Created by VTIT on 17/9/24.
//

import PDFKit

class Annotation: PDFAnnotation {

    private var borderColor: UIColor = .blue
    private var borderWidth: CGFloat = 1.0
    private var circleRadius: CGFloat = 6
    var selected: Bool = false

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

    private func drawCircle(at point: CGPoint, in context: CGContext) {
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
        bounds = CGRect(x: bounds.origin.x + translation.x,
                        y: bounds.origin.y,
                        width: bounds.width - translation.x,
                        height: bounds.height)
    }

    func resizeTrailing(_ translation: CGPoint) {
        bounds = CGRect(x: bounds.origin.x,
                        y: bounds.origin.y,
                        width: bounds.width + translation.x,
                        height: bounds.height)
    }

    func move(_ translation: CGPoint) {
        bounds = bounds.offsetBy(dx: translation.x, dy: -translation.y)
    }
}

class TextAnnotation: Annotation {
    
    static let kFont = UIFont.systemFont(ofSize: 50)
    static let kColor = UIColor.black
    static let kBackground = UIColor.clear

    init(bounds: CGRect) {
        super.init(bounds: bounds, forType: PDFAnnotationSubtype(rawValue: PDFAnnotationSubtype.freeText.rawValue), withProperties: nil)
        config()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }

    private func config() {
        alignment = .center
        backgroundColor = UIColor.clear
        color = UIColor.clear
        fontColor = UIColor.black
        interiorColor = .clear
    }
}
