$MODULE_NAME = "open-webview.zip"
$TOOLS = "tools.tar"
$ROOT_DIR = Get-Location
$OVERLAY_DIR = "overlays"
$TOOLS_DIR = "common/tools"

function Compress {
    param (
        [string]$type,
        [string]$output,
        [string[]]$input
    )
    Write-Host "Compressing $output..."
    & 7z.exe a -t$type -r $output $input | Out-Null
}

Write-Host "Deleting old files..."
if (Test-Path $MODULE_NAME) {
    Remove-Item -Force $MODULE_NAME
}
if (Test-Path "$TOOLS_DIR\$($TOOLS).xz") {
    Remove-Item -Force "$TOOLS_DIR\$($TOOLS).xz"
}
Get-ChildItem -Path "$OVERLAY_DIR" -Filter "*.zip" | Remove-Item -Force
Write-Host "Old files deleted!"

Write-Host "Zipping tools..."
Set-Location -Path "$TOOLS_DIR/tools"
Compress -type tar -output $TOOLS -input (Get-ChildItem -Name)
Compress -type xz -output "${TOOLS}.xz" -input $TOOLS
Remove-Item -Force $TOOLS
Move-Item -Path "${TOOLS}.xz" -Destination "$TOOLS_DIR" -Force
Set-Location -Path $ROOT_DIR
Write-Host "Tools zipped!"

Write-Host "Zipping overlays..."
Set-Location -Path $OVERLAY_DIR
$overlays = @{
    "mulch-overlay28.zip" = "./extracted/mulch-overlay28/*"
    "mulch-overlay29.zip" = "./extracted/mulch-overlay29/*"
    "thorium-overlay29.zip" = "./extracted/thorium-overlay29/*"
    "vanadium-overlay29.zip" = "./extracted/vanadium-overlay29/*"
}
foreach ($zip_name in $overlays.Keys) {
    Compress -type zip -output $zip_name -input $overlays[$zip_name]
}
Set-Location -Path $ROOT_DIR
Write-Host "Overlays zipped!"

Write-Host "Creating module zip..."
& 7z.exe a -tzip -r $MODULE_NAME * `
    "-xr!.git*" "-xr!img" "-xr!common/tools/tools" `
    "-xr!overlays/extracted" "-x!*.md" "-x!create-module.*" | Out-Null
Write-Host "Module zip created!"
Write-Host "Done!"
