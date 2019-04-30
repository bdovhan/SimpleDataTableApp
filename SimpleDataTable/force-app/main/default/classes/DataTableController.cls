/**
 * Created by Bohdan Dovhan on 1/26/2018.
 */
public inherited sharing virtual class DataTableController extends SimpleDataTableController {
     

    public class Modifier {
        private String value;
        private Set<String> keys;
        public Modifier(Object initializer) {
            keys = new Set<String>();
            value = String.valueOf( initializer );
            Pattern valuePattern;
            valuePattern = Pattern.compile('\\{([^\\}]+)\\}');
            Matcher valueMatcher = valuePattern.matcher( value );
            while ( valueMatcher.find() ) {
                keys.add(valueMatcher.group(1));
            }
        }

        public Object modify(Object data) {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped( JSON.serialize( data ) );
            String body = value;
            for ( String key : keys ) {
                body = body.replace( '{' + key + '}', String.valueOf( m.get( key ) ) );
            }
            return body;
        }
    }
    public static Object modifyValue(Object value, Modifier modifier) {
        return modifier.modify(value);
    }
    public static List<Map<String, Object>> modifyValues(List<SObject> records, Map<String, Object>  valueModifiers) {
        List<Map<String, Object>> toReturn = new List<Map<String, Object>>();
        for ( SObject record: records ) {
            Map<String, Object> modified = (Map<String, Object>) JSON.deserializeUntyped( JSON.serialize( record ) );
            modified.put('Origin', record);
            for ( String key: valueModifiers.keySet() ) {
                modified.put( key, modifyValue( record, new Modifier( valueModifiers.get( key ) ) ) );
            }
            toReturn.add( modified );
        }
        return toReturn;
    }
    
    protected virtual Map<String, Map<String, Object>> getColumnsMap(String sObjectName, List<String> sObjectFieldsNames, Map<String, Object> overrides) {
        Map<String, Map<String, Object>> columnsMap = getColumnsMap(sObjectName, sObjectFieldsNames);
        for ( String fieldName: sObjectFieldsNames ) {
            Map<String, Object> column = columnsMap.get( fieldName );
            if ( overrides != null && overrides.containsKey( fieldName ) ) {
                //Prevent error [Invalid conversion from runtime type Map<ANY,ANY> to Map<String,ANY>] by serializing and deserializing
                column.putAll( (Map<String, Object>) JSON.deserializeUntyped( JSON.serialize( overrides.get( fieldName ) ) ) );
            }
            columnsMap.put( fieldName, column );
        }
        return columnsMap;
    }
    protected virtual List<Map<String, Object>> query(String sObjectName, List<String> sObjectFieldsNames, String whereClause, Map<String, Object> valueModifiers) {
        List<SObject> records = query(sObjectName, sObjectFieldsNames, whereClause);
        return valueModifiers != null ? modifyValues( records, valueModifiers ) : Pluck.asList(records);
    }
    public virtual Map<String, Object> getColumnsData(
        String sObjectName, List<String> sObjectFieldsNames, String whereClause, Map<String, Object> overrides,
        Map<String, Object> valueModifiers
    ) {
        return new Map<String, Object>{
            'columns' => getColumnsMap(sObjectName, sObjectFieldsNames, overrides).values(),
            'data' => query(sObjectName, sObjectFieldsNames, whereClause, valueModifiers)
        };
    }
    
    @AuraEnabled
    public static Map<String, Object> getColumnsAndData(
        String sObjectName, List<String> sObjectFieldsNames, String whereClause, Map<String, Object> overrides,
        Map<String, Object> valueModifiers
    ) {
        try{
            return new DataTableController().getColumnsData(sObjectName, sObjectFieldsNames, whereClause,overrides,valueModifiers);
        } catch(Exception e) {
            throw AuraUtils.buildAuraHandledException(e);
        }
    }
}