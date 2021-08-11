targetScope = 'subscription'

param version int = 4

var location = 'eastus2'

module vwan '../../modules/sharedVwan.bicep' = {
  name: '${location}-sharedVwan'
  params: {
    version: version
    location: location
  }
}

output vwan_id string = vwan.outputs.vwan_id
