/**
 *     Apex Data Generation framework is a collection of apex classes which provide useful options for data generation
 *     in Salesforce.
 *     Copyright (C) 2018  Bohdan Dovhan a.k.a. Patlatus (patlatus.wordpress.com)
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *   DataBuilder is the default implementation of base AbstractDataBuilder class which defines how data is generated.
 *   You can either use this default implementation or extend it and use some customization
 */
public class DataBuilder extends AbstractDataBuilder {
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
    
    public interface KeyValueSplitter{
        void setData(String data);
        String getKey();
        String getValue();
    }
    public class SimpleSeparatorSplitter implements KeyValueSplitter {
        String data,key,value,separator;
        public SimpleSeparatorSplitter(String separator){
            this.separator = separator;
        }
        public void setData(String data){
            this.data = data;
            key = data.substringBefore(separator);
            value = data.substringAfter(separator);
        }
        public String getKey() {
            return key;
        }
        public String getValue() {
            return value;
        }
    }
    public class SObjectNameValueDefinitionSplitter implements KeyValueSplitter {
        SimpleSeparatorSplitter splitter;
        public SObjectNameValueDefinitionSplitter(){
            splitter = new SimpleSeparatorSplitter(':');
        }
        public SObjectNameValueDefinitionSplitter(String data){
            this();
            setData(data);
        }
        public void setData(String data){
            splitter.setData(data);
        }
        public String getKey() {
            return splitter.getKey();
        }
        public String getValue() {
            return splitter.getValue();
        }
    }
    public class FieldValueSplitter implements KeyValueSplitter {
        SimpleSeparatorSplitter splitter;
        public FieldValueSplitter(){
            splitter = new SimpleSeparatorSplitter('=');
        }
        public FieldValueSplitter(String data){
            this();
            setData(data);
        }
        public void setData(String data){
            splitter.setData(data);
        }
        public String getKey() {
            return splitter.getKey();
        }
        public String getValue() {
            return splitter.getValue();
        }
    }
    public interface ValueDefinitionPreProcessor{
        String preprocess(String label, String data);
    }

    public class ProcessEmbeddedRecordsPreProcessor implements ValueDefinitionPreProcessor{
        AbstractDataBuilder parent;
        public ProcessEmbeddedRecordsPreProcessor(AbstractDataBuilder parent) {
            this.parent = parent;
        }
        /**
         * I might refactor this code later.
         *
         * this should do following:
         *  when data contains embedded data, preprocess it and replace definition
         *  like following
         * Input string 'label',
         * 'Opportunity:ContractId={Contract:CustomerSignedById={Contact:AccountId={Account:Name=New Account}}}'
         * Then first Account should be inserted and put to map with label label.ContractId.CustomerSignedById.AccountId
         * And definition to Contact should be changed to
         *  Contact:AccountId=l.label.ContractId.CustomerSignedById.AccountId
         * Then Contact should be inserted and put to map with label label.ContractId.CustomerSignedById
         * And definition to Contract should be changed to
         *  Contract:CustomerSignedById=l.label.ContractId.CustomerSignedById
         * Then Contract should be inserted and put ot map with label label.ContractId
         * And definition should be changed to Opportunity:ContractId=l.label.ContractId
         */
        public String preprocess(String label, String data){
            String s = data;
            String prefix = s.subStringBefore('{');
            String fieldName = prefix.subStringAfter(':');
            if ( fieldName.contains(',') )
                fieldName = fieldName.subStringAfter(',');
            fieldName = fieldName.subStringBefore('=');
            String m = '';
            while ( s.contains('{') ) {
                m += prefix + 'l.' + label + '.' + fieldName;
                String v =  s.subStringAfter('{').subStringBefore('}');
                s = s.subStringAfter('}');
                
                Integer x = v.countMatches('{') - v.countMatches('}');
                Integer i = 0;
                while ( x > 0 && !String.isBlank(s) && i < 5 ) {
                    v += '}' + s.subStringBefore('}');
                    s = s.subStringAfter('}');
                    x = v.countMatches('{') - v.countMatches('}');
                    i++;
                }
                
                parent.build( label + '.' + fieldName, v );
                prefix = s.subStringBefore('{');
                     
                if ( prefix.contains(',') )
                    fieldName = prefix.subStringAfter(',');
                fieldName = fieldName.subStringBefore('=');
            }
            m += s;
            return m;
        }
    }
    public interface Splitter{
        List<String> split(String data);
    }
    public class FieldsCommaSplitter implements Splitter{
        public List<String> split(String data) {
            return data.split(',');
        }
    }
    public interface ValueDefinitionProcessor{
        Boolean detectIfApplicable(String valueDefinition);
        List<SObject> process(
            List<SObject> records, String label, String sObjectName, String field, String valueDefinition
        );
    }
    public class SimpleEmbeddedValueProcessor implements ValueDefinitionProcessor{
        AbstractDataBuilder parent;
        public SimpleEmbeddedValueProcessor(AbstractDataBuilder parent) {
            this.parent = parent;
        }
        public Boolean detectIfApplicable(String valueDefinition){
            return valueDefinition.contains(':');
        }
        public List<SObject> setRelationshipValue( List<SObject> records, String fieldsDefinition, SObject value ) {
            for ( SObject r: records ) {
                for ( String field: fieldsDefinition.split('\\|') ) {
                    r.putSObject( field, value );
                }
            }
            return records;
        }

