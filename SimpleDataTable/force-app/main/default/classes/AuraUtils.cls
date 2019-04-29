public class AuraUtils {
    /**
    * Method to throw AuraHandledException with correct message for testing purposes
    * It is workaround for issue described here: https://salesforce.stackexchange.com/questions/122657/testing-aurahandledexceptions
    * @param String message: exception message
    */
    public static void throwAuraHandledException(String message){
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        throw e;            
    }
    
    public static AuraHandledException buildAuraHandledException(Exception ex){
        AuraHandledException e = new AuraHandledException(ex.getMessage());
        e.setMessage(ex.getMessage());
        return e;            
    }
}