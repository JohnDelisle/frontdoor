resource vwan 'Microsoft.Network/virtualWans@2021-02-01' = {
  name: '${resourceGroup().name}-vwan'
  location: resourceGroup().location
  properties: {
    allowVnetToVnetTraffic: true
    allowBranchToBranchTraffic: true
    type: 'Standard'
  }
}

output vwan_id string = vwan.id
