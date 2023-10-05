public with sharing class CTLocationTriggerHandler {
    public static void beforeInsertHandler(List<Location__c> newRecords){
        for(Location__c location : newRecords){
            // make sure that the health status is Green upon inserting a new location
            location.Status__c = 'Green';
        }
    }

    public static void beforeUpdateHandler(List<Location__c> newRecords, Map<Id,Location__c> oldRecordsMap){
        for(Location__c location : newRecords){
            // update the status update date if a location status changes
            if(location.Status__c != oldRecordsMap.get(location.Id).Status__c){
                location.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdateHandler(List<Location__c> newRecords, Map<Id,Location__c> oldRecordsMap){
        Set<Id> statusChange = new Set<Id>();
        for (Location__c location : newRecords){
            if(location.Status__c == 'Red' && oldRecordsMap.get(location.Id).Status__c != 'Red'){
                statusChange.add(location.Id);
            }
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationIds(statusChange);
        // Set to store the person Ids
        Set<Id> personIds = new Set<Id>();
        for (Location_Tracing__c trace : locationTraces) {
            personIds.add(trace.Person__c);
        }

        // list of person records to update
        List<Person__c> personToUpdate = new List<Person__c>();
        for(Id pid : personIds) {
            personToUpdate.add(new Person__c(Id=pid, Health_Status__c='Yellow'));
        }

        // DML update operation on personToUpdate but first make sure that the list is not empty
        if(personToUpdate.size() > 0){
            update personToUpdate;
        }
    }
}