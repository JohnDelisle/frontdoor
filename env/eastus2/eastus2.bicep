param vwan_id string = '/subscriptions/d7c0f56a-558e-46e3-bbbb-2c733b72f3d8/resourceGroups/app508-jmdpe3-vwan-nr/providers/Microsoft.Network/virtualWans/app508-jmdpe3-vwan-nr-vwan'

targetScope = 'subscription'

var version = 4
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
var vnet_cidr = '10.1.0.0/16'
var hub_cidr = '10.255.1.0/24'

module regionalEnvironment '../../modules/regionalEnvironment.bicep' = {
  name: '${location}-regionalEnvironment'
  params: {
    version: version
    location: location
    subnets: subnets
    subnet_indexes: subnet_indexes
    dnsServer_privateIpAddress: dnsServer_privateIpAddress
    vwan_id: vwan_id
    vnet_cidr: vnet_cidr
    hub_cidr: hub_cidr
  }
}

output dnsVm_ipAddresses object = regionalEnvironment.outputs.dnsVm_ipAddresses
output dummyVm_ipAddresses object = regionalEnvironment.outputs.dummyVm_ipAddresses
