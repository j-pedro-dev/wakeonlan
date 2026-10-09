# wakeonlan

Scripts e guia para ligar o PC pela rede (Wake on LAN), a partir do celular ou de outro computador.

Requisitos: Windows e o PC ligado na rede **por cabo**.

## 1. BIOS/UEFI (manual)

Reinicie o PC e entre na BIOS (geralmente `Del` ou `F2`). Ative a opção com um destes nomes:
"Wake on LAN", "Power On by PCI-E", "Resume by LAN". Se existir "ErP" ou "Deep Sleep", desative.

## 2. Windows

No PC que vai ser ligado, abra o PowerShell **como Administrador** e rode:

```powershell
powershell -ExecutionPolicy Bypass -File .\configurar-wol.ps1
```

O script ativa o Wake on Magic Packet na placa de rede e desliga a inicialização rápida, além de mostrar o MAC da placa. Anote o MAC.

## 3. Ligar o PC

Desligue o PC pelo menu Iniciar (sem tirar da tomada). Depois, estando na mesma rede:

- **Celular Android:** app "Wake On Lan". Adicione um dispositivo com o MAC.
- **iPhone:** app "Mocha WOL".
- **Outro PC Windows:**
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\acordar-pc.ps1 -Mac A1-B2-C3-D4-E5-F6
  ```
- **Mac/Linux:** `wakeonlan A1:B2:C3:D4:E5:F6`

## Fora de casa

O jeito mais simples e seguro é instalar o Tailscale num aparelho que fica sempre ligado em casa e mandar o pacote através dele.
Redirecionar a porta UDP 9 no roteador também funciona, mas é menos confiável.

## Se não ligar

- Confira se a opção da BIOS ficou salva.
- Confira se a inicialização rápida está mesmo desativada.
- Alguns PCs só acordam se o LED da placa de rede continua aceso com o PC desligado.
