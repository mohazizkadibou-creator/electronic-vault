$scriptDir = "C:\Users\info\Desktop\ElectronicVault"
$batFile = Join-Path $scriptDir "run_vault.bat"
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "Electronic Vault.lnk"

# Create the shortcut
$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $batFile
$shortcut.WorkingDirectory = $scriptDir
$shortcut.Arguments = ""
$shortcut.Save()

Write-Host "Shortcut created successfully!"
Write-Host "Path: $shortcutPath"
Write-Host "You can now find Electronic Vault on your desktop"