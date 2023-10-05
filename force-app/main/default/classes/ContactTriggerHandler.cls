public with sharing class ContactTriggerHandler {
    public static void afterInsertHandler(List<Contact> newContacts) {
        Set<Id> accIds = new Set<Id>();
        for(Contact con : newContacts){
            if(String.isNotBlank(con.AccountId)){
                accIds.add(con.AccountId);
            }
        }
        AccountContactService.updateActiveContacts(accIds);
    }

    public static void afterupdateHandler(List<Contact> newContacts, Map<Id,Contact> oldContactsMap) {
        Set<Id> accIds = new Set<Id>();
        for(Contact con : newContacts){
            // capture the account id only if checkbox value is changed
            if(String.isNotBlank(con.AccountId) && oldContactsMap.get(con.Id).Active__c != con.Active__c){
                accIds.add(con.AccountId);
            }
            if(oldContactsMap.get(con.Id).AccountId != con.AccountId){
                accIds.add(con.AccountId);
                accIds.add(oldContactsMap.get(con.Id).AccountId);
            }
        }
        AccountContactService.updateActiveContacts(accIds);
    }

    public static void afterDeleteHandler(List<Contact> oldContacts) {
        Set<Id> accIds = new Set<Id>();
        for(Contact con : oldContacts){
            if(String.isNotBlank(con.AccountId)){
                accIds.add(con.AccountId);
            }
        }
        AccountContactService.updateActiveContacts(accIds);
    }

    public static void afterUndeleteHandler(List<Contact> newContacts) {
        Set<Id> accIds = new Set<Id>();
        for(Contact con : newContacts){
            if(String.isNotBlank(con.AccountId)){
                accIds.add(con.AccountId);
            }
        }
        AccountContactService.updateActiveContacts(accIds);
    }
}