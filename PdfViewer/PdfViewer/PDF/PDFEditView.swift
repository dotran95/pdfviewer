//
//  PDFDocumentEdit.swift
//  PdfViewer
//
//  Created by VTIT on 25/9/24.
//

import UIKit
import PDFKit
import SnapKit

enum PanAnnotationTransitionType {
    case move
    case resizeWidthLeading
    case resizeWidthTrailing
    case none
}

class PDFEditView {

    // MARK: - Constants and Computed
    private var colorPickerHeight: CGFloat = 300.0
    private var drawConfigureViewHeight: CGFloat = 100.0

    // MARK: - Elements
    weak var parent: PDFViewer?

    var pdfView: PDFView? {
        return parent?.pdfView
    }

    private let sidebarView: PDFDocumentSideBar

    private var panTransition: PanAnnotationTransitionType = .none

    lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        return tapGesture
    }()

    lazy var panGesture: PanGestureRecognizer = {
        let panGesture = PanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        return panGesture
    }()

    private var drawConfigureView : PDFDrawConfigurationView?


    var selectedAnnotation: Annotation?

    init(items: [PDFDocumentSideBarbuttons], parent: PDFViewer) {
        sidebarView = PDFDocumentSideBar(items)
        self.parent = parent
    }

    func showEditView() {
        guard let parent = parent else { return }
        // Set up the sidebar
        parent.view.addSubview(sidebarView)

        // Configure constraints for the sidebarView
        sidebarView.snp.makeConstraints { make in
            make.top.equalTo(parent.pdfView).inset(12)
            make.right.equalTo(parent.pdfView).inset(12)
            make.width.equalTo(60)
        }
        sidebarView.delegate = self

        addGestureRecognizers()
    }

    func removeSideBar() {
        sidebarView.removeFromSuperview()
        removeGestureRecognizers()
        removeSelectionAnnotation()
    }

    private func addGestureRecognizers() {
        guard let parent = parent else { return }
        // Add tap gesture recognizer to detect touches
        parent.pdfView.addGestureRecognizer(tapGesture)
        parent.pdfView.addGestureRecognizer(panGesture)
    }

    private func removeGestureRecognizers() {
        guard let parent = parent else { return }
        // remove tap gesture recognizer to detect touches
        parent.pdfView.removeGestureRecognizer(tapGesture)
        parent.pdfView.removeGestureRecognizer(panGesture)
    }

    @objc
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: pdfView)
        guard let pdfView = pdfView, let currentPage = pdfView.currentPage else { return }
        let pagePoint = pdfView.convert(location, to: currentPage)

        for annotation in currentPage.annotations {
            if let customAnnotation = annotation as? Annotation,
               customAnnotation.bounds.contains(pagePoint) {

                if selectedAnnotation?.hashValue != customAnnotation.hashValue {
                    setSelectiondAnnotation(customAnnotation)
                    return
                }
                if let textAnnotation = customAnnotation as? TextAnnotation {
                    showEditTextView(annotation: textAnnotation)
                    return
                }
                return
            }
        }
        removeSelectionAnnotation()
    }

    @objc
    private func handlePan(_ gesture: PanGestureRecognizer) {
        guard let pdfView = pdfView,
              let annotation = selectedAnnotation,
              let currentPage = pdfView.currentPage,
              let initialTouchLocation = gesture.initialTouchLocation else {
            return
        }

        let getTransitionType: (CGPoint) -> PanAnnotationTransitionType = { (point) in
            // Resize width of Annotation
            if annotation.resizeLeadingBounds.contains(point) {
                return .resizeWidthLeading
            } else if annotation.resizeTrailingBounds.contains(point) {
                return .resizeWidthTrailing
            } else if annotation.bounds.contains(point) {
                return PanAnnotationTransitionType.move
            }
            return PanAnnotationTransitionType.none
        }

        switch gesture.state {
        case .began:
            let pointInPage = pdfView.convert(initialTouchLocation, to: currentPage)
            panTransition = getTransitionType(pointInPage)
            break
        default:
            break
        }

        let translation = gesture.translation(in: gesture.view)
        switch panTransition {
        case .move:
            annotation.move(translation)
        case .resizeWidthLeading:
            annotation.resizeLeading(translation)
        case .resizeWidthTrailing:
            annotation.resizeTrailing(translation)
        case .none:
            removeSelectionAnnotation()
            return
        }

        gesture.setTranslation(.zero, in: gesture.view)
    }

}

// MARK: - PDFDocumentSideBarDelegate
extension PDFEditView: PDFDocumentSideBarDelegate {
    func onAddText(_ sender: UIButton) {
        addTextAnnotation()
    }
    
    func onAddSignature(_ sender: UIButton) {
        let vc = PDFSignatureVc()
        vc.delegate = self
        parent?.present(UINavigationController(rootViewController: vc), animated: true)
    }
}

// MARK: - Private funcs
extension PDFEditView {

    private func setSelectiondAnnotation(_ annotation: Annotation) {
        guard let pdfView = pdfView else { return }
        // Remove old annotation
        removeSelectionAnnotation()

        annotation.selected = true
        pdfView.currentPage?.addAnnotation(annotation)
        selectedAnnotation = annotation

        pdfView.disableScroll(true)
        pdfView.minScaleFactor = pdfView.scaleFactor
        pdfView.maxScaleFactor = pdfView.scaleFactor

        if annotation is PDFImageAnnotation {
            return
        }
        showDrawConfigView()
    }

