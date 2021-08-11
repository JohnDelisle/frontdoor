targetScope = 'subscription'

resource vwanRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'app508-jmdpe2-vwan-nr'
  location: 'eastus2'
}

module vwan '../../modules/vwan.bicep' = {
  name: 'vwan'
  scope: vwanRg
  params: {}
}

output vwan_id string = vwan.outputs.vwan_id

