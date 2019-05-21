On the 12th of April 2019 I have published [an article about migration from Aura to Lightning Web Components](https://corevalue.net/migrate-aura-lightning-web-components).
Shortly after that I was offered to prepare a workshop to demonstrate how this can be done in action. 
I decided to use an Aura component described in [my another article published on the 18th of June 2018 which was used to build a simple employee list application using standard lightning:datatable component from Lightning Aura Framework](https://corevalue.net/using-lightning-promises/).
Since this component is also available for use in Lightning Web Components Framework, I decided to prepare a workshop where the main task was to clone that application using Aura component and replace SimpleEmployeeList aura component with SimpleEmployees Lightning Web Component counterpart.
Also I offered additional task to clone another advanced application and replace reference to another DataTable Aura component with Lightning Web Component counterpart. 
This is the guide explaining how this migration can be performed. I plan to add video screenshots of important steps.

[ideo of workshop held on the 11th of May 2019](https://www.youtube.com/watch?v=TWSm6HBcQtY (in Ukrainian))

Workshop task is to clone SimpleDataApp and replace SimpleEmployeeList aura component with SimpleEmployees Lightning Web Component counterpart.
Additional workshop task is to clone DataTableTestApp and replace reference to DataTable with Lightning Web Component counterpart.

# Aura to LWS: how it works in real life
## Setup scratch org with prebuilt Aura components
1. Fork `bdovhan/SimpleDataTableAp`p written on Lightning Aura Framework.
2. Perform Git clone of your fork of SimpleDataTableApp to your local folder, for example, to `D:/Git/AuraToLWCWorkshop`
3. [Read App description and default available bat commands](readme.md) in `SimpleDataTable/readme.md`
4. Ensure that you have default dev hub set up correctly, if not then set up devhub first.
5. [Run](start.bat) `start.bat` (would work for Windows, need to implement .sh correspondent file for Mac)
6. Wait until the setup script is executed successfully. Confirm that `SimpleDataApp.app` is opened

## Create blank app and blank Lightning Web Components
1. Open `SimpleDataTableApp` Folder as project in Visual Studio Code.
2. Create a clone of `SimpleDataTableApp` either in VS by menu item or by code or in Developer Console. Call it `SimpleAppUsesLWC`.
If any component or app is created outside of VS Code, use retrieve menu item or commands `sfdx force:source:retrieve -m AuraDefinitionBundle` to see that component or app inside VS Code.
3. Copy content of `SimpleDataTableApp` App to `SimpleAppUsesLWC`.
4. Create blank `simpleEmployees` Lightning web component. You may copy to it commented code from `SimpleEmployeeList`.
5. Create blank `simpleTable` Lightning web component. You may copy to it commented code from `SimpleDataTable`.
## Start converting `SimpleDataTable` to `simpleTable`
1. Change colons to dashes in the commented code; remove most double quotation marks (expect for inline string values like `"Id"` for `keyField` value) and standard provider references `"!v"` and `"!c"` from the commented code.
2. Change `camelCased` properties to `kebab-cased`. Add closing tags. 
Html file of the component should look like the following
```
    <lightning-datatable data={data} columns={columns} key-field="id" 
    hide-checkbox-column onsort={updateColumnSorting}>
    </lightning-datatable>
```
3. Go to `simpleTable.js` and declare `data` and `columns`  properties there and `updateColumnSorting` method. Add `track` to imports.
Now `simpleTable.js` should look like following.
```
	import { LightningElement, track } from 'lwc';
	export default class SimpleTable extends LightningElement {
		@track data;
		@track columns;
		
		updateColumnSorting() {}
	}
```
4. Import apex controller by inserting line like `import getColumnsAndData from '@salesforce/apex/SimpleDataTableController.getColumnsAndData'`

Now `simpleTable.js` should look like following.
```
	import { LightningElement, track } from 'lwc';
	import getColumnsAndData from '@salesforce/apex/SimpleDataTableController.getColumnsAndData';
	export default class SimpleTable extends LightningElement {
		@track data;
		@track columns;
		
		updateColumnSorting() {}
	}
```
5. Deploy your changes by menu items or by command `sfdx force:source:deploy -m LightningComponentBundle`

## Use Imperative Apex in `simpleTable`
1. Call Apex method imperatively. Create method `connectedCallback` and inside of it call promise `getColumnsAndData`.
2. Pass parameters `sObjectName`, `sObjectFieldsNames`, `whereClause` into promise initializer.
3. Remove single quotes, replace `component.get('v.` by `this.`.
4. Declare public reactive properties `sObjectName`, `sObjectFieldsNames`, `whereClause`, and import `api` module.
5. Imperative Apex function is a promise. Write arrow-function for the `then` callback to process successful execution.
6. Write arrow-function for the `error` callback, add code to display error and add private reactive error property `@track error;` to Javascript module.
```
<template if:true={error}>
        <template if:true={error.body}>
            {error.body.message}
        </template>
    </template>
```
Now list of attributes in should look like following
```
    @api sObjectName;
    @api sObjectFieldsNames;
    @api whereClause;

    @track data;
    @track columns;
    @track error;
```
Connected callback function should look like following
```
    connectedCallback() {
        getColumnsAndData({
            sObjectName: this.sObjectName,
            sObjectFieldsNames: this.sObjectFieldsNames,
            whereClause: this.whereClause
        }).then(result=>{
            this.data = result.data;
            this.columns = result.columns;
        }).catch(error=>{
            this.error = error;
        });
    }
```
## Convert `SimpleEmployeeList` to `simpleEmployees`
1. Change colons to dashes in the commented code.
2. Change `camelCased` properties to `kebab-cased`. Add closing tags.  
Inner content of Html file of the component should look like the following
```
    <c-simple-table s-object-name="Contact"
    s-object-fields-names="FirstName,LastName,BirthDate,HireDate__c,Branch__c,Position__c,Email,Phone"
    where-clause="RecordType.Name = 'Employee'">
    </c-simple-table>
```
3. Use `simpleEmployees` component inside of `SimpleAppUsesLWC`. Inner content of `SimpleAppUsesLWC` should look like following
```
    <c:FakeOpportunityData/>
    <c:simpleEmployees/>
```
4. Deploy changes either by menu items or by command line.
## Error handling and troubleshooting
1. Comment catch block in `SimpleDataTableController` lines 41, 43-45.
2. Add code to `SimpleAppUsesLWC` to display an error because of invalid object name.
```
    <c:simpleTable sObjectName="Contact1"
    sObjectFieldsNames="FirstName,LastName,BirthDate,HireDate__c,Branch__c,Position__c,Email,Phone"
    whereClause="RecordType.Name = 'Employee'"/>
```
3. Notice two null-pointer errors.
4. Change code of `simpleTable.js` to transform string value into array and fix one of the null pointer error
```	
    connectedCallback() {
        getColumnsAndData({
            sObjectName: this.sObjectName,
            sObjectFieldsNames: this.sObjectFieldsNames.split(','),
            whereClause: this.whereClause
        }).then(result=>{
            this.data = result.data;
            this.columns = result.columns;
        }).catch(error=>{
            this.error = error;
        });
    }
```
5. Use Javascript Debugging in case if you don't see error displayed
6. Notice null-pointer error and learn how to transform it into a meaningful exception.
7. Learn that unhandled exceptions result into non-readable errors.

## Convert `updateColumnSorting` method into Javascript module method
1. Copy `updateColumnSorting` method code from `SimpleDataTableHelper.js` into `simpleTable.js` and comment it out.
2. Copy `sortData` method code from `SimpleDataTableHelper.js` into `simpleTable.js` and comment it out.
3. Copy `sortBy` method code from `SimpleDataTableHelper.js` into `simpleTable.js` and comment it out.
4. Remove `function` keyword and colon from `sortData` and `sortBy` function definitions.
5. Notice that sorting is not working in the current version but that it is working in the Aura version.
6. Replace `event` by `e`, replace `getSource()` by `srcElement`, remove `set("v.` and corresponding closing parenthesis and replace comma by assignment operator.
7. Replace `getParam('` by `detail.` and remove corresponding closing parenthesis.
8. Replace `helper` by `this` and replace `cmp` param by `e.srcElement`.
9. Uncomment `sortBy` code, it contains valid LWC code and doesn't have to be converted.
10. Inside `sortData`, replace `cmp` with `src`, and replace `cmp.get("v.data")` with `JSON.parse(JSON.stringify(src.data))` and `cmp.set("v.data",` with `src.data = ` and remove corresponding closing parenthesis.
11. Deploy changes and confirm that sorting now works in LWC version.
Check that the code of these functions looks like following 
```
    updateColumnSorting(e) {
        e.srcElement.sortedBy = e.detail.fieldName;
        e.srcElement.sortedDirection = e.detail.sortDirection;
        this.sortData(e.srcElement, e.detail.fieldName, e.detail.sortDirection);
    }
    
    sortData(src, fieldName, sortDirection) {
        /// src = equivalent to event.getSource()
        var data = JSON.parse(JSON.stringify(src.data));
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        var primer = (data && data.length && data[0].Origin) ? (x, field)=>x.Origin[field] : null;
        data.sort(this.sortBy(fieldName, reverse, primer));
        src.data = data;
         
    }
    sortBy(field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x, field)} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
```
## Implement wired function version of `getColumnsAndData` call in `simleTable.js`
## Implement wired property version of `getColumnsAndData` call in `simleTable.js`
## Clone `DataTableTestApp` and convert cloned version to use LWC version of `DataTable` Aura Component.
## Retrieve all modified source metadata and commit those changes into your repository and dispose scratch org.

# Future plans:
1. Shot and release a video in English to repeat these steps described in the plan.
2. Prepare an article presenting a plan how this migration can be performed with video screenshots of important steps.


# Possible Improvements:
1. Improve: implement version of script for MacOS 
2. Improve: replace creation of additional user with Lightning Debug Mode by user update 
3. Improve: include create project command in the start.bat so that everything is setup properly without the necessity of manually 
