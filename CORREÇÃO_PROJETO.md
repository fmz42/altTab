# Correção do Erro do AltTab Build

## 🐛 Problema Identificado

O erro `xcodebuild: error: Unable to read project 'AltTab.xcodeproj'` com a exceção `-[PBXGroup buildPhase]: unrecognized selector` estava sendo causado por um **conflito de IDs** no arquivo `project.pbxproj`.

### Detalhes do Problema:
- O ID `A12345678901234567890123` estava sendo usado para dois objetos diferentes:
  1. **PBXBuildFile** (AppDelegate.swift in Sources)  
  2. **PBXGroup** (pasta AltTab)

Isso criava uma ambiguidade que o Xcode não conseguia resolver, resultando no erro de "unrecognized selector".

## 🔧 Correções Aplicadas

### 1. Correção do ID Conflitante
- **Alterado**: ID do PBXBuildFile de `A12345678901234567890123` para `A12345678901234567890140`
- **Mantido**: ID do PBXGroup como `A12345678901234567890123`

### 2. Adição do Arquivo Entitlements
- **Adicionado**: `AltTab.entitlements` como PBXFileReference com ID `A12345678901234567890141`
- **Incluído**: Arquivo entitlements no grupo AltTab

### 3. Correção das Referências
- **Atualizado**: Referência na seção PBXSourcesBuildPhase para usar o novo ID
- **Verificado**: Todas as seções obrigatórias estão presentes e corretas

### 4. Melhoria do Script de Build
- **Adicionada**: Verificação de integridade do projeto antes do build
- **Melhorada**: Mensagens de erro mais claras

## ✅ Resultado

O arquivo `project.pbxproj` foi corrigido e agora deve funcionar corretamente no macOS. 

### Para testar (no macOS):
```bash
# Teste rápido
xcodebuild -project AltTab.xcodeproj -list

# Build completo
./build.sh
```

## 📋 Arquivos Modificados

1. `AltTab.xcodeproj/project.pbxproj` - Correções estruturais
2. `build.sh` - Adicionada verificação de integridade
3. `test_build.sh` - Script de teste e diagnóstico criado

## 🔍 Verificações Realizadas

- ✅ Estrutura balanceada (chaves, parênteses)
- ✅ Todas as seções obrigatórias presentes  
- ✅ rootObject definido corretamente
- ✅ Arquivo entitlements incluído
- ✅ Referências corrigidas

O projeto está agora pronto para build no macOS.
