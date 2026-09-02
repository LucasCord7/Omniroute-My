# 🚀 OmniRoute Gateway - Launcher & OpenCode Setup

Este repositório contém a infraestrutura pronta, configurada e personalizada do **OmniRoute** (Gateway com suporte a mais de 350 provedores de IA) com menu interativo para Windows e integração exclusiva otimizada para o **OpenCode**.

---

## ✨ Recursos Inclusos

- **Launcher Interativo Windows (`start.bat` / `start.ps1`)**:
  - `[1]` Iniciar Servidor + Dashboard Web (com abertura automática inteligente no navegador).
  - `[2]` Iniciar Servidor em modo Headless / Background (apenas endpoint API `:20128/v1`).
  - `[3]` Abrir Dashboard no navegador.
  - `[4]` Definir ou Redefinir senha de acesso do Dashboard em 1 clique.
  - `[5]` Gerenciador do instalador oficial Desktop Electron (`OmniRoute.Setup.exe`).
  - `[6]` Verificação de status e saúde do sistema.
  - `[7]` Iniciar OpenCode diretamente conectado aos modelos roteados.
  - `[8]` Configuração e Sincronização automática do plugin OpenCode com patches exclusivos.
  - `[9]` Parar o servidor com segurança.
  - `[0]` Sair.

- **Instalação One-Click em Novo Computador (`install.bat`)**:
  - Verifica o Node.js.
  - Instala todas as dependências (`npm install`).
  - Cria o arquivo `.env` local.
  - Injeta o plugin oficial no OpenCode e aplica os patches de performance e usabilidade.

- **Patches Exclusivos para o OpenCode**:
  - **Filtro `usableOnly` Ativo**: O seletor de modelos do OpenCode exibe **apenas os modelos gratuitos (`:free`)** e os provedores que você realmente tem logados/ativos no seu OmniRoute (`kiro`, `codex`, `grok-cli`, `antigravity`, `kimi-coding`, etc.). Elimina centenas de modelos inúteis de provedores sem saldo/chave.
  - **Zero Poluição de Tela no VSCode**: Ajuste no nível de log do plugin para `error`, evitando que avisos (`[WARN]`) sobrescrevam a interface visual (TUI) do terminal do VSCode.
  - **Timeout Estendido para Combos (20s)**: Previne o erro `The operation was aborted` na montagem dinâmica dos combos inteligentes.
  - **Autenticação Automática no `auth.json`**: Preenche as credenciais do provedor local automaticamente.

---

## 📦 Como Instalar em Outro Computador

Se você clonar este repositório em um novo computador:

1. Certifique-se de ter o **[Node.js](https://nodejs.org/)** instalado (versão 18 ou superior).
2. Clone este repositório:
   ```bash
   git clone https://github.com/LucasCord7/Omniroute-My.git
   cd Omniroute-My
   ```
3. Execute o instalador automático:
   ```cmd
   install.bat
   ```
4. Pronto! O ambiente estará 100% instalado e o OpenCode configurado.

---

## 🎮 Como Usar

### 1. Iniciar o Gateway OmniRoute
Basta dar dois cliques no arquivo **`start.bat`** (ou executar `.\start.ps1` no PowerShell):
- Escolha a opção **`1`** para iniciar o servidor e abrir o Dashboard Web automaticamente.
- Escolha a opção **`4`** caso queira definir ou redefinir a senha do seu Dashboard.

### 2. Endpoints Locais
- **Dashboard Web:** [http://localhost:20128/dashboard](http://localhost:20128/dashboard)
- **OpenAI-Compatible API:** `http://localhost:20128/v1`
- **Healthcheck:** `http://localhost:20128/api/monitoring/health`

### 3. Usar no OpenCode
Você pode iniciar o OpenCode diretamente pelo menu (opção **`7`**) ou pelo terminal:
```bash
opencode -m opencode-omniroute/auto
```
Para alternar modelos dentro da sessão do OpenCode:
1. Digite `/model`
2. Escolha entre os modelos disponíveis roteados pelo seu OmniRoute local.

---

## 🛠️ Estrutura de Arquivos

```text
├── scripts/
│   └── setup-opencode.mjs     # Script de automação e injeção de patches no OpenCode
├── .env.example               # Modelo de variáveis de ambiente locais
├── .gitignore                 # Arquivos ignorados pelo Git (dados locais, logs, sqlite)
├── install.bat                # Instalador em lote de 1 clique para novas máquinas
├── package.json               # Dependências do projeto (omniroute ^3.8.50)
├── README.md                  # Esta documentação completa
├── start.bat                  # Menu interativo principal (CMD/Batch com suporte a CRLF)
└── start.ps1                  # Menu interativo equivalente para PowerShell
```

---

## 🔒 Segurança e Credenciais

Os arquivos de banco de dados (`*.sqlite`), senhas, chaves pessoais e arquivos de sessão do OmniRoute e do OpenCode ficam armazenados no seu perfil de usuário (`%USERPROFILE%\.omniroute` e `%USERPROFILE%\.local\share\opencode`) e estão devidamente ignorados no `.gitignore` para nunca subirem ao repositório.