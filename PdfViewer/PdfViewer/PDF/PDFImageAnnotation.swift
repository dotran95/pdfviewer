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
        contentInset = .init(top: 30, left: 30, bottom: 30, right: 30)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        super.draw(with: box, in: context)
        guard let cgImage = image?.cgImage else { return }
        context.draw(cgImage, in: CGRect(x: bounds.origin.x + contentInset.left,
                                         y: bounds.origin.y + contentInset.top, 
                                         width: bounds.width - horizontalPadding,
                                         height: bounds.height - verizontalPadding))
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
}
