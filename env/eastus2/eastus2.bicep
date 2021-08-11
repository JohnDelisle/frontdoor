param vwan_id string

targetScope = 'subscription'

var version = 3
var location = 'eastus2'
var subnet_indexes = {
  vmSubnet: 0
  appServiceEndpointSubnet: 1
  dnsSubnet: 2
}
var subnets = [
  {
    name: 'vm-subnet'
    addressPrefix: '10.1.0.0/24'
  }
  {
    name: 'appservice-endpoint-subnet'
    addressPrefix: '10.1.1.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
  {
    name: 'dns-subnet'
    addressPrefix: '10.1.255.0/24'
  }
]
var dnsServer_privateIpAddress = '10.1.255.5'

module regionalEnvironment '../../modules/regionalEnvironment.bicep' = {
  name: 'regionalEnvironment'
  params: {
    version: version
    location: location
    subnets: subnets
    subnet_indexes: subnet_indexes
    dnsServer_privateIpAddress: dnsServer_privateIpAddress
    vwan_id: vwan_id
  }
}