//
//  DrawConfigurationView.swift
//  PdfViewer
//
//  Created by VTIT on 27/9/24.
//

import UIKit

protocol PDFDrawConfigurationViewDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
    func didSelectFont(_ font: UIFont)
    func currentFont() -> UIFont
    func currentColor() -> UIColor

}

enum PDFDrawConfigurationButton: Int {
    case settingOptions = 0
    case blackColor
    case blueColor
    case greenColor
    case yellowColor
    case redColor
    case pickerColor
    case annotations

    var color: UIColor {
        switch self {
        case .blackColor:
            return .black
        case .redColor:
            return  UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
        case .greenColor:
            return UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
        case .yellowColor:
            return UIColor(red: 236/255, green: 112/255, blue: 28/255, alpha: 1.0)
        case .blueColor:
            return UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        case .settingOptions:
            return UIColor.lightGray
        default:
            return .clear
        }
    }
}

enum PDFDrawAnnotationType {
    case text
    case none
}

class PDFDrawConfigurationView: UIViewController {

    // MARK: - Constants and Computed

    private let buttonWidth: CGFloat = 30

    private let buttons: [PDFDrawConfigurationButton] = [
        .settingOptions,
        .blackColor,
        .blueColor,
        .greenColor,
        .yellowColor,
        .redColor,
        .pickerColor
    ]

    private let backgroundViewColor: UIColor = .white

    // MARK: - UIElements
    private var container: UIStackView!

    weak var delegate: PDFDrawConfigurationViewDelegate?

    var type: PDFDrawAnnotationType = .none

    // MARK: - Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
    }

    private func setupInitialState() {
        view.backgroundColor = backgroundViewColor

        container = UIStackView(arrangedSubviews: buttons.map({ createButton($0) }))
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 10 // Space between views

        view.addSubview(container)

        container.snp.makeConstraints { make in
            make.top.equalTo(view).inset(20)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }

    }

    private func createButton(_ type: PDFDrawConfigurationButton) -> UIButton {
        let button = type == .pickerColor ? RainBowButton(type: .system) : UIButton(type: .system)
        button.layer.cornerRadius = buttonWidth / 2
        button.layer.masksToBounds = true

        button.snp.makeConstraints { make in
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonWidth)
        }
        button.backgroundColor = type.color

        switch type {
        case .settingOptions:
            button.setTitle("Aa", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17)
            break
        case .pickerColor:
            break
        default:
            break
        }

        button.addTarget(self, action: #selector(clickToDrawButton(_:)), for: .touchUpInside)
        button.tag = type.rawValue
        return button
    }

    @objc
    private func clickToDrawButton(_ sender: UIButton) {
        guard let type = PDFDrawConfigurationButton(rawValue: sender.tag) else { return }
        switch type {
        case .annotations:
            break
        case .settingOptions:
            showTextSettingPopover(sender)
            break
        case .pickerColor:
            presentColorPicker(sender)
            break
        default:
            delegate?.didSelectColor(type.color)
        }
    }

}

// MARK: - Actions

extension PDFDrawConfigurationView: UIPopoverPresentationControllerDelegate, UIColorPickerViewControllerDelegate {
    private func showTextSettingPopover(_ sender: UIButton) {
        let popoverContent = PDFTextSettingPopoverView() // Set size of popover
        popoverContent.modalPresentationStyle = .popover

        // Configure popover presentation controller
        if let popover = popoverContent.popoverPresentationController {
            popover.sourceView = sender // The button that was tapped
            popover.sourceRect = sender.bounds // The button's bounds
            popover.permittedArrowDirections = .any // Arrow direction can be any
            popover.delegate = self
        }

        popoverContent.onSelectedFont = { [weak self] font in
            self?.delegate?.didSelectFont(font)
        }
        popoverContent.currentFont = delegate?.currentFont() ?? .systemFont(ofSize: 20)

        // Present the popover
        present(popoverContent, animated: true)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    private func presentColorPicker(_ sender: UIButton) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.title = "Select Color"
        colorPicker.supportsAlpha = false
        colorPicker.delegate = self
        colorPicker.modalPresentationStyle = .popover
        colorPicker.selectedColor = delegate?.currentColor() ?? .black

        // Configure popover presentation controller
        if let popover = colorPicker.popoverPresentationController {
            popover.sourceView = sender // The button that was tapped
            popover.sourceRect = sender.bounds // The button's bounds
            popover.permittedArrowDirections = .any // Arrow direction can be any
            popover.delegate = self
        }
        self.present(colorPicker, animated: true)
    }

    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        delegate?.didSelectColor(color)
        container.arrangedSubviews.first(where: { $0.tag == PDFDrawConfigurationButton.pickerColor.rawValue })?.backgroundColor = color

        if !continuously {
            viewController.dismiss(animated: true)
        }
    }
}

class RainBowButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addRainbowBackground()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        addRainbowBackground()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
