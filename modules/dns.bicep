param vm_name string
param subnet_id string
param vm_host_number int
param subnet_prefix string

// works for a /24 or other prefixes ending in a .0
// it's a cludge, but there's no cidrhost() in Bicep
var network = split(subnet_prefix, '/')[0]
var private_ip = '${split(network, '.')[0]}.${split(network, '.')[1]}.${split(network, '.')[2]}.${vm_host_number}'

resource vmNic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${vm_name}-nic'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: subnet_id
          }
          privateIPAllocationMethod: 'Static'

          privateIPAddress: private_ip
        }
      }
    ]
    dnsSettings: {
      dnsServers: [
        '168.63.129.16'
      ]
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
      customData: loadFileAsBase64('./cloudinit.conf')
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
