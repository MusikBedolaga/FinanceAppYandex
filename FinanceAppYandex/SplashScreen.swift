import SwiftUI
import Splash

struct SplashScreen: View {
    @Binding var isFinished: Bool
    private let urlString = "https://yastatic.net/s3/school/files/387e4ea2-b85c-42e0-8020-3c7d4f22f1f4/upload.json"

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if let url = URL(string: urlString) {
                InitialLoadingView(url: url) {
                    isFinished = true
                }
                .frame(width: 300, height: 300)
            } else {
                Text("Ошибка загрузки анимации")
            }
        }
    }
}
