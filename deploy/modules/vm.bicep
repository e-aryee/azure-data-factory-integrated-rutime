@description('The location into which the Azure resources should be deployed.')
param location string

@description('The resource ID of the virtual network subnet that the VM should be deployed into.')
param subnetResourceId string

@description('The name of the SKU to use when creating the virtual machine.')
param vmSize string

@description('The details of the image to deploy on the virtual machine.')
param vmImageReference object

@description('The type of disk and storage account to use for the virtual machine\'s OS disk.')
param vmOSDiskStorageAccountType string

@description('The administrator username to use for the virtual machine.')
param vmAdminUsername string

@description('The administrator password to use for the virtual machine.')
@secure()
param vmAdminPassword string

var vmName = 'shirVM001'
var vmNicName = 'shirVM001-NIC'
var vmOSDiskName = 'shirVM001-OSDisk'

resource vmNic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: vmNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetResourceId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: vmImageReference
      osDisk: {
        name: vmOSDiskName
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: vmOSDiskStorageAccountType
        }
        diskSizeGB: 128
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
        }
      ]
    }
  }

  resource installCustomScriptExtension 'extensions' = {
    name: 'InstallCustomScript'
    location: location
    properties: {
      publisher: 'Microsoft.Compute'
      type: 'CustomScriptExtension'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      protectedSettings: {
        commandToExecute: 'powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -Restart'
      }
    }
  }
}

output virtualMachinePrivateIPAddress string = vmNic.properties.ipConfigurations[0].properties.privateIPAddress
