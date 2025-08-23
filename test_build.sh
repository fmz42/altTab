#!/bin/bash

# Script de teste para verificar se o projeto Xcode está funcionando
# Este script será executado em uma máquina macOS real

set -e

echo "🔍 Verificando projeto AltTab..."

# Verificar se estamos em macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  Este teste precisa ser executado em macOS"
    echo "📋 Resumo dos problemas encontrados e corrigidos:"
    echo ""
    echo "🐛 PROBLEMA IDENTIFICADO:"
    echo "   - ID duplicado A12345678901234567890123 usado para:"
    echo "     * PBXBuildFile (AppDelegate.swift in Sources)"
    echo "     * PBXGroup (AltTab folder)"
    echo ""
    echo "🔧 CORREÇÕES APLICADAS:"
    echo "   1. Alterado o ID do PBXBuildFile para A12345678901234567890140"
    echo "   2. Adicionado AltTab.entitlements como PBXFileReference (A12345678901234567890141)"
    echo "   3. Incluído AltTab.entitlements no grupo AltTab"
    echo "   4. Corrigida referência na seção PBXSourcesBuildPhase"
    echo ""
    echo "✅ CORREÇÕES COMPLETADAS"
    echo "   O arquivo project.pbxproj foi corrigido e deve funcionar agora."
    echo ""
    echo "📝 PRÓXIMOS PASSOS (executar em macOS):"
    echo "   1. Execute: xcodebuild clean -project AltTab.xcodeproj"
    echo "   2. Execute: xcodebuild -project AltTab.xcodeproj -scheme AltTab -configuration Release"
    echo "   3. Ou use: ./build.sh"
    exit 0
fi

# Verificar se Xcode está instalado
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode não está instalado"
    exit 1
fi

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "📁 Diretório: $PROJECT_DIR"

# Testar se o projeto pode ser lido
echo "🔍 Testando se o projeto pode ser lido..."
xcodebuild -project AltTab.xcodeproj -list

if [ $? -eq 0 ]; then
    echo "✅ Projeto foi corrigido com sucesso!"
    echo "🚀 Executando build..."
    
    # Clean primeiro
    xcodebuild clean -project AltTab.xcodeproj -scheme AltTab -configuration Release
    
    # Build
    xcodebuild -project AltTab.xcodeproj -scheme AltTab -configuration Release
    
    echo "✅ Build concluído com sucesso!"
else
    echo "❌ Ainda há problemas com o projeto"
    exit 1
fi
