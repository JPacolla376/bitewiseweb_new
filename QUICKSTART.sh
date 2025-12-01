#!/bin/bash
# 🚀 GUIA DE INÍCIO RÁPIDO - BiteWise Frontend Integrado

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║         🍽️  BiteWise Frontend + Backend Integration      ║"
echo "║                                                            ║"
echo "║                   ✨ Início Rápido ✨                      ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"

echo ""
echo "📋 Este script ajudará você a configurar e iniciar o projeto"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar se está na pasta certa
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erro: Execute este script na pasta 'bitewiseweb_new'${NC}"
    echo -e "${BLUE}Exemplo:${NC}"
    echo "  cd c:\\BiteWise\\PI_DSM_FATEC_2SEM2025\\Front\\bitewiseweb_new"
    echo "  bash QUICKSTART.sh"
    exit 1
fi

echo -e "${GREEN}✓ Você está na pasta correta${NC}"
echo ""

# Menu
echo -e "${BLUE}=== O que você quer fazer? ===${NC}"
echo ""
echo "1) 📦 Instalar dependências (flutter pub get)"
echo "2) 🚀 Executar o app (flutter run)"
echo "3) 🧹 Limpar cache (flutter clean)"
echo "4) ✅ Verificar instalação"
echo "5) 📖 Ver documentação"
echo "6) 🧪 Executar testes"
echo "0) ❌ Sair"
echo ""
echo -n "Escolha uma opção (0-6): "
read -r choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}📦 Instalando dependências...${NC}"
        flutter pub get
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Dependências instaladas com sucesso!${NC}"
        else
            echo -e "${RED}❌ Erro ao instalar dependências${NC}"
            exit 1
        fi
        ;;
    
    2)
        echo ""
        echo -e "${YELLOW}🚀 Iniciando o Flutter app...${NC}"
        echo ""
        echo -e "${BLUE}⚠️  IMPORTANTE:${NC}"
        echo "  1. Backend deve estar rodando em http://localhost:8080"
        echo "  2. Verifique com: curl http://localhost:8080/api/auth/login"
        echo ""
        echo "Continuando em 5 segundos... (Ctrl+C para cancelar)"
        sleep 5
        flutter run
        ;;
    
    3)
        echo ""
        echo -e "${YELLOW}🧹 Limpando cache...${NC}"
        flutter clean
        echo -e "${GREEN}✅ Cache limpo!${NC}"
        echo ""
        echo -e "${BLUE}Próximo passo: Execute novamente para instalar dependências${NC}"
        ;;
    
    4)
        echo ""
        echo -e "${YELLOW}✅ Verificando instalação...${NC}"
        echo ""
        
        # Verificar Flutter
        if command -v flutter &> /dev/null; then
            FLUTTER_VERSION=$(flutter --version | head -n 1)
            echo -e "${GREEN}✓ Flutter instalado: $FLUTTER_VERSION${NC}"
        else
            echo -e "${RED}✗ Flutter NÃO encontrado${NC}"
        fi
        
        # Verificar pubspec.yaml
        if [ -f "pubspec.yaml" ]; then
            echo -e "${GREEN}✓ pubspec.yaml encontrado${NC}"
        fi
        
        # Verificar pastas
        if [ -d "lib" ]; then
            echo -e "${GREEN}✓ Pasta 'lib' encontrada${NC}"
        fi
        
        if [ -d "ios" ]; then
            echo -e "${GREEN}✓ Suporte a iOS${NC}"
        fi
        
        if [ -d "android" ]; then
            echo -e "${GREEN}✓ Suporte a Android${NC}"
        fi
        
        if [ -d "web" ]; then
            echo -e "${GREEN}✓ Suporte a Web${NC}"
        fi
        
        echo ""
        echo -e "${BLUE}Verificando dependências...${NC}"
        flutter doctor
        ;;
    
    5)
        echo ""
        echo -e "${BLUE}=== Documentação Disponível ===${NC}"
        echo ""
        
        if [ -f "INTEGRATION_GUIDE.md" ]; then
            echo "📖 INTEGRATION_GUIDE.md"
            echo "   ↳ Guia de integração frontend-backend"
            echo ""
        fi
        
        if [ -f "IMPLEMENTATION_SUMMARY.md" ]; then
            echo "📊 IMPLEMENTATION_SUMMARY.md"
            echo "   ↳ Resumo visual de tudo que foi implementado"
            echo ""
        fi
        
        if [ -f "TESTING_GUIDE.md" ]; then
            echo "🧪 TESTING_GUIDE.md"
            echo "   ↳ Guia prático de testes e cenários"
            echo ""
        fi
        
        if [ -f "CHANGES_SUMMARY.md" ]; then
            echo "📝 CHANGES_SUMMARY.md"
            echo "   ↳ Resumo de arquivos criados e modificados"
            echo ""
        fi
        
        echo -n "Qual documento você quer ler? (ex: INTEGRATION_GUIDE.md): "
        read -r doc
        
        if [ -f "$doc" ]; then
            # Tentar abrir com less (Linux/Mac) ou more (Windows)
            if command -v less &> /dev/null; then
                less "$doc"
            elif command -v more &> /dev/null; then
                more "$doc"
            else
                cat "$doc"
            fi
        else
            echo -e "${RED}❌ Arquivo não encontrado: $doc${NC}"
        fi
        ;;
    
    6)
        echo ""
        echo -e "${YELLOW}🧪 Preparando testes...${NC}"
        echo ""
        echo -e "${BLUE}Testes disponíveis:${NC}"
        echo "1) Executar testes unitários"
        echo "2) Executar testes de integração (curl)"
        echo ""
        echo -n "Escolha (1-2): "
        read -r test_choice
        
        case $test_choice in
            1)
                echo -e "${YELLOW}Executando testes unitários...${NC}"
                flutter test
                ;;
            2)
                echo -e "${YELLOW}Testes de integração com curl...${NC}"
                if [ -f "test_integration.sh" ]; then
                    bash test_integration.sh
                else
                    echo -e "${RED}❌ Script de teste não encontrado${NC}"
                fi
                ;;
            *)
                echo -e "${RED}❌ Opção inválida${NC}"
                ;;
        esac
        ;;
    
    0)
        echo -e "${BLUE}Até logo! 👋${NC}"
        exit 0
        ;;
    
    *)
        echo -e "${RED}❌ Opção inválida${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✨ Processo concluído!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
