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
 *   Setup is class which setups employees records using DataBuilder data generation factory
 */
public class Setup {
    public static void setupData(Integer size){
        /*DataGenerator.putValues('firstNames', 'Aaliyah,Aaron,Abigail,Addison,Aiden,Alexander,Alexis,Allison,Alyssa,Amelia,Andrew,Anna,Anthony,Ashley,Aubrey,Audrey,Ava,Avery,Benjamin,Brandon,Brayden,Brianna,Brooklyn,Caleb,Camila,Carter,Charles,Charlotte,Chloe,Christian,Christopher,Claire,Daniel,David,Dylan,Elijah,Elizabeth,Ella,Emily,Emma,Ethan,Evan,Evelyn,Gabriel,Gavin,Grace,Hailey,Hannah,Isaac,Isabella,Isaiah,Jack,Jacob,James,Jayden,John,Jonah,Jonathan,Jordan,Joseph,Joshua,Julian,Kaylee,Khloe,Landon,Layla,Leah,Liam,Lillian,Lily,Logan,Lucas,Luke,Madeline,Madison,Mason,Matthew,Mia,Michael,Natalie,Nathan,Nevaeh,Nicholas,Noah,Olivia,Owen,Riley,Ryan,Samantha,Samuel,Sarah,Savannah,Sofia,Sophia,Taylor,Tyler,Victoria,William,Wyatt,Zoey'.split(','));
        DataGenerator.putValues('lastNames', 'Smith,Johnson,Williams,Brown,Jones,Miller,Davis,Garcia,Rodriguez,Wilson,Martinez,Anderson,Taylor,Thomas,Hernandez,Moore,Martin,Jackson,Thompson,White,Lopez,Lee,Gonzalez,Harris,Clark,Lewis,Robinson,Walker,Perez,Hall,Young,Allen,Sanchez,Wright,King,Scott,Green,Baker,Adams,Nelson,Hill,Ramirez,Campbell,Mitchell,Roberts,Carter,Phillips,Evans,Turner,Torres,Parker,Collins,Edwards,Stewart,Flores,Morris,Nguyen,Murphy,Rivera,Cook,Rogers,Morgan,Peterson,Cooper,Reed,Bailey,Bell,Gomez,Kelly,Howard,Ward,Cox,Diaz,Richardson,Wood,Watson,Brooks,Bennett,Gray,James,Reye,Cruz,Hughes,Price,Myers,Long,Foster,Sanders,Ross,Morales,Powell,Sullivan,Russell,Ortiz,Jenkins,Gutierrez,Perry,Butler,Barnes,Fisher'.split(','));
        delete DataGenerator.generateRecords('employees', 'Contact:RecordTypeId=r.Employee,FirstName=vs.firstNames,LastName=vs.lastNames');*/

        DataBuilder b = new DataBuilder();
        b.loadJSONValuesFromStaticResource('names');
        b.buildFromGeneratorStringInStaticResource('employees', 'Employee', size);
        //b.build('employees','Contact:RecordTypeId=r.Employee,FirstName=rvs.firstNames,LastName=rvs.lastNames,BirthDate=random.date,HireDate__c=random.date,Branch__c=random.picklist,Position__c=random.picklist,Phone=random.ukrainian.cell.phone,Email=builder.FirstName[0]+LastName+@gmail.com'
        
    }

    public static void default() {
        delete [select id from Contact where RecordType.Name = 'Employee'];
        Setup.setupData(348);
    }

}