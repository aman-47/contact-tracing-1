public with sharing class CTPersonTriggerHandler {
    public static void beforeInsertHandler(List<Person__c> newRecords){
        for(Person__c person : newRecords){
            // update the health status to Green
            person.Health_Status__c = 'Green';
            // Insert unique token using getToken method in CTPersonController class
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    public static void beforeUpdateHandler(List<Person__c> newRecords, Map<Id,Person__c> oldRecordsMap){
        for(Person__c person : newRecords){
            // check if the status changed in this transaction
            // also update Status_Update_Date__c
            if(person.Health_Status__c != oldRecordsMap.get(person.Id).Health_Status__c){
                person.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdateHandler(List<Person__c> newRecords, Map<Id,Person__c> oldRecordsMap){
        Set<Id> statusChange = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();
        for(Person__c person : newRecords){
            if(person.Health_Status__c != oldRecordsMap.get(person.Id).Health_Status__c){
                statusChange.add(person.Id);
            } 
            if(person.Health_Status__c == 'Red' && oldRecordsMap.get(person.Id).Health_Status__c != 'Red'){
                redStatus.add(person.Id);
            } 
        }

        Set<Id> alreadyProcessed = new Set<Id>();
        alreadyProcessed.addAll(redStatus);

        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();

        // list of person records to update using DML update operation
        List<Person__c> personToUpdate = new List<Person__c>();

        // add cohabitants
        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));
        // add primary contacts
        Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed);
        orangeStatus.addAll(primaryContacts);
        // add neighbors
        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));
        // add secondary contacts
        yellowStatus.addAll(CTPersonController.getSecondaryContacts(primaryContacts, alreadyProcessed));
    
        for(Id pId : orangeStatus){
            personToUpdate.add(new Person__c(Id=pId, Health_Status__c='Orange'));
        }

        for(Id pId : yellowStatus){
            personToUpdate.add(new Person__c(Id=pId, Health_Status__c='Yellow'));
        }

        // DML update operation on personToUpdate but first make sure that the list is not empty
        if(personToUpdate.size() > 0){
            update personToUpdate;
        }

        // list to update the location statuses related to the updated person record
        List<Location_Tracing__c> loactionTraces = CTLocationTracingController.getLocationsByPersonsId(statusChange);
        if(loactionTraces != null && loactionTraces.size() > 0){
            Set<Id> locationIds = new Set<Id>();
            for(Location_Tracing__c trace : loactionTraces){
                locationIds.add(trace.Location__c);
            }
            CTLocationController.updateRedScore(locationIds);
        }

    }
}