function Resolve-IdfPythonDir {
    param(
        [string]$ExplicitPythonDir,
        [string]$IdfToolsPath
    )

    if ($ExplicitPythonDir) {
        return $ExplicitPythonDir
    }

    if (-not $IdfToolsPath) {
        return $null
    }

    $pythonRoot = Join-Path $IdfToolsPath "tools\idf-python"
    if (-not (Test-Path $pythonRoot)) {
        return $null
    }

    $candidate = Get-ChildItem -Path $pythonRoot -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($candidate) {
        return $candidate.FullName
    }

    return $null
}

function Initialize-EspIdfEnvironment {
    param(
        [string]$ProjectPath = $env:ESP_IDF_PROJECT_DIR,
        [string]$IdfPath = $env:IDF_PATH,
        [string]$IdfToolsPath = $env:IDF_TOOLS_PATH,
        [string]$PythonDir = $env:IDF_PYTHON_DIR
    )

    if (-not $ProjectPath) {
        throw "Set ESP_IDF_PROJECT_DIR or pass -ProjectPath."
    }
    if (-not $IdfPath) {
        throw "Set IDF_PATH or pass -IdfPath."
    }
    if (-not $IdfToolsPath) {
        throw "Set IDF_TOOLS_PATH or pass -IdfToolsPath."
    }

    $resolvedPythonDir = Resolve-IdfPythonDir -ExplicitPythonDir $PythonDir -IdfToolsPath $IdfToolsPath
    if (-not $resolvedPythonDir) {
        throw "Set IDF_PYTHON_DIR or install ESP-IDF Python under IDF_TOOLS_PATH\tools\idf-python."
    }

    Remove-Item Env:MSYSTEM -ErrorAction SilentlyContinue
    $env:IDF_PATH = $IdfPath
    $env:IDF_TOOLS_PATH = $IdfToolsPath

    $pathEntries = $env:PATH -split ";"
    if (-not ($pathEntries | Where-Object { $_ -eq $resolvedPythonDir })) {
        $env:PATH = $resolvedPythonDir + ";" + $env:PATH
    }

    & (Join-Path $env:IDF_PATH "export.ps1")
    Set-Location $ProjectPath
}
