import PackageDescription

let package = Package(
    name: "ToriAPNS",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 0)
    ]
)
