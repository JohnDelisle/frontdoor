param location string
param version int
param rgPrefix string

targetScope = 'subscription'

resource vwanRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${rgPrefix}${version}-vwan-nr'
  location: location
}

module vwan './vwan.bicep' = {
  scope: vwanRg
  name: 'vwan'
  params: {}
}

output vwan_id string = vwan.outputs.vwan_id
