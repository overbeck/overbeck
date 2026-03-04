import SwiftUI

struct ContentView: View {
    @StateObject private var bpmDetector = BPMDetector()
    @State private var rippleRings: [RippleRing] = []
    @State private var isPressed = false
    @State private var buttonPulse = false

    private let buttonDiameter: CGFloat = 150

    // Ink-in-water hue palette — deep blues, teals, indigos, violets
    private let inkHues: [Double] = [0.58, 0.62, 0.66, 0.70, 0.73, 0.55, 0.50, 0.77]

    var body: some View {
        ZStack {
            // Deep still-water background
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.05, blue: 0.13),
                    Color(red: 0.02, green: 0.03, blue: 0.09)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 80) {
                bpmDisplay
                buttonArea
            }
        }
    }

    // MARK: - BPM Display

    private var bpmDisplay: some View {
        VStack(spacing: 8) {
            ZStack {
                if let bpm = bpmDetector.currentBPM {
                    Text("\(bpm)")
                        .font(.system(size: 96, weight: .ultraLight, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.88, green: 0.96, blue: 1.0),
                                    Color(red: 0.50, green: 0.75, blue: 1.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: bpm)
                        .transition(.opacity)
                } else {
                    Text("—")
                        .font(.system(size: 96, weight: .ultraLight, design: .rounded))
                        .foregroundColor(.white.opacity(0.12))
                        .transition(.opacity)
                }
            }
            .frame(height: 110)
            .animation(.easeInOut(duration: 0.3), value: bpmDetector.currentBPM == nil)

            Text("BPM")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(7)
                .foregroundColor(.white.opacity(0.22))
        }
    }

    // MARK: - Button + Ripples

    private var buttonArea: some View {
        ZStack {
            WaterRippleView(rings: rippleRings, buttonDiameter: buttonDiameter)
            tapButton
        }
        .frame(width: 380, height: 380)
    }

    private var tapButton: some View {
        Circle()
            // Deep liquid fill
            .fill(
                RadialGradient(
                    colors: [
                        Color(red: 0.20, green: 0.35, blue: 0.68),
                        Color(red: 0.09, green: 0.15, blue: 0.40)
                    ],
                    center: UnitPoint(x: 0.38, y: 0.32),
                    startRadius: 4,
                    endRadius: buttonDiameter * 0.72
                )
            )
            // Glass highlight
            .overlay(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.20),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: UnitPoint(x: 0.25, y: 0.08),
                            endPoint: UnitPoint(x: 0.75, y: 0.55)
                        )
                    )
                    .padding(18)
            )
            // Rim
            .overlay(
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(red: 0.45, green: 0.68, blue: 1.0).opacity(0.55),
                                Color(red: 0.15, green: 0.30, blue: 0.70).opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            .frame(width: buttonDiameter, height: buttonDiameter)
            // Glow
            .shadow(
                color: Color(red: 0.15, green: 0.40, blue: 0.95).opacity(0.55),
                radius: 28, x: 0, y: 6
            )
            .shadow(
                color: Color(red: 0.10, green: 0.28, blue: 0.80).opacity(0.25),
                radius: 55, x: 0, y: 0
            )
            .scaleEffect(isPressed ? 0.92 : (buttonPulse ? 1.018 : 1.0))
            .animation(
                isPressed
                    ? .easeOut(duration: 0.08)
                    : .spring(response: 0.38, dampingFraction: 0.55),
                value: isPressed
            )
            .animation(
                .easeInOut(duration: 2.8).repeatForever(autoreverses: true),
                value: buttonPulse
            )
            .onAppear { buttonPulse = true }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            handleTap()
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.55)) {
                            isPressed = false
                        }
                    }
            )
    }

    // MARK: - Tap Logic

    private func handleTap() {
        bpmDetector.tap()
        spawnRipples()
    }

    private func spawnRipples() {
        let baseHue = inkHues.randomElement()!
        for i in 0..<4 {
            let hue = (baseHue + Double(i) * 0.035).truncatingRemainder(dividingBy: 1.0)
            rippleRings.append(RippleRing(primaryHue: hue, delay: Double(i) * 0.085))
        }
        // Prune old rings to avoid memory growth
        if rippleRings.count > 40 {
            rippleRings.removeFirst(rippleRings.count - 40)
        }
    }
}

#Preview {
    ContentView()
}
