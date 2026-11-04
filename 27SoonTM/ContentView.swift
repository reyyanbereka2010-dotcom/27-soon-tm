import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "iphone")
                .font(.system(size: 72))
                .foregroundStyle(.blue)

            Text("27 Soon TM")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.primary)

            Text("Minimal iOS app scaffold")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Open this project in Xcode and archive it to produce an IPA.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .foregroundStyle(.secondary)
        }
        .padding(32)
    }
}

#Preview {
    ContentView()
}
