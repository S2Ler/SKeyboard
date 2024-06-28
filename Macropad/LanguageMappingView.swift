import SwiftUI
import SwiftData
import KeyboardKit

struct LanguageMappingView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var languageMappings: [LanguageMapping]

  @State private var isNewItemPresented: Bool = false
  @State private var newItemKeyboardId: LanguageId?
  @State private var newItemSystemId: String = ""

  var body: some View {
    List {
      ForEach(languageMappings) { languageMapping in
        VStack(alignment: .leading) {
          Text("System id: \(languageMapping.systemId)")
          Text("Keyboard id: \(languageMapping.keyboardId)")
        }
        .contextMenu {
          Button("Delete") {
            modelContext.delete(languageMapping)
          }
        }
      }
    }
    .padding()
    .listStyle(BorderedListStyle())
    .toolbar {
      ToolbarItem {
        Button(action: addCurrentLanguageMapping) {
          Label("Add Item", systemImage: "plus")
        }
      }
    }
    .sheet(isPresented: $isNewItemPresented) {
      withAnimation {
        if let newItemKeyboardId, !newItemSystemId.isEmpty {
          let newItem = LanguageMapping(systemId: newItemSystemId, keyboardId: newItemKeyboardId)
          modelContext.insert(newItem)
        }
      }
    } content: {
      Form {
        TextField("System ID", text: $newItemSystemId)
        TextField("Keyboard ID", value: $newItemKeyboardId, format: .number)
        Button("Done") {
          isNewItemPresented = false
        }
      }
      .frame(width: 200)
      .padding()
    }
  }

  private func addCurrentLanguageMapping() {
    newItemSystemId = (try? InputSource.current()) ?? ""
    isNewItemPresented = true
  }
}
