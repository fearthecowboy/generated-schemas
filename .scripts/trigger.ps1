
$ErrorActionPreference  = "stop"
. $PSScriptRoot/shared.ps1
. $PSScriptRoot/constants.ps1

# This script requires the following:
# nodejs v10.15 (LTS build)
# git
# autorest (v3 beta) -- use 'npm install -' 

# will quit after number of failed RPs
$MaxFailures = 9999

# filter out these modules for now (broken, fixing autorest core bug)
$filter  = @(
  'apimanagement',
  'network',
  'aszadmin',
  'cost-management',
  'datamigration',
  'deploymentmanager',
  'hardwaresecuritymodules',
  'security',
  'servicefabric',
  'storage'
)

# you can restrict it to generating just what's in here.
$only  = @(
#  'compute'
)

## ===========================================================================
# script
  
// cleanup schema folder first.
in $schemas { git checkout . ; git clean -xdf .  } 


// ensure we have the azure-rest-api-specs repo
if( -not (test-path $restSpecs)) {
  => cloning the repository
  In $tmp { git clone $restSpecsRepoUri --branch multiapi }
} else {
  try {
    => cleaning the repository
    in $restSpecs { git clean -xdf }
  } catch { 
    /$ hmm. just nuke it and clone it from scratch
    Remove-Item -recurse -force $restSpecs 
    In $tmp { git clone $restSpecsRepoUri --branch multiapi }
  }
}

$txt = "";

// get all readme.md files 
$allreadmes = get-childitem $restSpecs\readme.enable-multi-api.md -recurse  | where { $_.FullName -match "resource.manager" }

# filter out anything in $filter
if( $filter -and $filter.length ) {
  $allreadmes = $allreadmes | where { -not ($_.FullName -match ($filter -join '|')) }  
}

# keep anything in $only
if( $only -and $only.length ) {
  $allreadmes = $allreadmes | where { $_.FullName -match ($only -join '|') }  
}

$txt = ''
$x = 0

$allreadmes |% {
  if( $x -lt $MaxFailures ) {
    $x = $x +1 
  $file = $_
  $parent = Resolve-Path "$($file)\.."  
  
  $apiversions =  ((Get-ChildItem $parent -recurse -Directory).FullName | select-string -Pattern '.*\\(\d\d\d\d-\d\d-\d\d[^\\]*)$'  |% { $_.Matches } | % { $_.groups[1].value } | Group-Object).Name                          

  => On "$file `n => found api versions : $apiversions `n`n" 
  $apiversions |% {
    # // run autorest on $file with --api-version:$_  
    write-host autorest --use=C:\work\2019\autorest.azureresourceschema --enable-multi-api  --azureresourceschema $file --output-folder=$schemas "--api-version:$_"  --title=none 

    # Local test version of schema generator
    # use the following line to use a local build of the autorest.azureresourceschema generator.
    # autorest --use=C:\work\2019\autorest.azureresourceschema --azureresourceschema $file --output-folder=$schemas "--api-version:$_"  --title=none 

    # uses the published autorest resource schema generator v3
    autorest "--azureresourceschema@v3" $file --output-folder=$schemas "--api-version:$_"  --title=justschema

    $v = $LastExitCode
    if( $v -ne 0 ) {
      $txt =  "$txt`n$file - $_"
      write-host -fore red "FAILED: $file - APIVersion: $_"
    }
  }
  }
}

# record the failures
set-content -path $PSScriptRoot/failed.txt -value $txt


