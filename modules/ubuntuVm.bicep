param vm_name string
param vm_privateIpAddress string = ''
param vm_dnsServers array = []
param subnet_id string
param asg_id string
param customData string
param enable_public_ip bool

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = if (enable_public_ip) {
  name: '${vm_name}-pip'
  location: resourceGroup().location

  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vmNic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${vm_name}-nic'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          applicationSecurityGroups: [
            {
              id: asg_id
            }
          ]
          subnet: {
            id: subnet_id
          }
          privateIPAllocationMethod: vm_privateIpAddress == '' ? 'Dynamic' : 'Static'
          privateIPAddress: vm_privateIpAddress == '' ? null : vm_privateIpAddress
          publicIPAddress: enable_public_ip ? {
            id: publicIp.id
          } : null
        }
      }
    ]
    dnsSettings: {
      dnsServers: vm_dnsServers
    }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vm_name
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
        }
      ]
    }
    osProfile: {
      computerName: vm_name
      adminUsername: 'jdelisle'
      customData: customData != '' ? customData : null
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/jdelisle/.ssh/authorized_keys'
              keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDEckge3im507kTyAbPawT8CIGF4HgoMdF4zvuzWc3UtDnZwyg/vZF2g3CexzrMF9i+QbO0fLb4JNN4LPBDiEn5iFhhxIyjL1WedTDK0OD3P/Jx+iCREhbhN9WhSbS+KUBrOews+xXpeT5SbFeKyGKWyneQke6fItIbKaXqonnzpb9syBlsgWq6Ae57hX9ANB1NfDngPaOEQxCGo7gzDY/bxOBmSucxrlVd6ETcM/fuMKLq+Y7Rjxx2EDTPHTnhyv7NT0WeBbwfFvhymjNdFqUrH/4oSPk0LchGHBPpvAy3wYj2D3ID8PNaZwPphER9vsGcmfrKYmPk5JyPOCl8zc1 jdeli@TRS-80'
            }
          ]
        }
        provisionVMAgent: true
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

output publicIpAddress string = enable_public_ip ? publicIp.properties.ipAddress : ''
output privateIpAddress string = vmNic.properties.ipConfigurations[0].properties.privateIPAddress
