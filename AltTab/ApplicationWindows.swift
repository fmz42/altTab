import AppKit

struct ApplicationWindow: Identifiable {
    let id = UUID()
    let app: NSRunningApplication
    let window: AXUIElement? // Tornar a janela opcional
    
    var appName: String {
        return app.localizedName ?? "Unknown"
    }
    
    var appIcon: NSImage? {
        return app.icon
    }
    
    var title: String {
        if let window = window {
            var titleRef: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef)
            if result == .success, let title = titleRef as? String {
                return title
            }
        }
        return appName
    }
    
    // Inicializador que aceita uma janela opcional
    init(app: NSRunningApplication, window: AXUIElement? = nil) {
        self.app = app
        self.window = window
    }
}
