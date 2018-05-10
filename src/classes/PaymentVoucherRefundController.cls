/*

Test Class - PaymentVoucherRefundController_Test
*/
public class PaymentVoucherRefundController {
    
    public String pvId{get;set;} 
    public String pvLeaseId{get;set;}
    public String pvTenantId{get;set;}
    public String paymentMode{get;set;}
    public String pvBalance{get;set;}
    public String pvCurrency{get;set;}
    public String pvStatus{get;set;}
    public boolean success {get;set;}
    boolean isVF {get;set;}
    public PaymentVoucherRefundController(){
       success = false;
       
       isVF = true;
       pvId = Apexpages.CurrentPage().getParameters().get('pvId');
       pvStatus = Apexpages.CurrentPage().getParameters().get('pvStatus');
       pvBalance = Apexpages.CurrentPage().getParameters().get('pvBalance');
       pvLeaseId = Apexpages.CurrentPage().getParameters().get('pvLeaseId');
       pvTenantId = Apexpages.CurrentPage().getParameters().get('pvTenantId');
       pvCurrency = Apexpages.CurrentPage().getParameters().get('pvCurrency');
    }
    public PaymentVoucherRefundController(String pvId,String pvStatus,String pvBalance,String pvLeaseId,String pvTenantId,String pvCurrency){
       this.pvId = pvId;
       this.pvStatus = pvStatus;
       this.pvBalance = pvBalance;
       this.pvLeaseId = pvLeaseId;
       this.pvTenantId = pvTenantId;
       this.pvCurrency = pvCurrency;
       System.debug('pvLeaseId-->'+pvLeaseId);
		System.debug('pvBalance-->'+pvBalance);
		System.debug('pvTenantId-->'+pvTenantId);
		isVF = false;
    }
    
