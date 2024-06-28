import KeyboardKit
import SwiftUI

private struct StateEnvironmentKey: EnvironmentKey {
  static let defaultValue: State = State(
    layerMappings: [],
    languageMappings: []
  )
}

extension EnvironmentValues {
    var state: State {
        get { self[StateEnvironmentKey.self] }
        set { self[StateEnvironmentKey.self] = newValue }
    }
}