        public List<SObject> process(
                List<SObject> records, String label, String sObjectName, String field, String valueDefinition
        ){
            // shouldn't be here doInsert parameter true? Why is it false?
            return setRelationshipValue(
                records, field, parent.build(
                    label + '.' + field, valueDefinition, 1, false
                )[0]
            );
        }
    }

    public abstract class SingleValueProcessor implements ValueDefinitionProcessor{
        abstract  Object getValue(String sObjectName, String valueDefinition);
        public List<SObject> setFieldsValue( List<SObject> records, String fieldsDefinition, Object value ) {
            if ( records.size() > 0 ) {
                String valueType = getType(value);
                Map<String, Schema.SObjectField> fieldsMap = records[0].getSObjectType().getDescribe().fields.getMap();
                for ( String field: fieldsDefinition.split('\\|') ) {
                    String fieldType = String.valueOf( fieldsMap.get(field).getDescribe().getSOAPType() );
                    System.debug(LoggingLevel.ERROR, '@@@ valueType: ' + valueType );
                    System.debug(LoggingLevel.ERROR, '@@@ fieldType: ' + fieldType );
                    if ( valueType != fieldType ) {
                        throw new DataBuilderException(
                            'Please check if you have registered value processor for value definition ' + value
                            + ', because the type of value ' + valueType + ' and type ' + fieldType + ' of field '
                            + field + ' do not match. If you do not register your Value Processor in your value '
                            + 'processors list, the process will fall back to Idempotent operator and copy the '
                            + 'field definition to field value and will try to set String value to non-string field '
                            + ' type'
                        );
                    }
                }
                
            }
                
            for ( SObject r: records ) {
                for ( String field: fieldsDefinition.split('\\|') ) {
                    r.put( field, value );
                }
            }
            return records;
        }

        public List<SObject> process(
            List<SObject> records, String label, String sObjectName, String field, String valueDefinition
        ){
            return setFieldsValue( records, field, getValue( sObjectName, valueDefinition ) );
        }
    }

