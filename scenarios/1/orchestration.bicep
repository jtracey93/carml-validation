targetScope = 'subscription'

// Parameters
param parLocation string = deployment().location

param parNamePrefix string = 'scn1'

param parLawSolutions array = [
  {
    name: 'VMInsights'
    product: 'OMSGallery'
    publisher: 'Microsoft'
  }
]

param parAddressPrefixes array

param parSubnets array

// Variables

var varDeploymentNames = {
  modRsg: 'scenario-1-rsg'
  modLaw: 'scenario-1-law'
  modAppInsights: 'scenario-1-appInsights'
  modKeyVault: 'scenario-1-keyVault'
  modVNet: 'scenario-1-vNet'
}

var varResourceNaming = {
  modRsg: 'rsg-${parNamePrefix}-001'
  modLaw: 'law-${parNamePrefix}-001'
  modAppInsights: 'appi-${parNamePrefix}-001'
  modKeyVault: 'kvlt-${parNamePrefix}-001'
  modVNet: 'vnet-${parNamePrefix}-001'
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

module modVNet '../../carml/arm/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  scope: resourceGroup(varResourceNaming.modRsg)
  dependsOn: [
    modRSG
  ]
  name: varDeploymentNames.modVNet
  params: {
    name: varResourceNaming.modVNet
    location: parLocation
    addressPrefixes: parAddressPrefixes
     subnets: parSubnets
  }
}
