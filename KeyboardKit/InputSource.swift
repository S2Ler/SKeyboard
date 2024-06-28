import Carbon

public struct InputSource {
  public enum Error: Swift.Error {
    case brokenAPI
  }

  public static func currentId() throws -> SystemInputSourceId {
    guard let rawInputSource: Unmanaged<TISInputSource> = TISCopyCurrentKeyboardInputSource() else {
      throw Error.brokenAPI
    }

    defer {
      rawInputSource.release()
    }

    guard let rawInputSourceId = TISGetInputSourceProperty(
      rawInputSource.takeUnretainedValue(),
      kTISPropertyInputSourceID
    ) else {
      throw Error.brokenAPI
    }

    let sourceId = Unmanaged<CFString>.fromOpaque(rawInputSourceId).takeUnretainedValue() as String
    return .init(rawValue: sourceId)
  }

  public static func onChanged() -> some AsyncSequence {
    DistributedNotificationCenter.default().notifications(named: .tisNotifySelectedKeyboardInputSourceChanged)
  }
}

extension Notification.Name {
  fileprivate static var tisNotifySelectedKeyboardInputSourceChanged: Self {
    Self(kTISNotifySelectedKeyboardInputSourceChanged as String)
  }
}


// public func set() -> String {
//    let filter = command == "list" ? nil : [kTISPropertyInputSourceID: command]
//
//    TISCreateInputSourceList(nil, false)
//    guard let cfSources = TISCreateInputSourceList(filter as CFDictionary?, false),
//          let sources = cfSources.takeRetainedValue() as? [TISInputSource] else {
//        print("Use \"list\" as an argument to list all enabled input sources.")
//        exit(-1)
//    }
//
//    if filter == nil { // Print all sources
//        print("Change input source by passing one of these names as an argument:")
//        sources.forEach {
//            let cfID = TISGetInputSourceProperty($0, kTISPropertyInputSourceID)!
//            print(Unmanaged<CFString>.fromOpaque(cfID).takeUnretainedValue() as String)
//        }
//    } else if let firstSource = sources.first { // Select this source
//        exit(TISSelectInputSource(firstSource))
//    }
//    TISSelectInputSource()
//  return ""
//}
