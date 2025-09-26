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
    let items = ["りんご", "みかん", "バナナ"]

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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "選択したアイテム: \(itemName ?? "")"
        textView.keyboardDismissMode = .interactive
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])

        textView.becomeFirstResponder()
    }
}

// SwiftUI で使うラッパー
struct DetailVCWrapper: UIViewControllerRepresentable {
    var itemName: String

    func makeUIViewController(context: Context) -> DetailViewController {
        let vc = DetailViewController()
        vc.itemName = itemName
        return vc
    }

    func updateUIViewController(_ uiViewController: DetailViewController, context: Context) {
        // 必要があれば更新
    }
}

// SwiftUI Preview / 使用例
struct ContentView: View {
    var body: some View {
        NavigationView {
            DetailVCWrapper(itemName: "りんご")
                .navigationTitle("Detail")
        }
    }
}

// MARK: - AppDelegate
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let nav = UINavigationController(rootViewController: ListViewController())
        window.rootViewController = nav
        self.window = window
        window.makeKeyAndVisible()
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let nav = UINavigationController(rootViewController: ListViewController())
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }
}
