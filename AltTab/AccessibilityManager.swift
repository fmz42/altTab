import Cocoa
import ApplicationServices

class AccessibilityManager {
    
    func checkAccessibilityPermissions() -> Bool {
        let trusted = AXIsProcessTrusted()
        return trusted
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
        guard let appElement = AXUIElementCreateApplication(app.processIdentifier) else {
            return []
        }
        
        var windowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute, &windowsRef)
        
        guard result == .success,
              let windows = windowsRef as? [AXUIElement] else {
            return []
        }
        
        return windows.filter { window in
            // Filtrar apenas janelas visíveis e minimizáveis
            var isMinimized: CFTypeRef?
            AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute, &isMinimized)
            
            if let minimized = isMinimized as? Bool, minimized {
                return true // Incluir janelas minimizadas
            }
            
            var position: CFTypeRef?
            AXUIElementCopyAttributeValue(window, kAXPositionAttribute, &position)
            
            return position != nil
        }
    }
    
    func activateApplication(_ app: NSRunningApplication) {
        app.activate(options: [.activateIgnoringOtherApps])
    }
    
    func getApplicationIcon(_ app: NSRunningApplication) -> NSImage? {
        return app.icon
    }
    
    func getApplicationName(_ app: NSRunningApplication) -> String {
        return app.localizedName ?? "Unknown"
    }
    
    func getWindowTitle(_ window: AXUIElement) -> String? {
        var titleRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, kAXTitleAttribute, &titleRef)
        
        guard result == .success else { return nil }
        return titleRef as? String
    }
    
    func focusWindow(_ window: AXUIElement) {
        // Primeiro, tentar trazer a janela para frente
        AXUIElementSetAttributeValue(window, kAXMainAttribute, kCFBooleanTrue)
        AXUIElementSetAttributeValue(window, kAXFocusedAttribute, kCFBooleanTrue)
        
        // Se a janela estiver minimizada, restaurá-la
        var isMinimized: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute, &isMinimized)
        
        if result == .success, let minimized = isMinimized as? Bool, minimized {
            AXUIElementSetAttributeValue(window, kAXMinimizedAttribute, kCFBooleanFalse)
        }
    }
}
