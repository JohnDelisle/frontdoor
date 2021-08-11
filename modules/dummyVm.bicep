param vm_name string
param subnet_id string
param vm_host_number int = 256
param subnet_prefix string = ''

module dummyVm './ubuntuVm.bicep' = {
  name: 'dummyVm'
  scope: resourceGroup()
  params: {
    subnet_id: subnet_id
    vm_name: vm_name
    customData: ''
    enable_public_ip: true
    asg_id: asg.id
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
    ]
  }
}

output publicIpAddress string = dummyVm.outputs.publicIpAddress
output privateIpAddress string = dummyVm.outputs.privateIpAddress
