$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$terraformDir = Join-Path $repoRoot "terraform"

Push-Location $terraformDir
try {
    terraform fmt -recursive
    terraform init -backend=false
    terraform validate
}
finally {
    Pop-Location
}
