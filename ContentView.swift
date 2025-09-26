//
//  ContentView.swift
//  KeyboardToolbarViewController_2
//
//  Created by Yuki Sasaki on 2025/09/26.
//

import SwiftUI
import CoreData

import UIKit

// MARK: - ListViewController
class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()
    var items = ["りんご", "みかん", "バナナ"]

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 28
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "フルーツ一覧"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // フローティング + ボタン
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 56),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        addButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
    }

    @objc private func addItem() {
        print("＋ボタン tapped")
        // 新しいアイテムを追加してテーブル更新
        let newItem = "新しいアイテム \(items.count + 1)"
        items.append(newItem)
        tableView.insertRows(at: [IndexPath(row: items.count - 1, section: 0)], with: .automatic)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = DetailViewController()
        detailVC.itemName = items[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - DetailViewController
import SwiftUI
import UIKit

class DetailViewController: UIViewController {
    var itemName: String?
    let textView = UITextView()
    let bottomToolbar = UIToolbar()
    var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // TextView
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "選択したアイテム: \(itemName ?? "")"
        textView.keyboardDismissMode = .interactive
        view.addSubview(textView)

        // Bottom Toolbar
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        bottomToolbar.items = [flexible, done]
        view.addSubview(bottomToolbar)

        // Auto Layout
        bottomConstraint = bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor, constant: -8),

            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
            bottomToolbar.heightAnchor.constraint(equalToConstant: 44)
        ])

        // キーボード通知でボトムツールバーを上げる
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        textView.becomeFirstResponder()
    }
    

    @objc private func doneTapped() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            bottomConstraint.constant = -frame.height + view.safeAreaInsets.bottom
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            bottomConstraint.constant = 0
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// SwiftUI Preview / 使用例
struct ContentView: View {
    var body: some View {
        NavigationView {
            ListVCWrapper()
                .navigationTitle("Detail")
        }
    }
}


// ListViewController 用ラッパー
struct ListVCWrapper: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> ListViewController {
        let vc = ListViewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ListViewController, context: Context) {
        // 必要があれば更新
    }
}
