import SwiftUI
import SwiftData

struct LayersMappingView: View {
  @Environment(\.state) var state

  var body: some View {
    List {
      ForEach(state.layerMappings) { layerMapping in
        VStack(alignment: .leading) {
          Text("App bundle id: \(layerMapping.appBundleId)")
          Text("Layer id: \(layerMapping.layerIdx)")
        }
      }
      .onDelete(perform: deleteLayerMappings)
    }
    .listStyle(BorderedListStyle())
    .toolbar {
      ToolbarItem {
        Button(action: addNewLayerMapping) {
          Label("Add Item", systemImage: "plus")
        }
      }
    }
  }

  private func addNewLayerMapping() {
    withAnimation {
      modelContext.insert(LayerMapping(appBundleId: "com.apple.safari", layerIdx: 2))
    }
  }

  private func deleteLayerMappings(at offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(layerMappings[index])
      }
    }
  }
}
