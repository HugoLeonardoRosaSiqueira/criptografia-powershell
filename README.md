# 🔐 Criptografia em PowerShell

Este projeto é um exemplo prático de **criptografia e descriptografia em PowerShell** utilizando **AES (Advanced Encryption Standard)**.  
O objetivo é demonstrar como proteger mensagens de texto com senha, gerando um resultado seguro em **Base64**.

---

## 🚀 Funcionalidades
- Gerar salt e IV aleatórios para cada criptografia.
- Derivar chave de senha utilizando **PBKDF2**.
- Criptografar textos simples e retornar saída em Base64.
- Descriptografar os textos e recuperar a mensagem original.

---

## 📂 Estrutura
- `criptografia.ps1` → Script principal contendo:
  - `New-RandomBytes` → Gera bytes aleatórios.
  - `Get-AesKeyFromPassword` → Deriva chave segura da senha.
  - `Encrypt-Text` → Função para criptografar mensagens.
  - `Decrypt-Text` → Função para descriptografar mensagens.

---

## 🖥️ Como usar
1. Clone o repositório:
   ```bash
   git clone https://github.com/HugoLeonardoRosaSiqueira/criptografia-powershell.git
   cd criptografia-powershell
