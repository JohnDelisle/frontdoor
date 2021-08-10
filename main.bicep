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

module eastus2Net './modules/regionalNetwork.bicep' = {
  name: 'eastus2Net'
  scope: eastus2NetRg
  params: {
    vnet_cidr: '10.1.0.0/16'
    dnsSubnet_cidr: '10.1.255.0/24'
    vmSubnet_cidr: '10.1.1.0/24'
    appServiceEndpointSubnet_cidr: '10.1.2.0/24'
    vwan_id: vwan.outputs.vwan_id
    hub_cidr: '10.255.1.0/24'
  }
}

module centralusNet './modules/regionalNetwork.bicep' = {
  name: 'centralusNet'
  scope: centralusNetRg
  params: {
    vnet_cidr: '10.2.0.0/16'
    dnsSubnet_cidr: '10.2.255.0/24'
    vmSubnet_cidr: '10.2.1.0/24'
    appServiceEndpointSubnet_cidr: '10.2.2.0/24'
    vwan_id: vwan.outputs.vwan_id
    hub_cidr: '10.255.2.0/24'
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
    subnet_id: eastus2Net.outputs.appServiceEndpointSubnet_id
  }
}

module centralusWebApp './modules/webapp.bicep' = {
  name: 'centralusWebApp'
  scope: centralusWebRg
  params: {
    subnet_id: centralusNet.outputs.appServiceEndpointSubnet_id
  }
}

module eastus2DnsVm './modules/dns.bicep' = {
  name: 'eastus2DnsVm'
  scope: eastus2NetRg
  params: {
    subnet_id: eastus2Net.outputs.dnsSubnet_id
    subnet_prefix: eastus2Net.outputs.dnsSubnet_prefix
    vm_name: 'dns01'
    vm_host_number: 5
  }
}

module centralusDnsVm './modules/dns.bicep' = {
  name: 'centralusDnsVm'
  scope: centralusNetRg
  params: {
    subnet_id: centralusNet.outputs.dnsSubnet_id
    vm_name: 'dns01'
    subnet_prefix: centralusNet.outputs.dnsSubnet_prefix
    vm_host_number: 5
  }
}
