<#
.SYNOPSIS
    Orquestador Maestro del Pipeline P4 (Estándar Dzib V13.0)
.DESCRIPTION
    Ejecuta secuencialmente la Ingesta (Python) y las cargas transaccionales en SQL.
#>
$ErrorActionPreference = "Stop"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "🚀 INICIANDO ORQUESTACIÓN P4 (Estándar Dzib V13.0)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 0. Cargar variables de entorno atómicamente desde el propio directorio P4
$envPath = ".env"
if (Test-Path $envPath) {
  Get-Content $envPath | Where-Object { $_ -match "^[^#]" -and $_ -match "=" } | ForEach-Object {
    $name, $value = $_ -split '=', 2
    Set-Item -Path Env:\$name -Value $value.Trim()
  }
  Write-Host "✅ Variables de entorno cargadas correctamente." -ForegroundColor Green
}
else {
  throw "❌ ERROR: Archivo .env no encontrado en la ruta del proyecto P4."
}

$Server = $env:DB_SERVER
$Database = $env:DB_NAME

# 1. Fase de Ingesta (Python)
Write-Host "`n[1/2] Ejecutando Ingesta de Alta Velocidad (Python)..." -ForegroundColor Yellow
python 02_Ingesta_Pro\02_bulk_load_kaggle.py
if ($LASTEXITCODE -ne 0) { throw "❌ Fallo crítico en la Fase 1 (Ingesta Python)." }

# 2. Fase de Carga Transaccional a Analytics (SQL Server con -C para TrustServerCertificate)
Write-Host "`n[2/2] Ejecutando Carga Transaccional Analytics (SQLcmd)..." -ForegroundColor Yellow
sqlcmd -S "$Server" -d "$Database" -E -C -i "03_Orquestacion_Transacciones\01_load_analytics.sql"
if ($LASTEXITCODE -ne 0) { throw "❌ Fallo crítico en la Fase 2 (Analytics SQL)." }

Write-Host "`n========================================================" -ForegroundColor Green
Write-Host "✅ PIPELINE P4 EJECUTADO CON ÉXITO ABSOLUTO" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
