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
        let newWidth = bounds.width - translation.x
        let newHeight = calculateHeight(newWidth) ?? bounds.height
        bounds = CGRect(x: bounds.origin.x + translation.x,
                        y: bounds.origin.y,
                        width: newWidth,
                        height: newHeight)
    }

    func resizeTrailing(_ translation: CGPoint) {
        let newWidth = bounds.width + translation.x
        let newHeight = calculateHeight(newWidth) ?? bounds.height
        bounds = CGRect(x: bounds.origin.x,
                        y: bounds.origin.y,
                        width: newWidth,
                        height: newHeight)
    }

    func move(_ translation: CGPoint) {
        bounds = bounds.offsetBy(dx: translation.x, dy: -translation.y)
    }

    func calculateHeight(_ maxWidth: CGFloat) -> CGFloat? {
        return bounds.height
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

    override func calculateHeight(_ maxWidth: CGFloat) -> CGFloat? {
        guard let text = contents, let font = font else {
            return nil
        }
        let size = TextAnnotation.calculateContentSize(for: text,
                                                      with: font,
                                                      maxWidth: maxWidth)
        return size.height
    }

    static func calculateContentSize(for text: String,
                                     with font: UIFont,
                                     maxWidth: CGFloat) -> CGSize {
        let textView = UITextView()
        textView.text = text
        textView.font = font
        textView.frame = CGRect(x: 0, y: 0, width: maxWidth, height: 1000)
        textView.isScrollEnabled = false
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.textContainerInset = .zero
        // Force the textView to layout its content to get the correct contentSize
        textView.sizeToFit()

        return textView.contentSize
    }

}
