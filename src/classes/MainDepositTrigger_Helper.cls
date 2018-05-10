public  class MainDepositTrigger_Helper {
    public static void generateDPName(Set<Id> leaseUnit, List<Deposit__c> deposits){
        Map<Id, Lease_Unit__c> luMap= new Map<Id, Lease_Unit__c>([select Id,Lease_Agreement_No__r.Charge_Method__c,Lease_Agreement_No__r.Property__c,Lease_Agreement_No__r.Property__r.Short_Code__c, Lease_Agreement_No__r.Property__r.Deposit_Index__c from Lease_Unit__c where id =:leaseUnit]);
        Map<Id, LOI_Unit__c> loiUMap= new Map<Id, LOI_Unit__c>([select Id,LOI_Agreement_No__r.Charge_Method__c,LOI_Agreement_No__r.Property__c,LOI_Agreement_No__r.Property__r.Short_Code__c, LOI_Agreement_No__r.Property__r.Deposit_Index__c from LOI_Unit__c where id =:leaseUnit]);
        Map<Id, Property__c> listProperties = new Map<Id, Property__c>();
        String code;
        String chargeMethod;
        for(Deposit__c dp: deposits){
            if(luMap.containsKey(dp.Lease_Unit__c) || loiUMap.containsKey(dp.LOI_Unit__c) ){
            	
            	chargeMethod = (luMap.containsKey(dp.Lease_Unit__c) )?
			            		luMap.get(dp.Lease_Unit__c).Lease_Agreement_No__r.Charge_Method__c:
								loiUMap.get(dp.LOI_Unit__c).LOI_Agreement_No__r.Charge_Method__c;
                dp.Charge_Method__c = chargeMethod;
                
                
                code  = (luMap.containsKey(dp.Lease_Unit__c) )? 
            			luMap.get(dp.Lease_Unit__c).Lease_Agreement_No__r.Property__r.Short_Code__c:
            			loiUMap.get(dp.LOI_Unit__c).LOI_Agreement_No__r.Property__r.Short_Code__c;
                code += '-DI-';
                code += System.today().Year();
                if(System.today().Month() < 10){
                    code += '0';
                }
                code += System.today().Month();
                code += '-';
                Integer temp;
                if(luMap.containsKey(dp.Lease_Unit__c) ){
                	if(listProperties.containsKey(luMap.get(dp.Lease_Unit__c).Lease_Agreement_No__r.Property__c) ){
	                    temp = Integer.valueOf(listProperties.get(luMap.get(dp.Lease_Unit__c).Lease_Agreement_No__r.Property__c).Deposit_Index__c);
	                }else{
	                    temp =  Integer.valueof(luMap.get(dp.Lease_Unit__c).Lease_Agreement_No__r.Property__r.Deposit_Index__c);
	                }	
                }else{
                	if(listProperties.containsKey(loiUMap.get(dp.LOI_Unit__c).LOI_Agreement_No__r.Property__c) ){
	                    temp = Integer.valueOf(listProperties.get(loiUMap.get(dp.LOI_Unit__c).LOI_Agreement_No__r.Property__c).Deposit_Index__c);
	                }else{
	                    temp =  Integer.valueof(loiUMap.get(dp.LOI_Unit__c).LOI_Agreement_No__r.Property__r.Deposit_Index__c);
	                }	
                }
	                
                String tempNo;
                if(temp == 0 || temp == null){
                    temp   = 1;
                    tempNo = ''+temp;
                }else{
                    tempNo = ''+temp;
                }
                for(integer i =1;i<=6-tempNo.length();i++){
                    code += '0';
                }
                code += tempNo;
                dp.Name = code;
                temp += 1;
                if(luMap.containsKey(dp.Lease_Unit__c) ){
	                if(luMap.get(dp.Lease_Unit__c).Lease_Agreement_No__r.Property__c != null){
	                    Property__c pr = new Property__c();
	                    pr.Id = luMap.get(dp.Lease_Unit__c).Lease_Agreement_No__r.Property__c;
	                    if(listProperties.containsKey(pr.Id)){
	                        //pr.Deposit_Index__c = temp;
	                        listProperties.get(pr.Id).Deposit_Index__c += 1;
	                    }else{
	                        pr.Deposit_Index__c = temp;
	                        listProperties.put(pr.Id, pr);
	                    }
	                    
	                }
                }else{
                	if(loiUMap.get(dp.LOI_Unit__c).LOI_Agreement_No__r.Property__c != null){
	                    Property__c pr = new Property__c();
	                    pr.Id = loiUMap.get(dp.LOI_Unit__c).LOI_Agreement_No__r.Property__c;
	                    if(listProperties.containsKey(pr.Id)){
	                        //pr.Deposit_Index__c = temp;
	                        listProperties.get(pr.Id).Deposit_Index__c += 1;
	                    }else{
	                        pr.Deposit_Index__c = temp;
	                        listProperties.put(pr.Id, pr);
	                    }
	                    
	                }
                }
            }
        }
        if(listProperties!=null)
            update listProperties.values();
    }
}