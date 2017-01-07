import PackageDescription

let package = Package(
    name: "ToriAPNS",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/CCurl.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 15)
    ]
)
