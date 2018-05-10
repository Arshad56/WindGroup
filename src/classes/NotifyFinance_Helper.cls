public with sharing class NotifyFinance_Helper {

    @future
    public static void NotifyFinanceUsers( Set<Id> rrIds) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Rent_Roll__c> rentRolls = [select Id,Approved__c from Rent_Roll__c where Id =: rrIds];
        Set<Id> rentRollIds = new Set<Id>();
        for(Rent_Roll__c rr: rentRolls) {
            rentRollIds.add(rr.Id);
        }
        System.debug('rentRollIds-->' + rentRollIds);
        System.debug('Trigger.new-->' + Trigger.new);
            if(rentRollIds.size()>0){
                UserRole usrRole = [SELECT Id, Name FROM UserRole WHERE Name = 'Finance' limit 1 ];
                Map<Id, user> usersFinance = new Map<Id, user>([Select Email, ProfileId,UserRoleId, Name, Id From User where UserRoleId =: usrRole.Id ]); //and Id In: userdIds
                List<EmailTemplate> emailTemplateBilling = [Select id from EmailTemplate where name = 'Notification: To approve Rent Roll'];
                Map<Id, Rent_Roll__c> rentRollMap = new Map<Id, Rent_Roll__c>([Select Id, Billing_Type__c, Approved__c From Rent_Roll__c 
                                                                                where Id =: rentRollIds And Notified_Finance__c = false]);
                List<Rent_Roll__Share> rrShare = [select Id, ParentId, AccessLevel, UserOrGroupId, RowCause from Rent_Roll__Share where ParentId =: rentRollIds And AccessLevel != 'Read'];
                System.debug('rrShare-->' + rrShare);
                Set<Id> pgIds = new Set<Id>();
                for(Rent_Roll__Share rr: rrShare) {
                    pgIds.add(rr.UserOrGroupId);
                    System.debug('rr.UserOrGroupId-->' + rr.UserOrGroupId);
                }
                List<GroupMember> groupWithMMbr= [Select Id,GroupId, UserOrGroupId From GroupMember Where GroupId  =: pgIds];
                Map<Id,Set<String>> groupWithFinanceMMbrsMap= new Map<Id,Set<String>>();
                System.debug('rr.groupWithMMbr-->' + groupWithMMbr);
                System.debug('usersFinance-->' + usersFinance);
                for(GroupMember cgm: groupWithMMbr){
                    if(usersFinance.containsKey(cgm.UserOrGroupId)){
                        if(usersFinance.get(cgm.UserOrGroupId).UserRoleId == usrRole.Id){
                            Set<String> membersMail= new Set<String>();
                             
                            if(groupWithFinanceMMbrsMap.containsKey(cgm.GroupId))
                                membersMail = groupWithFinanceMMbrsMap.get(cgm.GroupId); 
                            
                            System.debug('membersMailmembersMail-->' + membersMail);     
                            
                            membersMail.add(usersFinance.get(cgm.UserOrGroupId).Email);
                            System.debug('membersMail-->' + membersMail);
                            groupWithFinanceMMbrsMap.put(cgm.GroupId, membersMail);
                        
                        }
                    }
                }
                System.debug('groupWithFinanceMMbrsMap-->' + groupWithFinanceMMbrsMap);
                Contact con = new Contact();
                
                List<Contact>  conList = [select id, Email from Contact where email != null limit 1];
                
                If(!(conList.size() > 0)){
                	con.email = 'Test111@gmail.com';
	                con.lastName = 'Test';
	                con.Region__c = 'Asia';
	                insert con;
                }else{
                	con = conList[0];
                }
                
                
                List<cc_Email_Address__c> mcs = cc_Email_Address__c.getall().values();
                Set<String> ccAddresses = new Set<String>();
                for(cc_Email_Address__c cc: mcs) {
                    if(cc.Email__c != null)
                        ccAddresses.add(cc.Email__c);
                }
                
                Map<Id, set<String> > mapToAddresses = new Map<Id, set<String>>();
                Map<Id, set<String> > mapCCAddresses = new Map<Id, set<String>>();
                
                for(Rent_Roll__Share rr: rrShare) {
                    System.debug('rr-->' + rr);
                    if(rentRollMap.containsKey(rr.ParentId) && rr.AccessLevel != 'Read') {
                        if(groupWithFinanceMMbrsMap.containsKey(rr.UserOrGroupId)){
                            Set<String> setAddress= new Set<String>();
                            setAddress = groupWithFinanceMMbrsMap.get(rr.UserOrGroupId);
                            if(mapToAddresses.containsKey(rr.ParentId))
                                setAddress.addAll(mapToAddresses.get(rr.ParentId)); 
                            mapToAddresses.put(rr.ParentId, setAddress);
                        }        
                        if(usersFinance.containsKey(rr.UserOrGroupId) ){
                            if((usersFinance.get(rr.UserOrGroupId).UserRoleId == usrRole.Id)){
                                Set<String> setAddress= new Set<String>();
                                if(mapToAddresses.containsKey(rr.ParentId))
                                    setAddress = mapToAddresses.get(rr.ParentId); 
                                setAddress.add(usersFinance.get(rr.UserOrGroupId).Email); 
                                mapToAddresses.put(rr.ParentId, setAddress);  
                            }
                        }
                        System.debug('rr.ParentId1-->' + rr.ParentId);
                        if(ccAddresses.size() >0){
                            Set<String> setccAddressTemp= new Set<String>(); 
                            if(mapCCAddresses.containsKey(rr.ParentId))
                                setccAddressTemp = mapCCAddresses.get(rr.ParentId);
                            
                            setccAddressTemp.addAll(ccAddresses);
                            mapCCAddresses.put(rr.ParentId, setccAddressTemp);
                            System.debug('setccAddressTemp-->' + setccAddressTemp);
                        }
                        
                        System.debug('mapCCAddresses11-->' + mapCCAddresses);
                    }
                }
    
                System.debug('mapToAddresses-->' + mapToAddresses);
                System.debug('mapCCAddresses-->' + mapCCAddresses);
                Set<Id> mailSent = new Set<Id>();
                for(Rent_Roll__Share rr: rrShare) {
                    System.debug('rrShare-->' + rr.Id);
                    System.debug('rr.ParentId-->' + rr.ParentId); 
                    if( !mailSent.contains(rr.ParentId) && rentRollMap.containsKey(rr.ParentId) && rr.AccessLevel != 'Read') {
                        List<string> addresses = new List<String>();
                        List<string> ccAddrs = new List<String>();
                        //addresses.add(usersFinance.get(rr.UserOrGroupId).Email);
                        if(mapToAddresses.containsKey(rr.ParentId))
                            if(mapToAddresses.get(rr.ParentId) != null)
                                addresses.addAll(mapToAddresses.get(rr.ParentId));
                        
                        if(mapCCAddresses.containsKey(rr.ParentId) )
                            if(mapCCAddresses.get(rr.ParentId) != null)
                                ccAddrs.addAll(mapCCAddresses.get(rr.ParentId));
                        System.debug('addresses-->' + addresses);
                        
                        if(addresses.size() > 0 || ccAddrs.size() > 0){
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            email.setTemplateId(emailTemplateBilling[0].Id);
                            email.setSaveAsActivity(false);
                            email.setToAddresses(addresses);
                            email.setccAddresses(ccAddrs);
                            email.setTargetObjectId(con.Id);
                            email.setWhatId(rr.ParentId);
                            email.setTreatTargetObjectAsRecipient(false);
                            emails.add(email);
                            mailSent.add(rr.ParentId);
                            System.debug('email222-->' + email);
                        }
                    }
                }
                if(emails.size()> 0) {
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
                    System.debug('results-->' + results);
                }
        }    
    }
}