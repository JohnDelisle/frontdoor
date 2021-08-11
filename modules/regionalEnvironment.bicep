targetScope = 'subscription'

param location string
param vwan_id string
param dnsServer_privateIpAddress string
param subnets array
param subnet_indexes object
param version int

resource netRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'app508-jmdpe${version}-net-${location}'
  location: location
}

resource webRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'app508-jmdpe${version}-web-${location}'
  location: location
}

module network './network.bicep' = {
  name: 'network'
  scope: netRg
  params: {
    vwan_id: vwan_id
    vnet_cidr: '10.1.0.0/16'
    hub_cidr: '10.255.1.0/24'
    dnsServer_privateIpAddress: dnsServer_privateIpAddress
    subnets: subnets
  }
}

module webApp './webApp.bicep' = {
  name: 'webApp'
  scope: webRg
  params: {
    subnet_id: network.outputs.subnets[subnet_indexes.appServiceEndpointSubnet].id
    dnsServer_ipAddress: dnsServer_privateIpAddress
  }
}

module dnsVm './dnsVm.bicep' = {
  name: 'dnsVm'
  scope: netRg
  params: {
    subnet_id: network.outputs.subnets[subnet_indexes.dnsSubnet].id
    vm_name: 'dns01'
    vm_privateIpAddress: dnsServer_privateIpAddress
  }
}

module dummyVm './dummyVm.bicep' = {
  name: 'dummyVm'
  scope: webRg
  params: {
    subnet_id: network.outputs.subnets[subnet_indexes.vmSubnet].id
    vm_name: 'dummy01'
  }
}

output dnsVm object = {
  publicIpAddress: dnsVm.outputs.publicIpAddress
  privateIpAddress: dnsVm.outputs.privateIpAddress
}

output dummyVm object = {
  publicIpAddress: dummyVm.outputs.publicIpAddress
  privateIpAddress: dummyVm.outputs.privateIpAddress
}
