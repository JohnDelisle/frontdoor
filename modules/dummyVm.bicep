param vm_name string
param location string
param subnet_id string
param vm_privateIpAddress string = ''

module dummyUbuntuVm './ubuntuVm.bicep' = {
  name: '${location}-dummyUbuntuVm'
  scope: resourceGroup()
  params: {
    subnet_id: subnet_id
    vm_name: vm_name
    vm_privateIpAddress: vm_privateIpAddress
    customData: ''
    enable_public_ip: true
    asg_id: asg.id
    nsg_id: nsg.id
  }
}

resource asg 'Microsoft.Network/applicationSecurityGroups@2021-02-01' = {
  name: '${resourceGroup().name}-dummy-asg'
  location: resourceGroup().location
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${resourceGroup().name}-dummy-nsg'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'permit-22'
        properties: {
          priority: 200
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asg.id
            }
          ]
          destinationPortRange: '22'
          access: 'Allow'
        }
      }
      {
        name: 'permit-80-443'
        properties: {
          priority: 300
          direction: 'Outbound'
          protocol: 'Tcp'
          sourceApplicationSecurityGroups: [
            {
              id: asg.id
            }
          ]
          sourcePortRange: '*'
          destinationAddressPrefixes: [
            '10.0.0.0/8'
          ]
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
        }
      }
    ]
  }
}

output publicIpAddress string = dummyUbuntuVm.outputs.publicIpAddress
output privateIpAddress string = dummyUbuntuVm.outputs.privateIpAddress
