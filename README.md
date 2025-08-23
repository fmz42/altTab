# AltTab para macOS Sequoia

Uma implementação nativa de Alt+Tab para macOS Sequoia, desenvolvida em Swift. Este projeto fornece uma interface visual elegante para alternar entre aplicações, similar ao Alt+Tab do Windows ou Linux.

## Características

- **Interface Visual Moderna**: UI limpa e intuitiva compatível com macOS Sequoia
- **Navegação com Teclado**: Use ⌘+Tab para navegar para frente e ⌘+⇧+Tab para navegar para trás
- **Suporte a Janelas Múltiplas**: Mostra todas as janelas abertas de cada aplicação
- **Ícones de Aplicação**: Exibe ícones das aplicações para fácil identificação
- **Permissões de Acessibilidade**: Integração completa com o sistema de acessibilidade do macOS
- **Background App**: Roda como aplicação de background sem dock icon

## Requisitos

- macOS 15.0 (Sequoia) ou superior
- Xcode 15.4 ou superior
- Permissões de acessibilidade habilitadas

## Instalação

### Compilação a partir do código-fonte

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/altTab.git
cd altTab
```

2. Abra o projeto no Xcode:
```bash
open AltTab.xcodeproj
```

3. Compile e execute o projeto (⌘+R)

4. Na primeira execução, o sistema solicitará permissões de acessibilidade:
   - Vá em **Preferências do Sistema** > **Segurança e Privacidade** > **Acessibilidade**
   - Adicione **AltTab** à lista de aplicações permitidas

## Uso

### Atalhos de Teclado

- **⌘+Tab**: Navegar para a próxima aplicação
- **⌘+⇧+Tab**: Navegar para a aplicação anterior
- **Escape**: Cancelar a navegação
- **Soltar ⌘**: Confirmar seleção e alternar para a aplicação

### Interface

A interface do AltTab aparece no centro da tela quando ativada, mostrando:
- Ícone de cada aplicação
- Nome da aplicação ou janela
- Indicador visual da seleção atual

## Arquitetura

O projeto está organizado nos seguintes componentes principais:

### AppDelegate.swift
- Ponto de entrada da aplicação
- Configuração inicial e verificação de permissões
- Gerenciamento do ciclo de vida da aplicação

### WindowSwitcher.swift
- Lógica principal de alternação entre janelas
- Gerenciamento da lista de aplicações
- Controle de navegação e seleção

### SwitcherView.swift
- Interface visual do switcher
- Exibição de ícones e nomes das aplicações
- Animações e transições visuais

### AccessibilityManager.swift
- Integração com APIs de acessibilidade do macOS
- Obtenção de informações sobre aplicações e janelas
- Ativação e foco de janelas

### HotKeyManager.swift
- Registro e gerenciamento de atalhos globais
- Integração com Carbon Framework para hotkeys
- Tratamento de eventos de teclado

## Configuração

### Permissões Necessárias

A aplicação requer as seguintes permissões:

1. **Acessibilidade**: Para acessar informações sobre janelas e aplicações
2. **Apple Events**: Para enviar comandos de ativação para outras aplicações

### Configurações Opcionais

O comportamento da aplicação pode ser customizado modificando os seguintes parâmetros:

- **Atalhos de teclado**: Modifique em `AppDelegate.setupHotKeys()`
- **Aparência da interface**: Ajuste cores e layout em `SwitcherView.swift`
- **Filtros de aplicação**: Configure quais aplicações aparecem em `AccessibilityManager.getRunningApplications()`

## Desenvolvimento

### Estrutura do Projeto

```
AltTab/
├── AltTab.xcodeproj/          # Projeto Xcode
├── AltTab/
│   ├── AppDelegate.swift      # Ponto de entrada
│   ├── WindowSwitcher.swift   # Lógica principal
│   ├── SwitcherView.swift     # Interface visual
│   ├── AccessibilityManager.swift # APIs de acessibilidade
│   ├── HotKeyManager.swift    # Gerenciamento de hotkeys
│   ├── Info.plist            # Configurações da aplicação
│   └── AltTab.entitlements   # Permissões necessárias
└── README.md
```

### Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

### Debugging

Para debug, você pode:

1. Habilitar logs detalhados adicionando prints nos métodos principais
2. Usar o Xcode debugger para inspecionar o estado da aplicação
3. Verificar permissões usando `AXIsProcessTrusted()`

## Solução de Problemas

### A aplicação não responde aos atalhos
- Verifique se as permissões de acessibilidade estão habilitadas
- Reinicie a aplicação após conceder permissões

### Janelas não são ativadas corretamente
- Certifique-se de que a aplicação de destino suporta Apple Events
- Verifique se a janela não está em um espaço diferente

### Interface não aparece
- Verifique se existem aplicações em execução
- Confirme que o monitor principal está detectado corretamente

## Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Agradecimentos

- Apple, pelas APIs de acessibilidade robustas do macOS
- Comunidade open-source por inspiração e feedback
- Desenvolvedores de ferramentas similares que pavimentaram o caminho

## Roadmap

- [ ] Suporte a previews de janelas
- [ ] Configurações personalizáveis via interface
- [ ] Suporte a múltiplos monitores
- [ ] Temas visuais customizáveis
- [ ] Estatísticas de uso de aplicações
