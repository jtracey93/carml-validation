targetScope = 'subscription'

// Parameters
param parLocation string = deployment().location

param parNamePrefix string = 'scn2'

param parLawSolutions array = [
  {
    name: 'VMInsights'
    product: 'OMSGallery'
    publisher: 'Microsoft'
  }
]

// Variables

var varDeploymentNames = {
  modRsg: 'scenario-2-rsg'
  modLaw: 'scenario-2-law'
  modAppInsights: 'scenario-2-appInsights'
  modKeyVault: 'scenario-2-keyVault'
  modAKS: 'scenario-2-aks'
  modSQL: 'scenario-2-sql'
  modACR: 'scenario-2-acr'
}

var varResourceNaming = {
  modRsg: 'rsg-${parNamePrefix}-001'
  modLaw: 'law-${parNamePrefix}-001'
  modAppInsights: 'appi-${parNamePrefix}-001'
  modKeyVault: 'kvlt-${parNamePrefix}-001'
  modAKS: 'aks-${parNamePrefix}-001'
  modSQL: 'sql-${parNamePrefix}-001'
  modACR: 'acr${parNamePrefix}001'
}

// Resources

// Modules

// Resource Group
module modRSG '../../carml/arm/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: varDeploymentNames.modRsg
  params: {
    name: varResourceNaming.modRsg
    location: parLocation
  }
}

// Log Analytics
module modLaw '../../carml/arm/Microsoft.OperationalInsights/workspaces/deploy.bicep' = {
  scope: resourceGroup(varResourceNaming.modRsg)
  dependsOn: [
    modRSG
  ]
  name: varDeploymentNames.modLaw
  params: {
    name: varResourceNaming.modLaw
    location: parLocation
    gallerySolutions: parLawSolutions
  }
}

// App Insights
module modAppInsights '../../carml/arm/Microsoft.Insights/components/deploy.bicep' = {
  scope: resourceGroup(varResourceNaming.modRsg)
  dependsOn: [
    modRSG
  ]
  name: varDeploymentNames.modAppInsights
  params: {
    name: varResourceNaming.modAppInsights
    location: parLocation
    workspaceResourceId: modLaw.outputs.resourceId
  }
}

// Key Vault
module modKeyVault '../../carml/arm/Microsoft.KeyVault/vaults/deploy.bicep' = {
  scope: resourceGroup(varResourceNaming.modRsg)
  dependsOn: [
    modRSG
  ]
  name: varDeploymentNames.modKeyVault
  params: {
    name: varResourceNaming.modKeyVault
    location: parLocation
    diagnosticWorkspaceId: modLaw.outputs.resourceId
  }
}

// ACR
module modACR '../../carml/arm/Microsoft.ContainerRegistry/registries/deploy.bicep' = {
  scope: resourceGroup(varResourceNaming.modRsg)
  dependsOn: [
    modRSG
  ]
  name: varDeploymentNames.modACR
  params: {
    name: varResourceNaming.modACR
    location: parLocation
    diagnosticWorkspaceId: modLaw.outputs.resourceId
  }
}

output outLawResoruceID string = modLaw.outputs.resourceId
output outKeyVaultResourceID string = modKeyVault.outputs.resourceId
