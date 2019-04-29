public class Setup {
    public static void setupData(Integer size){
        /*DataGenerator.putValues('firstNames', 'Aaliyah,Aaron,Abigail,Addison,Aiden,Alexander,Alexis,Allison,Alyssa,Amelia,Andrew,Anna,Anthony,Ashley,Aubrey,Audrey,Ava,Avery,Benjamin,Brandon,Brayden,Brianna,Brooklyn,Caleb,Camila,Carter,Charles,Charlotte,Chloe,Christian,Christopher,Claire,Daniel,David,Dylan,Elijah,Elizabeth,Ella,Emily,Emma,Ethan,Evan,Evelyn,Gabriel,Gavin,Grace,Hailey,Hannah,Isaac,Isabella,Isaiah,Jack,Jacob,James,Jayden,John,Jonah,Jonathan,Jordan,Joseph,Joshua,Julian,Kaylee,Khloe,Landon,Layla,Leah,Liam,Lillian,Lily,Logan,Lucas,Luke,Madeline,Madison,Mason,Matthew,Mia,Michael,Natalie,Nathan,Nevaeh,Nicholas,Noah,Olivia,Owen,Riley,Ryan,Samantha,Samuel,Sarah,Savannah,Sofia,Sophia,Taylor,Tyler,Victoria,William,Wyatt,Zoey'.split(','));
        DataGenerator.putValues('lastNames', 'Smith,Johnson,Williams,Brown,Jones,Miller,Davis,Garcia,Rodriguez,Wilson,Martinez,Anderson,Taylor,Thomas,Hernandez,Moore,Martin,Jackson,Thompson,White,Lopez,Lee,Gonzalez,Harris,Clark,Lewis,Robinson,Walker,Perez,Hall,Young,Allen,Sanchez,Wright,King,Scott,Green,Baker,Adams,Nelson,Hill,Ramirez,Campbell,Mitchell,Roberts,Carter,Phillips,Evans,Turner,Torres,Parker,Collins,Edwards,Stewart,Flores,Morris,Nguyen,Murphy,Rivera,Cook,Rogers,Morgan,Peterson,Cooper,Reed,Bailey,Bell,Gomez,Kelly,Howard,Ward,Cox,Diaz,Richardson,Wood,Watson,Brooks,Bennett,Gray,James,Reye,Cruz,Hughes,Price,Myers,Long,Foster,Sanders,Ross,Morales,Powell,Sullivan,Russell,Ortiz,Jenkins,Gutierrez,Perry,Butler,Barnes,Fisher'.split(','));
        delete DataGenerator.generateRecords('employees', 'Contact:RecordTypeId=r.Employee,FirstName=vs.firstNames,LastName=vs.lastNames');*/

        DataBuilder b = new DataBuilder();
        b.loadJSONValuesFromStaticResource('names');
        b.buildFromGeneratorStringInStaticResource('employees', 'Employee', size);
        //b.build('employees','Contact:RecordTypeId=r.Employee,FirstName=rvs.firstNames,LastName=rvs.lastNames,BirthDate=random.date,HireDate__c=random.date,Branch__c=random.picklist,Position__c=random.picklist,Phone=random.ukrainian.cell.phone,Email=builder.FirstName[0]+LastName+@gmail.com'
        
    }

    public static void default() {
        delete [select id from Contact where RecordType.Name = 'Employee'];
        Setup.setupData(348);
    }

    /*// analogue of https://github.com/ipavlic/apex-lambda  GroupBy.strings method
    public static Map<String, List<SObject>> groupBy( List<SObject> records, String field ) {
        Map<String, List<SObject>> mapToReturn = new Map<String, List<SObject>>();
        for ( SObject r: records ) {
            String key = String.valueOf( getValue( r, field ) );
            List<SObject> recs = mapToReturn.get( key );
            if ( recs == null )
                recs = new List<SObject>();
            recs.add( r );
            mapToReturn.put( key, recs );
        }
        return mapToReturn;
    }

    public static Object getValue(SObject record, String fieldPath) {
        SObject rec = record;
        System.debug(LoggingLevel.ERROR, '@@@ rec: ' + rec );
        System.debug(LoggingLevel.ERROR, '@@@ fieldPath: ' + fieldPath );
        if ( fieldPath.contains('.') ) {
            String[] relations = fieldPath.split('\\.');
            for ( Integer j = 0; j < relations.size() - 1; j++ ) {
                System.debug(LoggingLevel.ERROR, '@@@ relations[j]: ' + relations[j] );
                rec = rec.getSObject( relations[j] );
                System.debug(LoggingLevel.ERROR, '@@@ rec: ' + rec );
            }

            fieldPath = relations[relations.size() - 1];
            System.debug(LoggingLevel.ERROR, '@@@ fieldPath: ' + fieldPath );
        }
        return rec.get( fieldPath );
    }
    public static Set<String> pick(SObject record, String fieldsDefinition) {
        List<String> fieldNames = fieldsDefinition.split('\\|');
        Set<String> toReturn = new Set<String>();
        for ( String field: fieldNames ) {
            Object value = getValue( record, field );
            if ( value != null ) {
                toReturn.add( String.valueOf( value ) );
            }
        }
        return toReturn;
    }
    public Id getRandomItemId( List<SObject> scope ) {
        return scope[( Math.random() * scope.size() ).intValue()].Id;
    }
    public static void setHierarchy() {
        List<Contact> employees = [select id, Position__c from Contact where RecordType.Name = 'Employee'];
        Map<String, List<SObject>> employeesByPositionMap = groupBy( employees, 'Position__c' );
    }*/
}