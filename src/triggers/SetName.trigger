/*
Test Class - PVTrigger_Test
*/
trigger SetName on Payment_Voucher__c (before insert,before update) {
    if(trigger.isInsert){
        Set<Id> depositIds = new Set<Id>();
        Set<Id> InvoiceIds = new Set<Id>();
        for(Payment_Voucher__c pv:Trigger.New){
            depositIds.add(pv.deposit__c);
            InvoiceIds.add(pv.Invoice__c);
        }
        
        Map<Id,Deposit__c> depositMap = new Map<Id,Deposit__c>([Select id,lease__r.Property__c,lease__r.Property__r.Short_Code__c,lease__r.Property__r.Payment_Voucher_Index__c from Deposit__c where id in:depositIds and lease__r.Property__c!=null]);
        Map<Id,Invoice__c> InvoiceMap = new Map<Id,Invoice__c>([Select id,Property__c,Property_Short_Code__c,Lease__r.Property__r.Payment_Voucher_Index__c from Invoice__c where id in:InvoiceIds and Property__c!=null]);
        
        string curYear = ''+system.today().Year();
        string curMonth = (system.today().month()<10?'0'+system.today().month():''+system.today().month());
        
        List<property__c> propList = new List<Property__c>();
        Map<Id,integer> propToIndexMap = new Map<Id,Integer>();
        for(Payment_Voucher__c pv:Trigger.New){
            if(depositMap.containsKey(pv.Deposit__c) || InvoiceMap.containsKey(pv.Invoice__c)){
                property__c prop = new Property__c();
                
                if(depositMap.containsKey(pv.Deposit__c)){
                	prop.Id = depositMap.get(pv.Deposit__c).lease__r.Property__c;
	                if(propToIndexMap.containsKey(prop.Id)){
	                    prop.Payment_Voucher_Index__c = propToIndexMap.get(prop.Id);
	                }else{
	                    prop.Payment_Voucher_Index__c = depositMap.get(pv.Deposit__c).lease__r.Property__r.Payment_Voucher_Index__c;
	                }
	                prop.Short_Code__c = depositMap.get(pv.Deposit__c).lease__r.Property__r.Short_Code__c;
                }else if(InvoiceMap.containsKey(pv.Invoice__c)){
                	prop.Id = InvoiceMap.get(pv.Invoice__c).lease__r.Property__c;
	                if(propToIndexMap.containsKey(prop.Id)){
	                    prop.Payment_Voucher_Index__c = propToIndexMap.get(prop.Id);
	                }else{
	                    prop.Payment_Voucher_Index__c = InvoiceMap.get(pv.Invoice__c).Lease__r.Property__r.Payment_Voucher_Index__c;
	                }
	                prop.Short_Code__c = InvoiceMap.get(pv.Invoice__c).Property_Short_Code__c;
                }
	                
                Integer IntIndex = 1;
                if(prop.Payment_Voucher_Index__c!=null && prop.Payment_Voucher_Index__c>0){
                    intIndex = Integer.valueOf(prop.Payment_Voucher_Index__c);
                }
                
                Integer indexSize = string.valueOf(intIndex).length();
                
                string index = '';
                for(integer i =1;i<=6-indexSize;i++){
                    index += '0';
                }
                index += string.valueOf(intIndex);
                prop.Payment_Voucher_Index__c = intIndex + 1;
                propToIndexMap.put(prop.Id,intIndex + 1); 
                propList.add(prop);
                pv.Name = prop.Short_Code__c + '-PV-'+curYear+curMonth+'-'+index;
            }
        }
        update propList;
    }
    if(Trigger.isUpdate){
        for(Payment_Voucher__c pv:Trigger.New){
            if(pv.Name!=Trigger.oldMap.get(pv.Id).Name){
                pv.Name = Trigger.oldMap.get(pv.Id).Name;
            }
        }
    }
}