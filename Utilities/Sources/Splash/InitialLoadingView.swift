import SwiftUI
import Lottie

public struct InitialLoadingView: UIViewRepresentable {
    public let url: URL
    public var onFinished: (() -> Void)?

    public init(url: URL, onFinished: (() -> Void)? = nil) {
        self.url = url
        self.onFinished = onFinished
    }

    public func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let callback = onFinished

        LottieAnimation.loadedFrom(url: url) { animation in
            guard let animation = animation else { return }

            let animationView = LottieAnimationView(animation: animation)
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .playOnce
            animationView.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(animationView)

            NSLayoutConstraint.activate([
                animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                animationView.topAnchor.constraint(equalTo: container.topAnchor),
                animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])

            container.layoutIfNeeded()
            animationView.play { _ in
                callback?()
            }
        }

        return container
    }

    public func updateUIView(_ uiView: UIView, context: Context) {}
}
