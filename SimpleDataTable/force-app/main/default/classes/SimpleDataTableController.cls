/**
 * Created by Bohdan Dovhan on 1/26/2018.
 */
public inherited sharing class SimpleDataTableController  {
    /**
     * if I use this method  only for debug purposes then I should delete it
     * or move it to utils if I use it elsewhere
     */
    public static string getType(Object o) {
        if(o==null) return '';              // we can't say much about null with our current techniques
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+'';
        if(o instanceof Boolean)            return 'Boolean';
        if(o instanceof Id)                 return 'Id';
        if(o instanceof String)             return 'String';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'String';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';  // we can't distinguish between decimal and double
        if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
        if(o instanceof List<object>)       return 'List';
        return 'Object';                    // actually we can't detect maps and sets and maps
    }

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
    private static List<Map<String, Object>> asList(List<SObject> records) {
        List<Map<String, Object>> models = new List<Map<String, Object>>();
        for (Object instance : (List<Object>) JSON.deserializeUntyped( JSON.serialize( records ) ) ) {
            models.add((Map<String, Object>)instance);
        }
        return models;
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

        //return value;
    }


    @AuraEnabled
    public static Map<String, Object> getColumnsAndData(
            String sObjectName, List<String> sObjectFieldsNames, String whereClause
    ) {
        try{
            Map<String, Schema.SObjectField> m = Schema.describeSObjects(sObjectName.split(','))[0].fields.getMap();
            List<Object> columns = new List<Object>();
            for ( String fieldName: sObjectFieldsNames ) {
                Schema.DescribeFieldResult dfr = m.get( fieldName ).getDescribe();
                Map<String, Object> column = new Map<String, Object>{
                    'label' => dfr.getLabel(),
                    'fieldName' => dfr.getName(),
                    'type' => String.valueOf( dfr.getType() ).toLowerCase(),
                    'sortable'=>true
                };
                columns.add( column );
            }
            String query = 'SELECT ' + String.join( sObjectFieldsNames, ', ') + ' FROM ' + sObjectName;
            System.debug(LoggingLevel.ERROR, '@@@ whereClause: ' + whereClause );
            if (!String.isBlank(whereClause)) {
                query += ' WHERE ' + whereClause;
            }
            System.debug(LoggingLevel.ERROR, '@@@ query: ' + query );
            List<SObject> records = Database.query( query );
            return new Map<String, Object>{
                'columns' => columns,
                'data' => records
            };
        } catch(Exception e) {
            throw AuraUtils.buildAuraHandledException(e);
        }
    }
 

    /*@AuraEnabled
    public static Map<String, Object> getColumnsAndData(
            String sObjectName, List<String> sObjectFieldsNames, Map<String, Object> overrides,
            Map<String, Object> valueModifiers
    ) {
        System.debug( sObjectName );
        System.debug( sObjectFieldsNames );
        System.debug(getType(sObjectName) );

        System.debug( getType(sObjectFieldsNames) );

        //try{
            
        
            Map<String, Schema.SObjectField> m = Schema.describeSObjects(sObjectName.split(','))[0].fields.getMap();
            List<Object> columns = new List<Object>();
            for ( String fieldName: sObjectFieldsNames ) {
                Schema.DescribeFieldResult dfr = m.get( fieldName ).getDescribe();
                Map<String, Object> column = new Map<String, Object>{
                    'label' => dfr.getLabel(),
                    'fieldName' => dfr.getName(),
                    'type' => dfr.getType()
                };
                System.debug('column ' + column);
                if ( overrides != null && overrides.containsKey( fieldName ) ) {
                    column.putAll( (Map<String, Object>) JSON.deserializeUntyped( JSON.serialize( overrides.get( fieldName ) ) ) );
                    System.debug('column after ' + column);
                }
                columns.add( column );
            }
            String query = 'SELECT ' + String.join( sObjectFieldsNames, ', ') + ' FROM ' + sObjectName;
        System.debug(LoggingLevel.ERROR, '@@@ query: ' + query );
            List<SObject> records = Database.query( query );
    
    
            System.debug(query);
            System.debug(Database.query( query ));
            return new Map<String, Object>{
                'columns' => columns,
                'data' => valueModifiers != null ? modifyValues( records, valueModifiers ) : asList(records)
            };
        } catch(Exception e) {
            throw AuraUtils.buildAuraHandledException(e);
        }
    }*/
}