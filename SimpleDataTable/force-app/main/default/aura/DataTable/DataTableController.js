({
    init : function(component, event, helper) {
        helper.callActionAsPromise(
            component,
            helper,
            'c.getColumnsAndData',
            {
                'sObjectName': component.get('v.sObjectName'),
                'sObjectFieldsNames': component.get('v.sObjectFieldsNames'),
                'whereClause': component.get('v.whereClause'),
                'overrides': component.get('v.overrides'),
                'valueModifiers': component.get('v.valueModifiers')
            }
        ).then(function(r) {
            component.set('v.columns', r.r.columns);
            component.set('v.data', r.r.data);
        })
    }
})