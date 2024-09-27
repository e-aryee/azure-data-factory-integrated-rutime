@description('The name of the container registry to create. This must be globally unique.')
param name string = 'shir${uniqueString(resourceGroup().id)}'

@description('The name of the SKU to use when creating the container registry.')
param skuName string = 'Standard'

@description('The location into which the Azure resources should be deployed.')
param location string  = resourceGroup().location

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: true
  }
}

// Build the container image.
var containerImageName = 'win2019shir'
var containerImageTag = 'v1'
var dockerfileSourceGitRepository = 'https://github.com/e-aryee/images.git'
resource buildTask 'Microsoft.ContainerRegistry/registries/taskRuns@2019-06-01-preview' = {
  parent: containerRegistry
  name: 'buildTask'
  properties: {
    runRequest: {
      type: 'DockerBuildRequest'
      dockerFilePath: 'Dockerfile'
      sourceLocation: dockerfileSourceGitRepository
      imageNames: [
        '${containerImageName}:${containerImageTag}'
      ]
      platform: {
        os: 'Windows'
        architecture: 'amd64'
      }
    }
  }
}

output containerRegistryName string = containerRegistry.name
output containerImageName string = containerImageName
output containerImageTag string = containerImageTag
