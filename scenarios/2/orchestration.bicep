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

param parVnetAksCIDR array = [
  '10.1.0.0/16'
]

param parVnetAksSubnets array = [
  {
    name: 'aks-subnet'
    addressPrefix: '10.1.0.0/22'
  }
]

param parVnetHubCIDR array = [
  '10.2.0.0/16'
]

param parVnetHubSubnets array = [
  {
    name: 'vm-subnet'
    addressPrefix: '10.2.0.0/24'
  }
  {
    name: 'AzureBastionSubnet'
    addressPrefix: '10.2.240.0/24'
  }
  {
    name: 'AzureFirewallSubnet'
    addressPrefix: '10.2.255.0/24'
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
  modVnetAks: 'scenario-2-vnet-aks'
  modVnetHub: 'scenario-2-vnet-hub'
}

var varResourceNaming = {
  modRsg: 'rsg-${parNamePrefix}-001'
  modLaw: 'law-${parNamePrefix}-001'
  modAppInsights: 'appi-${parNamePrefix}-001'
  modKeyVault: 'kvlt-${parNamePrefix}-001'
  modAKS: 'aks-${parNamePrefix}-001'
  modSQL: 'sql-${parNamePrefix}-001'
  modACR: 'acr${parNamePrefix}001'
  modVnetAks: 'vnet-${parNamePrefix}-aks-001'
  modVnetHub: 'vnet-${parNamePrefix}-hub-001'
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

// Key Vault - With Private Endpoints
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
    enableSoftDelete: false
  }
}

// ACR - With Private Endpoints
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

//// VNETs - 1 & 2 

// VNET 1 - AKS
module modVnetAks '../../carml/arm/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  scope: resourceGroup(varResourceNaming.modRsg)
  dependsOn: [
    modRSG
  ]
  name: varDeploymentNames.modVnetAks
  params: {
    addressPrefixes: parVnetAksCIDR
    location: parLocation
    name: varResourceNaming.modVnetAks
    subnets: parVnetAksSubnets
  }
}

// VNET 2 - Hub
module modVnetHub '../../carml/arm/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  scope: resourceGroup(varResourceNaming.modRsg)
  dependsOn: [
    modRSG
  ]
  name: varDeploymentNames.modVnetHub
  params: {
    addressPrefixes: parVnetHubCIDR
    location: parLocation
    name: varResourceNaming.modVnetHub
    subnets: parVnetHubSubnets
    virtualNetworkPeerings: [
      {
        remoteVirtualNetworkId: modVnetAks.outputs.resourceId
        allowForwardedTraffic: true
        allowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
      }
    ]
  }
}

// Private DNS Zones

// Azure Firewall

output outLawResoruceID string = modLaw.outputs.resourceId
output outKeyVaultResourceID string = modKeyVault.outputs.resourceId
