# This is demo example of Simple app using lightning:datatable component.
SimpleDataTable Aura component displayed two instances of lightning:datatable component.
The first one contains dummy data hardcoded in Javascript controller while the second one contains dummy data loaded into Contact table.

DataTable Aura component also displayed two instances of lightning:datatable component.
The only different between two components is the order and that the DataTable component displays link to contact record on the FirstName column.

This repository is used for holding two different workshops:
 - [1. Migrate from Aura to LWC Workshop](https://github.com/bdovhan/SimpleDataTableApp/tree/master/SimpleDataTable/Guide.md)
 - [2. Migrate from 1GMP to 2GMP Workshop](https://github.com/bdovhan/SimpleDataTableApp/tree/master/SimpleDataTable/2gmp-workshop/Guide.md)

## Prerequisites: Tools

### Install SFDX CLI:
[Use installers for Windows, MacOS](https://developer.salesforce.com/tools/sfdxcli)
[Follow the Salesforce Guide for Linux installation](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm)

### Install Git
If you are using Windows, also [install Git Bash for Windows](https://gitforwindows.org/)

### Generate SSH Key

Replace `<your name>` with your credential and run the following script 
`ssh-keygen -t rsa -b 4096 -C "<your name>@softserveinc.com"`

Copy the SSH key to your clipboard. Based on your OS version, you might use either `clip` or `pbcopy` command here
`clip < ~/.ssh/id_rsa.pub` or `pbcopy < ~/.ssh/id_rsa.pub`


Go to [Github: Add New SSH Key](https://github.com/settings/ssh/new)
and paste the key from clipboard there and save

## Prerequisites: Setup DevHub org

This workshop required DevHub org, so it must be set up

### Verify if you have already a Dev Hub org setup

Run the following command to determine if you have Default DevHub username set up

`sfdx force:config:get defaultdevhubusername`

If the command response has blank space under Value column, this means that you don't have one and you need setup it using the following steps

`=== Get Config`

`Name                   Value  Success`

`─────────────────────  ─────  ───────`

`defaultdevhubusername         true`

### Choose the org where you can enable Dev Hub feature

You can enabled DevHub feature in your trial production or Developer Edition org without namespace registered. Also Partner Developer Edition org may not be used.

Go to Setup and search for `Dev Hub`.

![Searchning `Dev Hub`](https://github.com/bdovhan/SimpleDataTableApp/blob/master/SimpleDataTable/2gmp-workshop/DevHub.png?raw=true)

If you can't see it or can't find it, your org might not support Dev Hub. You need a different org or register a brand new Developer Edition org or Trailhead org.

[You can signup for 30-day DX Trial Org here](https://developer.salesforce.com/promotions/orgs/dx-signup)

[Alternatively just sign up for usual Developer Edition Org here](https://developer.salesforce.com/signup)

Once you have figured this out, click on the Dev Hub link and switch on the Enable Dev Hub toggle and Enable Unlocked Packages and Second-Generation Managed Packages

![Switching enable Dev Hub toggle input - update required](https://github.com/bdovhan/SimpleDataTableApp/blob/master/SimpleDataTable/2gmp-workshop/DevHub.gif?raw=true)

There are several documentation articles which provide extended information about DevHub setup. Refer to them if you can't figure this out and additional help or guidance is required

[Salesforce DX Developer Guide: Enable Dev Hub Features in Your Org](https://developer.salesforce.com/docs/atlas.en-us.230.0.sfdx_dev.meta/sfdx_dev/sfdx_setup_enable_devhub.htm)

[Salesforce Help: Enable Dev Hub Features in Your Org](https://help.salesforce.com/articleView?id=sfdx_setup_enable_devhub.htm&type=0)

### Authorize your Dev Hub org for SFDX

Go to CMD on Windows or Terminal in MacOS or Linux and execute the following command where you might replace DH with your own alias for your Dev Hub org

`sfdx force:auth:web:login -d -a DH` 

The browser window should open where you have to login to your Dev Hub org and Authorize SFDX CLI connected app

### Setup Different Default DevHub org

If you decide to use another org as your Default Dev Hub org, you might use `devHubSet.sh` script.

To set default DevHub org (required for creation of scratch orgs), execute command `devHubSet.sh DevHub` or `devHubSet.bat DevHub` and replace DevHub with the alias of your DevHub org where you have setup DevHub features.

## Prerequisites: Namespace org

This workshop required Namespace org, so it must be set up.
If you have already Developer Edition org with registered namespace, no action is needed for this step.
Otherwise please [Developer Edition Org here](https://developer.salesforce.com/signup) and register some namespace.

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
This demo app is prepared based on my article I published at June 14, 2018 on [my old ex-employer blog](https://corevalue.net/using-lightning-promises/) and then republished at Sep 01, 2020 on [the updated ex-employer blog here](https://www.avenga.com/magazine/using-lightning-promises/)
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
