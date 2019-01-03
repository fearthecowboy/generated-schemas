
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

## ===========================================================================

$root = resolvepath $PSScriptRoot/..
$schemas = resolvepath $root/schemas

if( -not (test-path $generated)) {
  In $tmp { git clone $schemaRepoUrl }
} else {
  try {
    in $generated { git clean -xdf } 
  } catch { 
    # just nuke it and clone it from scratch
    Remove-Item -recurse -force $generated 
    In $tmp { git clone $schemaRepoUrl }
  }
}



Write-Output $repo