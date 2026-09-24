# 🎉 417_CheerUp! v1.0.0

**Multilingual Supported (EN / JP / KR / ZH)**

A Cascadeur add-on that sends you random **encouragement messages** at a set interval while you work — because every animator deserves a little cheer! 🌟<br>


<br>

## ✨ Features

- ⏰ **Interval notifications** — get a random cheer message every n minutes
- 🌍 **EN / 日本語 / 한국어 / 中文** — switch language for both UI and messages
- ✏️ **Custom presets** — add, edit, delete your own messages in the Settings UI
- 📂 **JSON / TXT import & export** — Create personalized messages with AI, then import and share them.
- 🪶 **Ultra-lightweight** — runs a single QTimer, near-zero CPU/memory use

<br>

## 🚀 Installation

### Method A: Auto Installer (Recommended)
1. Download and extract the latest zip file.
2. Double-click `install.bat` located in the extracted folder.
3. The installer will automatically detect your Cascadeur installation and copy the necessary files.
   - *If it fails to auto-detect, please select the path manually (e.g., `C:\Program Files\Cascadeur`).*
   - *Note: You may be prompted for administrator privileges to copy files to Program Files.*
4. (Re)start Cascadeur.
5. The menu **Commands > 417_cheerup** will appear.

### Method B: Manual Installation
If the installer fails, you can manually copy the files.
Please refer to `manual_install.txt` inside the `to_cascadeur` folder.

<br>

## 🎮 Usage

| Menu item | Action |
|---|---|
| **Commands > 417_cheerup > Start (Reset)** | Start the timer (or reset it if already running). An immediate greeting is shown. |
| **Commands > 417_cheerup > Stop** | Stop the timer. |
| **Commands > 417_cheerup > Settings** | Open the settings dialog. |

<br>

## 📂 User Data Location

Your personal settings and custom messages are stored safely in your user directory (never inside `Program Files`):

```
%LOCALAPPDATA%\417_Casc_Addons\CheerUp\
  settings.json       ← language, interval, options
  presets.json        ← your custom message groups
```

<br>

## 🗑️ Uninstallation

1. Delete `commands\417_cheerup\` from Cascadeur's scripts folder.
2. Delete `models\417_cheerup\` from Cascadeur's scripts folder.
3. Optionally delete `%LOCALAPPDATA%\417_Casc_Addons\CheerUp\` to remove saved data.

<br>

## 💻 System Requirements

- **OS**: Windows 10 / 11
- **Cascadeur**: 2026.2

<br>

## ⚠️ Precautions

- If it does not work properly, try restarting or reinstalling Cascadeur and this add-on.
- For other issues, please check the [issues](../../issues) page.
  If the problem persists, please contact the author via [issues](../../issues) / [X](https://x.com/417_Butter) / [YouTube](https://youtu.be/kQZpaUDdBus).

**Disclaimer**: Use this add-on at your own risk. The author is not responsible for any troubles or damages caused by its use.

<br>

## 📜 License

This project is licensed under the **MIT License**.
You are free to use, modify, and distribute this software, including using the code as a reference for your own projects.
See the `LICENSE` file for details.

<br>

<br>

## 🎁 SPECIAL OFFER

🌐 **Get 15% OFF Cascadeur plans!**<br>
　 Promo Code: Butter<br>
　 ▶[Cascadeur Official Purchase Page Here!](https://cascadeur.com/plans?ref=Butter)

<br>

## 
Creator(417_Butter)：[X](https://x.com/417_Butter) | [YouTube](https://www.youtube.com/@417_Butter) | [GitHub](https://github.com/417-Butter)


🎬 **I also make [Cascadeur tutorials](https://www.youtube.com/@417_Butter) on Youtube!**

<br>

[<img width="1790" height="1456" alt="youtube_video" src="https://github.com/user-attachments/assets/987dc072-0066-486c-88b5-e8067c1185fc" />](https://www.youtube.com/@417_Butter)

