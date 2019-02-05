$ErrorActionPreference  = "stop"
. $PSScriptRoot/shared.ps1
. $PSScriptRoot/constants.ps1

# This script requires the following:
# git

# failures:
#   authorization 
#   apimanagement
#   azure-kusto
#   batch
#   billing
#   compute

## ===========================================================================
# script
  
// cleanup schema folder first.
in $schemas { git checkout . ; git clean -xdf .  } 

<#
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
#>

# node c:\work\2019\autorest\src\autorest\dist\app --enable-multi-api --use=C:\work\2019\autorest.azureresourceschema --azureresourceschema C:\work\2019\azure-rest-api-specs\specification\redis\resource-manager\readme.md --output-folder=./schemas
# --debug --verbose   --all C:\work\2019\azure-rest-api-specs\specification\redis\resource-manager\readme.md --output-folder=./schemas

# autorest --azureresourceschema --api-version:XXXX-YY-ZZ  --output-folder:$(csaharpsdk) --MYSDKFOLDER:/foo/bar/bing/

$txt = "";

// get all readme.md files 
# $allreadmes = get-childitem $restSpecs\readme.md -recurse  | where { $_.FullName -match "resource.manager" }
# $allreadmes = get-childitem tmp\azure-rest-api-specs\readme.md -recurse  | where { $_.FullName -match "resource.manager" }  #|where {$_.FullName -match "batch" } 

# (select-string -Path C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\compute\resource-manager\readme.md -Pattern "\(tag\).*'(.*)'" |% { $_.Matches } | % { $_.groups[1].value } | Group-Object).Name

$allreadmes = @("C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\apimanagement\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\azure-kusto\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\azurestack\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\billing\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\compute\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\containerinstance\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\cost-management\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\datamigration\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\eventhub\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\frontdoor\resource-manager\Microsoft.Network\preview\2018-08-01-preview\README.md -",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\hardwaresecuritymodules\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\hdinsight\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\iothub\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\logic\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\machinelearning\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\machinelearningcompute\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\machinelearningservices\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\mariadb\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\mediaservices\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\mysql\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\network\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\postgresql\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\recoveryservicesbackup\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\resources\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\servicebus\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\servicefabric\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\servicefabricmesh\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\service-map\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\signalr\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\sql\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\storage\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\subscription\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\timeseriesinsights\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\trafficmanager\resource-manager\readme.md",
"C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\web\resource-manager\readme.md")


$x = 0

$allreadmes |% {
  $file = $_
  $parent = Resolve-Path "$($file)\.."  
  $apiversions =  ((Get-ChildItem $parent -recurse -Directory).FullName | select-string -Pattern '.*\\(\d\d\d\d-\d\d-\d\d[^\\]*)$'  |% { $_.Matches } | % { $_.groups[1].value } | Group-Object).Name                          

  

  => On "$file `n => found api versions : $apiversions `n`n" 
  $apiversions |% {
    # // run autorest on $file with --api-version:$_  
    # // node c:\work\2019\autorest\src\autorest\dist\app --enable-multi-api --use=C:\work\2019\autorest.azureresourceschema --azureresourceschema $file --output-folder=./tmp/schemas "--api-version:$_" --verbose --debug
    # node c:\work\2019\autorest\src\autorest\dist\app --enable-multi-api --use=C:\work\2019\autorest.azureresourceschema --azureresourceschema $file --output-folder=./tmp/schemas "--api-version:$_" 
    write-host autorest --use=C:\work\2019\autorest.azureresourceschema --enable-multi-api  --azureresourceschema $file --output-folder=./tmp/schemas "--api-version:$_" 
    node --max-old-space-size=16384 c:\work\2019\autorest\src\autorest\dist\app --use=C:\work\2019\autorest.azureresourceschema --enable-multi-api  --azureresourceschema $file --output-folder=./tmp/schemas "--api-version:$_"  --title=ClientTitleName
    $v = $LastExitCode
    if( $v -ne 0 ) {
      $txt =  "$txt`n$file - $_"
      write-host $txt
    }
  }
  <#
  $tags  = (select-string -Path $file -Pattern "\(tag\).*'(.*)'" |% { $_.Matches } | % { $_.groups[1].value } | Group-Object).Name

  $tags |% {
    $tag = $_
    # autorest $file --output-folder:$schemas/$tag --azureresourceschema --tag:$tag
    => 
  }
  #>

}

<#

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

$cmd =  @()

$swaggers |% {
  $swagger = $_
  # $cmd = $cmd + "--input-file=$( resolve-path $swagger)"
  => autorest  --input-file=$(resolve-path $swagger)  --output-folder:$schemas --azureresourceschema
  autorest --input-file=$(resolve-path $swagger) --output-folder:$schemas --azureresourceschema --title:none

}

#=> autorest $cmd --output-folder:$schemas --azureresourceschema
#autorest $cmd --output-folder:$schemas --azureresourceschema --title:none

#>
$newfiles = in $schemas { (git status . -uall).Trim() }
$newMarkdownFiles = $newfiles | where { $_ -match ".md" }
$newSchemaFiles = $newfiles | where { $_ -match ".json" }

in $schemas { $newMarkdownFiles |% { remove-item $_ }  }

=> $newSchemaFiles