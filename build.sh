#!/bin/bash

# Script de build para AltTab
# Este script compila o projeto AltTab para macOS

set -e

echo "🚀 Iniciando build do AltTab para macOS Sequoia..."

# Verificar se estamos em um sistema macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Este script deve ser executado em macOS"
    exit 1
fi

# Verificar se Xcode está instalado
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode não está instalado. Por favor, instale o Xcode."
    exit 1
fi

# Diretório do projeto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# Configurações de build
PROJECT_NAME="AltTab"
SCHEME="AltTab"
CONFIGURATION="Release"
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
EXPORT_PATH="$BUILD_DIR/Export"

echo "📁 Diretório do projeto: $PROJECT_DIR"
echo "🔧 Configuração: $CONFIGURATION"

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Clean do projeto
echo "🧽 Executando clean do projeto..."
xcodebuild clean \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION"

# Build do projeto
echo "🔨 Compilando o projeto..."
xcodebuild build \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "generic/platform=macOS" \
    BUILD_DIR="$BUILD_DIR" \
    OBJROOT="$BUILD_DIR/Intermediates" \
    SYMROOT="$BUILD_DIR/Products"

# Verificar se o build foi bem-sucedido
if [ $? -eq 0 ]; then
    echo "✅ Build concluído com sucesso!"
    echo "📦 Aplicação compilada em: $BUILD_DIR/Products/$CONFIGURATION/"
    
    # Criar um alias na área de trabalho (opcional)
    APP_PATH="$BUILD_DIR/Products/$CONFIGURATION/$PROJECT_NAME.app"
    if [ -d "$APP_PATH" ]; then
        echo "🔗 Aplicação encontrada em: $APP_PATH"
        echo ""
        echo "Para instalar o AltTab:"
        echo "1. Copie '$PROJECT_NAME.app' para /Applications/"
        echo "2. Execute a aplicação"
        echo "3. Conceda permissões de acessibilidade quando solicitado"
        echo ""
        echo "Para testar diretamente:"
        echo "open '$APP_PATH'"
    fi
    
else
    echo "❌ Falha no build!"
    exit 1
fi

echo ""
echo "🎉 Build do AltTab concluído!"
echo "💡 Lembre-se de conceder permissões de acessibilidade em:"
echo "   Preferências do Sistema > Segurança e Privacidade > Acessibilidade"
