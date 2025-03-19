# 定義腳本參數，新增 -SkipRestorePoint 作為選擇性參數
param (
    [switch]$SkipRestorePoint
)

# 設定檔案編碼
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# 儲存當前工作目錄
$originalPath = Get-Location

try {
    # 設定工作目錄為檔案所在資料夾
    Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition)

    # 設定執行策略為 Bypass，範圍為 CurrentUser，並強制執行
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force

    # 提供選項給使用者
    Write-Host "Choose an action: 'apply' to apply configuration rules, 'restore' to restore previous settings."
    $action = Read-Host
    if ($action -eq 'apply') {
        Import-Module .\..\HardeningKitty.psm1

        # 檢查是否提供 -SkipRestorePoint 參數
        if ($PSBoundParameters.ContainsKey('SkipRestorePoint')) {
            # 若有 -SkipRestorePoint，執行時附加此參數
            Invoke-HardeningKitty -Mode HailMary -FileFindingList .\EGST_windows_rulset.csv -Log -SkipRestorePoint
        } else {
            # 若無，保持原有語法
            Invoke-HardeningKitty -Mode HailMary -FileFindingList .\EGST_windows_rulset.csv -Log
        }
    } elseif ($action -eq 'restore') {
        Import-Module .\..\HardeningKitty.psm1

        # 跳出檔案選擇對話框
        Add-Type -AssemblyName System.Windows.Forms
        $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $fileDialog.InitialDirectory = (Get-Location).Path
        $fileDialog.Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"
        $fileDialog.Title = "Select a backup file to restore"
        if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $selectedFile = $fileDialog.FileName

            # 執行 HardeningKitty 還原規則
            Invoke-HardeningKitty -Mode HailMary -FileFindingList $selectedFile -Log
        } else {
            Write-Information "No file selected. Restore canceled." -InformationAction Continue
        }
    } else {
        Write-Information "Invalid action. Script canceled." -InformationAction Continue
    }
}
finally {
    # 還原原始工作目錄
    Set-Location -Path $originalPath
}