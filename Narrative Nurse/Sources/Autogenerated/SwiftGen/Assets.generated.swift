// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Assets {
  internal static let arrowRight = ImageAsset(name: "arrowRight")
  internal static let closeMenu = ImageAsset(name: "closeMenu")
  internal static let email = ImageAsset(name: "email")
  internal static let history = ImageAsset(name: "history")
  internal static let info = ImageAsset(name: "info")
  internal static let logoOneRow = ImageAsset(name: "logoOneRow")
  internal static let logoTwoRowsDark = ImageAsset(name: "logoTwoRowsDark")
  internal static let logoTwoRowsLight = ImageAsset(name: "logoTwoRowsLight")
  internal static let menu = ImageAsset(name: "menu")
  internal static let moreMenuIcon = ImageAsset(name: "moreMenuIcon")
  internal static let print = ImageAsset(name: "print")
  internal static let questionsFooter = ImageAsset(name: "questionsFooter")
  internal static let questionsFooterWithShadow = ImageAsset(name: "questionsFooterWithShadow")
  internal static let resultPreview = ImageAsset(name: "resultPreview")
  internal static let security = ImageAsset(name: "security")
  internal static let settings = ImageAsset(name: "settings")
  internal static let share = ImageAsset(name: "share")
  internal static let sound = ImageAsset(name: "sound")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
