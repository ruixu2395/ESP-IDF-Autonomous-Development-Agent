param(
    [string]$ProjectPath = $env:ESP_IDF_PROJECT_DIR,
    [string]$Port = $env:ESP_PORT,
    [string]$Chip = $(if ($env:ESP_CHIP) { $env:ESP_CHIP } else { "esp32s3" }),
    [int]$BaudRate = $(if ($env:ESP_BAUD) { [int]$env:ESP_BAUD } else { 115200 }),
    [int]$DurationSeconds = 15,
    [string]$IdfPath = $env:IDF_PATH,
    [string]$IdfToolsPath = $env:IDF_TOOLS_PATH,
    [string]$PythonDir = $env:IDF_PYTHON_DIR
)

$ErrorActionPreference = "Stop"

if (-not $Port) {
    throw "Set ESP_PORT or pass -Port."
}

. (Join-Path $PSScriptRoot "idf_env.ps1")
Initialize-EspIdfEnvironment -ProjectPath $ProjectPath -IdfPath $IdfPath -IdfToolsPath $IdfToolsPath -PythonDir $PythonDir

python -m esptool --chip $Chip -p $Port --after hard_reset run
Start-Sleep -Milliseconds 500

$serialPort = New-Object System.IO.Ports.SerialPort $Port, $BaudRate, ([System.IO.Ports.Parity]::None), 8, ([System.IO.Ports.StopBits]::One)
$serialPort.ReadTimeout = 500

try {
    $serialPort.Open()
    Write-Host "=== Reading boot log for $DurationSeconds seconds ==="
    $endTime = (Get-Date).AddSeconds($DurationSeconds)

    while ((Get-Date) -lt $endTime) {
        if ($serialPort.BytesToRead -gt 0) {
            try {
                $line = $serialPort.ReadLine()
                Write-Host $line
            } catch {
            }
        }
        Start-Sleep -Milliseconds 20
    }
} finally {
    if ($serialPort.IsOpen) {
        $serialPort.Close()
    }
}
