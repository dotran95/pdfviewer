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
            make.width.equalTo(40)
        }
        sidebarView.delegate = self

        addGestureRecognizers()
    }

    func removeSideBar() {
        sidebarView.removeFromSuperview()
        removeGestureRecognizers()
        removeCurrentSelectedAnnotation()
    }

}

// MARK: - PDFDocumentSideBarDelegate
extension PDFEditView: PDFDocumentSideBarDelegate {

    func onClick(_ type: PDFDocumentSideBarbuttons) {
        switch type {
        case .text:
            addTextAnnotation()
            break
        default:
            break
        }
    }

}

// MARK: - Private funcs
extension PDFEditView {
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
                    setCurrentSelectedAnnotation(customAnnotation)
                    return
                }
                if let textAnnotation = customAnnotation as? TextAnnotation {
                    showEditTextView(annotation: textAnnotation)
                    return
                }
                return
            }
        }
        removeCurrentSelectedAnnotation()
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
            removeCurrentSelectedAnnotation()
            return
        }

        gesture.setTranslation(.zero, in: gesture.view)
    }

    private func setCurrentSelectedAnnotation(_ annotation: Annotation) {
        guard let pdfView = pdfView else { return }
        // Remove old annotation
        removeCurrentSelectedAnnotation()

        annotation.selected = true
        annotation.isReadOnly = false
        pdfView.currentPage?.addAnnotation(annotation)
        selectedAnnotation = annotation

        pdfView.disableScroll(true)
        pdfView.minScaleFactor = pdfView.scaleFactor
        pdfView.maxScaleFactor = pdfView.scaleFactor
    }

    private func removeCurrentSelectedAnnotation() {
        guard let selecte = selectedAnnotation, let pdfView = pdfView, let config = parent?.config else { return }
        selecte.selected = false
        pdfView.currentPage?.addAnnotation(selecte)
        selectedAnnotation = nil
        pdfView.minScaleFactor = config.minScaleFactor
        pdfView.maxScaleFactor = config.maxScaleFactor
        pdfView.disableScroll(false)
    }

}

extension PDFEditView {
    private func addTextAnnotation() {
        guard let pdfView = pdfView, let page = pdfView.currentPage else { return }
        // Calculate the page's size
        let centerPoint = (pdfView.bounds.size / 2).toPoint()
        let pointInPage = pdfView.convert(centerPoint, to: page)

        let font = UIFont.systemFont(ofSize: 50)

        // Determine the centered position
        let textSize = CGSize(width: 130, height: 50 * 1.227)
        let x = pointInPage.x - textSize.width / 2
        let y: CGFloat = pointInPage.y - textSize.height / 2

        // Create the text annotation
        let annotation = TextAnnotation(bounds: .zero)
        annotation.font = font
        annotation.contents = "Text"
        annotation.bounds = .init(origin: .init(x: x, y: y), size: annotation.calculateTextSize())
        page.addAnnotation(annotation)
    }

    func showEditTextView(annotation: TextAnnotation) {
        guard let parent = parent, let pdfView = pdfView, let page = pdfView.currentPage else { return }

        // Get the current annotation's position
        let currentBounds = annotation.bounds
        let scaleFactor = min(pdfView.scaleFactor, 1)

        let editTextView = PDFEditTextView(annotationRect: pdfView.convertBounds(annotation.bounds))
        editTextView.textView.text = annotation.contents
        editTextView.textView.textColor = annotation.fontColor
        editTextView.textView.font = annotation.font?.copyWith(scale: scaleFactor)
        editTextView.show(parent)

        page.removeAnnotation(annotation)
        editTextView.view.snp.makeConstraints { make in
            make.edges.equalTo(pdfView)
        }

        editTextView.onCompleted = { txtView in
            annotation.contents = txtView.text
            annotation.fontColor = txtView.textColor
            annotation.font = txtView.font

            txtView.sizeToFit()
            annotation.bounds = .init(origin: currentBounds.origin, size: (txtView.contentSize / pdfView.scaleFactor) + 12)
            page.addAnnotation(annotation)
        }

    }
}
