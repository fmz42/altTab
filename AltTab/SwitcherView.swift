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
        
        // Centralizar na tela
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
        
        // Remover seleção anterior
        if selectedIndex >= 0 && selectedIndex < applicationViews.count {
            applicationViews[selectedIndex].setSelected(false)
        }
        
        // Aplicar nova seleção
        selectedIndex = newIndex
        applicationViews[selectedIndex].setSelected(true)
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
        
        // Adicionar borda arredondada
        window?.contentView?.wantsLayer = true
        window?.contentView?.layer?.cornerRadius = 12
        window?.contentView?.layer?.masksToBounds = true
    }
    
    private func setupViews() {
        guard let window = window else { return }
        
        // Criar container principal
        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        window.contentView?.addSubview(containerView)
        
        // Criar stack view horizontal para as aplicações
        stackView = NSStackView()
        stackView?.orientation = .horizontal
        stackView?.distribution = .fillEqually
        stackView?.spacing = 8
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stackView!)
        
        // Adicionar constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: window.contentView!.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: window.contentView!.bottomAnchor, constant: -16),
            
            stackView!.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView!.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView!.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView!.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Adicionar views das aplicações
        for (index, application) in applications.enumerated() {
            let appView = ApplicationItemView(application: application)
            appView.translatesAutoresizingMaskIntoConstraints = false
            
            applicationViews.append(appView)
            stackView?.addArrangedSubview(appView)
            
            // Limitar a largura máxima
            NSLayoutConstraint.activate([
                appView.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
                appView.heightAnchor.constraint(equalToConstant: 80)
            ])
            
            // Parar se tivermos muitas aplicações para evitar overflow
            if index >= 8 {
                break
            }
        }
        
        // Ajustar tamanho da janela baseado no conteúdo
        let minWidth = min(applications.count * 108, 600)
        window.setContentSize(NSSize(width: minWidth + 32, height: 120))
    }
}

class ApplicationItemView: NSView {
    
    private let application: ApplicationWindow
    private var imageView: NSImageView!
    private var label: NSTextField!
    private var isSelected: Bool = false
    
    init(application: ApplicationWindow) {
        self.application = application
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        wantsLayer = true
        layer?.cornerRadius = 8
        
        // Configurar imagem da aplicação
        imageView = NSImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.image = application.icon ?? NSImage(named: "NSDefaultApplicationIcon")
        addSubview(imageView)
        
        // Configurar label do nome
        label = NSTextField(labelWithString: application.title)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 11)
        label.textColor = NSColor.labelColor
        label.alignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.maximumNumberOfLines = 2
        addSubview(label)
        
        // Configurar constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -4)
        ])
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        
        if selected {
            layer?.backgroundColor = NSColor.selectedControlColor.cgColor
            layer?.borderWidth = 2
            layer?.borderColor = NSColor.controlAccentColor.cgColor
            label.textColor = NSColor.selectedControlTextColor
        } else {
            layer?.backgroundColor = NSColor.clear.cgColor
            layer?.borderWidth = 0
            label.textColor = NSColor.labelColor
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if isSelected {
            NSColor.selectedControlColor.withAlphaComponent(0.3).setFill()
            dirtyRect.fill()
        }
    }
}
