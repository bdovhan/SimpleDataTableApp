public class DataGenerator {
    public static List<Id> pluckIds( List<SObject> records ) {
        List<String> keys = new List<String>();
        if ( records != null ){
            for ( SObject rec: records ) {
                keys.add( rec.Id );
            }
        }
        return keys;
    }
    public static Set<Object> toObjectSet( List<Object> data ) {
        return new Set<Object>(data);
    }
    /**
     * Retrieve a RecordTypeId by sobjectType and RT name
     * @param Schema.SObjectType objToken : //Account.sObjectType
     * @param String rTypeName : record type name
     * @return Id : record type id
     */
    public static Id getRecordTypeId(Schema.SObjectType objToken, String rTypeName){
        return objToken.getDescribe().getRecordTypeInfosByName().get(rTypeName).getRecordTypeId();
    }
	/**
     * Retrieve a RecordTypeId
     * @param String objName : object name
     * @param String rTypeName : record type name
     * @return Id : record type id
     */
    public static Id getRecordTypeId(String objName, String rTypeName){
        return getRecordTypeId(Schema.getGlobalDescribe().get(objName), rTypeName);
    }
    /**
     * Returns record type names to record type ids map
     * @param String objName : object name
     * @param List<String> rTypeNames : record type names
     * @return Map<String, Id> : record type names to record type ids map
     */
    public static Map<String, Id> getRecordTypeIds(String objName, List<String> rTypeNames){
        SObjectType soType = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult d = soType.getDescribe();
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        Map<String, Id> mapToReturn = new Map<String, Id>();

        for ( String recordTypeName : rTypeNames ) {
            System.debug( LoggingLevel.ERROR, '*** recordTypeName = ' + recordTypeName );
            System.debug( LoggingLevel.ERROR, '*** rtMapByName = ' + rtMapByName );
            Schema.RecordTypeInfo rtByName =  rtMapByName.get(recordTypeName);
            System.debug( LoggingLevel.ERROR, '*** rtByName = ' + rtByName );
            mapToReturn.put( recordTypeName, rtByName.getRecordTypeId() );
        }
        return mapToReturn;

    }
    
    public Id getRandomItemId( List<SObject> scope ) {
        return scope[( Math.random() * scope.size() ).intValue()].Id;
    }
    
    public String getRandomString( List<String> scope ) {
        return scope[( Math.random() * scope.size() ).intValue()];
    }
    
    
    public class ValueSet{
        public String field;
        public Set<Object> values;
        public Dependency dependency;
        
        public ValueSet( String f, Object v ) {
            field = f;
            values = new Set<Object>{ v };
        }
        
        public ValueSet( String f, Set<Object> vs ) {
            field = f;
            values = vs;
        }
        
        public ValueSet( String f, List<SObject> records ) {
            field = f;
            
            values = new Set<Object>();
            for ( SObject r: records ) {
                values.add( r.Id );
            }
        }
        
        public ValueSet( String f, Dependency d ) {
            field = f;
            dependency = d;
        }
        
    }
    
    public class Dependency{
        public String masterField;
        public Object elseValue;
        public Map<Object, Object> masterValueToDependentMap;
        
        public Dependency( String m, Map<Object, Object> m2dMap ) {
            masterField = m;
            masterValueToDependentMap = m2dMap;
        }
        
        public Dependency( String m, Map<Object, Object> m2dMap, Object ev ) {
            this( m, m2dMap );
            elseValue = ev;
        }
        
        
        public Dependency( String m, List<SObject> records, String lookupField ) {
            masterField = m;
            masterValueToDependentMap = new Map<Object, Object>();
            for ( SObject r: records ) {
                masterValueToDependentMap.put( r.get( lookupField ), r.get( 'Id' ) );
            }
        }
    }
    public static List<SObject> multiply( List<SObject> toReturn, String fieldsDefinition, Set<Object> values ) {
        List<SObject> newList = new List<SObject>();
        for ( SObject r: toReturn ) {
            for ( Object v: values ) {
                SObject record = r.clone(true, true, true, true);
                for ( String field: fieldsDefinition.split('\\|') ) {
                    record.put( field, v );
                }
                newList.add( record );
            }
        }
        return newList;
    }
    public static List<SObject> setFieldsValue( List<SObject> records, String fieldsDefinition, Object value ) {
        for ( SObject r: records ) {
            for ( String field: fieldsDefinition.split('\\|') ) {
                r.put( field, value );
            }
        }
        return records;
    }
    public static List<SObject> setRelationshipValue( List<SObject> records, String fieldsDefinition, SObject value ) {
        for ( SObject r: records ) {
            for ( String field: fieldsDefinition.split('\\|') ) {
                r.putSObject( field, value );
            }
        }
        return records;
    }
    
    static Map<String, List<SObject>> labeledDataMap = new Map<String, List<SObject>>();
    static Map<String, Object> labeledValueMap = new Map<String, Object>();
    static Map<String, Set<Object>> labeledValuesMap = new Map<String, Set<Object>>();
    
    public static void putValue( String label, Object value ) {
        labeledValueMap.put( label, value );
    }
    
    public static void putValues( String label, Set<Object> values ) {
        labeledValuesMap.put( label, values );
    }
    
    public static void putValues( String label, List<Object> values ) {
        labeledValuesMap.put( label, new Set<Object>( values ) );
    }
    
    public static Object getValue( String label ) {
        return labeledValueMap.get( label );
    }
    
    public static Set<Object> getValues( String label ) {
        return labeledValuesMap.get( label );
    }
    
    public static List<SObject> getData( String label ) {
        return labeledDataMap.get( label );
    }
 
    public static List<SObject> multiply( List<SObject> toReturn, String fieldsDefinition, String def ) {
        System.assert(toReturn.size() >= 1, 'No sense to pass empty list here');
        String sObjectType = toReturn[0].getSobjectType().getDescribe().getName();
        return multiply( toReturn, fieldsDefinition, parseValuesDef( sObjectType, def ) );
    }
    static Map<String, String> rtNamesToIdsMap = new Map<String, String>();
    public static Set<Object> parseValuesDef( String sObjectName, String def ) {
        String[] items = def.split('\\|');
        Set<Object> toReturn = new Set<Object>();
        String[] rtNames = new List<String>();
        if ( items.size() == 1 && ( items[0].startsWith( 'vs.' ) || items[0].startsWith( 'l.' ))) {
            String valueType = items[0].subStringBefore('.');
            String valueDef = items[0].subStringAfter('.');
            System.debug(LoggingLevel.ERROR, '@@@ valueDef: ' + valueDef );
            if ( valueType == 'l' ) {
                System.assert( labeledDataMap.containsKey( valueDef ), 'Undefined lookup labeled key ' + valueDef );
                toReturn = toObjectSet( pluckIds( labeledDataMap.get( valueDef ) ) );
            } else {//if ( valueType == 'vs' )
                System.assert( labeledValuesMap.containsKey( valueDef ), 'Undefined values set labeled key ' + valueDef );
                toReturn = labeledValuesMap.get( valueDef );
            }
        } else {
            for ( String item: items ) {
                if ( item.startsWith( 'r.' ) ) {
                    List<String> valueItems = item.split('\\.');
                    rtNames.add( valueItems[1] );
                } else if ( item.startsWith( 'vs.' ) || item.startsWith( 'l.' ) ) {
                    
                } else {
                    toReturn.add( parseValueDef( item ) );
                }
            }
            if ( !rtNames.isEmpty() ) {
                Map<String, String> x = getRecordTypeIds( sObjectName, rtNames );
                rtNamesToIdsMap.putAll( x );
                toReturn.addAll( toObjectSet( x.values() ) );
                /*for ( Id rtId: x.values() ) {
                    toReturn.add( rtId );
                }*/
            }
        }        
        return toReturn;
    }
    public static Object parseValueDef( String valueDef ) {
        Object value = valueDef;
        if ( valueDef.contains( '.' ) ) {
            List<String> valueItems = valueDef.split('\\.');
            String valueType = valueItems[0];
            valueDef = valueItems[1];
            if ( valueType == 'd' ) {
                value = valueDef == 'today' ? Date.today() : Date.valueOf( valueDef );
            } else if ( valueType == 'b' ) {
                value = Boolean.valueOf( valueDef );
            } else if ( valueType == 'v' ) {
                value = labeledValueMap.get( valueDef );
            } else if ( valueType == 'i' ) {
                value = Integer.valueOf( valueDef );
            } else if ( valueType == 'dec' ) {
                value = Decimal.valueOf( valueDef );
            }   
        }
        return value;
    }
    public static List<SObject> generateRecords( String label, String generatorString ) {
        return generateRecords( label, generatorString, 1 );
    }
    public static List<SObject> generateRecords( String label, String generatorString, Integer size ) {
        return generateRecords( label, generatorString, size, true );
    }
    static List<SObject> processGeneratorDefinitionString( List<SObject> records, String label, String sObjectName, String definition ) {
        List<String> pairs = definition.split(',');
        for ( String pair: pairs ) {
            String field = pair.substringBefore('=');
            Object value;
            String valueDef = pair.substringAfter('=');
            value = valueDef;
            Boolean multipleValue = false;
            
            Boolean dependency = false;
            Dependency dep;
            multipleValue = valueDef.contains('|') && !valueDef.startsWith('vdep.') || valueDef.startsWith('l.') || valueDef.startsWith('vs.');
            
            if ( valueDef.contains(':') ) {
                SObject related = generateRecords( label + '.' + field, valueDef, 1, false )[0];
                setRelationshipValue( records, field, related );
            } else {
                if ( !multipleValue && valueDef.contains( '.' ) ) {
                    String ending;
                    if ( valueDef.contains('|') ) {
                        List<String> valueItems = valueDef.split('\\|');
                        valueDef = valueItems[0];
                        ending = valueItems[1];
                    }
                    
                    
                    value = parseValueDef( valueDef );
                    
                    List<String> valueItems = valueDef.split('\\.');
                    String valueType = valueItems[0];
                    valueDef = valueItems[1];
                    
                    
                    if ( valueType == 'r' ) {
                        String rtId = getRecordTypeId( sObjectName, valueDef );
                        rtNamesToIdsMap.put( valueDef, rtId );
                        value = rtId;
                    } else if ( valueType == 'dep' ) {
                        dependency = true;
                        dep = new Dependency( valueItems[1], labeledDataMap.get( valueItems[2] ), valueItems[3] );
                    } else if ( valueType == 'vdep' ) {
                        dependency = true;
                        List<String> endItems = ending.split('>');
                        System.debug(LoggingLevel.ERROR, '@@@  endItems.size(): ' +  endItems.size() );
                        System.debug(LoggingLevel.ERROR, '@@@  endItems.size() % 2: ' +  Math.mod( endItems.size(), 2 ) );
                        String elseValueDef = Math.mod( endItems.size(), 2 ) == 0 ? '' : endItems[  endItems.size() - 1 ];
                        Map<String, String> definitionMap = new Map<String, String>();
                        for ( Integer i = 0; i < endItems.size() / 2; i++ ) {
                            definitionMap.put( endItems[ 2 * i ], endItems[ 2 * i + 1] );
                        }
                        Map<Object, Object> valueMap = new Map<Object, Object>();
                        for ( String key: definitionMap.keySet() ) {
                            System.debug(LoggingLevel.ERROR, '@@@ key: ' + key +  ' value: ' + definitionMap.get( key ) +  ' key.parse: ' + parseValueDef( key ) +  ' value.parse: ' + parseValueDef( definitionMap.get( key ) ));
                            Object keyParsed;
                            if ( key.startsWith('r.') ) {
                                List<String> keyItems = key.split('\\.');
                                String keyType = keyItems[0];
                                String keyDef = keyItems[1];
                                keyParsed = rtNamesToIdsMap.containsKey( keyDef ) ? rtNamesToIdsMap.get( keyDef ) : getRecordTypeId( sObjectName, keyDef );
                            } else {
                                keyParsed = parseValueDef( key );
                            }
                            
                            valueMap.put( keyParsed, parseValueDef( definitionMap.get( key ) ) );
                        }
                        System.debug(LoggingLevel.ERROR, '@@@ elseValueDef: ' + elseValueDef + ' ValueDef: ' + valueDef +  ' elseValue: ' + parseValueDef( elseValueDef ) );
                        dep = new Dependency( valueDef, valueMap, parseValueDef( elseValueDef ) );
                    }
                    
                    
                }
                if ( dependency ) {
                    for ( SObject r: records ) {
                        Boolean match = false;
                        for ( Object key: dep.masterValueToDependentMap.keySet() ) {
                            System.debug(LoggingLevel.ERROR, '@@@ key: ' + key + '  dep.masterField: ' + dep.masterField + ' value: ' +  r.get( dep.masterField ) );
                            if ( r.get( dep.masterField ) == key ) {
                                r.put( field, dep.masterValueToDependentMap.get( key ) );
                                match = true;
                                break;
                            }
                        }
                        System.debug(LoggingLevel.ERROR, '@@@ match: ' + match );
                        if ( !match && dep.elseValue != null ) {
                            System.debug(LoggingLevel.ERROR, '@@@ field: ' + field + 'dep.elseValue: ' + dep.elseValue);
                            r.put( field, dep.elseValue );
                        }
                    } 
                } else if ( multipleValue ) {
                    //records = useValuesMap ? multiply( records, field, labeledValuesMap.get( valueDef ) ): multiply( records, field, labeledDataMap.get( valueDef ) );
                    records = multiply( records, field, valueDef );
                } else {
                    setFieldsValue( records, field, value );
                }
            }
        }
        return records;
    }
    static String processEmbeddedRecords(String label, String generatorString) {
        String s = generatorString;
        System.debug(LoggingLevel.ERROR, '@@@  processEmbeddedRecords label: ' + label + ' generator ' + s  );
  
        String prefix = s.subStringBefore('{');
        System.debug(LoggingLevel.ERROR, '@@@ p: ' + prefix );
        String fieldName = prefix.subStringAfter(':');
        if ( fieldName.contains(',') )
            fieldName = fieldName.subStringAfter(',');
        fieldName = fieldName.subStringBefore('=');
        System.debug(LoggingLevel.ERROR, '@@@ fieldName: ' + fieldName );
        String m = '';
        while ( s.contains('{') ) {
            m += prefix + 'l.' + label + '.' + fieldName;
            System.debug(LoggingLevel.ERROR, '@@@ m: ' + m );
            String v =  s.subStringAfter('{').subStringBefore('}');
            s = s.subStringAfter('}');
            
            Integer x = v.countMatches('{') - v.countMatches('}');
            System.debug(LoggingLevel.ERROR, '@@@ x: ' + x );
            Integer i = 0;
            while ( x > 0 && !String.isBlank(s) && i < 5 ) {
                v += '}' + s.subStringBefore('}');
                s = s.subStringAfter('}');
                x = v.countMatches('{') - v.countMatches('}');
                i++;
                System.debug(LoggingLevel.ERROR, '@@@ v: ' + v );
                System.debug(LoggingLevel.ERROR, '@@@ s: ' + s  );
                System.debug(LoggingLevel.ERROR, '@@@ x: ' + x );
            }
            System.debug(LoggingLevel.ERROR, '@@@  embed   label: ' + label + '.' + fieldName + ' v ' + v  );
            
            generateRecords( label + '.' + fieldName, v );
            System.debug(LoggingLevel.ERROR, '@@@  processEmbeddedRecords continuation label: ' + label + ' generator ' + s  );
            
            System.debug(LoggingLevel.ERROR, '@@@ v: ' + v );
            System.debug(LoggingLevel.ERROR, '@@@ s: ' + s  );
            prefix = s.subStringBefore('{');
                 
            if ( prefix.contains(',') )
                fieldName = prefix.subStringAfter(',');
            fieldName = fieldName.subStringBefore('=');
            System.debug(LoggingLevel.ERROR, '@@@ p: ' + prefix );
            System.debug(LoggingLevel.ERROR, '@@@ fieldName: ' + fieldName );
        }
                System.debug(LoggingLevel.ERROR, '@@@ m: ' + m );
                System.debug(LoggingLevel.ERROR, '@@@ s: ' + s  );        
        m += s;
        System.debug(LoggingLevel.ERROR, '@@@ m: ' + m );
        return m;
    }
    
	public static List<SObject> generateRecords( String label, String generatorString, Integer size, Boolean doInsert ) {
        //List<String> items = generatorString.split(':');
        generatorString = processEmbeddedRecords( label, generatorString );
        String sObjectName = generatorString.substringBefore(':');
        String definition = generatorString.substringAfter(':');
        
        
        Type t = Type.forName( sObjectName );
        System.assertNotEquals( null, t, sObjectName + ' is not a valid type' );
        List<SObject> records = new List<SObject>();
            
        for ( Integer i = 0; i < size; i++ ) {
            records.add( (SObject) t.newInstance() );
        }
        if ( !String.isBlank( definition ) ) {
            if ( definition.contains('},{') ) {
                for ( String generatorItem: definition.substringAfter('[{').substringBefore('}]').split('\\},\\{') ) {
                    records = processGeneratorDefinitionString( records, label, sObjectName, generatorItem );
                }
            } else {
                records = processGeneratorDefinitionString( records, label, sObjectName, definition );
            }
        }
        if ( doInsert )
            insert records;
        labeledDataMap.put( label, records );
        return records;
    }
}