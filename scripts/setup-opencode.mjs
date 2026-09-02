import fs from "node:fs";
import path from "node:path";
import os from "node:os";

console.log("===================================================");
console.log("   Configurando Plugin OmniRoute para OpenCode     ");
console.log("===================================================\n");

const homeDir = os.homedir();
const configDir = path.join(homeDir, ".config", "opencode");
const dataDir = path.join(homeDir, ".local", "share", "opencode");
const appData = process.env.APPDATA || path.join(homeDir, "AppData", "Roaming");
const appDataPluginDir = path.join(appData, "opencode", "plugins", "omniroute");
const targetPluginDir = path.join(configDir, "plugins", "omniroute");

const rootDir = path.resolve(".");
const bundledPluginDir = path.join(rootDir, "node_modules", "omniroute", "@omniroute", "opencode-plugin");

if (!fs.existsSync(bundledPluginDir)) {
  console.error(`[ERRO] Plugin bundled não encontrado em: ${bundledPluginDir}`);
  console.error("Execute 'npm install' antes de rodar este script.");
  process.exit(1);
}

// 1. Criar diretórios necessários
[configDir, dataDir, targetPluginDir, appDataPluginDir].forEach((dir) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// 2. Copiar plugin para os locais do OpenCode
console.log("[1/4] Copiando arquivos do plugin...");
fs.cpSync(bundledPluginDir, targetPluginDir, { recursive: true });
fs.cpSync(bundledPluginDir, appDataPluginDir, { recursive: true });

// 3. Aplicar patches de otimização no dist/index.js
console.log("[2/4] Aplicando patches exclusivos (usableOnly, timeout e silenciamento de logs)...");
const targets = [
  path.join(targetPluginDir, "dist", "index.js"),
  path.join(appDataPluginDir, "dist", "index.js"),
  path.join(bundledPluginDir, "dist", "index.js"),
];

targets.forEach((filePath) => {
  if (fs.existsSync(filePath)) {
    let content = fs.readFileSync(filePath, "utf8");

    // Silenciar console.warn para não sobrepor o TUI no terminal
    content = content.replaceAll('var _level = "warn";', 'var _level = "error";');
    content = content.replaceAll('resolved.features?.logLevel ?? "warn"', 'resolved.features?.logLevel ?? "error"');

    // Aumentar timeout de auto-combos para 20s
    content = content.replaceAll("timeoutMs = 5e3", "timeoutMs = 20e3");

    // Ativar usableOnly por padrão
    content = content.replaceAll(
      "const wantUsableOnly = features.usableOnly === true;",
      "const wantUsableOnly = features.usableOnly !== false;"
    );
    content = content.replaceAll(
      "const wantUsableOnly = opts.features?.usableOnly === true;",
      "const wantUsableOnly = opts.features?.usableOnly !== false;"
    );

    // Garantir preservação de modelos gratuitos
    const targetFunc = "function isUsableRawModelId(id, usable, enrichment) {";
    const replaceFunc =
      "function isUsableRawModelId(id, usable, enrichment) {\n  if (id.includes(':free') || id.includes('/free') || id.endsWith('-free')) return true;\n  const enrich = enrichment?.get?.(id);\n  if (enrich && (enrich.isFree || enrich.pricing?.input === 0)) return true;";

    if (content.includes(targetFunc) && !content.includes("id.includes(':free')")) {
      content = content.replace(targetFunc, replaceFunc);
    }

    fs.writeFileSync(filePath, content, "utf8");
  }
});

// 4. Configurar auth.json com as credenciais locais
console.log("[3/4] Atualizando credenciais no auth.json do OpenCode...");
const authFile = path.join(dataDir, "auth.json");
let authData = {};
if (fs.existsSync(authFile)) {
  try {
    authData = JSON.parse(fs.readFileSync(authFile, "utf8"));
  } catch {
    authData = {};
  }
}

authData["opencode-omniroute"] = {
  type: "api",
  key: "omniroute-local",
  baseURL: "http://localhost:20128",
};
authData["omniroute"] = {
  type: "api",
  key: "omniroute-local",
  baseURL: "http://localhost:20128",
};

fs.writeFileSync(authFile, JSON.stringify(authData, null, 2), "utf8");

// 5. Configurar opencode.jsonc
console.log("[4/4] Registrando plugin no opencode.jsonc...");
const configFile = path.join(configDir, "opencode.jsonc");
let configData = {
  $schema: "https://opencode.ai/config.json",
  plugin: [],
};

if (fs.existsSync(configFile)) {
  try {
    const raw = fs.readFileSync(configFile, "utf8");
    configData = JSON.parse(raw);
  } catch {}
}

// Remover provider.omniroute estático se existir (para permitir modo dinâmico)
if (configData.provider && configData.provider.omniroute) {
  delete configData.provider.omniroute;
}

if (!Array.isArray(configData.plugin)) {
  configData.plugin = [];
}

const pluginPath = targetPluginDir;
if (!configData.plugin.includes(pluginPath)) {
  configData.plugin.push(pluginPath);
}

fs.writeFileSync(configFile, JSON.stringify(configData, null, 2), "utf8");

console.log("\n[SUCESSO] Integração com OpenCode configurada com sucesso!");
console.log("Reinicie o OpenCode para carregar o catálogo de modelos filtrados.");