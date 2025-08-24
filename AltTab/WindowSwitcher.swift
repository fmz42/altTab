import Cocoa

struct ApplicationWindow {
    let application: NSRunningApplication
    let window: AXUIElement?
    let title: String
    let icon: NSImage?
    
    init(application: NSRunningApplication, window: AXUIElement? = nil) {
        self.application = application
        self.window = window
        
        if let window = window {
            let accessibilityManager = AccessibilityManager()
            self.title = accessibilityManager.getWindowTitle(window: window) 
        } else {
            self.title = application.localizedName ?? "Unknown"
        }
        
        self.icon = application.icon
    }
}

class WindowSwitcher {
    
    private var switcherView: SwitcherView?
    private var accessibilityManager: AccessibilityManager
    private var currentApplications: [ApplicationWindow] = []
    private var selectedIndex: Int = 0
    private var isVisible: Bool = false
    private var eventMonitor: Any?
    
    init() {
        self.accessibilityManager = AccessibilityManager()
    }
    
    func showSwitcher(reverse: Bool = false) {
        if isVisible {
            // Se já estiver visível, apenas navegar
            if reverse {
                selectPrevious()
            } else {
                selectNext()
            }
            return
        }
        
        // Obter aplicações em execução
        currentApplications = getApplicationWindows()
        
        guard !currentApplications.isEmpty else {
            return
        }
        
        // Encontrar aplicação atual para iniciar a seleção
        selectedIndex = findCurrentApplicationIndex()
        
        // Se estamos navegando em reverso, ir para o item anterior
        if reverse {
            selectPrevious()
        } else {
            selectNext()
        }
        
        // Mostrar a interface
        showInterface()
        
        // Configurar monitoramento de eventos
        setupEventMonitoring()
        
        isVisible = true
    }
    
    func hideSwitcher() {
        guard isVisible else { return }
        
        // Ativar aplicação selecionada
        if selectedIndex >= 0 && selectedIndex < currentApplications.count {
            let selectedApp = currentApplications[selectedIndex]
            
            if let window = selectedApp.window {
                accessibilityManager.focusWindow(window)
            }
            
            accessibilityManager.activateApplication(selectedApp.application)
        }
        
        // Ocultar interface
        hideInterface()
        
        // Remover monitoramento de eventos
        removeEventMonitoring()
        
        isVisible = false
        currentApplications.removeAll()
    }
    
    private func getApplicationWindows() -> [ApplicationWindow] {
        let apps = accessibilityManager.getRunningApplications()
        var windows: [ApplicationWindow] = []
        
        for app in apps {
            let appWindows = accessibilityManager.getWindowsForApplication(app)
            
            if appWindows.isEmpty {
                // Adicionar a aplicação mesmo sem janelas específicas
                windows.append(ApplicationWindow(application: app))
            } else {
                // Adicionar cada janela da aplicação
                for window in appWindows {
                    windows.append(ApplicationWindow(application: app, window: window))
                }
            }
        }
        
        // Ordenar por uso recente (aplicações ativas primeiro)
        return windows.sorted { window1, window2 in
            if window1.application.isActive && !window2.application.isActive {
                return true
            }
            if !window1.application.isActive && window2.application.isActive {
                return false
            }
            return window1.application.processIdentifier > window2.application.processIdentifier
        }
    }
    
    private func findCurrentApplicationIndex() -> Int {
        guard let currentApp = NSWorkspace.shared.frontmostApplication else {
            return 0
        }
        
        for (index, window) in currentApplications.enumerated() {
            if window.application.processIdentifier == currentApp.processIdentifier {
                return index
            }
        }
        
        return 0
    }
    
    private func selectNext() {
        guard !currentApplications.isEmpty else { return }
        selectedIndex = (selectedIndex + 1) % currentApplications.count
        updateInterface()
    }
    
    private func selectPrevious() {
        guard !currentApplications.isEmpty else { return }
        selectedIndex = selectedIndex > 0 ? selectedIndex - 1 : currentApplications.count - 1
        updateInterface()
    }
    
    private func showInterface() {
        guard !currentApplications.isEmpty else { return }
        
        switcherView = SwitcherView(applications: currentApplications, selectedIndex: selectedIndex)
        switcherView?.show()
    }
    
    private func hideInterface() {
        switcherView?.hide()
        switcherView = nil
    }
    
    private func updateInterface() {
        switcherView?.updateSelection(selectedIndex)
    }
    
    private func setupEventMonitoring() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged]) { [weak self] event in
            self?.handleKeyEvent(event)
        }
    }
    
    private func removeEventMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        switch event.type {
        case .keyDown:
            if event.keyCode == 48 { // Tab key
                if event.modifierFlags.contains(.shift) {
                    selectPrevious()
                } else {
                    selectNext()
                }
            } else if event.keyCode == 53 { // Escape key
                isVisible = false
                hideInterface()
                removeEventMonitoring()
            }
            
        case .keyUp:
            // Verificar se Option foi solto
            if event.keyCode == 58 { // Option key
                hideSwitcher()
            }
            
        case .flagsChanged:
            // Se Option foi solto, finalizar switching
            if !event.modifierFlags.contains(.option) {
                hideSwitcher()
            }
            
        default:
            break
        }
    }
}
