import Cocoa
import ApplicationServices

class AccessibilityManager {
    
    func checkAccessibilityPermissions() -> Bool {
        return AXIsProcessTrusted()
    }
    
    func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    func getRunningApplications() -> [NSRunningApplication] {
        return NSWorkspace.shared.runningApplications.filter { app in
            app.activationPolicy == .regular &&
            !app.isTerminated &&
            app.localizedName != nil
        }
    }
    
    func getWindowsForApplication(_ app: NSRunningApplication) -> [AXUIElement] {
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        
        var windowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef)
        
        guard result == .success,
              let windows = windowsRef as? [AXUIElement] else {
            return []
        }
        
        return windows
    }
    
    func activateApplication(_ app: NSRunningApplication) {
        app.activate(options: [])
    }
    
    func getApplicationIcon(_ app: NSRunningApplication) -> NSImage? {
        return app.icon
    }
    
    func getApplicationName(_ app: NSRunningApplication) -> String {
        return app.localizedName ?? "Unknown"
    }

    func getWindowTitle(window: AXUIElement) -> String {
        var titleRef: AnyObject?
        let result = AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef)

        if result == .success, let title = titleRef as? String {
            return title
        }
        return ""
    }

    func focusWindow(_ window: AXUIElement) {
        AXUIElementSetAttributeValue(window, kAXMainAttribute as CFString, kCFBooleanTrue)
        AXUIElementSetAttributeValue(window, kAXFocusedAttribute as CFString, kCFBooleanTrue)
    }

    func unminimizeWindow(_ window: AXUIElement) {
        if isWindowMinimized(window: window) {
            AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString, kCFBooleanFalse)
        }
    }

    func isWindowMinimized(window: AXUIElement) -> Bool {
        var isMinimized: AnyObject?
        AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &isMinimized)
        return (isMinimized as? NSNumber)?.boolValue ?? false
    }
}
