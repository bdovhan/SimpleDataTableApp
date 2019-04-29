({
	init : function(component, event, helper) {
        debugger;
	    helper.callActionAsPromise(
	        component,
	        helper,
	        'c.getColumnsAndData',
	        {
	            'sObjectName': component.get('v.sObjectName'),
	            'sObjectFieldsNames': component.get('v.sObjectFieldsNames'),
	            'whereClause': component.get('v.whereClause')
	        }
	    ).then(function(r) {
	        component.set('v.columns', r.r.columns);
	        component.set('v.data', r.r.data);
	    })
	},
    
    // Client-side controller called by the onsort event handler
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        event.getSource().set("v.sortedBy", fieldName);
        
        event.getSource().set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    }
})