import SwiftUI

private enum AppTheme {
    static let background = Color(red: 0.035, green: 0.055, blue: 0.09)
    static let surface = Color(red: 0.075, green: 0.10, blue: 0.15)
    static let raised = Color(red: 0.10, green: 0.13, blue: 0.19)
    static let accent = Color(red: 0.40, green: 0.91, blue: 0.77)
    static let warning = Color(red: 1.0, green: 0.70, blue: 0.39)
    static let muted = Color(red: 0.58, green: 0.64, blue: 0.73)
}

private enum Finding: String, CaseIterable, Identifiable {
    case parameterSets
    case dimensions

    var id: String { rawValue }

    var number: String {
        switch self {
        case .parameterSets: "01"
        case .dimensions: "02"
        }
    }

    var title: String {
        switch self {
        case .parameterSets: "Unbounded parameter-set count"
        case .dimensions: "Negative SPS dimensions"
        }
    }

    var summary: String {
        switch self {
        case .parameterSets:
            "The HEVC format-description path accepted parameter-set arrays well beyond the expected three VPS/SPS/PPS entries."
        case .dimensions:
            "Crafted SPS bytes produced format descriptions reporting negative width and height; the decompression-session layer rejected them."
        }
    }

    var metric: String {
        switch self {
        case .parameterSets: "3 → 18,432 entries accepted"
        case .dimensions: "96 negative-dimension descriptions observed"
        }
    }

    var symbol: String {
        switch self {
        case .parameterSets: "square.stack.3d.up"
        case .dimensions: "arrow.up.left.and.arrow.down.right"
        }
    }

    var details: String {
        switch self {
        case .parameterSets:
            "On the reported iOS 27.0.1 (24A446) device, format descriptions and decompression sessions were created across the tested count series, up to 18,432 entries. The report notes that iOS 27.2 added count validation in the video-kext path."
        case .dimensions:
            "A byte-pair sweep over SPS offsets produced 96 format descriptions with negative dimensions, including examples such as −82 × −120. VideoToolbox rejected the resulting sessions with status 0x131. The report characterizes this as a userland validation gap, not a demonstrated kernel issue."
        }
    }
}

struct ContentView: View {
    @State private var selectedFinding: Finding?
    @State private var showingAbout = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    hero
                    statusStrip
                    findingsSection
                    responseCard
                    footer
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
                .padding(.bottom, 32)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $selectedFinding) { finding in
            FindingDetailSheet(finding: finding)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingAbout) {
            AboutSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.accent.opacity(0.13))
                    .frame(width: 40, height: 40)
                Image(systemName: "waveform.path.ecg.rectangle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("FIELDNOTES")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(2.2)
                    .foregroundStyle(AppTheme.muted)
                Text("27 Soon TM")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button {
                showingAbout = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(AppTheme.muted)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.surface, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("About these findings")
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack(spacing: 7) {
                Circle()
                    .fill(AppTheme.accent)
                    .frame(width: 7, height: 7)
                Text("SECURITY RESEARCH · VIDEO TOOLBOX")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.3)
                    .foregroundStyle(AppTheme.accent)
            }

            Text("A closer look at\nHEVC validation.")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .tracking(-1.3)
                .lineSpacing(-1)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text("Two input-validation findings documented on iOS 27.0.1, with the reported changes noted in iOS 27.2.")
                .font(.system(size: 15))
                .lineSpacing(4)
                .foregroundStyle(AppTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Label("iOS 27.0.1", systemImage: "iphone")
                Text("·")
                Text("24A446")
                Text("·")
                Text("iPhone 18 Pro")
            }
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.72))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(.white.opacity(0.06), in: Capsule())
        }
        .padding(.top, 8)
    }

    private var statusStrip: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 20))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 42, height: 42)
                .background(AppTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))

            VStack(alignment: .leading, spacing: 3) {
                Text("Addressed in the reported 27.2 build")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Based on the repository’s research notes")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(AppTheme.accent.opacity(0.07), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.accent.opacity(0.16), lineWidth: 1)
        }
    }

    private var findingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("THE FINDINGS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(AppTheme.muted)
                Spacer()
                Text("02 REPORTS")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(AppTheme.muted.opacity(0.8))
            }

            ForEach(Finding.allCases) { finding in
                Button {
                    selectedFinding = finding
                } label: {
                    FindingCard(finding: finding)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var responseCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 9) {
                Image(systemName: "checkmark.seal")
                    .foregroundStyle(AppTheme.warning)
                Text("WHY IT MATTERS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(.white)
            }

            Text("Validate before handing media data to lower layers.")
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text("The notes highlight two defensive checks: bound parameter-set counts and reject non-positive dimensions parsed from bitstreams.")
                .font(.system(size: 13))
                .lineSpacing(4)
                .foregroundStyle(AppTheme.muted)

            HStack(spacing: 8) {
                recommendationPill("Bound counts")
                recommendationPill("Check dimensions")
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        }
    }

    private func recommendationPill(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundStyle(AppTheme.warning)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(AppTheme.warning.opacity(0.10), in: Capsule())
    }

    private var footer: some View {
        VStack(spacing: 9) {
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)
            HStack {
                Text("RESEARCH NOTES · READ-ONLY")
                    .tracking(1.1)
                Spacer()
                Text("27.0.1 → 27.2")
            }
            .font(.system(size: 9, weight: .semibold, design: .rounded))
            .foregroundStyle(AppTheme.muted.opacity(0.75))
        }
    }
}

private struct FindingCard: View {
    let finding: Finding

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: finding.symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.accent.opacity(0.11), in: RoundedRectangle(cornerRadius: 13))

                VStack(alignment: .leading, spacing: 6) {
                    Text("FINDING \(finding.number)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(AppTheme.muted)
                    Text(finding.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.muted)
                    .padding(.top, 4)
            }

            Text(finding.summary)
                .font(.system(size: 12))
                .lineSpacing(3)
                .foregroundStyle(AppTheme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 7) {
                Circle().fill(AppTheme.warning).frame(width: 5, height: 5)
                Text(finding.metric)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.warning)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(AppTheme.warning.opacity(0.08), in: Capsule())
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct FindingDetailSheet: View {
    let finding: Finding
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("FINDING \(finding.number)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(AppTheme.accent)
                    Spacer()
                    Button("Done") { dismiss() }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }

                Label(finding.title, systemImage: finding.symbol)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .labelStyle(DetailLabelStyle())

                Text(finding.details)
                    .font(.system(size: 15))
                    .lineSpacing(5)
                    .foregroundStyle(AppTheme.muted)

                HStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Observed behavior summarized from the repository notes.")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.accent)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                Spacer(minLength: 0)
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
    }
}

private struct DetailLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 12) {
            configuration.icon
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 42, height: 42)
                .background(AppTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))
            configuration.title
        }
    }
}

private struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("ABOUT THIS APP")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(AppTheme.accent)
                    Spacer()
                    Button("Done") { dismiss() }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                Text("A concise field guide to two HEVC input-validation findings reported for iOS 27.0.1.")
                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text("This app is informational only. It does not generate crafted media, run proof-of-concept code, or test devices. Findings and version details reflect the repository’s published notes.")
                    .font(.system(size: 14))
                    .lineSpacing(4)
                    .foregroundStyle(AppTheme.muted)
                Spacer(minLength: 0)
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
