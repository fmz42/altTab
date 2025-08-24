import Cocoa

class SwitcherView {
    
    private var window: NSWindow?
    private var stackView: NSStackView?
    private var applicationViews: [ApplicationItemView] = []
    private var applications: [ApplicationWindow] = []
    private var selectedIndex: Int = 0
    
    init(applications: [ApplicationWindow], selectedIndex: Int) {
        self.applications = applications
        self.selectedIndex = selectedIndex
        createWindow()
        setupViews()
    }
    
    func show() {
        guard let window = window else { return }
        
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let windowFrame = window.frame
            let x = (screenFrame.width - windowFrame.width) / 2 + screenFrame.minX
            let y = (screenFrame.height - windowFrame.height) / 2 + screenFrame.minY
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        window.makeKeyAndOrderFront(nil)
        window.level = .modalPanel
        
        updateSelection(selectedIndex)
    }
    
    func hide() {
        window?.close()
        window = nil
    }
    
    func updateSelection(_ newIndex: Int) {
        guard newIndex >= 0 && newIndex < applicationViews.count else { return }
        
        if selectedIndex >= 0 && selectedIndex < applicationViews.count {
            applicationViews[selectedIndex].isSelected = false
        }
        
        selectedIndex = newIndex
        applicationViews[selectedIndex].isSelected = true
    }
    
    private func createWindow() {
        let windowRect = NSRect(x: 0, y: 0, width: 600, height: 120)
        
        window = NSWindow(
            contentRect: windowRect,
            styleMask: [],
            backing: .buffered,
            defer: false
        )
        
        window?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.95)
        window?.isOpaque = false
        window?.hasShadow = true
        window?.level = .modalPanel
        window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        window?.contentView?.wantsLayer = true
        window?.contentView?.layer?.cornerRadius = 12
        window?.contentView?.layer?.masksToBounds = true
    }
    
    private func setupViews() {
        guard let window = window, let contentView = window.contentView else { return }
        
        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        stackView = NSStackView()
        guard let stackView = stackView else { return }
        stackView.orientation = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        for (index, appWindow) in applications.enumerated() {
            let appView = ApplicationItemView(frame: .zero)
            appView.configure(with: appWindow)
            appView.translatesAutoresizingMaskIntoConstraints = false
            
            applicationViews.append(appView)
            stackView.addArrangedSubview(appView)
            
            NSLayoutConstraint.activate([
                appView.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
                appView.heightAnchor.constraint(equalToConstant: 80)
            ])
            
            if index >= 8 {
                break
            }
        }
        
        let minWidth = min(applications.count * 108, 600)
        window.setContentSize(NSSize(width: minWidth + 32, height: 120))
    }
}
