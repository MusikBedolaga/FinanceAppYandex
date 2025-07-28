import SwiftUI

struct OfflineBannerView: View {
    var body: some View {
        Text("Offline mode")
            .foregroundColor(.white)
            .font(.caption.bold())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.red)
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(1)
    }
}

