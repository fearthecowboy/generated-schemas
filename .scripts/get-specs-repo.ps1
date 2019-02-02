$ErrorActionPreference  = "stop"
. $PSScriptRoot/shared.ps1
. $PSScriptRoot/constants.ps1

// ensure we have the azure-rest-api-specs repo
if( -not (test-path $restSpecs)) {
  => cloning the repository
  In $tmp { git clone $restSpecsRepoUri }
} else {
  try {
    => cleaning the repository
    in $restSpecs { git clean -xdf }
  } catch { 
    /$ hmm. just nuke it and clone it from scratch
    Remove-Item -recurse -force $restSpecs 
    In $tmp { git clone $restSpecsRepoUri }
  }
}
