# This is demo example of Simple app using lightning:datatable component.
`SimpleDataTable` Aura app displayed two instances of `lightning:datatable` component.
The first one contains dummy data hardcoded in Javascript controller while the second one contains dummy data loaded into the `Contact` table.

`DataTable` Aura app also displayed two instances of `lightning:datatable` component.
The only different between two apps is the order and that the `DataTable` app displays link to `contact` record on the `FirstName` column.

This repository is used for holding two different workshops:
 - [1. Migrate from Aura to LWC Workshop](https://github.com/bdovhan/SimpleDataTableApp/tree/master/SimpleDataTable/Guide.md)
 - [2. Migrate from 1GMP to 2GMP Workshop](https://github.com/bdovhan/SimpleDataTableApp/tree/master/SimpleDataTable/2gmp-workshop/Guide.md)

## Prerequisites

The prerequisites for the 2GMP Migration Workshop are located [here](https://github.com/bdovhan/SimpleDataTableApp/tree/master/SimpleDataTable/2gmp-workshop/Prerequisites.md)

# Useful commands
## Setup Default DevHub org
To set default DevHub org (required for creation of scratch orgs), execute command `devHubSet.bat DevHub` and replace DevHub with the name of your DevHub org where you have setup DevHub features.

There are several documentation articles which provide extended information about DevHub setup. Refer to them if you can't figure this out and additional help or guidance is required

[Salesforce DX Developer Guide: Enable Dev Hub Features in Your Org](https://developer.salesforce.com/docs/atlas.en-us.230.0.sfdx_dev.meta/sfdx_dev/sfdx_setup_enable_devhub.htm)

[Salesforce Help: Enable Dev Hub Features in Your Org](https://help.salesforce.com/articleView?id=sfdx_setup_enable_devhub.htm&type=0)

## Setup a scratch org.
To setup a scratch org, execute `default.sh` or `default.bat` to setup default scratch org with alias DESO.
To setup a scratch org with non default alias, execute command `setupScratchOrg.sh DESO` or `setupScratchOrg.bat DESO` and replace DESO with desired alias.
These batch files create a scratch org with specified alias or with the default alias, push source metadata and run an Apex script to setup the Contact Employee data.
The last command in the batch file will open the Simple Data Table application.

## Delete a scratch org.
To delete a scratch org, execute `finish.bat` to delete default scratch org with alias DESO.
To delete a scratch org with non default alias, execute command `kickScratchOrg.sg DESO` or `kickScratchOrg.bat DESO` and replace DESO with desired alias.

## Setup a non scratch org.
To setup a non scratch org, execute `setupNonScratchOrg.sh DEV` or `setupNonScratchOrg.bat DEV` and replace DEV with alias of the desired org.
This batch file pushes source metadata and runs an Apex script to setup the Contact Employee data.
The last command in the batch file will open the Simple Data Table application.

## Open Data Table advanced app
To open the advanced Data Table app, execute command `openAnotherApp.bat -u DESO` where you can replace DESO with the alias of your organization which you have setup earlier (either a fresh new scratch org or an existing non-scratch org).

## Resources
This demo app is prepared based on my article I published at June 14, 2018 on [my old ex-employer blog](https://corevalue.net/using-lightning-promises/) and then republished at Sep 01, 2020 on [the updated ex-employer blog here](https://www.avenga.com/magazine/using-lightning-promises/).
The app uses [my apex data generation library to autogenerate dummy contact data](https://patlatus.wordpress.com/2018/05/02/apex-data-generation-library/)

## Description of Files and Directories
Folder `aura` in force-app/main/default contains Aura Lightning Components and stand-alone apps.
Folder `classes` in force-app/main/default contains Apex Classes (controllers for Lightning components) and setup classes.
Folder `objects` in force-app/main/default contains custom fields on Contact and custom Contact record type.
Folder `staticresources` in force-app/main/default contains static resources used to autogenerate dummy contact data.

Root config folder contains default scratch org configuration used in command to create a scratch org.
Root apex folder contains one-time script executed to setup Contact Employee data as part of setup process.

## Issues
This is a demo app and no issue trackers are relevant so no issues are tracked or supported at the current moment.
