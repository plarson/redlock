import PackageDescription

var package = Package(
    name: "Redlock",
    targets: [
        Target(name: "Redlock")
    ],
    dependencies: [
        .Package(url: "https://github.com/plarson/redscript.git", majorVersion: 0, minor: 1)
        ]
)

let lib = Product(name: "Redlock", type: .Library(.Dynamic), modules: "Redlock")
