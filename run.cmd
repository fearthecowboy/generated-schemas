node c:\work\2019\autorest\src\autorest\dist\app --enable-multi-api --use=C:\work\2019\autorest.azureresourceschema --azureresourceschema C:\work\2019\generated-schemas\tmp\azure-rest-api-specs\specification\redis\resource-manager\readme.md --output-folder=./tmp/schemas --api-version:2018-03-01 %*

@echo off
REM #--use:@microsoft.azure/autorest-interactive@latest


REM When a parameter 'in' is any value other than "body":
  REM - we do create the schema, but we missed moving x-ms-enum into the schema, and it gets left behind in the parameter, where it's not legal.