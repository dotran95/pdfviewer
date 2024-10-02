//
//  TextSettingPopoverView.swift
//  PdfViewer
//
//  Created by VTIT on 30/9/24.
//

import UIKit

class PDFTextSettingPopoverView: UIViewController {

    private let kItemHeight: CGFloat = 50.0
    private let kPadding: CGFloat = 8.0

    var currentFont: UIFont = .systemFont(ofSize: 20)
    var onSelectedFont: ((UIFont) -> Void)?

    private let fontSizeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 10 // Minimum font size
        slider.maximumValue = 100 // Maximum font size
        slider.value = 50 // Start at minimum value
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.tintColor = .black
        return slider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        preferredContentSize = CGSize(width: 200, height: 150)
    }

    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 8

        fontSizeView()

        // Add target for slider value change
        fontSizeSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        fontSizeSlider.value = Float(currentFont.pointSize)
    }

    private func fontSizeView() {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.text = "A"
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center

        titleLabel.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        let unitLabel = UILabel()
        unitLabel.font = .systemFont(ofSize: 17, weight: .bold)
        unitLabel.text = "A"
        unitLabel.textColor = .black
        unitLabel.textAlignment = .center
        unitLabel.snp.makeConstraints { make in
            make.width.equalTo(30)
        }

        let stackView = UIStackView(arrangedSubviews: [titleLabel, fontSizeSlider, unitLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill

        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.height.equalTo(kItemHeight)
            make.bottom.equalTo(self.view).inset(kPadding)
            make.horizontalEdges.equalTo(self.view).inset(kPadding)
        }
    }

    private func setupTextAligmentView() {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.text = "A"
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center

        titleLabel.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        let unitLabel = UILabel()
        unitLabel.font = .systemFont(ofSize: 17, weight: .bold)
        unitLabel.text = "A"
        unitLabel.textColor = .black
        unitLabel.textAlignment = .center
        unitLabel.snp.makeConstraints { make in
            make.width.equalTo(30)
        }

        let stackView = UIStackView(arrangedSubviews: [titleLabel, fontSizeSlider, unitLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill

        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.height.equalTo(kItemHeight)
            make.bottom.equalTo(self.view).inset(kPadding)
            make.horizontalEdges.equalTo(self.view).inset(kPadding)
        }
    }


    @objc
    private func sliderValueChanged(_ sender: UISlider) {
        let fontSize = CGFloat(sender.value)
        guard let newFont = currentFont.copyWith(fontSize: fontSize) else { return }
        onSelectedFont?(newFont)
    }
}