    public class RecordTypeValueProvider extends SingleValueProcessor{
        Map<String, String> rtNamesToIdsMap = new Map<String, String>();
        public override Object getValue(String sObjectName, String valueDefinition) {
            String rtName = valueDefinition.substringAfter('r.');
            String recordTypeId = rtNamesToIdsMap.get( rtName );
            if ( recordTypeId == null ) {
                recordTypeId = SchemaProvider.getRecordTypeId(sObjectName, rtName);
                rtNamesToIdsMap.put(rtName, recordTypeId);
            }
            return recordTypeId;

        }
        public Set<Object> getValues(String sObjectName, List<String> recordTypeNames) {
            Set<Object> toReturn = new Set<Object>();
            List<String> missing = new List<String>();
            for (String rtName: recordTypeNames) {
                if (rtNamesToIdsMap.containsKey(rtName)) {
                    toReturn.add( rtNamesToIdsMap.get( rtName ) );
                } else {
                    missing.add( rtName );
                }

            }
            if ( !missing.isEmpty() ) {
                Map<String, String> missingMap = SchemaProvider.getRecordTypeIds( sObjectName, missing );
                rtNamesToIdsMap.putAll( missingMap );
                toReturn.addAll(new Set<Object>((List<Object>)missingMap.values()));
            }
            return toReturn;
        }
        public Boolean detectIfApplicable(String valueDefinition){
            return valueDefinition.startsWith('r.');
        }

    }

    public class PrimitiveTypeValueProvider extends SingleValueProcessor{
        AbstractDataBuilder parent;
        public PrimitiveTypeValueProvider(AbstractDataBuilder parent) {
            this.parent = parent;
        }
        public override Object getValue(String sObjectName, String valueDefinition) {
            return get(valueDefinition);
        }

