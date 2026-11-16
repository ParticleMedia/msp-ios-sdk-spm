// swift-tools-version: 5.9
// MSP iOS SDK 3.5.2 as a binary Swift package.
//
// Every binary target is an unmodified xcframework from the 3.5.2 release of
// https://github.com/ParticleMedia/msp-ios-sdk-public:
// - MSPCore, MSPPrebidAdapter, MSPGoogleAdapter, MSPGoogleAdsTypes, MSPFacebookAdapter use the
//   release zips CocoaPods installs (same SHA-256 as the 3.5.2 podspecs).
// - MSPiOSCore, MSPSharedLibraries, PrebidMobile, OMSDK_Newsbreak1, NovaCore, MSPNovaAdapter use
//   single-xcframework zips repackaged from MSPSharedLibraries-3.5.2.zip and
//   MSPNovaAdapter-3.5.2.zip (see scripts/repackage-3.5.2.sh): SwiftPM needs one xcframework per zip.

import PackageDescription

let package = Package(
    name: "MSPSDK",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "MSPCore", targets: ["MSPCoreSPM"]),
        .library(name: "MSPNovaAdapter", targets: ["MSPNovaAdapterSPM"]),
        .library(name: "MSPGoogleAdapter", targets: ["MSPGoogleAdapterSPM"]),
        .library(name: "MSPFacebookAdapter", targets: ["MSPFacebookAdapterSPM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", "12.0.0"..<"13.0.0"),
        .package(url: "https://github.com/facebook/FBAudienceNetwork.git", "6.15.0"..<"7.0.0"),
    ],
    targets: [
        // Binary targets cannot declare dependencies, so each product is a thin source wrapper
        // that pulls in its binaries and third-party packages.
        .binaryTarget(
            name: "MSPiOSCore",
            url: "https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/3.5.2/MSPiOSCore.xcframework-3.5.2.zip",
            checksum: "ea441dc6ddb761441aa474e7b5d9bb7f62375592689e1d7c08a54dd0ab3084cb"
        ),
        .binaryTarget(
            name: "MSPSharedLibraries",
            url: "https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/3.5.2/MSPSharedLibraries.xcframework-3.5.2.zip",
            checksum: "2db2b361b06150f2fffbe2bfa7ceb3a1af48777ba63b65fc56621a06037e0880"
        ),
        .binaryTarget(
            name: "MSPPrebidAdapter",
            url: "https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/3.5.2/MSPPrebidAdapter-3.5.2.zip",
            checksum: "f466d7a1af45f8bc9be287a8137fc13a1769b979a727a357ce6e26d27e8c1dc4"
        ),
        .binaryTarget(
            name: "MSPCore",
            url: "https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/3.5.2/MSPCore-3.5.2.zip",
            checksum: "2193d2e47eaa034abdf3a6d3f02892a6b4769e85cc58f841338fe76642fe6b37"
        ),
        .binaryTarget(
            name: "PrebidMobile",
            url: "https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/3.5.2/PrebidMobile.xcframework-3.5.2.zip",
            checksum: "4ec2bdcc2569280fd5f30aa61e81e26a2e9d38b1a49a0b3066a36f2a7dcc18aa"
        ),
        .binaryTarget(
            name: "OMSDK_Newsbreak1",
            url: "https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/3.5.2/OMSDK_Newsbreak1.xcframework-3.5.2.zip",
            checksum: "1e0440bb35cf4f9732e8037f09ab8a7bec465e3ed495428012d0dfd23402f765"
        ),
        .binaryTarget(
            name: "NovaCore",
            url: "https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/3.5.2/NovaCore.xcframework-3.5.2.zip",
            checksum: "0090a03aa2788ac02a877636ddc4c9ec0e8559771230d4a0b50e82448562b752"
        ),
        .binaryTarget(
            name: "MSPNovaAdapter",
            url: "https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/3.5.2/MSPNovaAdapter.xcframework-3.5.2.zip",
            checksum: "e2c797c84d6376d443434d844fdd24d3d582a5ae44f8e0186b23dc1bf701eee3"
        ),
        .binaryTarget(
            name: "MSPGoogleAdsTypes",
            url: "https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/3.5.2/MSPGoogleAdsTypes-3.5.2.zip",
            checksum: "c8dc05f59d0ad7b7f6d74b696087236e8e5c5cf916742f9c687c1bcd37310e95"
        ),
        .binaryTarget(
            name: "MSPGoogleAdapter",
            url: "https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/3.5.2/MSPGoogleAdapter-3.5.2.zip",
            checksum: "f63f5a2a834ff254be4e9431309913954ccd7687d7f26797da52a729c739b4f9"
        ),
        .binaryTarget(
            name: "MSPFacebookAdapter",
            url: "https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/3.5.2/MSPFacebookAdapter-3.5.2.zip",
            checksum: "7a456a38bdc36cc06642fe92f56ef65c6293a9355f65a85ca3bc556f0680a4ee"
        ),

        .target(
            name: "MSPCoreSPM",
            dependencies: [
                "MSPCore", "MSPiOSCore", "MSPSharedLibraries", "MSPPrebidAdapter",
                "PrebidMobile", "OMSDK_Newsbreak1",
            ]
        ),
        .target(
            name: "MSPNovaAdapterSPM",
            dependencies: ["MSPCoreSPM", "NovaCore", "MSPNovaAdapter"]
        ),
        .target(
            name: "MSPGoogleAdapterSPM",
            dependencies: [
                "MSPCoreSPM", "MSPGoogleAdsTypes", "MSPGoogleAdapter",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ]
        ),
        .target(
            name: "MSPFacebookAdapterSPM",
            dependencies: [
                "MSPCoreSPM", "MSPFacebookAdapter",
                .product(name: "FBAudienceNetwork", package: "FBAudienceNetwork"),
            ]
        ),
    ]
)
