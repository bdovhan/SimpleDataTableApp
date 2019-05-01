public class Setup {
    public static void setupData(Integer size){
        DataBuilder b = new DataBuilder();
        b.loadJSONValuesFromStaticResource('names');
        b.buildFromGeneratorStringInStaticResource('employees', 'Employee', size);
        //b.build('employees','Contact:RecordTypeId=r.Employee,FirstName=rvs.firstNames,LastName=rvs.lastNames,BirthDate=random.inrange.date.y.-18.-,HireDate__c=random.inrange.date.y.-7.0,Branch__c=random.picklist,Position__c=random.picklist,Phone=random.ukrainian.cell.phone,Email=builder.FirstName[0]+LastName+@gmail.com', size);
    }

    public static void default() {
        delete [select id from Contact where RecordType.Name = 'Employee'];
        Setup.setupData(348);
    }
}