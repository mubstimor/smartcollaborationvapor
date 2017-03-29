import PackageDescription

let package = Package(
    name: "SmartCollaborationVapor",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/vapor/postgresql-provider", majorVersion: 1, minor: 0),
        .Package(url:"https://github.com/anthonycastelli/vapor-stripe.git", majorVersion: 0, minor: 3)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

// .Package(url:"https://github.com/anthonycastelli/vapor-stripe.git", majorVersion: 0, minor: 3)
// .Package(url:"https://github.com/gomfucius/vapor-stripe.git", majorVersion: 0, minor: 2)
