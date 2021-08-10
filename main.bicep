targetScope = 'subscription'

resource eastus2NetRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'app508-jmdpe-net-eastus2'
  location: 'eastus2'
}

resource centralusNetRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'app508-jmdpe-net-centralus'
  location: 'centralus'
}

resource vwanRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'app508-jmdpe-vwan-nr'
  location: 'eastus2'
}

resource eastus2WebRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'app508-jmdpe-web-eastus2'
  location: 'eastus2'
}

resource centralusWebRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'app508-jmdpe-web-centralus'
  location: 'centralus'
}

var subnet_indexes = {
  vmSubnet: 0
  appServiceEndpointSubnet: 1
  dnsSubnet: 2
}

module eastus2Net './modules/regionalNetwork.bicep' = {
  name: 'eastus2Net'
  scope: eastus2NetRg
  params: {
    vwan_id: vwan.outputs.vwan_id
    vnet_cidr: '10.1.0.0/16'
    hub_cidr: '10.255.1.0/24'
    dnsServer_host_number: 5
    subnets: [
      {
        name: 'vm-subnet'
        addressPrefix: '10.1.0.0/24'
      }
      {
        name: 'appservice-endpoint-subnet'
        addressPrefix: '10.1.1.0/24'
      }
      {
        name: 'dns-subnet'
        addressPrefix: '10.1.255.0/24'
      }
    ]
    subnet_indexes: subnet_indexes
  }
}

module centralusNet './modules/regionalNetwork.bicep' = {
  name: 'centralusNet'
  scope: centralusNetRg
  params: {
    vwan_id: vwan.outputs.vwan_id
    vnet_cidr: '10.2.0.0/16'
    hub_cidr: '10.255.2.0/24'
    dnsServer_host_number: 5
    subnets: [
      {
        name: 'vm-subnet'
        addressPrefix: '10.2.0.0/24'
      }
      {
        name: 'appservice-endpoint-subnet'
        addressPrefix: '10.2.1.0/24'
      }
      {
        name: 'dns-subnet'
        addressPrefix: '10.2.255.0/24'
      }
    ]
    subnet_indexes: subnet_indexes
  }
}

module vwan './modules/vwan.bicep' = {
  name: 'vwan'
  scope: vwanRg
  params: {}
}

module eastus2WebApp './modules/webapp.bicep' = {
  name: 'eastus2WebApp'
  scope: eastus2WebRg
  params: {
    subnet_id: eastus2Net.outputs.subnets[subnet_indexes.appServiceEndpointSubnet].id
  }
}

module centralusWebApp './modules/webapp.bicep' = {
  name: 'centralusWebApp'
  scope: centralusWebRg
  params: {
    subnet_id: centralusNet.outputs.subnets[subnet_indexes.appServiceEndpointSubnet].id
  }
}

module eastus2DnsVm './modules/dns.bicep' = {
  name: 'eastus2DnsVm'
  scope: eastus2NetRg
  params: {
    subnet_id: eastus2Net.outputs.subnets[subnet_indexes.dnsSubnet].id
    subnet_prefix: eastus2Net.outputs.subnets[subnet_indexes.dnsSubnet].properties.addressPrefix
    vm_name: 'dns01'
    vm_host_number: 5
  }
}

module centralusDnsVm './modules/dns.bicep' = {
  name: 'centralusDnsVm'
  scope: centralusNetRg
  params: {
    subnet_id: centralusNet.outputs.subnets[subnet_indexes.dnsSubnet].id
    subnet_prefix: centralusNet.outputs.subnets[subnet_indexes.dnsSubnet].properties.addressPrefix
    vm_name: 'dns01'
    vm_host_number: 5
  }
}
