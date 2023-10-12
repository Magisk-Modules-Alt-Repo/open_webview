$MODULE_NAME = "open-webview.zip"
$TOOLS = "tools.tar"
$ROOT_DIR = Get-Location

Write-Host -Object "deleting old files..."
if (Test-Path -Path $MODULE_NAME) {
    & { $null = Remove-Item $MODULE_NAME -Recurse -Force } && `
      Write-Host -Object "|  removed previous $MODULE_NAME"
}
if (Test-Path -Path .\common\tools\"$TOOLS.xz") {
    & { $null = Remove-Item .\common\tools\"$TOOLS.xz" -Recurse -Force } && `
      Write-Host -Object "|  removed previous $TOOLS"
}
Write-Host -Object "ok!"


Write-Host -Object "creating tools archive..."
Set-Location -Path common/tools/tools

Write-Host -Object "|  creating .tar archive" -NoNewLine
& { $null = 7z.exe a -ttar -r $TOOLS * } && `
  Write-Host -Object "`r|  created .tar archive "

Write-Host -Object "|  creating .xz archive" -NoNewLine
& { $null = 7z.exe a -txz -r "${TOOLS}.xz" $TOOLS } && `
  Write-Host -Object "`r|  created .xz archive "

Remove-Item $TOOLS -Recurse -Force && Write-Host "|  removed temp files"
Move-Item -Path "${TOOLS}.xz" -Destination .\.. -Force

Set-Location -Path $ROOT_DIR
Write-Host -Object "ok!"

Write-Host "creating module zip..."
Write-Host -Object "|  creating zip archive" -NoNewLine
& { 
    $null = 7z.exe a -tzip -r $MODULE_NAME * "-xr!.git*" "-xr!img" `
      "-xr!common/tools/tools" "-xr!overlays/extracted" "-x!*.md"  `
      "-x!create-module.*" 
} && Write-Host "`r|  created zip archive "
Write-Host -Object "done!"
