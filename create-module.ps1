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
    Write-Host -Object "compressing $output..." -NoNewLine
    & {
        $null = 7z.exe a -t$type -r $output @input
    } && Write-Host "`r|  compressed $output"
}

Write-Host -Object "deleting old files..."
if (Test-Path -Path $MODULE_NAME) {
    Remove-Item -Recurse -Force $MODULE_NAME
    Write-Host "|  removed previous $MODULE_NAME"
}
if (Test-Path -Path "$TOOLS_DIR\${TOOLS}.xz") {
    Remove-Item -Recurse -Force "$TOOLS_DIR\${TOOLS}.xz"
    Write-Host "|  removed previous $TOOLS.xz"
}
Write-Host -Object "ok!"

Write-Host -Object "creating tools archive..."
Set-Location -Path "$TOOLS_DIR/tools"

Write-Host -Object "|  creating .tar archive" -NoNewLine
Compress -type tar -output $TOOLS -input (Get-ChildItem -Name)

Write-Host -Object "|  creating .xz archive" -NoNewLine
Compress -type xz -output "${TOOLS}.xz" -input $TOOLS

Remove-Item $TOOLS -Recurse -Force
Write-Host "|  removed temp files"
Move-Item -Path "${TOOLS}.xz" -Destination "$TOOLS_DIR" -Force

Set-Location -Path $ROOT_DIR
Write-Host -Object "ok!"

Write-Host -Object "Zipping overlays..."
Set-Location -Path $OVERLAY_DIR

Get-ChildItem -Filter "*.zip" | Remove-Item -Force

$overlays = @{
    "cromite-overlay29.zip" = "./extracted/cromite-overlay29/*"
    "mulch-overlay28.zip" = "./extracted/mulch-overlay28/*"
    "mulch-overlay29.zip" = "./extracted/mulch-overlay29/*"
    "thorium-overlay29.zip" = "./extracted/thorium-overlay29/*"
    "vanadium-overlay29.zip" = "./extracted/vanadium-overlay29/*"
}

foreach ($zip_name in $overlays.Keys) {
    Compress -type zip -output $zip_name -input $overlays[$zip_name]
}

Set-Location -Path $ROOT_DIR

Write-Host -Object "creating module zip..."
Write-Host -Object "|  creating zip archive" -NoNewLine
& {
    $null = 7z.exe a -tzip -r $MODULE_NAME * "-xr!.git*" "-xr!img" `
      "-xr!common/tools/tools" "-xr!overlays/extracted" "-x!*.md" `
      "-x!create-module.*"
} && Write-Host "`r|  created zip archive"
Write-Host -Object "done!"
