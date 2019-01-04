$ErrorActionPreference  = "stop"

# This script requires the following:
# git

## functions
function ResolvePath {
  param (
      [string] $FileName
  )

  $FileName = Resolve-Path $FileName -ErrorAction SilentlyContinue `
                                     -ErrorVariable _frperror
  if (-not($FileName)) {
      $FileName = $_frperror[0].TargetObject
  }

  return $FileName
}

function In($location, $scriptblock) {
  pushd $location
  try {
    & $scriptblock
  } finally {
    popd 
  }
}

## ===========================================================================
$restSpecsRepoUri = "https://github.com/azure/azure-rest-api-specs"

## ===========================================================================

$root = resolvepath $PSScriptRoot/..
$tmp = resolvepath $root/tmp ; mkdir -ea 0  $tmp
$restSpecs = resolvepath $tmp/azure-rest-api-specs
$schemas = resolvepath $root/schemas

# cleanup schema folder first.
in $schemas { git checkout . ; git clean -xdf .  } 

# clone the azure-rest-api-specs repo
if( -not (test-path $restSpecs)) {
  In $tmp { git clone $restSpecsRepoUri }
} else {
  try {
    in $restSpecs git clean -xdf
  } catch { 
    # just nuke it and clone it from scratch
    Remove-Item -recurse -force $restSpecs 
    In $tmp { git clone $restSpecsRepoUri }
  }
}

Write-Output $repo