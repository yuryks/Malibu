// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Malibu",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9)
    ],
    products: [
        .library(name: "Malibu",
                 targets: ["Malibu"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git",
                 .upToNextMinor(from: "2.2.0")),
        .package(url: "https://github.com/Quick/Nimble.git",
                 .upToNextMinor(from: "8.0.5")),
        .package(url: "https://github.com/yuryks/When.git",
                 .upToNextMajor(from: "4.0.0"))
//        .package(url: "https://github.com/vadymmarkov/When.git",
//                 .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        .target(name: "Malibu",
                dependencies: ["When"],
                path: "Sources"),
        .testTarget(name: "MalibuTests",
                    dependencies: ["Malibu", "When", "Quick", "Nimble"],
                    path: "MalibuTests"),
    ],
    swiftLanguageVersions: [.v5]
)
