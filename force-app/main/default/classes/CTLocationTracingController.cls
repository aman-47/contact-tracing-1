public with sharing class CTLocationTracingController {

    public static List<Location_Tracing__c> getVisitors (String locationId){
        return [SELECT Id, Person__c, Person__r.Token__c, Person__r.Health_Status__c, Location__c, Visit_Date__c 
                                                FROM Location_Tracing__c
                                                Where Location__c =:locationId 
                                                AND Visit_Date__c = LAST_N_DAYS:30
                                                ORDER BY Visit_Date__c DESC];

    }

    public static List<Location_Tracing__c> getLocationsByPersonsId (Set<Id> personsId){
        return [SELECT Id, Person__c,  Location__c
                FROM Location_Tracing__c
                WHERE Person__c IN:personsId
                AND Visit_Date__c = LAST_N_DAYS:10];

    }

    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds){
        return [SELECT Id, Person__c,  Location__c
                FROM Location_Tracing__c
                WHERE Location__c IN:locationIds
                AND Person__r.Health_Status__c = 'Green'
                AND Visit_Date__c = LAST_N_DAYS:10];
    }

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> locationTraces){
        // store unique location ids
        Set<Id> locationIds = new Set<Id>();
        // store unique person ids
        Set<Id> personIds = new Set<Id>();

        for(Location_Tracing__c trace : locationTraces){
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        // map of location ids and set of person ids
        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();
       
        // query existing location tracing records
        List<Location_Tracing__c> existingRecords = [SELECT Id, Person__c,  Location__c
                                                        FROM Location_Tracing__c
                                                        WHERE Location__c IN:locationIds
                                                        AND Person__c IN: personIds];

        // list of duplicate records
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();
        
        if(existingRecords != null && existingRecords.size()>0){
            for(Location_Tracing__c trace : existingRecords){
                if(! mapOfExistingRecords.containsKey(trace.Location__c)){
                    mapOfExistingRecords.put(trace.Location__c, new Set<Id>());
                }
                // add person ids to map set
                mapOfExistingRecords.get(trace.Location__c).add(trace.Person__c);
            }

            // loop over the new location tracing records
            for(Location_Tracing__c trace : locationTraces){
                // first check for location Id
                // if  item found in map, then check for person in set
                if(mapOfExistingRecords.containsKey(trace.Location__c) 
                    && mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)){
                        duplicates.add(trace);
                    }
            }
        }

        return duplicates;
    }
}