# 🛠 SCRIPTS

This repository contains helpful PowerShell scripts for PC maintenance, optimization, and automation. These tools can be used to clean up your system, boost performance for gaming, run antivirus scans, and perform safe shutdowns.

---

## 📂 Contents

- **`PCMaintenance.ps1`**  
  Removes temporary files, clears caches and log files, and tidies up system folders.

- **`RunBootScan.ps1`**  
  Launches a user‑selected antivirus scan using Windows Defender (or another AV tool installed on your PC).

- **`restart.ps1`**  
  Restart script that performs cleanup before rebooting—ideal for preparing your system for optimal gaming performance.

- **`CleanAndBackup.ps1`**  
  Cleans up temp files and memory usage before shutting down the PC.

---

## 🖱 How to Add These Scripts as Desktop Shortcuts
Make it easy to run any script with a double-click!

📌 Example: Create a Shortcut for your files
→ Right-click on your Desktop
→ Choose New > Shortcut

In the location box, paste:

>
>  ```powershell
> powershell.exe -ExecutionPolicy Bypass -File "C:\Scripts\FILENAME.ps1
> ```

Click Next, name it the name of your choice, then click 'Finish'

## 🚀 Usage and How to Download
- Click the **Green Code icon** that you see near the top of your screen
- Then click **Download ZIP**

>**Note:** You may need to enable script execution on your system. Open PowerShell as Administrator and run:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

## 🔧 Customization
- Open any .ps1 script in a text editor (like VS Code or Notepad++) to:
- Modify paths (e.g. add or remove folders)
- Add third-party antivirus or cleanup tools
- Enable/disable cleanup routines
