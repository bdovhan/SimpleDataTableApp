import { LightningElement, track, api } from 'lwc';
import getColumnsAndData from '@salesforce/apex/SimpleDataTableController.getColumnsAndData';

export default class SimpleTable extends LightningElement {
    @api sObjectName;
    @api sObjectFieldsNames;
    @api whereClause;

    @track data;
    @track columns;
    @track error;
    connectedCallback() {
        getColumnsAndData({
            sObjectName: this.sObjectName,
            sObjectFieldsNames: this.sObjectFieldsNames.split(','),
            whereClause: this.whereClause
        }).then(result=>{
            this.data = result.data;
            this.columns = result.columns;
        }).catch(error=>{
            this.error = error;
        });
    }
    updateColumnSorting(e) {
        e.srcElement.sortedBy = e.detail.fieldName;
        e.srcElement.sortedDirection = e.detail.sortDirection;
        this.sortData(e.srcElement, e.detail.fieldName, e.detail.sortDirection);
    }
    
    sortData(src, fieldName, sortDirection) {
        /// src = equivalent to event.getSource()
        var data = JSON.parse(JSON.stringify(src.data));
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        var primer = (data && data.length && data[0].Origin) ? (x, field)=>x.Origin[field] : null;
        data.sort(this.sortBy(fieldName, reverse, primer));
        src.data = data;
         
    }
    sortBy(field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x, field)} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
}