param version int

targetScope = 'subscription'

resource vwanRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'app508-jmdpe${version}-vwan-nr'
  location: 'eastus2'
}

module vwan './vwan.bicep' = {
  scope: vwanRg
  name: 'vwan'
  params: {}
}

output vwan_id string = vwan.outputs.vwan_id
