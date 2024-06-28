import KeyboardKit

public struct State {
  public var layerMappings: [LayerMapping]
  public var languageMappings: [LanguageMapping]

  public static var empty: Self {
    .init(
      layerMappings: [],
      languageMappings: []
    )
  }
}
