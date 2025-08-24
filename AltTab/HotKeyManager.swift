import Cocoa
import Carbon

typealias HotKeyHandler = () -> Void

class HotKeyManager {
    
    private var hotKeys: [UInt32: (EventHotKeyRef, HotKeyHandler)] = [:]
    private var nextHotKeyID: UInt32 = 1
    
    init() {
        // Instalar event handler global para hot keys
        let eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                     eventKind: OSType(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(),
                           hotKeyEventHandler,
                           1,
                           [eventSpec],
                           UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                           nil)
    }
    
    deinit {
        unregisterAllHotKeys()
    }
    
    func registerHotKey(keyCode: UInt32, modifierFlags: NSEvent.ModifierFlags, handler: @escaping HotKeyHandler) -> UInt32? {
        let hotKeyID = nextHotKeyID
        nextHotKeyID += 1
        
        let carbonModifiers = convertToCarbonModifiers(modifierFlags)
        
        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(keyCode,
                                       carbonModifiers,
                                       EventHotKeyID(signature: fourCharCode(from: "ALTB"), id: hotKeyID),
                                       GetApplicationEventTarget(),
                                       0,
                                       &hotKeyRef)
        
        if status == noErr, let hotKey = hotKeyRef {
            hotKeys[hotKeyID] = (hotKey, handler)
            return hotKeyID
        }
        
        return nil
    }
    
    func unregisterHotKey(_ hotKeyID: UInt32) {
        if let (hotKeyRef, _) = hotKeys[hotKeyID] {
            UnregisterEventHotKey(hotKeyRef)
            hotKeys.removeValue(forKey: hotKeyID)
        }
    }
    
    func unregisterAllHotKeys() {
        for (hotKeyID, _) in hotKeys {
            unregisterHotKey(hotKeyID)
        }
    }
    
    private func convertToCarbonModifiers(_ modifierFlags: NSEvent.ModifierFlags) -> UInt32 {
        var carbonModifiers: UInt32 = 0
        
        if modifierFlags.contains(.command) {
            carbonModifiers |= UInt32(cmdKey)
        }
        if modifierFlags.contains(.option) {
            carbonModifiers |= UInt32(optionKey)
        }
        if modifierFlags.contains(.control) {
            carbonModifiers |= UInt32(controlKey)
        }
        if modifierFlags.contains(.shift) {
            carbonModifiers |= UInt32(shiftKey)
        }
        
        return carbonModifiers
    }
    
    fileprivate func handleHotKeyEvent(_ hotKeyID: UInt32) {
        if let (_, handler) = hotKeys[hotKeyID] {
            handler()
        }
    }
    
    private func fourCharCode(from string: String) -> FourCharCode {
        return string.utf16.reduce(0, {$0 << 8 + FourCharCode($1)})
    }
}

// Event handler global para hot keys
private func hotKeyEventHandler(nextHandler: EventHandlerCallRef?,
                               event: EventRef?,
                               userData: UnsafeMutableRawPointer?) -> OSStatus {
    
    guard let userData = userData,
          let event = event else {
        return OSStatus(eventNotHandledErr)
    }
    
    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(event,
                                  OSType(kEventParamDirectObject),
                                  OSType(typeEventHotKeyID),
                                  nil,
                                  MemoryLayout<EventHotKeyID>.size,
                                  nil,
                                  &hotKeyID)
    
    if status == noErr {
        let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
        manager.handleHotKeyEvent(hotKeyID.id)
        return noErr
    }
    
    return OSStatus(eventNotHandledErr)
}
