# Apex Data Generation
Salesforce (SFDC) Data Generation Framework written on Apex
Initially this was used to be designed as test utility framework for data generation for tests.
Later I redesigned it to support data generation outside of the test and renamed class to DataGenerator.
After that I considered to rewrite this class to be extendable and split it into AbstractDataBuilder and DataBuilder classes and minor helper methods extracted into Helper class.

Some simple example of how DataBuilder class can be used is the following

First, we can create a dummy account record and label it as "account" in data map.
Next, we can create in one line contact, contract and opportunity, attached to each other and to this account

DataBuilder db = new DataBuilder(); 
db.build(
    'account',
    'Account:Name=New Account'
);

db.build(
    'label',
    'Opportunity:Name=Opp,StageName=Closed Won,CloseDate=random.date,ContractId={Contract:AccountId=l.account,CustomerSignedId={Contact:LastName=LastName,AccountId=l.account}}'
);

Method build is basic method to build data, it does insert DML operation, if you don't want to insert records, you can use build method with four parameter where last parameter is false.
The first parameter is label map in data map and the second is generation string. It begins from SObject type separated by colon, then list of field values pairs follows, separated by comma.
Field name from value is separated by equal sign. The value can be either literal or a definition or another generation string for relationship fields enclosed in braces.
String literal values are simpliest, since they don't need any prefix, while integer, date or other types need correspondent prefix.
In this example, we populate Account lookups on both Contact and Contract record using label definition reference, which starts with l prefix separated by dot from the label value.
Previously we put to data map one inserted account record with "account" label, so now we can use it.

Some advanced usage examples you can find in examples folder like this one

DataBuilder b = new DataBuilder();
b.loadJSONValuesFromStaticResource('names');
b.buildFromGeneratorStringInStaticResource('employees', 'Employee', size);

You can consider Employee static resource for reference.

For convenience, data samples can be loaded from static resource using method loadJSONValuesFromStaticResource
For example, if there is "names" static resource with the given data
{"firstNames":["Aaliyah","Aaron"],
"lastNames":["Smith","Johnson"]}
then "Aaliyah" and "Aaron" values will be loaded into dataset with label "firstNames" while "Smith" and "Johnson" will be loaded with label "lastNames".

Let's consider the following generation string line 
b.build(
'employees',
'Contact:RecordTypeId=r.Employee,FirstName=rvs.firstNames,LastName=rvs.lastNames,BirthDate=random.date,HireDate__c=random.date,Branch__c=random.picklist,Position__c=random.picklist,Phone=random.ukrainian.cell.phone,Email=builder.FirstName[0]+LastName+@gmail.com'

Prefix 'r' is used to specify record type by name.
Prefix 'rvs' is used to select one arbitrary random values of a value set.
Prefix 'random' is used to select some random value, in this case, 'random.date' generates some random date.
Definition 'random.picklist' select arbitrary value out of picklist values.
Definition 'random.ukrainian.cell.phone' generates arbitrary Ukrainian cell phone number.
Definition 'builder.FirstName[0]+LastName+@gmail.com' takes the value of FirstName, takes the char from it at position 0, concatenates it with value from LastName and concatenates with '@gmail.com' string literal ending.

You can introduce your own definition and prefixes by implementing ValueDefinitionProcessor interface and using addValueProcessor or addValueProcessors methods.