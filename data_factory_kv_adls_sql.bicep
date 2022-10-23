/*
Template for data factory, setup a linked service for keyvault, adls and the sql server
*/
targetScope = 'resourceGroup'

@description('The name of the resource you are deploying')
param name string
@description('The location the resource will be deployed to')
param location string
@description('Tag values')
param resourceTags object

param linkedServiceKeyVaultURL string
param linkedServiceADLSUri string

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: name
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
}

resource linkedServiceKeyVault 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'LS_KeyVault'
  parent: dataFactory
  properties: {
    description: 'Linked service relating to the key vault for this application'
    parameters: {}
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: linkedServiceKeyVaultURL
    }
  }
}

resource linkedServiceADLS 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'LS_PrimaryADLS'
  parent: dataFactory
  properties: {
    description: 'Linked service for the primary ADLS account'
    parameters: {}
    type: 'AzureBlobFS'
    typeProperties: {
      azureCloudType: 'AzurePublic'
      url: linkedServiceADLSUri
    }
  }
}

resource linkedServicePrimarySQL 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'LS_PrimarySQL'
  parent: dataFactory
  properties: {
    description: 'Linked service for the primary AzureSQL Database'
    parameters: {}
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: linkedServiceKeyVault.name
          type: 'LinkedServiceReference'
        }
        secretName: 'primary-sql-connectionstring'
      }
    }
  }
}

output id string = dataFactory.id
output principalId string = dataFactory.identity.principalId
output name string = dataFactory.name
