<aura:application extends="force.slds" >
    Teat Appp
    <!-- <c:DataTable sObjectName="IBM_Integration_Sync_Status__c"
                 sObjectFieldsNames="Job_Type__c,Result_Message__c,Status__c,Start_Time__c,Stop_Time__c,Talend_Processing_Duration__c,CreatedDate,LastModifiedDate,Completion_Status_Set_Time__c,Overall_Time_Duration__c"
                 overrides="{'Job_Type__c':{'type':'url','typeAttributes':{'label':{ 'fieldName': 'Origin.Job_Type__c' },'tooltip':{ 'fieldName': 'Origin.Job_Type__c' },'title':{ 'fieldName': 'Origin.Job_Type__c' }}}}"
                 valueModifiers="{'Origin.Job_Type__c':'{Job_Type__c}', 'Job_Type__c':'/{Id}'}"
    />-->
    <c:SimpleDataTable sObjectName="Synchronization_Status__c" sObjectFieldsNames="Job_Type__c"/>

    <c:DataTable sObjectName="Synchronization_Status__c"
                 sObjectFieldsNames="Job_Type__c"
                 overrides="{'Job_Type__c':{'type':'url','typeAttributes':{'label':{ 'fieldName': 'Origin.Job_Type__c' },'tooltip':{ 'fieldName': 'Origin.Job_Type__c' },'title':{ 'fieldName': 'Origin.Job_Type__c' }}}}"
                 valueModifiers="{'Origin.Job_Type__c':'{Job_Type__c}', 'Job_Type__c':'/{Id}'}"
    />

    <c:DataTableTestComp />
</aura:application>