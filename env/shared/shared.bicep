targetScope = 'subscription'

param version int = 4
param rgPrefix string

var location = 'eastus2'

module sharedVwan '../../modules/sharedVwan.bicep' = {
  name: '${location}-sharedVwan'
  params: {
    rgPrefix: rgPrefix
    version: version
    location: location
  }
}

output vwan_id string = sharedVwan.outputs.vwan_id
