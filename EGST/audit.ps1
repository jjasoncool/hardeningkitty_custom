# 設定檔案編碼
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# 儲存當前工作目錄
$originalPath = Get-Location

# 設定工作目錄為檔案所在資料夾
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition)

# 設定執行策略為 Bypass，範圍為 CurrentUser，並強制執行
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force

# 匯入 HardeningKitty 模組
Import-Module .\..\HardeningKitty.psm1

# 備份原始設定資料
Invoke-HardeningKitty -Mode Config -FileFindingList .\EGST_windows_rulset.csv -Backup

# 執行 HardeningKitty（根據你的需求調整命令）
Invoke-HardeningKitty -Mode Audit -FileFindingList .\EGST_windows_rulset.csv -Log -Report

# 還原原始工作目錄
Set-Location -Path $originalPath