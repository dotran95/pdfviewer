//
//  DrawConfigurationView.swift
//  PdfViewer
//
//  Created by VTIT on 27/9/24.
//

import UIKit

protocol DrawConfigurationViewDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
}

enum DrawConfigurationButton: Int {
    case settingOptions = 0
    case blackColor
    case blueColor
    case greenColor
    case yellowColor
    case redColor
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

enum DrawAnnotationType {
    case text
    case none
}

class DrawConfigurationView: UIView {

    // MARK: - Constants and Computed

    private let buttonWidth: CGFloat = 40

    private let buttons: [DrawConfigurationButton] = [.settingOptions, .blackColor, .blueColor, .greenColor, .yellowColor, .redColor]


    private let backgroundViewColor: UIColor = .white

    // MARK: - UIElements


    weak var delegate: DrawConfigurationViewDelegate?

    private var type: DrawAnnotationType = .none

    // MARK: - Initialize

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialState()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(_ show: Bool, type: DrawAnnotationType) {
        self.isHidden = !show
        self.type = type
    }

    // MARK: - Lifecycle


    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

    private func setupInitialState() {
        backgroundColor = .gray.withAlphaComponent(0.5)

        let stackView = UIStackView(arrangedSubviews: buttons.map({ createButton($0) }))
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10 // Space between views

        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalTo(self).inset(20)
            make.centerX.equalTo(self.safeAreaLayoutGuide)
        }

    }

    private func createButton(_ type: DrawConfigurationButton) -> UIButton {
        let button = UIButton(type: .system)
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
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
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
        guard let type = DrawConfigurationButton(rawValue: sender.tag) else { return }
        switch type {
        case .annotations:
            break
        case .settingOptions:
            showTextSettingPopover(sender)
            break
        default:
            delegate?.didSelectColor(type.color)
        }
    }

}

// MARK: - Actions

extension DrawConfigurationView {
    private func showTextSettingPopover(_ sender: UIButton) {
        let popover = TextSettingPopoverView(frame: CGRect(x: 0, y: 0, width: 200, height: 100)) // Set size of popover
        popover.center = sender.center // Center the popover over the button
        popover.translatesAutoresizingMaskIntoConstraints = false

        // Position the popover
        if let superview = sender.superview {
            superview.addSubview(popover)
            popover.center = CGPoint(x: sender.center.x, y: sender.center.y - sender.bounds.height - 50) // Adjust position
        }
    }
}


extension DrawConfigurationView {

    func drawCircle() {

//        let rect = colorPickerButton.frame.insetBy(dx: -2.0, dy: -2.0)
//        let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.width * 0.5)
//
//        let newLayer = CAShapeLayer()
//        newLayer.path = path.cgPath
//        newLayer.fillColor = UIColor.clear.cgColor
//        newLayer.strokeColor = pickedColor.cgColor
//
//        roundedLayer?.removeFromSuperlayer()
//        layer.addSublayer(newLayer)
//        roundedLayer = newLayer
    }
}

class TextSettingPopoverView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 8

        // Add a label or any other UI elements here
        let label = UILabel()
        label.text = "This is a popover!"
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
