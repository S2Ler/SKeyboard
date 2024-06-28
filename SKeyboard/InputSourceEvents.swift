import AppKit
import Carbon

let k = {
  let keyboard = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
  let keyboardString = String(describing: keyboard)
  return keyboardString
}()
