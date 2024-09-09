//
//  PDFSearchResultCell.swift
//  app
//
//  Created by dotn on 5/9/24.
//

import UIKit
import SnapKit

class PDFSearchResultCell: UITableViewCell {

    static let identifier = "PDFSearchResultCell"

    var contentLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 17)
        lbl.textColor = UIColor.black
        lbl.numberOfLines = 0
        return lbl
    }()

    var pageNumberLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15)
        lbl.textColor = UIColor.gray
        lbl.numberOfLines = 1
        lbl.textAlignment = .right
        return lbl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }

    private func makeUI() {

        addSubview(contentLabel)
        addSubview(pageNumberLabel)

        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(self).offset(12)
            make.left.equalTo(self).offset(12)
            make.bottom.equalTo(self).offset(-12)
            make.right.lessThanOrEqualTo(pageNumberLabel.snp.left).offset(-8)
        }

        pageNumberLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(30)
            make.top.equalTo(self).offset(12)
            make.bottom.equalTo(self).offset(-12)
            make.right.equalTo(self).offset(-12)
        }
    }

}
