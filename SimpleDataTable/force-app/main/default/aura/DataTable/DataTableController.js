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
	            'whereClause': component.get('v.whereClause'),
	            'overrides': component.get('v.overrides'),
	            'valueModifiers': component.get('v.valueModifiers')
	        }
	    ).then(function(r) {
	    debugger;
	        component.set('v.columns', r.r.columns);
	        component.set('v.data', r.r.data);
	    })
	    //1. get Fields Metadata
	    // 2. get data

		 /*cmp.set('v.mycolumns', [
                        {label: 'Opportunity name', fieldName: 'opportunityName', type: 'text'},
                        {label: 'Confidence', fieldName: 'confidence', type: 'percent', cellAttributes:
                            { iconName: { fieldName: 'trendIcon' }, iconPosition: 'right' }},
                        {label: 'Amount', fieldName: 'amount', type: 'currency', typeAttributes: { currencyCode: 'EUR'}},
                        {label: 'Contact Email', fieldName: 'contact', type: 'email'},
                        {label: 'Contact Phone', fieldName: 'phone', type: 'phone'}
                    ]);
                cmp.set('v.mydata', [{
                        id: 'a',
                        opportunityName: 'Cloudhub',
                        confidence: 0.2,
                        amount: 25000,
                        contact: 'jrogers@cloudhub.com',
                        phone: '2352235235',
                        trendIcon: 'utility:down'
                    },
                    {
                        id: 'b',
                        opportunityName: 'Quip',
                        confidence: 0.78,
                        amount: 740000,
                        contact: 'quipy@quip.com',
                        phone: '2352235235',
                        trendIcon: 'utility:up'
                    }]);*/
	}
})