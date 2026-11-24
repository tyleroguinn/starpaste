import SwiftUI
import UIKit

/// The keyboard itself. iOS creates this when someone switches to Starpaste.
/// It hosts the SwiftUI `KeyboardView` and passes taps through to the text field.
final class KeyboardViewController: UIInputViewController {
    private let model = KeyboardModel()
    private var hostingController: UIHostingController<KeyboardView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        model.insertText = { [weak self] text in self?.textDocumentProxy.insertText(text) }
        model.deleteBackward = { [weak self] in self?.textDocumentProxy.deleteBackward() }
        model.nextKeyboard = { [weak self] in self?.advanceToNextInputMode() }

        let host = UIHostingController(rootView: KeyboardView(model: model))
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(host)
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)
        hostingController = host

        let height = view.heightAnchor.constraint(equalToConstant: 286)
        height.priority = UILayoutPriority(999)
        height.isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.reloadRecents()
    }

    override func viewWillLayoutSubviews() {
        // iPhones with Face ID already show a globe under the keyboard,
        // so we only draw our own when iOS says it's needed.
        let needsGlobe = needsInputModeSwitchKey
        if model.showsGlobe != needsGlobe { model.showsGlobe = needsGlobe }
        super.viewWillLayoutSubviews()
    }
}
