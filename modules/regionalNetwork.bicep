param vnet_cidr string
param dnsSubnet_cidr string
param vmSubnet_cidr string
param appServiceEndpointSubnet_cidr string
param vwan_id string
param hub_cidr string

resource virtualHub 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: '${resourceGroup().name}-hub'
  location: resourceGroup().location
  properties: {
    addressPrefix: hub_cidr
    virtualWan: {
      id: vwan_id
    }
  }
}

resource virtualHubConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2021-02-01' = {
  name: '${virtualHub.name}/${virtualNetwork.name}-con'
  properties: {
    remoteVirtualNetwork: {
      id: virtualNetwork.id
    }
    routingConfiguration: {
      associatedRouteTable: {
        id: '${virtualHub.id}/hubRouteTables/defaultRouteTable'
      }
      propagatedRouteTables: {
        ids: [
          {
            id: '${virtualHub.id}/hubRouteTables/defaultRouteTable'
          }
        ]
      }
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: '${resourceGroup().name}-vnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_cidr
      ]
    }
  }
}

resource dnsSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  parent: virtualNetwork
  name: 'dns-subnet'
  properties: {
    addressPrefix: dnsSubnet_cidr
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource vmSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  parent: virtualNetwork
  name: 'vm-subnet'
  properties: {
    addressPrefix: vmSubnet_cidr
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource appServiceEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  parent: virtualNetwork
  name: 'appservice-endpoint-subnet'
  dependsOn: [
    vmSubnet
  ]
  properties: {
    addressPrefix: appServiceEndpointSubnet_cidr
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

output appServiceEndpointSubnet_id string = appServiceEndpointSubnet.id
output dnsSubnet_id string = dnsSubnet.id
output dnsSubnet_prefix string = dnsSubnet.properties.addressPrefix
