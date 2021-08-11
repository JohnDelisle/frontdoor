param location string
param vm_name string
param subnet_id string
param vm_privateIpAddress string = ''

module dnsUbuntuVm './ubuntuVm.bicep' = {
  name: '${location}-dnsUbuntuVm'
  scope: resourceGroup()
  params: {
    subnet_id: subnet_id
    vm_name: vm_name
    vm_privateIpAddress: vm_privateIpAddress
    vm_dnsServers: [
      '168.63.129.16'
    ]
    customData: loadFileAsBase64('./cloudinit.yml')
    enable_public_ip: false
    asg_id: asg.id
    nsg_id: nsg.id
  }
}

resource asg 'Microsoft.Network/applicationSecurityGroups@2021-02-01' = {
  name: '${resourceGroup().name}-dns-asg'
  location: resourceGroup().location
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${resourceGroup().name}-dns-nsg'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'permit-53'
        properties: {
          priority: 200
          direction: 'Inbound'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asg.id
            }
          ]
          destinationPortRange: '53'
          access: 'Allow'
        }
      }
      {
        name: 'default-deny-in'
        properties: {
          priority: 300
          direction: 'Inbound'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asg.id
            }
          ]
          destinationPortRange: '*'
          access: 'Deny'
        }
      }
      {
        name: 'default-deny-out'
        properties: {
          priority: 300
          direction: 'Outbound'
          protocol: '*'
          sourceApplicationSecurityGroups: [
            {
              id: asg.id
            }
          ]
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
          access: 'Deny'
        }
      }
    ]
  }
}

output publicIpAddress string = dnsUbuntuVm.outputs.publicIpAddress
output privateIpAddress string = dnsUbuntuVm.outputs.privateIpAddress
