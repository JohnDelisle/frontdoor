param subnet_id string
param dnsServer_ipAddress string

resource serverFarm 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: '${resourceGroup().name}-asp'
  location: resourceGroup().location

  sku: {
    name: 'P1v2'
    tier: 'PremiumV2'
    size: 'P1v2'
    family: 'P1v2'
    capacity: 1
  }
  kind: 'app'
}

resource webApp 'Microsoft.Web/sites@2021-01-15' = {
  name: '${resourceGroup().name}-app'
  location: resourceGroup().location
  kind: 'app'
  properties: {
    serverFarmId: serverFarm.id
  }
}

resource appSettings 'Microsoft.Web/sites/config@2021-01-15' = {
  parent: webApp
  name: 'appsettings'
  properties: {
    WEBSITE_DNS_SERVER: dnsServer_ipAddress
    WEBSITE_VNET_ROUTE_ALL: '1'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: '${webApp.name}-pe'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: subnet_id
    }
    privateLinkServiceConnections: [
      {
        name: '${webApp.name}-pe-conn'
        properties: {
          privateLinkServiceId: webApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}
