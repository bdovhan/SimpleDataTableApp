/**
 * Created by Bohdan Dovhan on 24.02.2018.
 */
public class Helper {
	/**
	 * Equivalent to Javascript `x || y` syntax. If x is not null, returns x, otherwise y.
	 * @param Object x : the first argument to return if it is not null
	 * @param Object y: the second argument returned if x is null
	 * @return Object: x either y
	 */
	public static Object either(Object x, Object y) {
		return x != null ? x : y;
	}
	/**
	 * Converts List of Objects to Set
	 * @param List<Object> data : the list of objects to convert
	 * @return Set<Object>: list converted to set
	 */
	public static Set<Object> toObjectSet( List<Object> data ) {
		return new Set<Object>(data);
	}

	static Map<String,Schema.RecordTypeInfo> getRecordTypeMapByName(Schema.SObjectType objToken){
		return objToken.getDescribe().getRecordTypeInfosByName();
	}
	static Schema.SObjectType getObjectToken(String objName) {
		System.assert( Schema.getGlobalDescribe().containsKey(objName), 'Not valid object name ' + objName );
		return Schema.getGlobalDescribe().get(objName);
	}
	/**
	 * Retrieve a RecordTypeId by sobjectType and record type name
	 * @param Schema.SObjectType objToken : //Account.sObjectType
	 * @param String rTypeName : record type name
	 * @return Id : record type id
	 */
	public static Id getRecordTypeId(Schema.SObjectType objToken, String rTypeName){
		return getRecordTypeMapByName( objToken ).get(rTypeName).getRecordTypeId();
	}
	/**
	 * Retrieve a RecordTypeId
	 * @param String objName : object name
	 * @param String rTypeName : record type name
	 * @return Id : record type id
	 */
	public static Id getRecordTypeId(String objName, String rTypeName){
		return getRecordTypeId(getObjectToken(objName), rTypeName);
	}
	/**
     * Returns record type names to record type ids map
     * @param String objName : object name
     * @param List<String> rTypeNames : record type names
     * @return Map<String, Id> : record type names to record type ids map
     */
	public static Map<String, Id> getRecordTypeIds(String objName, List<String> rTypeNames){
		Map<String,Schema.RecordTypeInfo> rtMapByName = getRecordTypeMapByName(getObjectToken(objName));
		Map<String, Id> mapToReturn = new Map<String, Id>();
		for ( String recordTypeName : rTypeNames ) {
			mapToReturn.put( recordTypeName, rtMapByName.get(recordTypeName).getRecordTypeId() );
		}
		return mapToReturn;
	}
	/**
     * Plucks Id values from records
     * @param List<SObject> records: sObject records
     * @return List<Id> : records Id values
     */
	public static List<Id> pluckIds( List<SObject> records ) {
		List<String> keys = new List<String>();
		if ( records != null ){
			for ( SObject rec: records ) {
				keys.add( rec.Id );
			}
		}
		return keys;
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

		Schema.SObjectField soField = getObjectToken(objName).getDescribe().fields.getMap().get(field);
		if (soField == null) return values;

		// get the field result, return if not found or if field isn't a picklist
		dfResult = soField.getDescribe();
		if (dfResult == null || (dfResult.getType() != DisplayType.picklist && dfResult.getType() != DisplayType.multipicklist)) return values;

		// build the SelectOption list from the values and names of the field's picklist entries
		for (Schema.PicklistEntry p : dfResult.getPicklistValues()) {
			values.add(p.getValue());
		}
		return values;
	}

	public static Map<String, Schema.SObjectField> getFieldMap(String objName) {
		return getObjectToken(objName).getDescribe().fields.getMap();
	}
}