        public Object get(String valueDefinition) {
            Object value = valueDefinition;
            if ( valueDefinition.contains( '.' ) ) {
                List<String> valueItems = valueDefinition.split('\\.');
                String valueType = valueItems[0];
                valueDefinition = valueItems[1];
                if ( valueType == 'd' ) {
                    value = valueDefinition == 'today' ? Date.today() : Date.valueOf( valueDefinition );
                } else if ( valueType == 'b' ) {
                    value = Boolean.valueOf( valueDefinition );
                } else if ( valueType == 'v' ) {
                    value = parent.getValue( valueDefinition );
                } else if ( valueType == 'i' ) {
                    value = Integer.valueOf( valueDefinition );
                } else if ( valueType == 'dec' ) {
                    value = Decimal.valueOf( valueDefinition );
                }
            }
            return value;

        }
        public Boolean detectIfApplicable(String valueDefinition){
            for ( String prefix: 'd.|b.|v.|i.|dec.'.split('\\|')) {
                if ( valueDefinition.startsWith(prefix)) {
                    return true;
                }
            }
            return false;
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

    public abstract class DependencyValueProcessor implements ValueDefinitionProcessor{
        abstract  Dependency buildDependency(String sObjectName, String valueDefinition);

        public List<SObject> process(
                List<SObject> records, String label, String sObjectName, String field, String valueDefinition
        ){
            Dependency dep = buildDependency(sObjectName, valueDefinition);
            for ( SObject r: records ) {
                Boolean match = false;
                for ( Object key: dep.masterValueToDependentMap.keySet() ) {
                    if ( r.get( dep.masterField ) == key ) {
                        r.put( field, dep.masterValueToDependentMap.get( key ) );
                        match = true;
                        break;
                    }
                }
                if ( !match && dep.elseValue != null ) {
                    r.put( field, dep.elseValue );
                }
            }

            return records;
        }
    }

    public class SimpleDependencyValueProcessor extends DependencyValueProcessor{
        AbstractDataBuilder parent;
        public SimpleDependencyValueProcessor(AbstractDataBuilder parent) {
            this.parent = parent;
        }
        public override Dependency buildDependency(String sObjectName, String valueDefinition){
            return build(valueDefinition);
        }
        public Dependency build(String valueDefinition){
            List<String> valueItems = valueDefinition.split('\\.');
            return new Dependency( valueItems[1], parent.getData( valueItems[2] ), valueItems[3] );
        }
        public Boolean detectIfApplicable(String valueDefinition){
            return valueDefinition.startsWith('dep.');
        }
    }

    public class DataDependencyValueProcessor extends DependencyValueProcessor{
        RecordTypeValueProvider recordTypeValueProvider;
        PrimitiveTypeValueProvider primitiveTypeValueProvider;
        public DataDependencyValueProcessor(
                RecordTypeValueProvider recordTypeValueProvider, PrimitiveTypeValueProvider primitiveTypeValueProvider
        ) {
            this.recordTypeValueProvider = recordTypeValueProvider;
            this.primitiveTypeValueProvider = primitiveTypeValueProvider;
        }
        public override Dependency buildDependency(String sObjectName, String valueDefinition){
            String ending;
            if ( valueDefinition.contains('|') ) {
                List<String> valueItems = valueDefinition.split('\\|');
                valueDefinition = valueItems[0];
                ending = valueItems[1];
            }

            List<String> endItems = ending.split('>');
            String elseValueDef = Math.mod( endItems.size(), 2 ) == 0 ?
                                  '' : endItems[  endItems.size() - 1 ];
            Map<String, String> definitionMap = new Map<String, String>();
            for ( Integer i = 0; i < endItems.size() / 2; i++ ) {
                definitionMap.put( endItems[ 2 * i ], endItems[ 2 * i + 1] );
            }
            Map<Object, Object> valueMap = new Map<Object, Object>();
            for ( String key: definitionMap.keySet() ) {
                Object keyParsed;
                if ( key.startsWith('r.') ) {
                    List<String> keyItems = key.split('\\.');
                    String keyType = keyItems[0];
                    String keyDef = keyItems[1];
                    keyParsed = recordTypeValueProvider.getValue( sObjectName, keyDef );
                } else {
                    keyParsed = primitiveTypeValueProvider.get( key );
                }

                valueMap.put( keyParsed, primitiveTypeValueProvider.get( definitionMap.get( key ) ) );
            }
            return new Dependency( valueDefinition, valueMap, primitiveTypeValueProvider.get( elseValueDef ) );
        }
        public Boolean detectIfApplicable(String valueDefinition){
            return valueDefinition.startsWith('vdep.');
        }
    }

    public class MultiplicationProcessor implements ValueDefinitionProcessor{
        AbstractDataBuilder parent;
        RecordTypeValueProvider recordTypeValueProvider;
        PrimitiveTypeValueProvider primitiveTypeValueProvider;
        public MultiplicationProcessor(AbstractDataBuilder parent, RecordTypeValueProvider recordTypeValueProvider,
                                       PrimitiveTypeValueProvider primitiveTypeValueProvider) {
            this.parent = parent;
            this.recordTypeValueProvider = recordTypeValueProvider;
            this.primitiveTypeValueProvider = primitiveTypeValueProvider;
        }
        public List<SObject> multiply( List<SObject> toReturn, String fieldsDefinition, Set<Object> values ) {
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
        public List<SObject> multiply(
                List<SObject> toReturn, String fieldsDefinition, String sObjectName, String def
        ) {
            return multiply( toReturn, fieldsDefinition, parseValuesDef( sObjectName, def ) );
        }
        public Set<Object> parseValuesDef( String sObjectName, String def ) {
            String[] items = def.split('\\|');
            Set<Object> toReturn = new Set<Object>();
            String[] rtNames = new List<String>();
            if ( items.size() == 1 && ( items[0].startsWith( 'vs.' ) || items[0].startsWith( 'l.' ))) {
                String valueType = items[0].subStringBefore('.');
                String valueDef = items[0].subStringAfter('.');
                if ( valueType == 'l' ) {
                    List<SObject> data = parent.getData( valueDef );

                    System.assertNotEquals( null, data, 'Undefined lookup labeled key ' + valueDef );
                    toReturn = new Set<Object>((List<Object>)Pluck.ids(( data ) ) );
                } else {//if ( valueType == 'vs' )
                    Set<Object> values = parent.getValues( valueDef );
                    System.assertNotEquals( null, values,'Undefined values set labeled key ' + valueDef );
                    toReturn = values;
                }
            } else {
                for ( String item: items ) {
                    if ( item.startsWith( 'r.' ) ) {
                        List<String> valueItems = item.split('\\.');
                        rtNames.add( valueItems[1] );
                    } else {
                        toReturn.add( primitiveTypeValueProvider.get( item ) );
                    }
                }
                if ( !rtNames.isEmpty() ) {
                    toReturn = recordTypeValueProvider.getValues( sObjectName, rtNames );
                }
            }
            return toReturn;
        }

        public List<SObject> process(
                List<SObject> records, String label, String sObjectName, String field, String valueDefinition
        ){
            return multiply( records, field, sObjectName, valueDefinition );
        }
        public Boolean detectIfApplicable(String valueDefinition){
            return  valueDefinition.contains('|') && !valueDefinition.startsWith('vdep.') ||
                    valueDefinition.startsWith('l.') || valueDefinition.startsWith('vs.');
        }
    }

    public class IdempotentValueDefinitionProcessor extends SingleValueProcessor{
        public override Object getValue(String sObjectName, String valueDefinition) {
            return valueDefinition;
        }
        public Boolean detectIfApplicable(String valueDefinition){
            return true;
        }
    }

    public abstract class AbstractRandomValueProcessor implements ValueDefinitionProcessor{
        abstract Object getValue(String sObjectName, String field, String valueDefinition);
        public Object getRandom( Set<Object> scope ) {
            return getRandom(new List<Object>( scope ));
        }
        public Object getRandom( List<Object> scope ) {
            return scope[( Math.random() * scope.size() ).intValue()];
        }
        public Long getRandomLong( Long max) {
            return ( Math.random() * max ).longValue();
        }
        public List<SObject> process(
            List<SObject> records, String label, String sObjectName, String field, String valueDefinition
        ){
            for ( SObject r: records ) {
                r.put( field, getValue(sObjectName, field, valueDefinition) );
            }
            return records;
        }
    }

    public class RandomValueDefinitionProcessor extends AbstractRandomValueProcessor{
        AbstractDataBuilder parent;
        public RandomValueDefinitionProcessor(AbstractDataBuilder parent) {
            this.parent = parent;
        }
        public override Object getValue(String sObjectName, String field, String valueDefinition) {
            return getRandom( parent.getValues(valueDefinition.substringAfter('rvs.')) );
        }
        public Boolean detectIfApplicable(String valueDefinition){
            return valueDefinition.startsWith('rvs.');
        }
    }

    public class RandomDateProcessor extends AbstractRandomValueProcessor{
        public override Object getValue(String sObjectName, String field, String valueDefinition) {
            return DateTime.newInstance(getRandomLong(DateTime.now().getTime()) ).date();
        }
        public Boolean detectIfApplicable(String valueDefinition){
            return valueDefinition.startsWith('random.date');
        }
    }
    
    public class RandomDateInRangeProcessor extends AbstractRandomValueProcessor{
        private DateTime getEndDate(Integer value, String descriptor) {
            DateTime now = DateTime.now();
            DateTime toReturn = now;
            switch on descriptor.toLowerCase() {
                when 'y' {
                    toReturn = now.addYears(value);
                }
                when 'm' {
                    toReturn = now.addMonths(value);
                }
                when 'd' {
                    toReturn = now.addDays(value);
                }
                when 'h' {
                    toReturn = now.addHours(value);
                }
                when 'i' {
                    toReturn = now.addMinutes(value);
                }
                when 's' {
                    toReturn = now.addSeconds(value);
                }
            }
            return toReturn;
        }
        public override Object getValue(String sObjectName, String field, String valueDefinition) {
            List<String> valueItems = valueDefinition.split('\\.');
            if ( valueItems.size() < 6 ) {
                throw new DataBuilderException('RandomDateInRangeProcessor requires at least 6 items like random.inrange.date.y.-7.0 or random.inrange.date.y.-18.- but received ' + valueDefinition + ' with size ' + valueItems.size() );
            }
            String lastItem = valueItems[5];
            if ( lastItem == '-' ) {
                DateTime endDate = getEndDate(Integer.valueOf(valueItems[4]), valueItems[3]);
                return DateTime.newInstance(getRandomLong(endDate.getTime()) ).date();
            } else {
                Integer value1 = Integer.valueOf(valueItems[4]);
                Integer value2 = Integer.valueOf(valueItems[5]);
                Integer min = Math.min(value1, value2);
                Integer max = Math.max(value1, value2);
                DateTime minDate = getEndDate(min, valueItems[3]);
                DateTime maxDate = getEndDate(max, valueItems[3]);
                return DateTime.newInstance(
                    minDate.getTime() + getRandomLong(maxDate.getTime() - minDate.getTime())
                ).date();
            }
        }
        public Boolean detectIfApplicable(String valueDefinition){
            return valueDefinition.startsWith('random.inrange.date');
        }
    }

    public class RandomPicklistProcessor extends AbstractRandomValueProcessor{
        public override Object getValue(String sObjectName, String field, String valueDefinition) {
            return getRandom(SchemaProvider.getPicklistValues( sObjectName, field ));
        }
        public Boolean detectIfApplicable(String valueDefinition){
            return valueDefinition.startsWith('random.picklist');
        }
    }

    public class RandomUkrainianPhoneProcessor extends AbstractRandomValueProcessor{

        public override Object getValue(String sObjectName, String field, String valueDefinition) {
            String numberPart = String.valueOf( getRandomLong(10000000) );
            if ( numberPart.length() < 7 ) {
                for ( Integer i = numberPart.length(); i < 7; i++ ) {
                    numberPart = '0' + numberPart;
                }
            }
            return '+380' + getRandom('93|63|67|97|96|98|99|95|50'.split('\\|')) + numberPart;

        }
        public Boolean detectIfApplicable(String valueDefinition){
            return valueDefinition.startsWith('random.ukrainian.cell.phone');
        }
    }

    public class BuilderValueProcessor implements ValueDefinitionProcessor{

        public Boolean detectIfApplicable(String valueDefinition){
            return valueDefinition.startsWith('builder.');
        }

        public List<SObject> process(
            List<SObject> records, String label, String sObjectName, String field, String valueDefinition
        ){
            Map<String, Schema.SObjectField> fieldsMap = SchemaProvider.getFieldMap( sObjectName );
            String definition = valueDefinition.substringAfter('builder.');
            List<String> items = definition.split('\\+');
            for ( SObject record: records ) {
                String concatenatedValue = '';
                for (String item: items) {
                    String hypotheticalFieldName = item.substringBefore('[');
                    if ( fieldsMap.containsKey(hypotheticalFieldName) ) {
                        String value = String.valueOf( record.get( hypotheticalFieldName ) );
                        if (item.endsWith(']')) {
                            Integer index = Integer.valueOf( item.substringBetween('[', ']') );
                            item = item.substringBefore('[');
                            System.assert(fieldsMap.containsKey(item), 'Field ' + item +
                                ' was not found in object ' + sObjectName );
                            value = value.substring(index, index+1);
                        }
                        concatenatedValue += value;
                    } else {
                        concatenatedValue += item;
                    }
                }
                record.put(field, concatenatedValue);
            }
            return records;
        }
    }

    KeyValueSplitter nameDefinitionSplitter, fieldValueSplitter;
    ValueDefinitionPreProcessor preprocessor;
    Splitter fieldsSplitter;
    List<ValueDefinitionProcessor> valueProcessors;
    public DataBuilder() {
        this(null, null, null, null, null);
    }
    public DataBuilder(
        KeyValueSplitter nameDefSplitter, ValueDefinitionPreProcessor preprocessor,
        KeyValueSplitter fieldValueSplitter, Splitter fieldsSplitter, List<ValueDefinitionProcessor> valueProcessors
    ) {
        nameDefinitionSplitter = (KeyValueSplitter)
            Pluck.either( nameDefSplitter, new SObjectNameValueDefinitionSplitter() );
        this.preprocessor = (ValueDefinitionPreProcessor) Pluck.either(
            preprocessor, new ProcessEmbeddedRecordsPreProcessor(this) );
        this.fieldValueSplitter = (KeyValueSplitter) Pluck.either( fieldValueSplitter, new FieldValueSplitter() );
        this.fieldsSplitter = (Splitter) Pluck.either( fieldsSplitter, new FieldsCommaSplitter() );
        RecordTypeValueProvider rtProvider = new RecordTypeValueProvider();
        PrimitiveTypeValueProvider pvProvider = new PrimitiveTypeValueProvider(this);
        this.valueProcessors = (List<ValueDefinitionProcessor>) Pluck.either(
            valueProcessors, new List<ValueDefinitionProcessor>{
                new SimpleEmbeddedValueProcessor(this),
                rtProvider,
                pvProvider,
                new SimpleDependencyValueProcessor(this),
                new DataDependencyValueProcessor(rtProvider, pvProvider),
                new MultiplicationProcessor(this, rtProvider, pvProvider),
                new RandomValueDefinitionProcessor(this),
                new RandomDateInRangeProcessor(),
                new RandomDateProcessor(),
                new RandomPicklistProcessor(),
                new RandomUkrainianPhoneProcessor(),
                new BuilderValueProcessor(),
                new IdempotentValueDefinitionProcessor()
            }
        );
    }
    Map<String, List<SObject>> labeledDataMap = new Map<String, List<SObject>>();
    Map<String, Object> labeledValueMap = new Map<String, Object>();
    Map<String, Set<Object>> labeledValuesMap = new Map<String, Set<Object>>();

    public override void putValue( String label, Object value ) {
        labeledValueMap.put( label, value );
    }
    public override Object getValue( String label ) {
        return labeledValueMap.get( label );
    }
    public override void putValues( String label, Set<Object> values ) {
        labeledValuesMap.put( label, values );
    }
    public override Set<Object> getValues( String label ) {
        return labeledValuesMap.get( label );
    }
    public override List<SObject> getData( String label ) {
        return labeledDataMap.get( label );
    }
    public override void putData( String label, List<SObject> data ) {
        labeledDataMap.put( label, data );
    }
    
    public override List<SObject> build(String label, String generatorString, Integer size, Boolean doInsert) {
        generatorString = preprocessor.preprocess(label, generatorString);
        nameDefinitionSplitter.setData(generatorString);
        String sObjectName = nameDefinitionSplitter.getKey();
        String definition = nameDefinitionSplitter.getValue();
        Type t = Type.forName( sObjectName );
        System.assertNotEquals( null, t, sObjectName + ' is not a valid type' );
        List<SObject> records = new List<SObject>();
        for ( Integer i = 0; i < size; i++ ) {
            records.add( (SObject) t.newInstance() );
        }
        if ( !String.isBlank( definition ) ) {
            // Do not remember why did I have to use this if condition
            if ( definition.contains('},{') ) {
                for ( String generatorItem: definition.substringAfter('[{').substringBefore('}]')
                    .split('\\},\\{')
                ) {
                    records = processGeneratorDefinitionString( records, label, sObjectName, generatorItem );
                }
            } else {
                records = processGeneratorDefinitionString( records, label, sObjectName, definition );
            }
        }
        System.debug(LoggingLevel.ERROR, '@@@ records.size(): ' + records.size() );
        if ( doInsert )
            //insert records;
            Database.insert(records, false);
        putData( label, records );


        return null;
    }

    List<SObject> processGeneratorDefinitionString(
        List<SObject> records, String label, String sObjectName, String definition
    ) {
        List<String> pairs = fieldsSplitter.split(definition);
        for ( String pair: pairs ) {
            fieldValueSplitter.setData( pair );
            String field = fieldValueSplitter.getKey();
            String valueDef = fieldValueSplitter.getValue();
            Object value = valueDef;

            for ( ValueDefinitionProcessor processor: valueProcessors ) {
                if ( processor.detectIfApplicable( valueDef) ) {
                    records = processor.process(records, label, sObjectName, field, valueDef );
                    break;
                }
            }
        }
        return records;
    }
    
    public class DataBuilderException extends Exception{}
}