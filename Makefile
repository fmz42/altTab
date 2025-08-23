# Makefile para AltTab macOS

.PHONY: build clean run install help

# Configurações
PROJECT_NAME = AltTab
SCHEME = AltTab
CONFIGURATION = Release
BUILD_DIR = build
APP_NAME = $(PROJECT_NAME).app

# Target padrão
all: build

# Compilar o projeto
build:
	@echo "🔨 Compilando $(PROJECT_NAME)..."
	@./build.sh

# Limpar arquivos de build
clean:
	@echo "🧹 Limpando arquivos de build..."
	@rm -rf $(BUILD_DIR)
	@xcodebuild clean -project $(PROJECT_NAME).xcodeproj -scheme $(SCHEME) -configuration $(CONFIGURATION) 2>/dev/null || true

# Executar a aplicação
run: build
	@echo "🚀 Executando $(PROJECT_NAME)..."
	@open "$(BUILD_DIR)/Products/$(CONFIGURATION)/$(APP_NAME)"

# Instalar na pasta Applications
install: build
	@echo "📦 Instalando $(PROJECT_NAME) em /Applications..."
	@sudo cp -R "$(BUILD_DIR)/Products/$(CONFIGURATION)/$(APP_NAME)" /Applications/
	@echo "✅ $(PROJECT_NAME) instalado com sucesso!"
	@echo "💡 Não esqueça de conceder permissões de acessibilidade"

# Abrir o projeto no Xcode
xcode:
	@echo "🛠️ Abrindo projeto no Xcode..."
	@open $(PROJECT_NAME).xcodeproj

# Verificar dependências
check:
	@echo "🔍 Verificando dependências..."
	@command -v xcodebuild >/dev/null 2>&1 || { echo "❌ Xcode não está instalado"; exit 1; }
	@echo "✅ Xcode encontrado"
	@sw_vers | grep "ProductVersion"

# Mostrar informações do projeto
info:
	@echo "📋 Informações do projeto:"
	@echo "  Nome: $(PROJECT_NAME)"
	@echo "  Scheme: $(SCHEME)"
	@echo "  Configuração: $(CONFIGURATION)"
	@echo "  Diretório de build: $(BUILD_DIR)"

# Remover aplicação das Applications
uninstall:
	@echo "🗑️ Removendo $(PROJECT_NAME) de /Applications..."
	@sudo rm -rf "/Applications/$(APP_NAME)"
	@echo "✅ $(PROJECT_NAME) removido com sucesso!"

# Debug build
debug:
	@echo "🐛 Compilando em modo debug..."
	@xcodebuild build \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration Debug \
		-destination "generic/platform=macOS"

# Mostrar ajuda
help:
	@echo "📖 Comandos disponíveis:"
	@echo "  make build     - Compilar o projeto"
	@echo "  make clean     - Limpar arquivos de build"
	@echo "  make run       - Compilar e executar"
	@echo "  make install   - Instalar em /Applications"
	@echo "  make uninstall - Remover de /Applications"
	@echo "  make xcode     - Abrir no Xcode"
	@echo "  make check     - Verificar dependências"
	@echo "  make info      - Mostrar informações do projeto"
	@echo "  make debug     - Build em modo debug"
	@echo "  make help      - Mostrar esta ajuda"
