# MSP iOS SDK — Swift Package

Swift Package Manager distribution of the MSP iOS SDK. This repository holds only the package
manifest and thin wrapper targets; the SDK binaries are downloaded from the
[`msp-ios-sdk-public` releases](https://github.com/ParticleMedia/msp-ios-sdk-public/releases)
and verified by SwiftPM against the checksums in `Package.swift`.

## Available versions

The package version is not always the SDK version: a package-only fix gets a new package
version while the SDK binaries stay the same.

| Package version | SDK version | Binaries | Notes |
|---|---|---|---|
| **3.5.3** | 3.5.2 | Unmodified xcframeworks from the [3.5.2 release](https://github.com/ParticleMedia/msp-ios-sdk-public/releases/tag/3.5.2) — the same binaries CocoaPods installs for `pod 'MSPCore', '3.5.2'` | Use this one. Google Mobile Ads is no longer a package dependency (see below). `MSP.getSDKVersion()` reports 3.5.2. |
| 3.5.2 | 3.5.2 | Same as 3.5.3 | Superseded: declares Google Mobile Ads 12.x, so apps that get GMA 13 from elsewhere (e.g. AppLovin MAX) cannot resolve. |

## Requirements

- iOS 15.0+
- Xcode 26.1+ (the 3.5.2 binaries were built with Swift 6.2.1)

## Installation

In Xcode, choose **File → Add Package Dependencies…**, enter

```
https://github.com/ParticleMedia/msp-ios-sdk-spm
```

choose the **Exact Version** rule `3.5.3`, and add the products you need to your app target.

Or, in a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ParticleMedia/msp-ios-sdk-spm", exact: "3.5.3"),
    // Only if you use MSPGoogleAdapter:
    .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", "12.0.0"..<"13.0.0"),
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "MSPCore", package: "msp-ios-sdk-spm"),
            .product(name: "MSPNovaAdapter", package: "msp-ios-sdk-spm"),
            .product(name: "MSPGoogleAdapter", package: "msp-ios-sdk-spm"),
            .product(name: "MSPFacebookAdapter", package: "msp-ios-sdk-spm"),
            // Only if you use MSPGoogleAdapter:
            .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
        ]
    ),
]
```

| Product | Required | Third-party SDK |
|---|---|---|
| `MSPCore` | Yes | — |
| `MSPNovaAdapter` | No | — |
| `MSPGoogleAdapter` | No | **Add it yourself:** [Google Mobile Ads](https://github.com/googleads/swift-package-manager-google-mobile-ads) 12.x, product `GoogleMobileAds` |
| `MSPFacebookAdapter` | No | Pulled in automatically: [FBAudienceNetwork](https://github.com/facebook/FBAudienceNetwork) 6.x |

### Google Mobile Ads is not a package dependency

SwiftPM applies the version range of every dependency a package declares to all of its clients,
whether or not they use the product that needs it. If this package declared Google Mobile Ads,
apps that don't use `MSPGoogleAdapter` but get GMA 13 from elsewhere (for example AppLovin MAX's
Google adapter) could not resolve. So the package leaves GMA out:

- Not using `MSPGoogleAdapter`: nothing to do; your app can use any GMA version.
- Using `MSPGoogleAdapter`: add the Google Mobile Ads package (12.x for SDK 3.5.2) and its
  `GoogleMobileAds` product to your app target. Without it the build fails with
  `Unable to find module dependency: 'GoogleMobileAds'`.

Not available via SPM for SDK 3.5.2: the Moloco, Liftoff and Amazon adapters.

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
