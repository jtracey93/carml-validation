// Parameters
// param parLocation string = deployment().location
param parLocation string = 'centralus'

param parNamePrefix string = 'scn2'

param parExistingLawResourceID string 
param parExistingKeyVaultResourceID string 

// Variables

var varDeploymentNames = {
  modRsg: 'scenario-2-rsg'
  modLaw: 'scenario-2-law'
  modAppInsights: 'scenario-2-appInsights'
  modKeyVault: 'scenario-2-keyVault'
  modAKS: 'scenario-2-aks'
  modSQL: 'scenario-2-sql'
  modACR: 'scenario-2-acr'
  modVNet: 'scenario-2-vNet'
}

var varResourceNaming = {
  modRsg: 'rsg-${parNamePrefix}-001'
  modLaw: 'law-${parNamePrefix}-001'
  modAppInsights: 'appi-${parNamePrefix}-001'
  modKeyVault: 'kvlt-${parNamePrefix}-001'
  modAKS: 'aks-${parNamePrefix}-001'
  modSQL: 'sql-${parNamePrefix}-001sdf'
  modACR: 'acr${parNamePrefix}001'
  modVNet: 'vNet-${parNamePrefix}-001'
}

resource resExistingLaw 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: '${split(parExistingLawResourceID, '/')[8]}'
}

resource resExistingKeyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: '${split(parExistingKeyVaultResourceID, '/')[8]}'
}

module modSQL '../../carml/arm/Microsoft.Sql/servers/deploy.bicep' = {
  name: varDeploymentNames.modSQL
  params: {
    name: varResourceNaming.modSQL
    location: parLocation
    administratorLogin: 'johndoe'
    administratorLoginPassword: resExistingKeyVault.getSecret('sqlserversecret')
    databases:[
      {
        name: 'scenario2DB'
        collation: 'SQL_Latin1_General_CP1_CI_AS'
        tier: 'GeneralPurpose'
        skuName: 'GP_Gen5_2'
        maxSizeBytes: 34359738368
        licenseType: 'LicenseIncluded'
        workspaceId: resExistingLaw.id
      }
    ]
  }
}

//AKS
module modAKS '../../carml/arm/Microsoft.ContainerService/managedClusters/deploy.bicep' = {
  scope: resourceGroup(varResourceNaming.modRsg)
  name: varDeploymentNames.modAKS
  params: {
    name: varResourceNaming.modAKS
    location: parLocation
    primaryAgentPoolProfile: [
      {
        name: 'npsystem'
        count: 3
        vmSize: 'Standard_DS2'
        osDiskSizeGB: 80
        osDiskType: 'Ephemeral'
        osType: 'Linux'
        minCount: 3
        maxCount: 4
        enableAutoScaling: true
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        scaleSetPriority: 'Regular'
        scaleSetEvictionPolicy: 'Delete'
        orchestratorVersion: '1.22.4'
        enableNodePublicIP: false
        maxPods: 30
        upgradeSettings: {
          maxSurge: '33%'
        }
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
      }
    ]
    systemAssignedIdentity: true
  }
}

// module modVNet '../../carml/arm/Microsoft.Network/virtualNetworks/deploy.bicep' = {
//   scope: resourceGroup(varResourceNaming.modRsg)
//   dependsOn: [
//     modRSG
//   ]
//   name: varDeploymentNames.modVNet
//   params: {
//     name: varResourceNaming.modVNet
//     location: parLocation
//     addressPrefixes: parAddressPrefixes
//      subnets: parSubnets
//   }
// }
