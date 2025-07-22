import Foundation
import SwiftUI
import Lottie

struct InitialLoadingView: UIViewRepresentable {
    let url: URL
    var onFinished: (() -> Void)?
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let callback = onFinished
        
        LottieAnimation.loadedFrom(url: url) { animation in
            guard let animation = animation else { return }
            
            let animationView = LottieAnimationView(animation: animation)
            animationView.frame = container.bounds
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .playOnce
            animationView.translatesAutoresizingMaskIntoConstraints = false
            
            animationView.play { _ in
                callback?()
            }
            
            container.addSubview(animationView)
            
            NSLayoutConstraint.activate([
                animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                animationView.topAnchor.constraint(equalTo: container.topAnchor),
                animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
