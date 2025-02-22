#!/usr/bin/env powershell

#Requires -Version 5

param(
    # The name of the plan that is to be built.
    [string]$Plan
)

$env:HAB_ORIGIN = 'ci'
$Plan = 'chef-infra-client'

Write-Host "--- :8ball: :windows: Verifying $Plan"

$hab_version = (hab --version)
$hab_minor_version = $hab_version.split('.')[1]
if ( -not $? -Or $hab_minor_version -lt 85 ) {
    Write-Host "--- :habicat: Installing the version of Habitat required"
    install-habitat --version 0.85.0.20190916
} else {
    Write-Host "--- :habicat: :thumbsup: Minimum required version of Habitat already installed"
}


Write-Host "--- :key: Generating fake origin key"
hab origin key generate $env:HAB_ORIGIN


$project_root = "$(git rev-parse --show-toplevel)"
Set-Location $project_root

Write-Host "--- :construction: Building $Plan"
$env:DO_CHECK=$true; hab pkg build .
if (-not $?) { throw "unable to build"}

. results/last_build.ps1
if (-not $?) { throw "unable to determine details about this build"}

Write-Host "--- :hammer_and_wrench: Installing $pkg_ident"
hab pkg install results/$pkg_artifact
if (-not $?) { throw "unable to install this build"}

Write-Host "--- :mag_right: Testing $Plan"
powershell -File "./habitat/tests/test.ps1" -PackageIdentifier $pkg_ident
