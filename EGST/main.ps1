# 設定檔案編碼
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# 確認管理員權限，若不足則自動提權重啟
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 統一視窗背景為黑色
$Host.UI.RawUI.BackgroundColor = 'Black'
$Host.UI.RawUI.ForegroundColor = 'White'
Clear-Host

# 路徑定義
$egstPath   = $PSScriptRoot
$modulePath = "$PSScriptRoot\..\hardeningkitty\HardeningKitty.psm1"
$ruleSet    = "$PSScriptRoot\EGST_windows_rulset.csv"

# 儲存當前工作目錄
$originalPath = Get-Location

function Show-Menu {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  HardeningKitty - EGST 管理工具"
    Write-Host "  HardeningKitty - EGST Management Tool"
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  [1] 稽核        / Audit"
    Write-Host "  [2] 套用安全原則 / Apply Rules"
    Write-Host "  [3] 復原設定    / Restore"
    Write-Host "  [0] 離開        / Exit"
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Get-OutputFileName {
    param([string]$Prefix, [string]$Extension)
    $hostname  = $env:COMPUTERNAME
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $listName  = [System.IO.Path]::GetFileNameWithoutExtension($ruleSet)
    return "$egstPath\${Prefix}_${hostname}_${listName}-${timestamp}.${Extension}"
}

try {
    do {
        Show-Menu
        $choice = Read-Host "請選擇 / Select"

        switch ($choice) {
            '1' {
                Write-Host "`n[稽核 / Audit] 開始執行..." -ForegroundColor Green
                Import-Module $modulePath

                $backupFile = Get-OutputFileName -Prefix "hardeningkitty_backup" -Extension "csv"
                $reportFile = Get-OutputFileName -Prefix "hardeningkitty_report" -Extension "csv"
                $logFile    = Get-OutputFileName -Prefix "hardeningkitty_log"    -Extension "log"

                Write-Host "執行稽核並備份 / Running audit with backup..." -ForegroundColor Yellow
                Invoke-HardeningKitty -Mode Audit -FileFindingList $ruleSet -Log -LogFile $logFile -Report -ReportFile $reportFile -Backup -BackupFile $backupFile

                Write-Host "`n輸出位置 / Output location: $egstPath" -ForegroundColor Cyan
                Read-Host "`n按 Enter 返回選單 / Press Enter to return to menu"
            }
            '2' {
                Write-Host "`n[套用安全原則 / Apply Rules] 開始執行..." -ForegroundColor Green

                $skipRP = Read-Host "是否略過建立系統還原點？/ Skip creating Restore Point? (y/n)"
                $logFile = Get-OutputFileName -Prefix "hardeningkitty_log" -Extension "log"

                Import-Module $modulePath

                if ($skipRP -eq 'y' -or $skipRP -eq 'Y') {
                    Invoke-HardeningKitty -Mode HailMary -FileFindingList $ruleSet -Log -LogFile $logFile -SkipRestorePoint
                } else {
                    Invoke-HardeningKitty -Mode HailMary -FileFindingList $ruleSet -Log -LogFile $logFile
                }

                Write-Host "`n輸出位置 / Output location: $egstPath" -ForegroundColor Cyan
                Read-Host "`n按 Enter 返回選單 / Press Enter to return to menu"
            }
            '3' {
                Write-Host "`n[復原設定 / Restore] 請選擇備份檔案..." -ForegroundColor Green

                Add-Type -AssemblyName System.Windows.Forms
                $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
                $fileDialog.InitialDirectory = $egstPath
                $fileDialog.Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"
                $fileDialog.Title = "選擇備份檔案 / Select Backup File to Restore"

                if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                    $selectedFile = $fileDialog.FileName
                    $logFile      = Get-OutputFileName -Prefix "hardeningkitty_log" -Extension "log"

                    Write-Host "使用備份檔案 / Using backup: $selectedFile" -ForegroundColor Yellow
                    Import-Module $modulePath
                    Invoke-HardeningKitty -Mode HailMary -FileFindingList $selectedFile -Log -LogFile $logFile
                } else {
                    Write-Host "未選擇檔案，已取消 / No file selected. Canceled." -ForegroundColor Yellow
                }

                Read-Host "`n按 Enter 返回選單 / Press Enter to return to menu"
            }
            '0' {
                Write-Host "離開 / Exiting..." -ForegroundColor Cyan
            }
            default {
                Write-Host "無效選項 / Invalid selection." -ForegroundColor Red
                Read-Host "`n按 Enter 返回選單 / Press Enter to return to menu"
            }
        }
    } while ($choice -ne '0')
}
finally {
    Set-Location -Path $originalPath
}
