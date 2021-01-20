# Migrate from 1GMP to 2GMP Workshop Guide

Read [the Prerequisites section from Readme file here](../README.md)
Git, SFDX CLI tools and at least one Dev Hub org and at least one Org with registered namespace are required for this workshop.

## Agenda

For this workshop, the following steps will be performed.
The code will be split into two subdirectories to divide it into the base 2GMP package and the dependent 2GMP package.
`SimpleDataTableController` class and related entities should be placed into the base 2GMP package
`DataTableController` class and related entities should be placed into the dependent 2GMP package
Then both packages will be installed into some test environment (Dev Hub org) might be reused for this purpose
@NamespaceAccessible annotation should be used in the base package to expose the code for the dependent package.
Both packages will share the same registered namespace.

## Fork

Fork repository https://github.com/bdovhan/SimpleDataTableApp/tree/master/SimpleDataTable

## Split the project into three pieces

Open `SimpleDataTable` subfolder in VSCode

Split the project into three subprojects: baseSetup, simpleDataTable and dataTable

Create subfolders `baseSetup`, `simpleDataTable` and `dataTable`

### Create baseSetup subProject

In `baseSetup` folder create subfolders
 - `classes`
 - `objects`
 - `statisresources`

Move classes `Pluck`, `SchemaProvider`, `Setup`, `DataBuilder` and `AbstractDataBuilder` from `force-app/main/default/classes` folder to `baseSetup/classes` folder
 - `Setup.cls` and `Setup.cls-meta.xml`
 - `DataBuilder.cls` and `DataBuilder.cls-meta.xml` 
 - `AbstractDataBuilder.cls` and `AbstractDataBuilder.cls-meta.xml`  
 - `Pluck.cls` and `Pluck.cls-meta.xml` 
 - `SchemaProvider.cls` and `SchemaProvider.cls-meta.xml`   

Move `Contact` folder from `force-app/main/default/objects` folder to `baseSetup/objects` folder

Move `names` and `Employee` static resources from `force-app/main/default/statisresources` folder to `baseSetup/statisresources` folder

### Create simpleDataTable subProject

In `simpleDataTable` folder create subfolders
 - `aura`
 - `classes`
 
Move `SimpleDataApp`, `SimpleDataTable`, `FakeOpportunityData` and `SimpleEmployeeList` from `force-app/main/default/aura` folder to `simpleDataTable/aura` folder

--Remove `<c:FakeOpportunityData/>` reference from `SimpleDataApp.app`.--

Move classes `AuraUtils`, `Pluck`, `SchemaProvider`, `SimpleDataTableController`, `Setup`, `DataBuilder` and `AbstractDataBuilder` from `force-app/main/default/classes` folder to `base_simpleDataTable/classes` folder
 - `SimpleDataTableController.cls` and `SimpleDataTableController.cls-meta.xml`
 - `AuraUtils.cls` and `AuraUtils.cls-meta.xml`

### Create dataTable subProject

In `dataTable` folder create subfolders
 - `aura`
 - `classes`
 
Move `DataTableTestApp`, `DataTable` from `force-app/main/default/aura` folder to `dataTable/aura` folder

--Remove `<c:FakeOpportunityData/>` reference from `DataTableTestApp.app`.--

Move classes `DataTableController` from `force-app/main/default/classes` folder to `dataTable/classes` folder
 - `DataTableController.cls` and `DataTableController.cls-meta.xml`
  
## Specify the namespace

### Link the namespace org to the Dev Hub

### Specify the namespace in the project.json file

## Create packages

### Create SetupBase package

### Create SimpleDataTable package

Include dependency to the SetupBase package 

### Create DataTable package

Include dependency to the SimpleDataTable package 

## Create package versions

### Create SetupBase package version

Include the post install and uninstall scripts

### Create SimpleDataTable package version

### Create DataTable package version

### Create Scratch Org and install the package version into the scratch org 

### Install the package version into the scratch org 

### Install the package version into the sandbox

### Install the package version into the production

## Promote package versions

### Promote SetupBase package version

### Promote SimpleDataTable package version

### Promote DataTable package version

### Promote Scratch Org and install the package version into the scratch org 

### Install the promoted package version into the scratch org 

### Install the promoted package version into the production


