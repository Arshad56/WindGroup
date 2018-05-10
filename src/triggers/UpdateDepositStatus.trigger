trigger UpdateDepositStatus on Deposit__c (before update) {
    for(Deposit__c dep:Trigger.New){
        /*System.debug('111-->'+ (dep.Status__c!='Cancelled' && dep.Status__c!='Rejected' && (dep.Amount_Paid__c!=Trigger.OldMap.get(dep.Id).Amount_Paid__c || dep.Deposit_Amount__c!=Trigger.OldMap.get(dep.Id).Deposit_Amount__c)));
        System.debug('amount paid-->'+ (dep.Amount_Paid__c!=Trigger.OldMap.get(dep.Id).Amount_Paid__c));
        if(dep.Status__c!='Cancelled' && dep.Status__c!='Rejected' && (dep.Amount_Paid__c!=Trigger.OldMap.get(dep.Id).Amount_Paid__c || dep.Deposit_Amount__c!=Trigger.OldMap.get(dep.Id).Deposit_Amount__c)){
            
            dep.Amount_Paid__c = (dep.Amount_Paid__c == null) ? 0 : dep.Amount_Paid__c;
            dep.Deposit_Amount__c = (dep.Deposit_Amount__c == null) ? 0 : dep.Deposit_Amount__c;
            
            Decimal outstandingAmt = dep.Deposit_Amount__c - dep.Amount_Paid__c;
            outstandingAmt = outstandingAmt.setScale(2);
            
            System.debug(outstandingAmt+' deposit Amt-->'+dep.Deposit_Amount__c.setScale(2));
            System.debug('2222-->'+ (dep.Deposit_Amount__c.setScale(2)==outstandingAmt)); 
            
            if(outstandingAmt == 0 ){ 
                dep.Status__c = 'Paid';
            }else if(((dep.Deposit_Amount__c > 0 && outstandingAmt > 0) || (dep.Deposit_Amount__c < 0 && outstandingAmt < 0)) && dep.Deposit_Amount__c.setScale(2)==outstandingAmt && dep.Amount_Paid__c==0){
                dep.Status__c = 'Outstanding';
            }else if((dep.Deposit_Amount__c > 0 && outstandingAmt > 0 && dep.Amount_Paid__c > 0) || (dep.Deposit_Amount__c < 0 && outstandingAmt < 0 && dep.Amount_Paid__c < 0)){
                dep.Status__c = 'Partially Paid';
            }
        }*/
        if(Trigger.isBefore && dep.Status__c!='Cancelled' && dep.Status__c!='Rejected'  && (dep.Amount_Paid__c!=Trigger.OldMap.get(dep.Id).Amount_Paid__c || dep.Deposit_Amount__c!=Trigger.OldMap.get(dep.Id).Deposit_Amount__c)){
            if(dep.Outstanding_Amount__c==0){
                dep.Status__c = 'Paid';
            }else if(((dep.Deposit_Amount__c > 0 && dep.Outstanding_Amount__c > 0) || (dep.Deposit_Amount__c < 0 && dep.Outstanding_Amount__c < 0)) && dep.Deposit_Amount__c.setScale(2)==dep.Outstanding_Amount__c && dep.Amount_Paid__c==0){
                dep.Status__c = 'Outstanding';
            }else if((dep.Deposit_Amount__c > 0 && dep.Outstanding_Amount__c > 0 && dep.Amount_Paid__c > 0) || (dep.Deposit_Amount__c < 0 && dep.Outstanding_Amount__c < 0 && dep.Amount_Paid__c < 0)){
                dep.Status__c = 'Partially Paid';
            }
        }
    }
}