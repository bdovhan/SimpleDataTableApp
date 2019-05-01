public class Setup {
    public static void setupData(Integer size){
        DataBuilder b = new DataBuilder();
        b.loadJSONValuesFromStaticResource('names');
        b.buildFromGeneratorStringInStaticResource('employees', 'Employee', size);
    }

    public static void default() {
        delete [select id from Contact where RecordType.Name = 'Employee'];
        Setup.setupData(348);
    }
}