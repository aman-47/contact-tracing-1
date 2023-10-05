({
    doInit : function(component, event, helper) {
        const columns = [
            {label: 'Game Number', fieldName: 'Name', type: 'text'},
            {label: 'Mode', fieldName: 'Mode__c', type: 'text'},
            {label: 'Played On', fieldName: 'CreatedDate', type: 'date'},
            {label: 'Result', fieldName: 'Result__c', type: 'text'}
        ];
        component.set("v.columns", columns);

        // get previous results
        helper.fetchResult(component);
    },

    // function for real time update of game results table
    onResultHandler: function(component, event, helper){
        helper.fetchResult(component);
    }
});
