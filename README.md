# MSP iOS SDK — Swift Package

Swift Package Manager distribution of the MSP iOS SDK. This repository holds only the package
manifest and thin wrapper targets; the SDK binaries are downloaded from the
[`msp-ios-sdk-public` releases](https://github.com/ParticleMedia/msp-ios-sdk-public/releases)
and verified by SwiftPM against the checksums in `Package.swift`.

## Available versions

| Version | Binaries |
|---|---|
| 3.5.2 | Unmodified xcframeworks from the [3.5.2 release](https://github.com/ParticleMedia/msp-ios-sdk-public/releases/tag/3.5.2) — the same binaries CocoaPods installs for `pod 'MSPCore', '3.5.2'` |

## Requirements

- iOS 15.0+
- Xcode 26.1+ (the 3.5.2 binaries were built with Swift 6.2.1)

## Installation

In Xcode, choose **File → Add Package Dependencies…**, enter

```
https://github.com/ParticleMedia/msp-ios-sdk-spm
```

choose the **Exact Version** rule `3.5.2`, and add the products you need to your app target.

Or, in a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ParticleMedia/msp-ios-sdk-spm", exact: "3.5.2"),
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "MSPCore", package: "msp-ios-sdk-spm"),
            .product(name: "MSPNovaAdapter", package: "msp-ios-sdk-spm"),
            .product(name: "MSPGoogleAdapter", package: "msp-ios-sdk-spm"),
            .product(name: "MSPFacebookAdapter", package: "msp-ios-sdk-spm"),
        ]
    ),
]
```

| Product | Required | Pulls in automatically |
|---|---|---|
| `MSPCore` | Yes | — |
| `MSPNovaAdapter` | No | — |
| `MSPGoogleAdapter` | No | [Google Mobile Ads](https://github.com/googleads/swift-package-manager-google-mobile-ads) 12.x |
| `MSPFacebookAdapter` | No | [FBAudienceNetwork](https://github.com/facebook/FBAudienceNetwork) 6.x |

Not available via SPM for 3.5.2: the Moloco, Liftoff and Amazon adapters.

Module names (`MSPCore`, `MSPiOSCore`, `MSPNovaAdapter`, `MSPGoogleAdapter`, `MSPFacebookAdapter`)
are the same as with CocoaPods, so app code does not change.

## Integration guide

SDK initialization, ad loading and per-network setup for 3.5.2 are described in the
[MSP SDK iOS Integration Guide (SPM, SDK 3.5.2)](https://github.com/ParticleMedia/msp-sdk-demo-ios/tree/spm_3.5.2#msp-sdk--ios-integration-guide-swift-package-manager-sdk-352),
with a working demo app on the same branch.

## How the binaries are packaged

SwiftPM needs one xcframework per binary-target zip:

- `MSPCore`, `MSPPrebidAdapter`, `MSPGoogleAdapter`, `MSPGoogleAdsTypes` and `MSPFacebookAdapter`
  use the original release zips.
- `MSPiOSCore`, `MSPSharedLibraries`, `PrebidMobile`, `OMSDK_Newsbreak1`, `NovaCore` and
  `MSPNovaAdapter` use `<Name>.xcframework-<version>.zip` assets on the same release, each holding
  one unmodified xcframework taken from `MSPSharedLibraries-<version>.zip` or
  `MSPNovaAdapter-<version>.zip`. [`scripts/repackage-3.5.2.sh`](scripts/repackage-3.5.2.sh)
  verifies that they match the original release zips byte for byte.
