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
  modRsg: 'scenario-3-rsg'
  modLaw: 'scenario-3-law'
  modAppInsights: 'scenario-3-appInsights'
  modKeyVault: 'scenario-3-keyVault'
  modAKS: 'scenario-3-aks'
  modSQL: 'scenario-3-sql'
  modACR: 'scenario-3-acr'
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
module modRSG 'br/CoreModules:microsoft.resources.resourcegroups:0.1.0' = {
  name: varDeploymentNames.modRsg
  params: {
    name: varResourceNaming.modRsg
    location: parLocation
  }
}

// // Log Analytics
// module modLaw 'br/CoreModules:Microsoft.OperationalInsights:0.1.0' = {
//   scope: resourceGroup(varResourceNaming.modRsg)
//   dependsOn: [
//     modRSG
//   ]
//   name: varDeploymentNames.modLaw
//   params: {
//     name: varResourceNaming.modLaw
//     location: parLocation
//     gallerySolutions: parLawSolutions
//   }
// }

// // App Insights 
// module modAppInsights 'br/CoreModules:Microsoft.Insights:0.1.0' = {
//   scope: resourceGroup(varResourceNaming.modRsg)
//   dependsOn: [
//     modRSG
//   ]
//   name: varDeploymentNames.modAppInsights
//   params: {
//     name: varResourceNaming.modAppInsights
//     location: parLocation
//     workspaceResourceId: modLaw.outputs.resourceId
//   }
// }

// // Key Vault - With Private Endpoints
// module modKeyVault 'br/CoreModules:Microsoft.KeyVault:0.1.0' = {
//   scope: resourceGroup(varResourceNaming.modRsg)
//   dependsOn: [
//     modRSG
//   ]
//   name: varDeploymentNames.modKeyVault
//   params: {
//     name: varResourceNaming.modKeyVault
//     location: parLocation
//     diagnosticWorkspaceId: modLaw.outputs.resourceId
//   }
// }

// // ACR - With Private Endpoints

// module modACR 'br/CoreModules:Microsoft.ContainerRegistry:0.1.0' = {
//   scope: resourceGroup(varResourceNaming.modRsg)
//   dependsOn: [
//     modRSG
//   ]
//   name: varDeploymentNames.modACR
//   params: {
//     name: varResourceNaming.modACR
//     location: parLocation
//     diagnosticWorkspaceId: modLaw.outputs.resourceId
//   }
// }

// // VNETs - 1 & 2 

// // VNET Peering

// // Private DNS Zones

// output outLawResoruceID string = modLaw.outputs.resourceId
// output outKeyVaultResourceID string = modKeyVault.outputs.resourceId