    private func removeSelectionAnnotation() {
        guard let selecte = selectedAnnotation, let pdfView = pdfView, let config = parent?.config else { return }
        selecte.selected = false
        pdfView.currentPage?.addAnnotation(selecte)
        selectedAnnotation = nil
        pdfView.minScaleFactor = config.minScaleFactor
        pdfView.maxScaleFactor = config.maxScaleFactor
        pdfView.disableScroll(false)

        if drawConfigureView != nil {
            drawConfigureView?.willMove(toParent: nil)
            drawConfigureView?.view.removeFromSuperview()
            drawConfigureView?.removeFromParent()
            drawConfigureView = nil
        }
    }

    private func showDrawConfigView() {
        guard let parent = parent else { return }

        let drawVc = PDFDrawConfigurationView()
        drawVc.delegate = self
        parent.addChild(drawVc)
        parent.view.addSubview(drawVc.view)
        drawVc.view.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(parent.view)
            make.height.equalTo(drawConfigureViewHeight)
            make.bottom.equalTo(parent.view)
        }
        drawVc.didMove(toParent: parent)
        drawVc.type = selectedAnnotation is TextAnnotation ? .text:.none
        drawConfigureView = drawVc
    }
}

// MARK: - TextAnnotation
extension PDFEditView {
    private func addTextAnnotation() {
        guard let pdfView = pdfView, let page = pdfView.currentPage else { return }
        
        let centerPoint = page.bounds(for: .cropBox).center
        
        // Defaut fontsize of page is 20 when scaleFactor equa 1
        let font = TextAnnotation.kFont
        let maxWidth = pdfView.bounds.width
        
        // Determine the centered position
        let textSize: CGSize = TextAnnotation.calculateContentSize(for: "Text", with: font, maxWidth: maxWidth)

        let origin = centerPoint - (textSize / 2).toPoint()

        // Create the text annotation
        let annotation = TextAnnotation(bounds: .init(origin: origin, size: textSize))
        annotation.font = font
        annotation.contents = "Text"
        annotation.widgetStringValue = "Text"
        annotation.fontColor = TextAnnotation.kColor
        page.addAnnotation(annotation)

    }

    func showEditTextView(annotation: TextAnnotation) {
        guard let parent = parent, let pdfView = pdfView, let page = pdfView.currentPage else { return }

        // Get the current annotation's position
        let currentBounds = annotation.bounds
        let centerPoint = CGPoint(x: currentBounds.midX, y: currentBounds.midY)
        let pointInPDFView = pdfView.convertBounds(annotation.bounds)

        let editTextView = PDFEditTextView(annotationRect: CGRect(origin: pointInPDFView.origin, size: pointInPDFView.size / pdfView.scaleFactor))
        editTextView.textView.text = annotation.contents
        editTextView.textView.textColor = annotation.fontColor
        editTextView.textView.font = annotation.font
        editTextView.show(parent)

        page.removeAnnotation(annotation)
        editTextView.view.snp.makeConstraints { make in
            make.edges.equalTo(pdfView)
        }

        editTextView.onCompleted = { txtView in
            guard let text = txtView.text, let font = txtView.font else { return }
            annotation.contents = text
            annotation.widgetStringValue = text
            annotation.fontColor = txtView.textColor
            annotation.font = font
            
            let maxWidth = pdfView.bounds.width

            let newSize = TextAnnotation.calculateContentSize(for: text, with: font, maxWidth: maxWidth)
            let newCenter = centerPoint - newSize.toPoint() / 2
            annotation.bounds = .init(origin: newCenter, size: newSize)
            page.addAnnotation(annotation)
        }

    }
}

extension PDFEditView: PDFDrawConfigurationViewDelegate {
    func didSelectFont(_ font: UIFont) {
        if let textAnnotation = selectedAnnotation as? TextAnnotation {
            textAnnotation.font = font
            textAnnotation.resize()
            return
        }
    }

    func didSelectColor(_ color: UIColor) {
        if let textAnnotation = selectedAnnotation as? TextAnnotation {
            textAnnotation.fontColor = color
            return
        }
    }

    func currentFont() -> UIFont {
        return selectedAnnotation?.font ?? UIFont.systemFont(ofSize: 20)
    }

    func currentColor() -> UIColor {
        if let textAnnotation = selectedAnnotation as? TextAnnotation {
            return textAnnotation.fontColor ?? .black
        }
        return .black
    }
}

extension PDFEditView: PDFSignatureDelegate {
    func signature(_ signature: UIImage?) {
        guard let image = signature, let pdfView = pdfView, let page = pdfView.currentPage else { return }

        let centerPoint = page.bounds(for: .cropBox).center

        let size = CGSize(width: 150, height: 150)
        let origin = centerPoint - (size / 2).toPoint()

        let annotaion = PDFImageAnnotation(image: image, properties: nil, rect: CGRect(origin: origin, size: size))
        page.addAnnotation(annotaion)
    }
}
