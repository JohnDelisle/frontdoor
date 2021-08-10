param vwan_id string
param vnet_cidr string
param hub_cidr string
param dnsServer_host_number int
param subnets array
param subnet_indexes object

// works for a /24 or other prefixes ending in a .0
// it's a cludge, but there's no cidrhost() in Bicep
var dnsServer_network = split(subnets[subnet_indexes.dnsSubnet].addressPrefix, '/')[0]
var dnsServer_ip = '${split(dnsServer_network, '.')[0]}.${split(dnsServer_network, '.')[1]}.${split(dnsServer_network, '.')[2]}.${dnsServer_host_number}'

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
    dhcpOptions: {
      dnsServers: [
        dnsServer_ip
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
      }
    }]
  }
}

output subnets array = virtualNetwork.properties.subnets
