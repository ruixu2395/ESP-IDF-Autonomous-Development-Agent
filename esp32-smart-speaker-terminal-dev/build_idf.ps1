param(
    [string]$ProjectPath = $env:ESP_IDF_PROJECT_DIR,
    [ValidateSet("build", "flash", "monitor", "flash-monitor")]
    [string]$Action = "build",
    [string]$Port = $env:ESP_PORT,
    [string]$IdfPath = $env:IDF_PATH,
    [string]$IdfToolsPath = $env:IDF_TOOLS_PATH,
    [string]$PythonDir = $env:IDF_PYTHON_DIR,
    [string[]]$ExtraArgs = @()
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "idf_env.ps1")
Initialize-EspIdfEnvironment -ProjectPath $ProjectPath -IdfPath $IdfPath -IdfToolsPath $IdfToolsPath -PythonDir $PythonDir

$idfArgs = @()

switch ($Action) {
    "build" {
        $idfArgs += "build"
    }
    "flash" {
        if (-not $Port) {
            throw "Set ESP_PORT or pass -Port when Action is flash."
        }
        $idfArgs += "-p", $Port, "flash"
    }
    "monitor" {
        if (-not $Port) {
            throw "Set ESP_PORT or pass -Port when Action is monitor."
        }
        $idfArgs += "-p", $Port, "monitor"
    }
    "flash-monitor" {
        if (-not $Port) {
            throw "Set ESP_PORT or pass -Port when Action is flash-monitor."
        }
        $idfArgs += "-p", $Port, "flash", "monitor"
    }
}

if ($ExtraArgs.Count -gt 0) {
    $idfArgs += $ExtraArgs
}

& idf.py @idfArgs
