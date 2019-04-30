# This is demo example of Simple app using lightning:datatable component.
SimpleDataTable Aura component displayed two instances of lightning:datatable component.
The first one contains dummy data hardcoded in Javascript controller while the second one contains dummy data loaded into Contact table.

DataTable Aura component also displayed two instances of lightning:datatable component.
The only different between two components is the order and that the DataTable component displays link to contact record on the FirstName column.

## Setup a scratch org.
To setup a scratch org, execute `default.bat` to setup default scratch org with alias DESU.
To setup a scratch org with non default alias, execute command `setupScratchOrg.bat DESU` and replace DESU with desired alias.

## Delete a scratch org.
To delete a scratch org, execute `finish.bat` to delete default scratch org with alias DESU.
To delete a scratch org with non default alias, execute command `kickScratchOrg.bat DESU` and replace DESU with desired alias.

## Setup a non scratch org.
To setup a non scratch org, execute `setupNonScratchOrg.bat DEV` and replace DEV with alias of the desired org.

## Resources
This demo app is prepared based on my article I published at June 14, 2018 on my employer blog https://corevalue.net/using-lightning-promises/
The app uses my apex data generation library to autogenerate dummy contact data https://patlatus.wordpress.com/2018/05/02/apex-data-generation-library/

## Description of Files and Directories
Folder `aura` contains Aura Lightning Components and stand-alone apps.
Folder `classes` contains Apex Classes (controllers for Lightning components) and setup classes.
Folder `object` contains custom fields on Contact and custom Contact record type.
Folder `staticresources` contains static resources used to autogenerate dummy contact data.

## Issues
This is a demo app and no issue trackers are relevant so no issues are tracked or supported at the current moment.
