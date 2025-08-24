import Cocoa

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
            let selected = currentApplications[selectedIndex]
            
            if let window = selected.window {
                accessibilityManager.focusWindow(window)
            }
            
            accessibilityManager.activateApplication(selected.app)
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
                windows.append(ApplicationWindow(app: app))
            } else {
                // Adicionar cada janela da aplicação
                for window in appWindows {
                    windows.append(ApplicationWindow(app: app, window: window))
                }
            }
        }
        
        // Ordenar por uso recente (aplicações ativas primeiro)
        return windows.sorted { w1, w2 in
            if w1.app.isActive && !w2.app.isActive { return true }
            if !w1.app.isActive && w2.app.isActive { return false }
            return w1.app.processIdentifier > w2.app.processIdentifier
        }
    }
    
    private func findCurrentApplicationIndex() -> Int {
        guard let currentApp = NSWorkspace.shared.frontmostApplication else {
            return 0
        }
        
        for (index, appWindow) in currentApplications.enumerated() {
            if appWindow.app.processIdentifier == currentApp.processIdentifier {
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
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyUp) { [weak self] event in
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
        // Verifica se a tecla Option (Alt) foi solta
        if event.keyCode == 58 && !event.modifierFlags.contains(.option) {
            hideSwitcher()
        }
    }
}
