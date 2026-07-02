import SwiftUI
import UIKit

struct KeyboardDismissTapInstaller: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.installIfNeeded(from: uiView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private weak var installedWindow: UIWindow?
        private var tapRecognizer: UITapGestureRecognizer?

        func installIfNeeded(from view: UIView) {
            guard let window = view.window else { return }
            guard installedWindow !== window else { return }

            uninstall()

            let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            recognizer.cancelsTouchesInView = false
            recognizer.delegate = self
            window.addGestureRecognizer(recognizer)

            installedWindow = window
            tapRecognizer = recognizer
        }

        func uninstall() {
            if let tapRecognizer, let installedWindow {
                installedWindow.removeGestureRecognizer(tapRecognizer)
            }
            tapRecognizer = nil
            installedWindow = nil
        }

        @objc private func handleTap() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            var view = touch.view
            while let current = view {
                if current is UIControl || current is UITextField || current is UITextView {
                    return false
                }

                let className = String(describing: type(of: current))
                if className.contains("TextField") || className.contains("TextView") {
                    return false
                }

                view = current.superview
            }

            return true
        }
    }
}
