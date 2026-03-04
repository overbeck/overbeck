import Foundation
import Combine

class BPMDetector: ObservableObject {
    @Published var currentBPM: Int? = nil

    private var tapTimes: [Date] = []
    private var resetTimer: Timer?
    private let resetDelay: TimeInterval = 2.5
    private let maxTaps = 8

    func tap() {
        let now = Date()
        tapTimes.append(now)

        if tapTimes.count > maxTaps {
            tapTimes.removeFirst()
        }

        if tapTimes.count >= 2 {
            let intervals = zip(tapTimes, tapTimes.dropFirst())
                .map { $1.timeIntervalSince($0) }
            let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
            let bpm = Int(round(60.0 / avgInterval))
            currentBPM = min(max(bpm, 20), 300)
        }

        scheduleReset()
    }

    private func scheduleReset() {
        resetTimer?.invalidate()
        resetTimer = Timer.scheduledTimer(withTimeInterval: resetDelay, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.tapTimes = []
                self?.currentBPM = nil
            }
        }
    }
}
