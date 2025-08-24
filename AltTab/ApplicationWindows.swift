import AppKit

struct ApplicationWindow: Identifiable {
    let id = UUID()
    let app: NSRunningApplication
    let window: AXUIElement
    
    var appName: String {
        return app.localizedName ?? "Unknown"
    }
    
    var appIcon: NSImage? {
        return app.icon
    }
    
    var windowTitle: String? {
        var titleRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef)
        guard result == .success else { return nil }
        return titleRef as? String
    }
}
