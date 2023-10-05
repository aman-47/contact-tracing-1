public with sharing class CTPeopleTracingTriggerHandler {
    public static void beforeInsertHandler(List<People_Tracing__c> newRecords) {
        for(People_Tracing__c traces : newRecords){
            if(CTPeopleTracingController.checkDuplicates(newRecords).size() != 0)
            {
                traces.addError('Record already exists');
            }
        }
    }
}