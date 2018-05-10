trigger GeneratePDF on Deposit__c (after insert, after update) {
	Set<Id> generatePDFfor= new Set<Id>();
	Set<Id> loiToLA= new Set<Id>();
	Boolean check = false;
    for(Deposit__c dp: Trigger.new){

    	System.debug('dp==>'+dp);
    	System.debug(Trigger.isAfter+' ==>'+dp +' tt '+ (Trigger.isUpdate && !Trigger.oldmap.get(dp.Id).Deposit_Generated__c  && dp.Deposit_Generated__c));
    	if(Trigger.isAfter){
	    	check = (Trigger.isInsert && dp.Deposit_Generated__c) || (Trigger.isUpdate && !Trigger.oldmap.get(dp.Id).Deposit_Generated__c  && dp.Deposit_Generated__c);
            if(Trigger.isUpdate && Trigger.oldmap.get(dp.Id).Lease__c == null && dp.Lease__c != null && dp.Deposit_Generated__c){
    			loiToLA.add(dp.Id);
    		}else if(check){
    			generatePDFfor.add(dp.Id);
    			System.debug('dp11==>'+dp);
    		}
    	}
    }
    if(generatePDFfor.size() > 0)
    	DownloadDeposit.generateFromDepositTrigger(generatePDFfor, 'LOI');
    if(loiToLA.size()>0)
    	DownloadDeposit.generateFromDepositTrigger(loiToLA, 'LOI To LA Conversion');
}