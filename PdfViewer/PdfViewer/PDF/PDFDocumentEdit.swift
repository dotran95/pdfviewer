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

class PDFDocumentEdit {

    weak var parent: PDFViewer?

    var pdfView: PDFView? {
        return parent?.pdfView
    }

    private let sidebarView: PDFDocumentSideBar

    var panTransition: PanAnnotationTransitionType = .none

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

    func addSideBarNavigation() {
        guard let parent = parent else { return }
        // Set up the sidebar
        parent.view.addSubview(sidebarView)

        // Configure constraints for the sidebarView
        sidebarView.snp.makeConstraints { make in
            make.top.equalTo(parent.pdfView).inset(12)
            make.right.equalTo(parent.pdfView).inset(12)
            make.width.equalTo(40)
        }
        sidebarView.delegate = parent

        addGestureRecognizers()
    }

    func removeSideBar() {
        sidebarView.removeFromSuperview()
        removeGestureRecognizers()
        removeCurrentSelectedAnnotation()
    }

    func addTextAnnotation() {
        guard let pdfView = pdfView, let page = pdfView.currentPage else { return }
        // Calculate the page's size
        let centerPoint = (pdfView.bounds.size / 2).toPoint()
        let pointInPage = pdfView.convert(centerPoint, to: page)

        let font = UIFont.systemFont(ofSize: 50)

        // Determine the centered position
        let textSize = CGSize(width: 130, height: 50 * 1.227)
        let x = pointInPage.x - textSize.width / 2
        let y: CGFloat = pointInPage.y - textSize.height / 2

        let annotationBounds = CGRect(origin: .init(x: x, y: y), size: textSize)

        // Create the text annotation
        let annotation = TextAnnotation(bounds: annotationBounds)
        annotation.font = font
        annotation.widgetStringValue = "Text"
        page.addAnnotation(annotation)
    }
}

extension PDFDocumentEdit {
    // MARK: - Private funcs
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
                    animateAnnotationToCenter(textAnnotation, onPage: currentPage)
                    return
                }
                return
            }
        }
        removeCurrentSelectedAnnotation()
    }

    @objc
    private func handlePan(_ gesture: PanGestureRecognizer) {
        print("panTransition")
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
        guard let pdfView = pdfView, let config = parent?.config else { return }
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

    func animateAnnotationToCenter(_ annotation: TextAnnotation, onPage page: PDFPage) {
        guard let pdfView = pdfView else { return }

        // Get the current annotation's position
        let currentBounds = annotation.bounds
        let currentpoint = currentBounds.origin
        let frame = pdfView.convert(annotation.bounds, from: page)

        print(frame, pdfView.bounds)

        let view = CustomTextFieldView(textFieldFrame: frame)
        view.backgroundColor = .black.withAlphaComponent(0)
        view.textField.text = annotation.widgetStringValue
        view.textField.textColor = annotation.fontColor
        view.textField.font = annotation.font
        parent?.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalTo(parent!.view)
        }

        UIView.animate(withDuration: 0.3) {
            view.backgroundColor = .black.withAlphaComponent(0.5)
            view.textField.frame = frame
        }
    }
}

class CustomTextFieldView: UIView {

    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter text here"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        textField.backgroundColor = .clear
        textField.layer.borderColor = UIColor.clear.cgColor
        return textField
    }()

    // Initializer
    init(textFieldFrame: CGRect) {
        super.init(frame: .zero)

        // Add the text field as a subview
        self.addSubview(textField)
        textField.frame = textFieldFrame

    }

    // Required initializer for using with Storyboard (if needed)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)

        // If the touch location is outside the textField bounds, remove the view
        if !textField.frame.contains(touchLocation) {
            self.removeFromSuperview()
        }
    }
}
