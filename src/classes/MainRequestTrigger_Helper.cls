public with sharing class MainRequestTrigger_Helper {
	public static Notify_Schedule_Request_Creation__c notifyScheduled;
	public static void validateCompleteTasks(Map<Id, Request__c> mapReq){ 
		Map<Id, Request__c> mapWithReq = new Map<Id, Request__c>([Select Status__c, Id, (Select Id, Status From Tasks where Status !=: 'Completed') From Request__c]);
		for(Request__c req: mapReq.values()){
			if(req.Status__c =='Closed' && mapWithReq.containsKey(req.Id) && mapWithReq.get(req.Id).Tasks.size() > 0){
				req.addError('Please close all tasks before closing Request');
			}
		}
		//checkRecursive.makeRunTrue();
	}
	public static Map<Id,Set<Id>> getConWithProp(Set<Id> cons, Set<String> emailsSet){
		Map<Id,Set<Id>> conWithProp = new Map<Id,Set<Id>>();
		List<Permission_Assignment__c> passList= [select Id, Operations_User__r.Email,Operations_User__c, Notify__c, Status__c, Permission_Set__r.Status__c,Permission_Set__r.Mobile_Module__r.App__c,Permission_Set__r.Property__c from Permission_Assignment__c  where (Operations_User__c =: cons Or Operations_User__r.Email =: emailsSet )  and Status__c = 'Active'  and Permission_Set__r.Status__c = 'Active'  and Permission_Set__r.Mobile_Module__r.App__c = 'iRequest' And Notify__c =true];
			for(Permission_Assignment__c pas:passList){
				Set<Id> tempProp= new Set<Id>();
				tempProp.add(pas.Permission_Set__r.Property__c);
				
				if(conWithProp.containsKey(pas.Operations_User__c))
				tempProp.addAll(conWithProp.get(pas.Operations_User__c));
				
				conWithProp.put(pas.Operations_User__c, tempProp);
			}
		return conWithProp;
	}
	public static void sendNotificationOnStatusPICChange(Map<Id,Request__c> reqNewMap , Map<Id,Request__c> reqOldMap){
		
		Map<Id,Request__c> reqMap= new Map<Id,Request__c>([select Id,Action_Remarks__c,Description__c,Last_Updated_From__c,Property__c,Dept_in_Charge__c,Status__c,Request_Type__c,Person_In_Charge__c,Team__c,Requested_By__c,Requested_By__r.email from Request__c where id = : reqNewMap.keySet()]);
		Set<String> picSet= new Set<String>();
		Set<Id> teams= new Set<Id>();
		for(Id ids: reqMap.KeySet()){
			if(reqMap.get(ids).Person_In_Charge__c != null ){
				picSet.add(reqMap.get(ids).Person_In_Charge__c);
			}
			if(reqMap.get(ids).Team__c != null && reqMap.get(ids).Team__c != reqOldMap.get(ids).Team__c){
				teams.add(reqMap.get(ids).Team__c);
			}
		}
		Map<Id, Contact> conWithTeam = new Map<Id, Contact>([Select Id, Email, (Select Id, In_Charge__c, Status__c, Member__c, Team__c, Team__r.Property__c, Team__r.Department__c, Team__r.Job_Type__c,Team__r.Status__c  From Team_Members__r where Status__c = 'Active' And Team__r.Status__c = 'Active') From Contact where id=:picSet ]);
		
		Map<Id, Action_Taker__c> teamsMap= new Map<Id, Action_Taker__c>( [Select Id, Property__c, Property__r.Name, Job_Type__c, Department__c, (Select Id, Team__c, Member__c, In_Charge__c, Status__c, Member__r.Email From Team_Members__r) From Action_Taker__c where Id =: teams]);
		Set<Id> cons= new Set<Id>();
		Map<Id, List<Team_Member__c>> teamWithMembers= new Map<Id, List<Team_Member__c>>();
		for(Id ids: reqMap.KeySet()){
			if(teamsMap.containsKey(reqMap.get(ids).Team__c))
				for(Team_Member__c tmm: teamsMap.get(reqMap.get(ids).Team__c).Team_Members__r){
					List<Team_Member__c> temp = new List<Team_Member__c>();
					temp.add(tmm); 
					if(teamWithMembers.containsKey(tmm.Team__c))
						temp.addAll(teamWithMembers.get(tmm.Team__c));
					teamWithMembers.put(tmm.Team__c,temp);
					cons.add(tmm.Member__c);
				}
		}
		Map<Id,Set<Id>> conWithProp = new Map<Id,Set<Id>>(MainRequestTrigger_Helper.getConWithProp(cons,new Set<String>()));
	
		List<EmailTemplate> emailTemplates = [Select id from EmailTemplate where name='Request: New Assignment Notification'];
		List<EmailTemplate> emailTemplatesReqBy = [Select id from EmailTemplate where name = 'Request: Update Notification'];
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		Boolean checkIsChaged;
		
		Id propId;
		Set<string> addresses= new Set<String>();
		for(Id ids: reqMap.KeySet()){
		    propId = reqMap.get(ids).Property__c;
			addresses = new Set<String>();
			System.debug('reqMap.get(ids)-->'+reqMap.get(ids));
			
		    checkIsChaged = reqMap.get(ids).Requested_By__c != null && reqMap.get(ids).Requested_By__r.email!= null && (reqMap.get(ids).Status__c != reqOldMap.get(ids).Status__c || reqMap.get(ids).Action_Remarks__c != reqOldMap.get(ids).Action_Remarks__c || reqMap.get(ids).Description__c != reqOldMap.get(ids).Description__c);
			if(reqMap.get(ids).Team__c != null && reqMap.get(ids).Team__c != reqOldMap.get(ids).Team__c){
				if(conWithTeam.containskey(reqMap.get(ids).Person_In_Charge__c)){
					addresses.add(conWithTeam.get(reqMap.get(ids).Person_In_Charge__c).Email);
				}
				if(reqMap.get(ids).Team__c!=null ){//&& reqMap.get(ids).Last_Updated_From__c == 'SF'
					System.debug(reqOldMap.get(ids).Team__c);
					System.debug(reqMap.get(ids).Team__c);
					System.debug(teamWithMembers.get(reqMap.get(ids).Team__c).size());
					if(teamWithMembers.containsKey(reqMap.get(ids).Team__c)){
						for(Team_Member__c tmm: teamWithMembers.get(reqMap.get(ids).Team__c)){
							if(tmm.In_Charge__c || (conWithProp.containsKey(tmm.Member__c) && conWithProp.get(tmm.Member__c).contains(propId))) {
								addresses.add(tmm.Member__r.Email);
							}
						}
					}
				}
			}
			if(checkIsChaged){
				if(conWithTeam.containskey(reqMap.get(ids).Person_In_Charge__c)){
					addresses.add(conWithTeam.get(reqMap.get(ids).Person_In_Charge__c).Email);
				}
			}
			if(addresses.size() >0){
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage ();
				email.setTemplateId(emailTemplates[0].Id);
				email.setSaveAsActivity(false);
				email.setToAddresses(new List<String>(addresses));
				email.setTargetObjectId(reqMap.get(ids).Person_In_Charge__c);
				email.setWhatId(ids);
				email.setTreatTargetObjectAsRecipient(false);
				emails.add(email);
			}
			
			addresses = new Set<String>();
			//if(conWithTeam.containsKey(reqMap.get(ids).Person_In_Charge__c))
			//addresses.add(conWithTeam.get(reqMap.get(ids).Person_In_Charge__c).Email);
			addresses.add(reqMap.get(ids).Requested_By__r.email);
			
			if(checkIsChaged){
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage ();
				email.setTemplateId(emailTemplatesReqBy[0].Id);
				email.setSaveAsActivity(false);
				email.setToAddresses(new List<String>(addresses));
				//email.setccAddresses(new List<String>{'arshad.shaikh@techmatrixconsulting.com'});
				email.setTargetObjectId(reqMap.get(ids).Requested_By__c);
				email.setWhatId(ids);
				email.setTreatTargetObjectAsRecipient(false);
				emails.add(email);
			}
		}
		if(emails.size() > 0 && !Test.isRunningTest()) {
			List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
			System.debug('results111-->'+results);
		}
	}
	// Assign PIC on Create only. And send notification to Team
	public static void sendNotificationOnPICChange(Map<Id,Request__c> reqMap , Map<Id,Request__c> reqOldMap){
		Map<Id,Request__c> reqNewMap= new Map<Id,Request__c>([select Id,Last_Updated_From__c,Property__c,Dept_in_Charge__c,Request_Type__c,Person_In_Charge__c,Team__c,Requested_By__c from Request__c where id = : reqMap.keySet()]);
		Set<String> picSet= new Set<String>();
		Set<String> emailsSet= new Set<String>();
		for(Id ids: reqNewMap.KeySet()){
			if(reqNewMap.get(ids).Person_In_Charge__c != null ){
				picSet.add(reqNewMap.get(ids).Person_In_Charge__c);
				reqNewMap.get(ids).Team__c = null; 
			}
			if(reqNewMap.get(ids).Requested_By__c == null){
				emailsSet.add(UserInfo.getUserId());
			}
		}
		Map<Id, Contact> conWithTeam = new Map<Id, Contact>([Select Id, Email,SF_User__c, (Select Id, In_Charge__c, Status__c, Member__c, Team__c, Team__r.Property__c, Team__r.Department__c, Team__r.Job_Type__c,Team__r.Status__c  From Team_Members__r where Status__c = 'Active' And Team__r.Status__c = 'Active') From Contact where id=:picSet OR SF_User__c =: emailsSet]);
		Map<String, Contact> conEmailWithId = new Map<String, Contact>();
		for(Contact con:conWithTeam.values()){
			if(con.SF_User__c != null)
			conEmailWithId.put(con.SF_User__c, con);
		}
		String propReq  = '';
		String dpt      = '';
		String reqType  = '';
		String propTeam = '';
		String deptTeam = '';
		String jobType  = '';
		Set<Id> teams= new Set<Id>();
		for(Id ids: reqNewMap.KeySet()){
			if(conWithTeam.containsKey(reqNewMap.get(ids).Person_In_Charge__c))
				for(Team_Member__c tm: conWithTeam.get(reqNewMap.get(ids).Person_In_Charge__c).Team_Members__r){
					 propReq  = reqNewMap.get(ids).Property__c == null? '' : reqNewMap.get(ids).Property__c;
					 dpt      = reqNewMap.get(ids).Dept_in_Charge__c	 == null? '' : reqNewMap.get(ids).Dept_in_Charge__c	;
					 reqType  = reqNewMap.get(ids).Request_Type__c == null? '' : reqNewMap.get(ids).Request_Type__c;
					 propTeam = tm.Team__r.Property__c == null? '' : tm.Team__r.Property__c;
					 deptTeam = tm.Team__r.Department__c == null? '' : tm.Team__r.Department__c;
					 jobType  = tm.Team__r.Job_Type__c == null? '' : tm.Team__r.Job_Type__c;
					 if(propReq == propTeam && dpt == deptTeam && jobType.contains(reqType) ){
						 reqNewMap.get(ids).Team__c = tm.Team__c;
					 	 break;
					 }
				}
				if(reqNewMap.get(ids).Team__c != null){
					teams.add(reqNewMap.get(ids).Team__c);
				}
		}
		
		Map<Id, Action_Taker__c> teamsMap= new Map<Id, Action_Taker__c>( [Select Id, Property__c, Property__r.Name, Job_Type__c, Department__c, (Select Id, Team__c, Member__c, In_Charge__c, Status__c, Member__r.Email From Team_Members__r) From Action_Taker__c where Id =: teams]);

		Set<Id> cons= new Set<Id>();
		Map<Id, List<Team_Member__c>> teamWithMembers= new Map<Id, List<Team_Member__c>>();
		
		for(Id ids: reqNewMap.KeySet()){
			if(teamsMap.containsKey(reqNewMap.get(ids).Team__c))
				for(Team_Member__c tmm: teamsMap.get(reqNewMap.get(ids).Team__c).Team_Members__r){
					List<Team_Member__c> temp = new List<Team_Member__c>();
					temp.add(tmm); 
					if(teamWithMembers.containsKey(tmm.Team__c))
						temp.addAll(teamWithMembers.get(tmm.Team__c));
					teamWithMembers.put(tmm.Team__c,temp);
					cons.add(tmm.Member__c);
				}
		}
		Map<Id,Set<Id>> conWithProp = new Map<Id,Set<Id>>(MainRequestTrigger_Helper.getConWithProp(cons,emailsSet));
		
		List<EmailTemplate> emailTemplates = [Select id from EmailTemplate where name='Request: New Assignment Notification'];
		List<EmailTemplate> emailTemplatesReqBy = [Select id from EmailTemplate where name = 'Request: Update Notification'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		
		Boolean checkIsChaged;
		for(Id req: reqNewMap.KeySet()){
			System.debug('req-->'+req);
			Id propId = reqNewMap.get(req).Property__c;
			Set<string> addresses = new Set<String>();
			Set<string> addressesReqBy = new Set<String>();
			
		    checkIsChaged = reqNewMap.get(req).Requested_By__c == null ;
			
			if( conEmailWithId.containsKey(UserInfo.getUserId()) && checkIsChaged){
				//reqNewMap.get(req).Requested_By__c == null || reqNewMap.get(req).Status__c != reqOldMap.get(req).Status__c || reqNewMap.get(req).Action_Remarks__c != reqOldMap.get(req).Action_Remarks__c || reqNewMap.get(req).Description__c != reqOldMap.get(req).Description__c
				reqNewMap.get(req).Requested_By__c = conEmailWithId.get(UserInfo.getUserId()).Id;
				addressesReqBy.add(conEmailWithId.get(UserInfo.getUserId()).Email);
			}
			if(conWithTeam.containskey(reqNewMap.get(req).Person_In_Charge__c)){
				addresses.add(conWithTeam.get(reqNewMap.get(req).Person_In_Charge__c).Email);
				//addressesReqBy.add(conWithTeam.get(reqNewMap.get(req).Person_In_Charge__c).Email);
			}
			if(reqNewMap.get(req).Team__c!=null ){//&& reqNewMap.get(req).Last_Updated_From__c == 'SF'
				System.debug(reqOldMap.get(req).Team__c);
				System.debug(reqNewMap.get(req).Team__c);
				System.debug(teamWithMembers.get(reqNewMap.get(req).Team__c).size());
				if(teamWithMembers.containsKey(reqNewMap.get(req).Team__c)){
					for(Team_Member__c tmm: teamWithMembers.get(reqNewMap.get(req).Team__c)){
						if(tmm.In_Charge__c || (conWithProp.containsKey(tmm.Member__c) && conWithProp.get(tmm.Member__c).contains(propId))) {
							addresses.add(tmm.Member__r.Email);
						}
					}
				}
			}
			if(addresses.size() >0){
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage ();
				email.setTemplateId(emailTemplates[0].Id);
				email.setSaveAsActivity(false);
				email.setToAddresses(new List<String>(addresses));
				email.setTargetObjectId(reqNewMap.get(req).Person_In_Charge__c);
				email.setWhatId(req);
				email.setTreatTargetObjectAsRecipient(false);
				emails.add(email);
			}
			if(addressesReqBy.size() >0){
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage ();
				email.setTemplateId(emailTemplatesReqBy[0].Id);
				email.setSaveAsActivity(false);
				email.setToAddresses(new List<String>(addressesReqBy));
				//email.setccAddresses(new List<String>{'arshad.shaikh@techmatrixconsulting.com'});
				email.setTargetObjectId(reqNewMap.get(req).Person_In_Charge__c);
				email.setWhatId(req);
				email.setTreatTargetObjectAsRecipient(false);
				emails.add(email);
			}
		}
		update reqNewMap.values();
		System.debug('emails-->'+emails);
		if(emails.size() > 0 && !Test.isRunningTest()) {
	        List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
	         System.debug('results222-->'+results);
	      }
	}
	
	public static void assignPersonInCharge(Map<Id,Request__c> reqMap1, List<Request__c> reqList){
		Map<Id,Request__c> reqMap= new Map<Id,Request__c>([select Id,Last_Updated_From__c,Property__c,Dept_in_Charge__c,Request_Type__c,Person_In_Charge__c,Team__c,Requested_By__c,Status__c,Type__c from Request__c where id = : reqMap1.keySet()]);
		system.debug('reqMap-->'+reqMap);
		List<Request__c> listReq = new List<Request__c>();
		Map<Id, Action_Taker__c> actTakerMap = new Map<Id,Action_Taker__c>([select Id,Property__c,Department__c,Job_Type__c from Action_Taker__c where Job_Request__c = 'Request' and Status__c = 'Active' And Admin_Team__c = false]);
		List<Team_Member__c> tmMmbrList= [select Id, Member__c, Status__c, Team__c, In_Charge__c,Team__r.Admin_Team__c from Team_Member__c  where Team__r.Job_Request__c = 'Request' and Team__r.Status__c = 'Active'  and In_Charge__c = true];
		Map<Id, Team_Member__c> tmMMbrMap= new Map<Id, Team_Member__c>();
		Id adminTeam;
		Id adminTeamMember;
		for(Team_Member__c tm:tmMmbrList){
			if(tm.Team__c != null && !tmMMbrMap.containsKey(tm.Team__c)){
				tmMMbrMap.put(tm.Team__c, tm);
			}
			if(tm.Team__r.Admin_Team__c  && tm.Member__c!= null && tm.Team__c != null){
				adminTeam = tm.Team__c;
				adminTeamMember = tm.Member__c;
			}
		}
		system.debug('adminTeam-->'+adminTeam);
		system.debug('adminTeamMember-->'+adminTeamMember);
		system.debug('tmMMbrMap-->'+tmMMbrMap);
		system.debug('actTakerMap-->'+actTakerMap);
		Map<Id,Set<Id>> picAssigned = new Map<Id,Set<Id>>();
		Set<Id> teamIds = new Set<Id>();
		Set<String> picSet= new Set<String>();
		Set<String> emailsSet= new Set<String>();
		if(actTakerMap != null){
		for(Id req: reqMap.KeySet()){
			if(reqMap.get(req).Team__c == null && reqMap.get(req).Person_In_Charge__c == null){
				for(Id act: actTakerMap.KeySet()){
					system.debug('<-------------------------->');
					system.debug('reqMap.get(req).Property__c-->'+reqMap.get(req).Property__c);
					system.debug('reqMap.get(req).Dept_in_Charge__c-->'+reqMap.get(req).Dept_in_Charge__c);
					system.debug('reqMap.get(req).Request_Type__c-->'+reqMap.get(req).Request_Type__c);
					
					system.debug('actTakerMap.get(act).Id-->'+actTakerMap.get(act).Id);
					system.debug('actTakerMap.get(act).Property__c-->'+actTakerMap.get(act).Property__c);
					system.debug('actTakerMap.get(act).Department__c-->'+actTakerMap.get(act).Department__c);
					system.debug('actTakerMap.get(act).Job_Type__c-->'+actTakerMap.get(act).Job_Type__c);
					system.debug('<-------------------------->');
					if(actTakerMap.get(act).Id != null){
					    if(reqMap.get(req).Dept_in_Charge__c == null && actTakerMap.get(act).Department__c == null && reqMap.get(req).Request_Type__c == null && actTakerMap.get(act).Job_Type__c == null){
							if(reqMap.get(req).Property__c == actTakerMap.get(act).Property__c){
								reqMap.get(req).Team__c = actTakerMap.get(act).Id;
								if(tmMMbrMap.containsKey(act) && tmMMbrMap.get(act).Member__c != null){
									reqMap.get(req).Person_In_Charge__c = tmMMbrMap.get(act).Member__c;
									reqMap.get(req).Status__c = 'In Progress';
								}
							}
						}else if(reqMap.get(req).Request_Type__c == null && actTakerMap.get(act).Job_Type__c == null){
							if(reqMap.get(req).Property__c == actTakerMap.get(act).Property__c && reqMap.get(req).Dept_in_Charge__c == actTakerMap.get(act).Department__c){
								reqMap.get(req).Team__c = actTakerMap.get(act).Id;
								if(tmMMbrMap.containsKey(act) && tmMMbrMap.get(act).Member__c != null){
									reqMap.get(req).Person_In_Charge__c = tmMMbrMap.get(act).Member__c;
									reqMap.get(req).Status__c = 'In Progress';
								}
							}
						}else if(reqMap.get(req).Dept_in_Charge__c == null && actTakerMap.get(act).Department__c == null){
							if(reqMap.get(req).Property__c == actTakerMap.get(act).Property__c && actTakerMap.get(act).Job_Type__c.contains(reqMap.get(req).Request_Type__c)){
								reqMap.get(req).Team__c = actTakerMap.get(act).Id;
								if(tmMMbrMap.containsKey(act) && tmMMbrMap.get(act).Member__c != null){
									reqMap.get(req).Person_In_Charge__c = tmMMbrMap.get(act).Member__c;
									reqMap.get(req).Status__c = 'In Progress';
								}
							}
						}else if(reqMap.get(req).Property__c == actTakerMap.get(act).Property__c && reqMap.get(req).Dept_in_Charge__c == actTakerMap.get(act).Department__c && actTakerMap.get(act).Job_Type__c.contains(reqMap.get(req).Request_Type__c)){
								reqMap.get(req).Team__c = actTakerMap.get(act).Id;
								if(tmMMbrMap.containsKey(act) && tmMMbrMap.get(act).Member__c != null){
									reqMap.get(req).Person_In_Charge__c = tmMMbrMap.get(act).Member__c;
									reqMap.get(req).Status__c = 'In Progress';
								}
						}
					}
				}
				system.debug('eend ->'+reqMap.get(req).Team__c);
				system.debug('eend ->'+reqMap.get(req).Person_In_Charge__c);
				system.debug('1st ->'+(reqMap.get(req).Team__c == null || reqMap.get(req).Person_In_Charge__c == null) );
				system.debug('2nd ->'+adminTeam != null && adminTeamMember != null);
				if((reqMap.get(req).Team__c == null || reqMap.get(req).Person_In_Charge__c == null) && adminTeam != null && adminTeamMember != null) {
					reqMap.get(req).Team__c = adminTeam;
					reqMap.get(req).Person_In_Charge__c = adminTeamMember;
					reqMap.get(req).Status__c = 'In Progress';
				}
				system.debug('eend11 ->'+reqMap.get(req).Team__c);
				system.debug('eend11 ->'+reqMap.get(req).Person_In_Charge__c);
			}
			listReq.add(reqMap.get(req));
			System.debug('reqMap.get(req)-->'+reqMap.get(req));
			teamIds.add(reqMap.get(req).Team__c);
			if(reqMap.get(req).Person_In_Charge__c != null ){
				picSet.add(reqMap.get(req).Person_In_Charge__c);
			}
			if(reqMap.get(req).Requested_By__c == null){
				emailsSet.add(UserInfo.getUserId());
			}
		}
		Map<Id, Contact> conWithTeam = new Map<Id, Contact>([Select Id, Email,SF_User__c, (Select Id, In_Charge__c, Status__c, Member__c, Team__c, Team__r.Property__c, Team__r.Department__c, Team__r.Job_Type__c,Team__r.Status__c  From Team_Members__r where Status__c = 'Active' And Team__r.Status__c = 'Active')  From Contact where id=:picSet OR SF_User__c =: emailsSet]);
		Map<String, Contact> conEmailWithId = new Map<String, Contact>();
		Set<Id> cons = new Set<Id>();
		for(Contact con:conWithTeam.values()){
			if(con.SF_User__c != null)
			conEmailWithId.put(con.SF_User__c, con);
			cons.add(con.Id);
		}
		List<Team_Member__c> listTMbr= [Select Id,Team__c,In_Charge__c,Member__c,Member__r.Email From Team_Member__c where Team__c =: teamIds];
		Map<Id, List<Team_Member__c>> teamWithMembers= new Map<Id, List<Team_Member__c>>();
		
		for(Team_Member__c mmbr:listTMbr){
			List<Team_Member__c> temp = new List<Team_Member__c>();
			temp.add(mmbr);
			if(teamWithMembers.containsKey(mmbr.Team__c))
				temp.addAll(teamWithMembers.get(mmbr.Team__c));
			teamWithMembers.put(mmbr.Team__c,temp);
			cons.add(mmbr.Member__c);
		}
		Map<Id,Set<Id>> conWithProp = new Map<Id,Set<Id>>(MainRequestTrigger_Helper.getConWithProp(cons,emailsSet));
		
		Map<Id,Permission_Assignment__c> passMap = new map<Id,Permission_Assignment__c>(); 
		List<EmailTemplate> emailTemplates = [Select id from EmailTemplate where name = 'Request: New Assignment Notification'];
		List<EmailTemplate> emailTemplatesReqBy = [Select id from EmailTemplate where name = 'Request: Update Notification'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		Boolean checkSheduled = false;
		
		for(Id req: reqMap.KeySet()){
			if(reqMap.get(req).Type__c != null && notifyScheduled != null)
		    checkSheduled = (reqMap.get(req).Type__c != notifyScheduled.Name || ( reqMap.get(req).Type__c == notifyScheduled.Name && notifyScheduled.Notify_ON_OFF__c));
			System.debug('req-->'+req);
			Id propId = reqMap.get(req).Property__c;
			Set<string> addresses = new Set<String>();
			Set<string> addressesReqBy = new Set<String>();
			if(reqMap.get(req).Requested_By__c == null && conEmailWithId.containsKey(UserInfo.getUserId()) ){
				reqMap.get(req).Requested_By__c = conEmailWithId.get(UserInfo.getUserId()).Id;
				addressesReqBy.add(conEmailWithId.get(UserInfo.getUserId()).Email);
			}
			if(conWithProp.containsKey(reqMap.get(req).Person_In_Charge__c)){
				addresses.add(conWithTeam.get(reqMap.get(req).Person_In_Charge__c).Email);
			}
			if(reqMap.get(req).Team__c!=null ){
				if(teamWithMembers.get(reqMap.get(req).Team__c).size() > 0  ){//&& reqMap.get(req).Last_Updated_From__c == 'SF'
					for(Team_Member__c tmm: teamWithMembers.get(reqMap.get(req).Team__c)){
						if(tmm.In_Charge__c || (conWithProp.containsKey(tmm.Member__c) && conWithProp.get(tmm.Member__c).contains(propId))) {
							addresses.add(tmm.Member__r.Email);
						}
					}
				}
			}
			if(checkSheduled){
				if(addresses.size() >0 ){
					Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage ();
					email.setTemplateId(emailTemplates[0].Id);
					email.setSaveAsActivity(false);
					email.setToAddresses(new List<String>(addresses));
					email.setTargetObjectId(reqMap.get(req).Person_In_Charge__c);
					email.setWhatId(req);
					email.setTreatTargetObjectAsRecipient(false);
					emails.add(email);
					
				}
				if(addressesReqBy.size() >0){
					Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage ();
					email.setTemplateId(emailTemplatesReqBy[0].Id);
					email.setSaveAsActivity(false);
					email.setToAddresses(new List<String>(addressesReqBy));
					//email.setccAddresses(new List<String>{'arshad.shaikh@techmatrixconsulting.com'});
					email.setTargetObjectId(reqMap.get(req).Person_In_Charge__c);
					email.setWhatId(req);
					email.setTreatTargetObjectAsRecipient(false);
					emails.add(email);
				}
			}
		}
			System.debug('emails-->'+emails);
			if(emails.size() > 0 && !Test.isRunningTest()) {
		        List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
		         System.debug('results-->'+results);
		      }
			System.debug('reqMap-->'+ reqMap.values());
			System.debug('listReq-->'+ listReq);
			update reqMap.values();
		}
	}
    public static void generateReqName( List<Request__c> reqList){
    	Set<Id> propIds = new Set<Id>();
    	for(Request__c req: reqList){
    		if(req.Property__c != null && !propIds.contains(req.Property__c) && req.Last_Updated_From__c =='SF')
    			propIds.add(req.Property__c);
    	}
    	
    	Map<Id, Property__c> listProperties= new Map<Id, Property__c>([select Id,Short_Code__c, Request_Index__c from Property__c where id =:propIds]);
    	Map<Id, Property__c> mapProperties = new Map<Id, Property__c>();
    	Map<Id, Integer> mapCount = new Map<Id, Integer>();
    	String code;
    	Integer countLabel = Integer.valueof(Count_Index__c.getValues('Request_ST_Index').Count__c);
    	Count_Index__c lst= Count_Index__c.getValues('Request_ST_Index');
    	
    	for(Request__c req: reqList){
    		if(req.Last_Updated_From__c == 'SF'){
	    		if(req.Property__c != null && listProperties.containsKey(req.Property__c)){
	    			code  =  listProperties.get(req.Property__c).Short_Code__c;
	    			code += '-WQ-';
	    			code += System.today().Year();
	    			if(System.today().Month() < 10){
	    				code += '0';
	    			}
	    			code += System.today().Month();
	    			code += '-';
	    			Integer temp;
	    			if(mapProperties.containsKey(listProperties.get(req.Property__c).Id)){
	    				temp = Integer.valueOf(mapProperties.get(listProperties.get(req.Property__c).Id).Request_Index__c);
	    			}else{
	    				temp =  Integer.valueof(listProperties.get(req.Property__c).Request_Index__c);
	    			}
	    			String tempNo;
	    			if(temp == 0 || temp == null){
	    				temp   = 1;
	    				
	    			}
	    			tempNo = ''+temp;
	    			for(integer i =1;i<=6-tempNo.length();i++){
	                    code += '0';
	                }
	    			code += tempNo;
	    			req.Name = code;
	    			if(listProperties.get(req.Property__c).Id != null){
	    				Property__c pr = new Property__c();
		    			pr.Id = listProperties.get(req.Property__c).Id;
		    			if(mapProperties.containsKey(pr.Id)){
		    				//pr.Request_Index__c = temp;
		    				mapProperties.get(pr.Id).Request_Index__c += 1;
		    			}else{
		    				temp += 1;
		    				pr.Request_Index__c = temp;
		    				mapProperties.put(pr.Id, pr);
		    			}
		    			
	    			}
	    		}else{
	    			code  =  'ST';
	    			code += '-WQ-';
	    			code += System.today().Year();
	    			if(System.today().Month() < 10){
	    				code += '0';
	    			}
	    			code += System.today().Month();
	    			code += '-';
	    			Integer temp;
	    			
	    			temp = countLabel;
	    			
	    			String tempNo;
	    			if(temp == 0 || temp == null){
	    				temp   = 1;
	    				countLabel = temp+1;
	    				tempNo = ''+temp;
	    			}else{
	    				temp += 1;
	    				countLabel++;
	    				tempNo = ''+temp; 
	    			}
	    			for(integer i =1;i<=6-tempNo.length();i++){
	                    code += '0';
	                }
	    			code += ''+temp;
	    			req.Name = code;
	    		}
    		}
    	}
    	try{
            lst.Count__c = countLabel;
            update lst;
    		update mapProperties.values();
    	}catch(Exception e){
    		System.debug('Exception occured -- > '+e);
    	}
    }
}