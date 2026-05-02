import Foundation
import SwiftUI

struct CatBreakView: View {
    let until: Date
    let onFinished: () -> Void

    @State private var now = Date()
    @State private var entered = false
    @State private var bounce = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            GatekeeperCatShape()
                .frame(width: 300, height: 250)
                .offset(x: entered ? 0 : 340)
                .offset(y: bounce ? -8 : 6)
                .animation(.spring(response: 0.72, dampingFraction: 0.66), value: entered)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: bounce)

            Text("Cat hijack")
                .font(.system(size: 42, weight: .black, design: .rounded))

            Text("The cat has your screen now. Rest until the countdown ends.")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(timeRemaining)
                .font(.system(size: 54, weight: .black, design: .rounded))
                .monospacedDigit()
                .padding(.horizontal, 26)
                .padding(.vertical, 10)
                .background(.white.opacity(0.72), in: Capsule())
                .overlay(alignment: .topLeading) {
                    CatPaw()
                        .frame(width: 54, height: 42)
                        .rotationEffect(.degrees(-12))
                        .offset(x: -22, y: -24)
                }
                .overlay(alignment: .topTrailing) {
                    CatPaw()
                        .frame(width: 54, height: 42)
                        .rotationEffect(.degrees(12))
                        .offset(x: 22, y: -24)
                }

            Spacer()
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 1.0, green: 0.93, blue: 0.68).opacity(0.98))
        .foregroundStyle(.black)
        .onAppear {
            entered = true
            bounce = true
        }
        .onReceive(timer) { value in
            now = value
            if value >= until {
                onFinished()
            }
        }
    }

    private var secondsRemaining: Int {
        max(0, Int(ceil(until.timeIntervalSince(now))))
    }

    private var timeRemaining: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

private struct GatekeeperCatShape: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(red: 0.97, green: 0.58, blue: 0.24))
                .frame(width: 258, height: 182)
                .offset(y: 24)

            Circle()
                .fill(Color(red: 0.98, green: 0.65, blue: 0.32))
                .frame(width: 148, height: 136)
                .offset(y: -56)

            ear(x: -48)
            ear(x: 48)

            Circle().fill(.black).frame(width: 12, height: 12).offset(x: -26, y: -72)
            Circle().fill(.black).frame(width: 12, height: 12).offset(x: 26, y: -72)
            Capsule().fill(.black).frame(width: 16, height: 10).offset(y: -52)
            Capsule().fill(.black.opacity(0.7)).frame(width: 42, height: 4).offset(y: -34)

            Capsule()
                .fill(Color(red: 1.0, green: 0.82, blue: 0.48))
                .frame(width: 128, height: 90)
                .offset(y: 40)

            ForEach([-72, -30, 30, 72], id: \.self) { x in
                Capsule()
                    .fill(Color(red: 0.78, green: 0.36, blue: 0.18))
                    .frame(width: 14, height: 38)
                    .offset(x: CGFloat(x), y: 102)
            }

            CatPaw()
                .frame(width: 70, height: 54)
                .rotationEffect(.degrees(-18))
                .offset(x: -116, y: 18)

            CatPaw()
                .frame(width: 70, height: 54)
                .rotationEffect(.degrees(18))
                .offset(x: 116, y: 18)
        }
        .shadow(color: .black.opacity(0.18), radius: 24, y: 14)
    }

    private func ear(x: CGFloat) -> some View {
        Triangle()
            .fill(Color(red: 0.92, green: 0.47, blue: 0.21))
            .frame(width: 44, height: 42)
            .rotationEffect(.degrees(x < 0 ? -18 : 18))
            .offset(x: x, y: -116)
    }
}

private struct CatPaw: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(red: 0.98, green: 0.65, blue: 0.32))
                .frame(width: 48, height: 34)
                .offset(y: 8)

            ForEach([-16, 0, 16], id: \.self) { x in
                Circle()
                    .fill(Color(red: 0.98, green: 0.65, blue: 0.32))
                    .frame(width: 18, height: 18)
                    .offset(x: CGFloat(x), y: -8)
            }
        }
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
