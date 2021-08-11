targetScope = 'subscription'

var version = 3

module vwan '../../modules/sharedVwan.bicep' = {
  name: 'sharedVwan'
  params: {
    version: version
  }
}

output vwan_id string = vwan.outputs.vwan_id
