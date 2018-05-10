trigger updateContactPermission on Contact (before update) {
    
    Set<Id> contactIdsInactive = new Set<Id>();
    Set<Id> contactIdsActive = new Set<Id>();
    
    for(Contact contact: Trigger.New){
        
        if(contact.Status__c != null && contact.Status__c.equals('Resigned')){
            contactIdsInactive .add(contact.Id);
        }
        
        if(contact.Status__c != null && contact.Status__c.equals('Employed')){
            contactIdsActive .add(contact.Id);
        }
    }
    
    //Permission_Assignment__c[] pass = [SELECT Id, Status__c FROM Permission_Assignment__c WHERE Operations_User__c IN :Trigger.new AND Trigger.New.];

    List <Permission_Assignment__c> permissionAssignList = [Select Id, Status__c from Permission_Assignment__c Where Operations_User__c IN :contactIdsInactive];
    List <Permission_Assignment__c> tempPSList = new List <Permission_Assignment__c>();
    
    for(Permission_Assignment__c ps: permissionAssignList)
    {
        ps.Status__c = 'Inactive';
        tempPSList.add(ps);
    }
    
    update tempPSList;
    
    permissionAssignList = [Select Id, Status__c from Permission_Assignment__c Where Operations_User__c IN :contactIdsActive ];
    tempPSList = new List <Permission_Assignment__c>();
    
    for(Permission_Assignment__c ps: permissionAssignList)
    {
        ps.Status__c = 'Active';
        tempPSList.add(ps);
    }
    
    update tempPSList;

}