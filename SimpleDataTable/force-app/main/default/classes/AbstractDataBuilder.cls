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
 *   AbstractDataBuilder is base class which defines how data is generated.
 *   You can either use default DataBuilder implementation or extend it and use some customization
 */
public abstract class AbstractDataBuilder {
	public abstract List<SObject> build(String label, String generatorString, Integer size, Boolean doInsert);
    
    public List<SObject> build(String label, String generatorString, Integer size) {
        return build( label, generatorString, size, true );
    }
    
    public List<SObject> build(String label, String generatorString) {
        return build( label, generatorString, 1 );        
    }

    public abstract void putValue( String label, Object value );
    public abstract Object getValue( String label );

    public abstract void putValues( String label, Set<Object> values );
    public abstract Set<Object> getValues( String label );

    public abstract void putData( String label, List<SObject> data );
    public abstract List<SObject> getData( String label );

    public void putValues(String label, List<Object> values) {
        putValues( label, new Set<Object>( values ) );
    }

    public void loadJSONValuesFromStaticResource(String staticResourceName) {
        List<StaticResource> srs = [ SELECT Id, Name, Body FROM StaticResource WHERE Name = :staticResourceName ];
        System.assertEquals( 1, srs.size(), 'Static Resource with name '+ staticResourceName +
                ' was not found. Zero: ' + srs.size());
        System.debug( 'srs[0].Body' + srs[0].Body.toString());
        Map<String, Object> jsonDataMap = (Map<String, Object>) JSON.deserializeUntyped( srs[0].Body.toString() );
        for ( String key: jsonDataMap.keySet() ) {
            putValues( key, (List<Object>) jsonDataMap.get( key ) );
        }
    }

    public void buildFromGeneratorStringInStaticResource(String label, String staticResourceName, Integer size) {
        List<StaticResource> srs = [ SELECT Id, Name, Body FROM StaticResource WHERE Name = :staticResourceName ];
        System.assertEquals( 1, srs.size(), 'Static Resource with name '+ staticResourceName +
                ' was not found. Zero: ' + srs.size());
        build(label,  srs[0].Body.toString(), size );
    }
}