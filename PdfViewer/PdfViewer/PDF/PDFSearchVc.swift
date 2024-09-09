//
//  PDFSearchVc.swift
//  PdfViewer
//
//  Created by dotn on 9/9/24.
//

import UIKit
import PDFKit
import SnapKit

protocol PDFSearchDelegate: AnyObject {
    func onSelect(selection: PDFSelection)
}

class PDFSearchVc: UIViewController {

    private var searchBar = UISearchBar()
    private var tableView = UITableView()
    private var results: [PDFSelection] = []
    private let debouncer = Debouncer(delay: .milliseconds(300))
    var document: PDFDocument?
    weak var delegate: PDFSearchDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.endEditing(true)
    }

    deinit {
        print("PDFSearchVc")
    }


    // MARK: - UI
    private func makeUI() {

        // Search Bar
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.becomeFirstResponder()

        // TableView
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        tableView.register(PDFSearchResultCell.self, forCellReuseIdentifier: PDFSearchResultCell.identifier)
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension PDFSearchVc: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PDFSearchResultCell.identifier, for: indexPath) as? PDFSearchResultCell else {
            return UITableViewCell()
        }

        let item = results[indexPath.row]
        cell.contentLabel.attributedText = resultAttributedString(item)
        cell.pageNumberLabel.text = "\(item.pages.first?.pageRef?.pageNumber ?? 1)"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.onSelect(selection: results[indexPath.row])
    }
}

// MARK: - UISearchBarDelegate
extension PDFSearchVc: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debouncer.call { [weak self] in
            self?.onSearchDocument(searchText)
        }
    }

    private func onSearchDocument(_ keyword: String) {
        if keyword.isEmpty {
            results = []
        } else {
            results = document?.findString(keyword, withOptions: [.caseInsensitive, .diacriticInsensitive]) ?? []
        }
        tableView.reloadData()
    }

    private func resultAttributedString(_ selection: PDFSelection) -> NSAttributedString? {
        guard let newSelection = selection.copy() as? PDFSelection,
              let highlightText = selection.string else {
            return selection.attributedString
        }

        newSelection.extend(atStart: 100)
        newSelection.extend(atEnd: 20)
        let displaySelection = newSelection.selectionsByLine().first(where: { $0.string?.contains(highlightText) ?? false })

        guard let fullText = displaySelection?.string else {
            return selection.attributedString
        }

        let mutableAttr = NSMutableAttributedString(string: fullText, attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 15)
        ])
        let range = (fullText as NSString).range(of: highlightText)

        // Check if the text to be highlighted is found
        if range.location != NSNotFound {
            mutableAttr.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .bold), range: range)
        }

        return mutableAttr
    }
}


class Debouncer {

    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue
    private let delay: DispatchTimeInterval

    init(delay: DispatchTimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    func call(_ action: @escaping () -> Void) {
        workItem?.cancel()
        let workItem = DispatchWorkItem(block: action)
        self.workItem = workItem
        queue.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
