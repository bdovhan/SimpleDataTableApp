public class SchemaProvider {
    private static Map<String, SObjectType> globalDescribe = new Map<String, SObjectType>();
    private static SObjectType getDescribe(String token) {
        SObjectType describe = globalDescribe.get(token);
        if ( describe == null ) {
            if ( Type.forName(token) == null ) {
                throw new CustomException(token + ' is not valid SObject name');
            }
            describe = ((SObject) Type.forName(token).newInstance()).getSObjectType();
            

            globalDescribe.put(token, describe);
        }
        return describe;
    }
    /**
     * Get picklist values
     * @param String objName : objectName
     * @param String field : field name
     * @return List<String> : picklist values
     */
    public static List<String> getPicklistValues(String objName, String field){
        List<String> values = new List<String>();
        Schema.DescribeFieldResult dfResult;

        Schema.SObjectField soField = getDescribe(objName).getDescribe().fields.getMap().get(field);
        if (soField == null) return values;

        // get the field result, return if not found or if field isn't a picklist
        dfResult = soField.getDescribe();
        Boolean isPicklist = dfResult != null && new Set<DisplayType>{DisplayType.picklist,DisplayType.multipicklist}
            .contains(dfResult.getType());
        if (dfResult == null || !isPicklist) return values;

        // build the SelectOption list from the values and names of the field's picklist entries
        for (Schema.PicklistEntry p : dfResult.getPicklistValues()) {
            values.add(p.getValue());
        }
        return values;
    }
    /**
     * Retrieve a RecordTypeId
     * @param String objName : object name
     * @param String rTypeName : record type name
     * @return Id : record type id
     */
    public static Id getRecordTypeId(String objName, String rTypeName){
        return getDescribe(objName).getDescribe().getRecordTypeInfosByName().get(rTypeName).getRecordTypeId();
    }
    /**
     * Returns record type names to record type ids map
     * @param String objName : object name
     * @param List<String> rTypeNames : record type names
     * @return Map<String, Id> : record type names to record type ids map
     */
    public static Map<String, Id> getRecordTypeIds(String objName, List<String> rTypeNames){
        Map<String,Schema.RecordTypeInfo> rtMapByName = getDescribe(objName).getDescribe().getRecordTypeInfosByName();
        Map<String, Id> mapToReturn = new Map<String, Id>();
        for ( String recordTypeName : rTypeNames ) {
            mapToReturn.put( recordTypeName, rtMapByName.get(recordTypeName).getRecordTypeId() );
        }
        return mapToReturn;
    }
    public static Map<String, Schema.SObjectField> getFieldMap(String objName) {
        return getDescribe(objName).getDescribe().fields.getMap();
    }

    public class CustomException extends Exception {}
}