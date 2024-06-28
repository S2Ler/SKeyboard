public struct LayerMapping {
  public let appBundleId: AppBundleId
  public let layerIdx: LayerIndex

  public init(
    appBundleId: AppBundleId,
    layerIdx: LayerIndex
  ) {
    self.appBundleId = appBundleId
    self.layerIdx = layerIdx
  }
}
