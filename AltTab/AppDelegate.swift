import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var windowSwitcher: WindowSwitcher!
    private var accessibilityManager: AccessibilityManager!
    private var hotKeyManager: HotKeyManager!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Configurar a aplicação para rodar em background
        NSApp.setActivationPolicy(.accessory)
        
        // Inicializar os componentes principais
        accessibilityManager = AccessibilityManager()
        windowSwitcher = WindowSwitcher()
        hotKeyManager = HotKeyManager()
        
        // Verificar permissões de acessibilidade
        if !accessibilityManager.checkAccessibilityPermissions() {
            showAccessibilityAlert()
            return
        }
        
        // Configurar atalhos de teclado
        setupHotKeys()
        
        print("AltTab iniciado com sucesso!")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Limpar recursos
        hotKeyManager?.unregisterAllHotKeys()
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    private func setupHotKeys() {
        // Registrar Command+Tab (ou Alt+Tab)
        hotKeyManager.registerHotKey(
            keyCode: 48, // Tab key
            modifierFlags: .command
        ) { [weak self] in
            self?.windowSwitcher.showSwitcher()
        }
        
        // Registrar Command+Shift+Tab para navegação reversa
        hotKeyManager.registerHotKey(
            keyCode: 48, // Tab key
            modifierFlags: [.command, .shift]
        ) { [weak self] in
            self?.windowSwitcher.showSwitcher(reverse: true)
        }
    }
    
    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Permissão de Acessibilidade Necessária"
        alert.informativeText = "AltTab precisa de permissão de acessibilidade para funcionar. Por favor, vá em Preferências do Sistema > Segurança e Privacidade > Acessibilidade e adicione AltTab à lista de aplicações permitidas."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Abrir Preferências do Sistema")
        alert.addButton(withTitle: "Cancelar")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
        
        NSApp.terminate(nil)
    }
}
