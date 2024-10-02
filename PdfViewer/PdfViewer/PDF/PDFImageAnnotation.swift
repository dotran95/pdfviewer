//
//  PDFImageAnnotation.swift
//  PdfViewer
//
//  Created by VTIT on 2/10/24.
//

import PDFKit
import UIKit

class PDFImageAnnotation: Annotation {

    private var image: UIImage?

    init(image: UIImage?, properties: [AnyHashable: Any]?, rect: CGRect) {
        super.init(bounds: rect, forType: .widget, withProperties: properties)
        self.image = image
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        super.draw(with: box, in: context)
        guard let cgImage = image?.cgImage else { return }
        context.draw(cgImage, in: bounds)
    }

    override func resizeLeading(_ translation: CGPoint) {
        let newWidth = bounds.width - translation.x
        bounds = CGRect(x: bounds.origin.x + translation.x,
                        y: bounds.origin.y,
                        width: newWidth,
                        height: newWidth)
    }

    override func resizeTrailing(_ translation: CGPoint) {
        let newWidth = bounds.width + translation.x
        bounds = CGRect(x: bounds.origin.x,
                        y: bounds.origin.y,
                        width: newWidth,
                        height: newWidth)
    }

    override func resize() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let newHeight = calculateHeight(bounds.width) ?? bounds.height

        bounds = CGRect(x: center.x - newHeight / 2,
                        y: center.y - newHeight / 2,
                        width: newHeight,
                        height: newHeight)
    }

}
