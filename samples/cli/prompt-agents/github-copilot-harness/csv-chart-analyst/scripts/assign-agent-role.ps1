$ErrorActionPreference = 'Stop'

$projectEndpoint = azd env get-value FOUNDRY_PROJECT_ENDPOINT
$projectId = azd env get-value AZURE_AI_PROJECT_ID
$agentName = azd env get-value AGENT_CSV_CHART_ANALYST_NAME

$agentPrincipalId = az rest `
  --method GET `
  --url "$projectEndpoint/agents/$agentName`?api-version=v1" `
  --resource https://ai.azure.com `
  --query instance_identity.principal_id `
  --output tsv

$assignmentCount = az role assignment list `
  --assignee-object-id $agentPrincipalId `
  --role 'Foundry User' `
  --scope $projectId `
  --fill-principal-name false `
  --query 'length(@)' `
  --output tsv

if ($assignmentCount -eq '0') {
  az role assignment create `
    --assignee-object-id $agentPrincipalId `
    --assignee-principal-type ServicePrincipal `
    --role 'Foundry User' `
    --scope $projectId `
    --output none
}

Write-Host "Foundry User is assigned to agent identity $agentPrincipalId at project scope."