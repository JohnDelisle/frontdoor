param vwan_id string
param vnet_cidr string
param hub_cidr string
param dnsServer_privateIpAddress string
param subnets array

resource virtualHub 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: '${resourceGroup().name}-hub'
  location: resourceGroup().location
  properties: {
    addressPrefix: hub_cidr
    virtualWan: {
      id: vwan_id
    }
    allowBranchToBranchTraffic: true
  }
}

resource virtualHubConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2021-02-01' = {
  name: '${virtualHub.name}/${virtualNetwork.name}-con'
  dependsOn: [
    virtualHub
    virtualNetwork
  ]
  properties: {
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: false

    remoteVirtualNetwork: {
      id: virtualNetwork.id
    }
    /*
    routingConfiguration: {

      associatedRouteTable: {
        id: '${virtualHub.id}/hubRouteTables/defaultRouteTable'
      }
      propagatedRouteTables: {
        /*ids: [
          {
            id: '${virtualHub.id}/hubRouteTables/defaultRouteTable'
          }
        ]*/

    /*
        labels: [
          'default'
        ]
      }
    }
    */
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: '${resourceGroup().name}-vnet'
  location: resourceGroup().location
  properties: {
    dhcpOptions: {
      dnsServers: [
        dnsServer_privateIpAddress
        '168.63.129.16'
      ]
    }
    addressSpace: {
      addressPrefixes: [
        vnet_cidr
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : null
      }
    }]
  }
}

output subnets array = virtualNetwork.properties.subnets
