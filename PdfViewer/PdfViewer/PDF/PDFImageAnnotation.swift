//
//  PDFImage.swift
//  PdfViewer
//
//  Created by dotn on 11/9/24.
//

import PDFKit

class PDFImageAnnotation: PDFAnnotation {

    private var image: UIImage?

    init(_ attributedString: NSAttributedString, properties: [AnyHashable: Any]?, rect: CGRect, transform: CGAffineTransform? = nil) {
        super.init(bounds: rect, forType: .stamp, withProperties: properties)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        image = renderer.image { context in
            attributedString.draw(in: CGRect(origin: .zero, size: rect.size))
        }
    }

    init(image: UIImage?, properties: [AnyHashable: Any]?, rect: CGRect) {
        super.init(bounds: rect, forType: .stamp, withProperties: properties)
        self.image = image
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        guard let cgImage = image?.cgImage else { return }
        context.draw(cgImage, in: bounds)
    }
}
