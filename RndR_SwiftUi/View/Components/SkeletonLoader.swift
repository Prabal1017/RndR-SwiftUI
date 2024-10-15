import SwiftUI

struct SkeletonLoader: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(maxWidth: .infinity, maxHeight: 120)
            .shimmer()  // Custom modifier to add a shimmer effect
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: Double = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.4), Color.gray.opacity(0.2)]),
                               startPoint: .leading,
                               endPoint: .trailing)
                    .rotationEffect(.degrees(80))
                    .offset(x: phase * 200)
                    .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false), value: phase)
            )
            .onAppear {
                phase = 1
            }
    }
}