    public String checkData(){
		System.debug('checkData-->');
		System.debug('pvLeaseId-->'+pvLeaseId);
		System.debug('pvBalance-->'+pvBalance);
		System.debug('pvTenantId-->'+pvTenantId);
		String errStr='';
		 try{
	        Lease__c lease = [Select property__c from lease__c where id = :pvLeaseId];
	        List <Invoice__c> outStandingInvoiceslist = [Select id from Invoice__c where Status__c in ('Outstanding','Partially Paid') and tenant__c= :pvTenantId and property__c = :lease.property__c and billing_Type__c != 'Credit Note' and Voided__c = false];       
	        List <Deposit__c> outStandingDepositlist = [Select id from Deposit__c where Status__c in ('Outstanding','Partially Paid') and tenant__c= :pvTenantId and property__c = :lease.property__c and Voided__c = false];
	        System.debug('pvLeaseId-->'+pvLeaseId);
	        
	        if( outStandingInvoiceslist!= null && !outStandingInvoiceslist.isEmpty() && outStandingDepositlist != null && !outStandingDepositlist.isEmpty()){
	            errStr ='There is outstanding invoice(s)/deposit(s), refund is not allow.';
	            System.debug('11-->');
	        }else{
	        	System.debug('22-->');
	            if(pvBalance == null || (pvBalance.substring(0, 1) != '-' || double.valueOf(pvBalance) == 0))
	                errStr = 'No available balance for refund.';
	            else if(!pvStatus.equals('New'))
	                errStr = 'Payment Vouceher is VOIDED/REFUNDED.';
	            else{
	                System.debug('33-->');
	               
	                    Payment_Voucher__c pv=[Select id, Payment_Mode__c from Payment_Voucher__c where id=:pvId limit 1]; 
	                    Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
	                    psr.setObjectId(pv.Id);
	                    Approval.ProcessResult result = Approval.process(psr);
	                    pv.Payment_Mode__c = paymentMode;
	                    update pv;
	                    success =true; 
						errStr = 'Payment Voucher refunded Successfully. ';
	                
	            }  
	        }
        } catch (Exception ex){
            errStr = ex.getMessage();
        }
        System.debug('errStr-->'+errStr);
        if(isVF)
        	Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, errStr));
    	
    	return errStr;
    }
    
    public List<SelectOption> getPaymentModeOptions() {
        List<SelectOption> pvOption = new List<SelectOption>();
        pvOption.add(new SelectOption('','-None-'));
        pvOption.add(new SelectOption('Cash','Cash'));
        pvOption.add(new SelectOption('Cheque','Cheque'));
        return pvOption;
    }
    
    public static void createPaymentVoucher(Payment_Voucher__c[] newPVList){
        
        Set<Id> pvIds = new Set<Id>();
        for(Payment_Voucher__c pv:newPVList){
            pvIds.add(pv.Id);
        }
        
        List<Payment_Voucher__c> pvList = [Select Id,Invoice__c,Invoice__r.Property__c, Status__c, Lease__c, Refunded_Amount__c, Exchange_Rate__c, Payment_Mode__c, Currency_Code__c, Outstanding_Amount__c, Lease__r.Tenant__c, Lease__r.Property__c,Deposit__c,Refund_Mode__c from Payment_Voucher__c where Id in:pvIds];
  		List<Payment_Voucher__c> tempPVList = new List<Payment_Voucher__c>();
        
        for(Payment_Voucher__c pv: pvList){
            Payment_Voucher__c newpv = new Payment_Voucher__c();
            
            if(pv.Refund_Mode__c == 'Offset Invoice' && pv.Status__c =='Closed' && pv.Outstanding_Amount__c != 0){
                newpv.Deposit__c = pv.Deposit__c;
                newpv.Payment_Voucher__c = pv.Id;
                newpv.Refund_Mode__c = pv.Payment_Mode__c;
                newpv.Currency_Code__c = pv.Currency_Code__c;
                newpv.Amount__c = pv.Outstanding_Amount__c;
                newpv.Lease__c = pv.Lease__c;
                newpv.Exchange_Rate__c = pv.Exchange_Rate__c;
                newpv.Status__c = 'New';
                newpv.Transaction_Type__c = 'Deposit';
                tempPVList.add(newpv);               
                pv.Status__c = 'Closed';
                
            }else if((pv.Refund_Mode__c == 'Cash' || pv.Refund_Mode__c == 'Cheque') && pv.Status__c =='Paid'){
                
                //if(pv.Refund_Mode__c == 'Cheque' && (pv.Cheque_No__c == '' || pv.Cheque_No__c == null))
                   //pv.addError('Please enter cheque no');
  				pv.Refunded_Amount__c = (pv.Refunded_Amount__c!=null)?pv.Refunded_Amount__c:0;
  				
               	pv.Refunded_Amount__c = pv.Refunded_Amount__c + pv.Outstanding_Amount__c;
                
            }else if (pv.Refund_Mode__c == 'Offset Invoice' && pv.Outstanding_Amount__c == 0){
                pv.Status__c = 'Closed';
            }
                       
        }     
        if(tempPVList.size()>0)	
        	insert tempPVList;
        if(pvList.size() > 0)
        	update pvList;
        
    }
    
    public static void updateVoidPaymentVoucher(Payment_Voucher__c[] newPVList, Payment_Voucher__c[] oldPVList){
        
        Map<Id,Payment_Voucher__c> oldPVMap = new Map<Id,Payment_Voucher__c>(oldPVList);
        Set<Id> pvIds = new Set<Id>();
        for(Payment_Voucher__c pv:newPVList){
        	//By AS 21st FEB 2018
        	// Changed from Status == 'Void' to checkbox
            if(pv.Void__c && pv.Status__c != oldPVMap.get(pv.Id).Status__c && pv.Payment_Voucher__c != null)
                pvIds.add(pv.Payment_Voucher__c);    
        }
        
        List<Payment_Voucher__c> pvList = [Select Id,Status__c from Payment_Voucher__c where Id in:pvIds];
        
        for(Payment_Voucher__c pv:pvList){
            pv.Status__c = 'New';
        }
        
        update pvList;
        
    } 
  
}