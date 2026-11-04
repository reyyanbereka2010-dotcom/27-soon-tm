# 27 Soon TM iOS app scaffold

This repository includes a minimal SwiftUI iOS app in `27SoonTM.xcodeproj`.

## Build and export an IPA

1. Open `27SoonTM.xcodeproj` in Xcode on macOS.
2. Select the `27SoonTM` scheme and set a unique **Bundle Identifier** in Signing & Capabilities.
3. Choose your Apple Developer team and enable automatic signing for a device IPA.
4. Select **Any iOS Device (arm64)**, then use **Product → Archive**.
5. In Organizer, choose the archive and select **Distribute App** to export the IPA. Choose the distribution method appropriate for your use.

For a local simulator build, use the iOS Simulator destination; simulator builds are not device-installable IPAs.
