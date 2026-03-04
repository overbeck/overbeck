import SwiftUI

// MARK: - Ripple Model

struct RippleRing: Identifiable {
    let id: UUID
    let primaryHue: Double
    let secondaryHue: Double
    let delay: Double

    init(primaryHue: Double, delay: Double) {
        self.id = UUID()
        self.primaryHue = primaryHue
        self.secondaryHue = (primaryHue + 0.06).truncatingRemainder(dividingBy: 1.0)
        self.delay = delay
    }
}

// MARK: - Single Ripple Ring

struct RippleRingView: View {
    let ring: RippleRing
    let buttonDiameter: CGFloat

    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.0
    @State private var lineWidth: CGFloat = 2.5

    var body: some View {
        Circle()
            .strokeBorder(
                AngularGradient(
                    colors: [
                        Color(hue: ring.primaryHue, saturation: 0.75, brightness: 0.95),
                        Color(hue: ring.secondaryHue, saturation: 0.65, brightness: 1.0),
                        Color(hue: ring.primaryHue, saturation: 0.55, brightness: 0.85),
                        Color(hue: ring.secondaryHue, saturation: 0.75, brightness: 0.95),
                    ],
                    center: .center
                ),
                lineWidth: lineWidth
            )
            .frame(width: buttonDiameter, height: buttonDiameter)
            .scaleEffect(scale)
            .opacity(opacity)
            .blur(radius: scale < 1.5 ? 0 : (scale - 1.5) * 0.6)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + ring.delay) {
                    opacity = 0.8
                    withAnimation(.timingCurve(0.1, 0.8, 0.2, 1.0, duration: 2.2)) {
                        scale = 4.2
                        opacity = 0
                        lineWidth = 0.4
                    }
                }
            }
    }
}

// MARK: - Ripple Container

struct WaterRippleView: View {
    let rings: [RippleRing]
    let buttonDiameter: CGFloat

    var body: some View {
        ZStack {
            ForEach(rings) { ring in
                RippleRingView(ring: ring, buttonDiameter: buttonDiameter)
            }
        }
    }
}
