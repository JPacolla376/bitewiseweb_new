# 🔐 Integração Frontend-Backend com JWT

## 📋 O que foi implementado

### 1. **Serviço de API (`lib/services/api_service.dart`)**
- ✅ Comunicação com backend em `http://localhost:8080/api`
- ✅ Interceptores JWT automáticos
- ✅ Armazenamento seguro de tokens com `flutter_secure_storage`
- ✅ Validação de expiração de tokens
- ✅ Gerenciamento de erros HTTP

### 2. **Autenticação Melhorada (`lib/global_state.dart`)**
- ✅ Estado de autenticação completo com `UserAuth`
- ✅ Gerenciamento de sessão automático
- ✅ Função de registro (`register`)
- ✅ Função de login (`login`)
- ✅ Função de logout (`logout`)

### 3. **Login Modal Atualizado (`lib/screens/login_modal.dart`)**
- ✅ Integração com requisições reais do backend
- ✅ Validação de email e senha
- ✅ Feedback de carregamento e erros
- ✅ Toggle de visibilidade de senha
- ✅ Fluxo de registro + login automático

### 4. **Geração de Receitas (`lib/screens/tabs/create_tab.dart`)**
- ✅ Requisições reais à API `/recipes/generate`
- ✅ Suporte para múltiplos modelos de IA (GPT e Gemini)
- ✅ Validação de autenticação antes de gerar
- ✅ Passagem de dados da API para exibição

## 🚀 Como usar

### 1. **Preparar o ambiente**

```bash
# No diretório do projeto
flutter pub get
```

### 2. **Certificar que o backend está rodando**

```bash
# Backend deve estar em http://localhost:8080
# Verifique com: curl http://localhost:8080/api/auth/login
```

### 3. **Usar o aplicativo**

#### Registrar novo usuário:
1. Abra o aplicativo
2. Clique em "Usar e-mail e senha"
3. Clique em "Criar Conta"
4. Preencha: Nome, Email, Senha
5. Clique em "CADASTRAR"

#### Login:
1. Clique em "Usar e-mail e senha"
2. Preencha: Email, Senha
3. Clique em "ENTRAR"

#### Gerar receita:
1. Após login, vá para a aba "Criar"
2. Selecione ingredientes
3. Clique em "GERAR RECEITA"
4. Escolha a IA (ChatGPT ou Gemini)
5. Visualize a receita gerada

## 🔑 Endpoints utilizados

```bash
# Registro
POST /api/auth/register
Content-Type: application/json
{
  "name": "Nome Completo",
  "email": "email@example.com",
  "password": "senha123"
}

# Login
POST /api/auth/login
Content-Type: application/json
{
  "email": "email@example.com",
  "password": "senha123"
}
Response:
{
  "token": "eyJhbGc..."
}

# Gerar Receita
POST /api/recipes/generate?aiModel=gpt
Content-Type: application/json
Authorization: Bearer {token}
{
  "ingredients": ["Frango", "Arroz", "Tomate"]
}
```

## 🔒 Segurança

- **Tokens**: Armazenados em `flutter_secure_storage` (criptografia nativa)
- **Headers**: Token enviado automaticamente em requisições autenticadas
- **Validação**: Tokens com expiração são verificados antes de uso
- **Logout**: Remove token do armazenamento seguro

## 📱 Fluxo de autenticação

```
Usuário abre app
    ↓
AuthNotifier verifica token armazenado
    ↓
Se válido: Auto-login (sessão mantida)
    ↓
Se inválido/expirado: Tela de login
    ↓
Após login bem-sucedido: Salva token e email
    ↓
Cada requisição: Token incluído automaticamente
```

## 🛠️ Troubleshooting

### Erro: "Conexão recusada"
- Verifique se o backend está rodando em `localhost:8080`
- Teste com: `curl http://localhost:8080/api/auth/login`

### Erro: "Email inválido"
- Use um email com formato válido: `usuario@dominio.com`

### Erro: "Conta já existe"
- O email já está registrado no backend
- Tente fazer login ou use outro email

### Erro: "Token expirado"
- Faça logout e login novamente
- O token será renovado automaticamente

## 📚 Estrutura de arquivos

```
lib/
├── services/
│   ├── api_service.dart       # Serviço de API com JWT
│   └── recipe_service.dart    # Serviço de receitas
├── screens/
│   ├── login_modal.dart       # Modal de login/registro
│   ├── home_screen.dart       # Tela principal
│   ├── recipe_result_screen.dart # Exibição de receita
│   └── tabs/
│       ├── create_tab.dart    # Criação com integração de receita
│       ├── saved_tab.dart     # Receitas salvas
│       └── profile_tab.dart   # Perfil do usuário
├── global_state.dart          # Estado global com autenticação
└── main.dart
```

## ✅ Próximos passos

- [ ] Integrar Google Sign-In
- [ ] Refresh automático de tokens
- [ ] Persistência de receitas no backend
- [ ] Sincronização cross-device
- [ ] Notificações em tempo real

---

**Desenvolvido com ❤️ para BiteWise**
