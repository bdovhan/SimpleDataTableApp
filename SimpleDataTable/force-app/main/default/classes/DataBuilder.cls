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
                
                parent.build( label + '.' + fieldName, v );
                System.debug(LoggingLevel.ERROR, '@@@  processEmbeddedRecords continuation label: ' + label +
                        ' generator ' + s  );
                
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
            String keyDef = valueDefinition.substringAfter('r.');
            return (String) Helper.either(
                   rtNamesToIdsMap.get( keyDef ),
                   Helper.getRecordTypeId( sObjectName, keyDef )
            );

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
                Map<String, String> missingMap = Helper.getRecordTypeIds( sObjectName, missing );
                rtNamesToIdsMap.putAll( missingMap );
                toReturn.addAll( Helper.toObjectSet( missingMap.values() ) );
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
                    System.debug(LoggingLevel.ERROR, '@@@ key: ' + key + '  dep.masterField: ' + dep.masterField +
                            ' value: ' +  r.get( dep.masterField ) );
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
            System.debug(LoggingLevel.ERROR, '@@@  endItems.size(): ' +  endItems.size() );
            System.debug(LoggingLevel.ERROR, '@@@  endItems.size() % 2: ' +
                    Math.mod( endItems.size(), 2 ) );
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
                System.debug(LoggingLevel.ERROR, '@@@ valueDef: ' + valueDef );
                if ( valueType == 'l' ) {
                    List<SObject> data = parent.getData( valueDef );

                    System.assertNotEquals( null, data, 'Undefined lookup labeled key ' + valueDef );
                    toReturn = Helper.toObjectSet( Helper.pluckIds(( data ) ) );
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

    public class RandomPicklistProcessor extends AbstractRandomValueProcessor{
        public override Object getValue(String sObjectName, String field, String valueDefinition) {
            return getRandom(Helper.getPicklistValues( sObjectName, field ));
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
            Map<String, Schema.SObjectField> fieldsMap = Helper.getFieldMap( sObjectName );
            String definition = valueDefinition.substringAfter('builder.');
            List<String> items = definition.split('\\+');
            for ( SObject record: records ) {
                String concatenatedValue = '';
                for (String item: items) {
                    System.debug(LoggingLevel.ERROR, '@@@ item: ' + item );
                    String hypotheticalFieldName = item.substringBefore('[');
                    System.debug(LoggingLevel.ERROR, '@@@ hypotheticalFieldName: ' + hypotheticalFieldName );
                    System.debug(LoggingLevel.ERROR, '@@@ fieldsMap.containsKey(hypotheticalFieldName): ' +
                            fieldsMap.containsKey(hypotheticalFieldName) );
                    System.debug(LoggingLevel.ERROR, '@@@ fieldsMap: ' +
                            String.join(new List<String>(fieldsMap.keySet()), ',') );
                    System.debug(LoggingLevel.ERROR, '@@@ (hypotheticalFieldName.lower()) in fieldsMap: ' +
                            fieldsMap.containsKey(hypotheticalFieldName.toLowerCase()) );
                    if ( fieldsMap.containsKey(hypotheticalFieldName) ) {
                        String value = String.valueOf( record.get( hypotheticalFieldName ) );
                        System.debug(LoggingLevel.ERROR, '@@@ value: ' + value );
                        if (item.endsWith(']')) {
                            Integer index = Integer.valueOf( item.substringBetween('[', ']') );
                            System.debug(LoggingLevel.ERROR, '@@@ index: ' + index );
                            item = item.substringBefore('[');
                            System.assert(fieldsMap.containsKey(item), 'Field ' + item +
                                    ' was not found in object ' + sObjectName );
                            value = value.substring(index, index+1);
                            System.debug(LoggingLevel.ERROR, '@@@ value: ' + value );
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
                Helper.either( nameDefSplitter, new SObjectNameValueDefinitionSplitter() );
        this.preprocessor = (ValueDefinitionPreProcessor) Helper.either(
                preprocessor, new ProcessEmbeddedRecordsPreProcessor(this) );
        this.fieldValueSplitter = (KeyValueSplitter) Helper.either( fieldValueSplitter, new FieldValueSplitter() );
        this.fieldsSplitter = (Splitter) Helper.either( fieldsSplitter, new FieldsCommaSplitter() );
        RecordTypeValueProvider rtProvider = new RecordTypeValueProvider();
        PrimitiveTypeValueProvider pvProvider = new PrimitiveTypeValueProvider(this);
        this.valueProcessors = (List<ValueDefinitionProcessor>) Helper.either(
                valueProcessors, new List<ValueDefinitionProcessor>{
                    new SimpleEmbeddedValueProcessor(this),
                    rtProvider,
                    pvProvider,
                    new SimpleDependencyValueProcessor(this),
                    new DataDependencyValueProcessor(rtProvider, pvProvider),
                    new MultiplicationProcessor(this, rtProvider, pvProvider),
                    new RandomValueDefinitionProcessor(this),
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
        if ( doInsert )
            insert records;
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
                System.debug(LoggingLevel.ERROR, '@@@ processor: ' + processor );
                System.debug(LoggingLevel.ERROR, '@@@ valueDef: ' + valueDef );
                System.debug(LoggingLevel.ERROR, '@@@ processor.detectIfApplicable( valueDef): ' +
                        processor.detectIfApplicable( valueDef) );
                if ( processor.detectIfApplicable( valueDef) ) {
                    records = processor.process(records, label, sObjectName, field, valueDef );
                    break;
                }
            }
        }
        return records;
    }
}