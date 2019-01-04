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

function write-hostcolor { Param ( $color,  [parameter(ValueFromRemainingArguments=$true)] $content ) write-host -fore $color $content }
function comment { Param ( [parameter(ValueFromRemainingArguments=$true)] $content ) write-host -fore darkgray $content }
function action { Param ( [parameter(ValueFromRemainingArguments=$true)] $content ) write-host -fore green $content }
function warn { Param ( [parameter(ValueFromRemainingArguments=$true)] $content ) write-host -fore yellow $content }

function err { Param ( [parameter(ValueFromRemainingArguments=$true)] $content ) write-host -fore red $content }

new-alias '//'  comment
new-alias '=>' action
new-alias '/$' warn
new-alias '/!' err

new-alias '==>' write-hostcolor

## ===========================================================================
# constants
$restSpecsRepoUri = "https://github.com/azure/azure-rest-api-specs"

## ===========================================================================
# locations
$root = resolvepath $PSScriptRoot/..
$tmp = resolvepath $root/tmp ; mkdir -ea 0  $tmp
$restSpecs = resolvepath $tmp/azure-rest-api-specs
$schemas = resolvepath $root/schemas


## ===========================================================================
# script
// cleanup schema folder first.
in $schemas { git checkout . ; git clean -xdf .  } 

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

// find files changed in last commit.
$files = in $restSpecs { git diff-tree --no-commit-id --name-only -r HEAD~1 } 
$swaggers = @()

$files |% { 
  $file = "$restSpecs/$_"
  $content = get-content -raw $file
  if( $content -match '"swagger": "2.0"' ) {
    // $file is a swagger file
    $swaggers += $file 
  }
}


$swaggers |% {
  $swagger = $_
  autorest --input-file:$swagger --output-folder:$schemas --azureresourceschema
}

$newfiles = in $schemas { git status . -uall }
$newMarkdownFiles = $newfiles | where { $_ -match ".md" }
$newSchemaFiles = $newfiles | where { $_ -match ".json" }

in $restSpecs { $newMarkdownFiles |% { remove-item $_ }  }

=> $newSchemaFiles