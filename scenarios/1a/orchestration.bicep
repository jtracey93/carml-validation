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

// Variables

var varDeploymentNames = {
  modRsg: 'scenario-1-rsg'
  modLaw: 'scenario-1-law'
  modAppInsights: 'scenario-1-appInsights'
  modKeyVault: 'scenario-1-keyVault'
  modVM: 'scenario-1-vm'
}

var varResourceNaming = {
  modRsg: 'rsg-${parNamePrefix}-001'
  modLaw: 'law-${parNamePrefix}-001'
  modAppInsights: 'appi-${parNamePrefix}-001'
  modKeyVault: 'kvlt-${parNamePrefix}-001'
  modVM: 'vm-${parNamePrefix}-001'
}

var varUserName = {
  modVMAdmin: 'admin${parNamePrefix}'
}

module modRSG '../../carml/arm/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: varDeploymentNames.modRsg
  params: {
    name: varResourceNaming.modRsg
    location: parLocation
  }
}

module modVM '../../carml/arm/Microsoft.Compute/virtualMachines/deploy.bicep' = {
  scope: resourceGroup(varResourceNaming.modRsg)
  dependsOn: [
    modRSG
  ]
  name: varResourceNaming.modVM
  params: {
    adminUsername: varUserName.modVMAdmin
    imageReference: {
      offer: 'MicrosoftServer'
      publisher: 'MicrosoftWindowsServer'
      sku: parWindowsOSVersion
      version: 'latest'
    }
    nicConfigurations: [
      'Save for Nic'
    ]
    osDisk: {
    }
    osType: 'Windows'
  }
}
