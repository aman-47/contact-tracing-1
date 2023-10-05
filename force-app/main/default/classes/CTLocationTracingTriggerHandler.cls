public with sharing class CTLocationTracingTriggerHandler {
    public static void beforeInsertHandler(List<Location_Tracing__c> newRecords) {
        for(Location_Tracing__c traces : newRecords){
            if(CTLocationTracingController.checkDuplicates(newRecords).size() != 0)
            {
                traces.addError('Record already exists');
            }
        }
    }
}