targetScope = 'subscription'
param version int = 4
param rgPrefix string = 'app508-jmdpe'

module frontdoor_Shared '../shared/shared.bicep' = {
  name: 'frontdoor_Shared'
  params: {
    rgPrefix: rgPrefix
    version: version
  }
}

module frontdoor_eastus2 '../eastus2/eastus2.bicep' = {
  name: 'frontdoor_eastus2'
  dependsOn: [
    frontdoor_Shared
  ]
  params: {
    rgPrefix: rgPrefix
    version: version
    vwan_id: frontdoor_Shared.outputs.vwan_id
  }
}

module frontdoor_centralus '../centralus/centralus.bicep' = {
  name: 'frontdoor_centralus'
  dependsOn: [
    frontdoor_Shared
    frontdoor_eastus2
  ]
  params: {
    rgPrefix: rgPrefix
    version: version
    vwan_id: frontdoor_Shared.outputs.vwan_id
  }
}

output ipAddresses object = {
  eastus2: {
    dnsVm: frontdoor_eastus2.outputs.dnsVm_ipAddresses
    dummyVm: frontdoor_eastus2.outputs.dummyVm_ipAddresses
  }
  centralus: {
    dnsVm: frontdoor_centralus.outputs.dnsVm_ipAddresses
    dummyVm: frontdoor_centralus.outputs.dummyVm_ipAddresses
  }
}
