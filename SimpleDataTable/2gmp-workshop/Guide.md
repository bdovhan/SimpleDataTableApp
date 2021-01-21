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

Select the namespace org you would like to use and copy the namespace value into the project.json file.

You can open the namespace package settings by executing sfdx command 

`sfdx force:org:open -p /0A2?setupid=Package -u namespaced_org`

where `namespaced_org` is the alias of your namespaced org.

If you haven't connected your namespace org to sfdx, you can do that by executing the command

`sfdx force:auth:web:login -d -a namespaced_org` 

and then entering login credentials for your namespaced org.

Once opened the packaging namespace tab, you can read it from the screen or copy Namespace Prefix from the UI

![Package Types Allowed: Managed and Unmanaged; Managed Package: Test; Namespace Prefix: TestApplication](https://github.com/bdovhan/SimpleDataTableApp/blob/master/SimpleDataTable/2gmp-workshop/TestApplication.png?raw=true)

If you don't have any namespaced org yet, you can just register a developer edition org. When you open Packages tab you will see that there is no Namespace prefix is defined.

![Package Types Allowed: Unmanaged Only; Managed Package: None; Namespace Prefix: None](https://github.com/bdovhan/SimpleDataTableApp/blob/master/SimpleDataTable/2gmp-workshop/NoNamespace.png?raw=true)

If you click Edit button, you can select and define your own namespace here.

### Link the namespace org to the Dev Hub

Open Namespace Registries tab by executing the following command

`sfdx force:org:open -p /1NR -u DH`

and click Link Namespace button.

If you haven't connected your DevHub org to SFDX, please to the [README Guide and complete prerequisite required](https://github.com/bdovhan/SimpleDataTableApp/Guide.md)

A popup should show up, if it is not shown up, please check your browser setting and open popup manually and consider to allow popup for Salesforce site.

In the popup window, login to your namespaced org and click allow.

This would link you namespaced org to the Dev Hub

For the more information, consider reading [Salesforce Documentation](https://help.salesforce.com/articleView?id=sfdx_dev_reg_namespace.htm&type=5)

### Specify the namespace in the project.json file

Now go to VSCode and open the sfdx-project.json file and insert the copied namespace prefix into line 8

![Copying and pasting TestApplication namespace into namespace key value](https://github.com/bdovhan/SimpleDataTableApp/blob/master/SimpleDataTable/2gmp-workshop/Namespace.gif?raw=true)

And save by using key combination Ctrl-S (or Cmd-S on MacOS).

## Create packages



### Create SetupBase package

Open terminal by key combination Ctrl-\` (or Cmd-\` on MacOS)

Execute the command 

`./createPackage.sh DH "Base Setup" baseSetup`

to create the base setup package.

### Create SimpleDataTable package

Execute the command 

`./createPackage.sh DH "Simple Data Table" simpleDataTable`

to create the Simple Data Table package.

Include dependency to the Base Setup package by inserting the following code into the `sfdx-project.json file

```
	"dependencies": [
		{
			"package": "Test App: Base Setup",
			"versionNumber": "0.1.0.LATEST"
		}
	]
```
![Copying and pasting the above code into sfdx-project.json](https://github.com/bdovhan/SimpleDataTableApp/blob/master/SimpleDataTable/2gmp-workshop/SimpleDataTablePackageCreation.gif?raw=true)

And save by using key combination Ctrl-S (or Cmd-S on MacOS).

### Create DataTable package

Execute the command 

`./createPackage.sh DH "Data Table" dataTable`

to create the Data Table package.

Include dependency to the Simple Data Table package by inserting the following code into the `sfdx-project.json file

```
	"dependencies": [
		{
			"package": "Test App: Simple Data Table",
			"versionNumber": "0.1.0.LATEST"
		}
	]
```
## Create package versions

### Create SetupBase package version
Before you run this program, please make sure you have installed `jq`.
To install jq on Windows, execute the `installJQWindows.bat`.

Then execute the following command to create the package version 

`./createPackageVersion.sh DH namespaced_org "Base Setup" baseSetup "Setup.default();" ""`

This commands includes the post install and uninstall scripts, the code `Setup.default();` sets up some dummy data and executes on package install.

### Create SimpleDataTable package version

`./createPackageVersion.sh DH namespaced_org "Simple Data Table" simpleDataTable "" ""`
 
### Create DataTable package version

`./createPackageVersion.sh DH namespaced_org "Data Table" dataTable "" ""`

### Create Scratch Org and install the package version into the scratch org 

### Install the package version into the scratch org 

### Install the package version into the sandbox

### Install the package version into the production

## Promote package versions

### Promote SetupBase package version

`./promote.sh rrr temp "Base Setup" baseSetup`


### Promote SimpleDataTable package version

### Promote DataTable package version

### Promote Scratch Org and install the package version into the scratch org 

### Install the promoted package version into the scratch org 

### Install the promoted package version into the production


