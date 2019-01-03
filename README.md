# generated-schemas
Testing generated schemas for Azure


# Process.
Find the changed swagger files

clone the generated respository

run the generator for each chagned swagger file:

autorest 
  --azureresourceschema 
  --output-folder=./$GENERATED_REPO/schemas
  --input-file:azure-rest-api-specs/specification/advisor/resource-manager/Microsoft.Advisor/stable/2017-04-19\advisor.json 

get the changed files in the output repository

(Remove the .md files) -- or add in a .gitignore setting (schemas/**/*.md )?

if( files changed)
  create the PR for the target.
    

    
  