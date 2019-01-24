## ===========================================================================
# constants
$restSpecsRepoUri = "https://github.com/azure/azure-rest-api-specs"

## ===========================================================================
# locations
$root = resolvepath $PSScriptRoot/..
$tmp = resolvepath $root/tmp ; mkdir -ea 0  $tmp
$restSpecs = resolvepath $tmp/azure-rest-api-specs
$schemas = resolvepath $root/schemas


