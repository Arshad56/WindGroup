public class CalcLatePaymentController{
    public Date setTodayDate{get;set;}
    public void CalcLatePayment(){
       Date TodayDate = system.today().addDays(-1);
       
       if(setTodayDate <> NULL)
       TodayDate = setTodayDate.addDays(-1);
        
       //Integer month = TodayDate.month();
        
       // if(month == 1)
       //     month = 13;
    
       //Integer curMonth = month-1;
       //Integer curYear = TodayDate.year();
       
       Integer curMonth = TodayDate.month();
       Integer curYear = TodayDate.year();
       
       Date curDate = Date.NewInstance(curYear,curMonth,Date.DaysInMonth(curYear,curMonth));
       /*if(label.Late_Charge_Batch_Date!=null){
           curDate = Date.NewInstance(curYear,curMonth,Integer.valueOf(label.Late_Charge_Batch_Date));
       }else{
           curDate = system.today();
       }*/
       
       //Schedule Job will run at 1st Day of Month. 
       //Payment Due Date < Current Date. Last Day of the month record will not be pick.
       //Outstanding Amount > 0 OR (LInast_Payment_Date__c!=null and Late_Charge_Days__c>0 and Calendar_Month(Last_Payment_Date__c)=:curMonth and Calendar_Year =: curYear)
       //Decommission Date: 5th December against issue late charge is generated for Credit Note
       //List<Invoice__c> invList = [Select Id,Name,Outstanding_Amount__c,Payment_Due_Date__c,Late_Charge_Applicable__c,Lease__r.Property__c,Lease__r.Tenant__c,Lease__r.Late_Payment_Interest__c,Currency_Code__c,Exchange_Rate__c,Last_Payment_Date__c FROM Invoice__c where Payment_Due_Date__c<=:curDate and (Outstanding_Amount__c > 0 or (Last_Payment_Date__c!=null and Late_Charge_Days__c>0 and Calendar_Month(Last_Payment_Date__c)=:curMonth and Calendar_Year(Last_Payment_Date__c)=:curYear)) and Late_Charge_Applicable__c=true and Lease__r.Property__r.Late_Charge_Batch__c=true and Voided__c=false and Status__c!='Cancelled'];
       System.debug('#### Current Date ---->' + curDate);
       /** when outstanding > 0 or
        * outstanding <= 0 but user made full payment before next scheduler run ((Last_Payment_Date__c!=null and Calendar_Month(Last_Payment_Date__c)<=:curMonth and Calendar_Year(Last_Payment_Date__c)=:curYear))
        **/
       List<Invoice__c> invList = [Select Id,Name,Outstanding_Amount__c,Payment_Due_Date__c,Late_Charge_Applicable__c,Lease__r.Property__c,Lease__r.Tenant__c,Lease__r.Late_Payment_Interest__c,Currency_Code__c,Exchange_Rate__c,Last_Payment_Date__c FROM Invoice__c where Payment_Due_Date__c<:curDate and ( Outstanding_Amount__c > 0 Or (Last_Payment_Date__c!=null and Calendar_Month(Last_Payment_Date__c)<=:curMonth and Calendar_Year(Last_Payment_Date__c)=:curYear)) and Late_Charge_Applicable__c=true and Lease__r.Property__r.Late_Charge_Batch__c=true and Voided__c=false and Status__c!='Cancelled' and billing_type__c != 'Credit Note'];
       
      
       //Map property, currency code and invoicelist.
       Map<Id,Map<string,List<Invoice__c>>> propToCurrCodeInvMap = new Map<Id,Map<string,List<Invoice__c>>>();
       Set<Id> invIds = new Set<Id>();
       for(Invoice__c inv:invList){
           List<Invoice__c> tempList= new List<Invoice__c>();
           Map<string,List<Invoice__c>> tempMap = new Map<string,List<Invoice__c>>();
           if(propToCurrCodeInvMap.containsKey(inv.Lease__r.Property__c)){
               tempMap = propToCurrCodeInvMap.get(inv.Lease__r.Property__c);
           }
           if(tempMap.containsKey(inv.Currency_Code__c)){
               tempList.addAll(tempMap.get(inv.Currency_Code__c));
           }
           tempList.add(inv);
           tempMap.put(inv.Currency_Code__c,tempList);
           propToCurrCodeInvMap.put(inv.Lease__r.Property__c,tempMap);
           invIds.add(inv.Id);
       }
       
       // Map Invoice with Cash Detail
       Map<Id,List<Cash_Detail__c>> invToCashDetMap = new Map<Id,List<Cash_Detail__c>>();
       if(invIds.size()>0){
           for(Cash_Detail__c cd:[Select id,name, Amount_Paid__c,Payment_Date__c,Currency_Code__c,Invoice__c,Invoice__r.Payment_Due_Date__c,Invoice__r.Currency_Code__c,Invoice__r.Exchange_Rate__c from Cash_Detail__c where Invoice__c in:invIds and Void__c=false]){
               System.debug('####### cd ' + cd.name);
               System.debug('####### cd ' + cd.Payment_Date__c);
               System.debug('####### cd ' + curMonth);
               System.debug('####### cd ' + cd.Payment_Date__c.month());
               if(cd.Payment_Date__c!=null && cd.Payment_Date__c.month()==curMonth && cd.Payment_Date__c>cd.Invoice__r.Payment_Due_Date__c){
                   
                   List<Cash_Detail__c> tempList = new List<Cash_Detail__c>();
                   if(invToCashDetMap.containsKey(cd.Invoice__c)){
                       tempList.addAll(invToCashDetMap.get(cd.Invoice__c));
                   }
                   tempList.add(cd);
                   invToCashDetMap.put(cd.Invoice__c,tempList);
               }
           }
       }
       
       //Property with Total Square Feet
       if(propToCurrCodeInvMap.size()>0){
           Map<Id,Property__c> PropertyMap = new Map<Id,Property__c>([Select id,Name,Late_Charge_By__c,Rent_Roll_Index__c,Short_Code__c from Property__c where id in:propToCurrCodeInvMap.keyset()]);
           
           List<Lease_Unit__c> leaseUnits = [Select id,Area_Sq_Ft__c,Unit__r.Property__c from Lease_Unit__c where Unit__r.Property__c in:propToCurrCodeInvMap.keyset() and Area_Sq_Ft__c!=null];
           Map<Id,Decimal> totalLeaseAreaMap = new Map<Id,Decimal>();
           for(Lease_Unit__c lu:leaseUnits){
               decimal temp = 0;
               if(totalLeaseAreaMap.containsKey(lu.Unit__r.Property__c)){
                   temp = totalLeaseAreaMap.get(lu.Unit__r.Property__c);
               }
               temp += lu.Area_Sq_Ft__c;
               totalLeaseAreaMap.put(lu.Unit__r.Property__c,temp);
           }
           
           //RR Creation no issue
           List<RentRollWrapper> rrWrapList = new List<RentRollWrapper>();
           List<Invoice__c> invoiceList = new List<Invoice__c>();
           for(Id propId:propToCurrCodeInvMap.keyset()){
               Property__c prop = PropertyMap.get(propId);
               for(string str:propToCurrCodeInvMap.get(propId).keyset()){
                   RentRollWrapper rrw = new RentRollWrapper();
                   Rent_Roll__c rr = new Rent_Roll__c();
                   rr.Property__c = propId;
                   if(totalLeaseAreaMap.containsKey(propId)){
                       rr.Total_Leased_Area_Sq_Ft__c = totalLeaseAreaMap.get(propId);
                   }
                   rr.Expected_Invoice_Date__c = curDate + 1;
                   rr.Actual_Invoice_Date__c = curDate + 1;
                   
                   rr.Billing_Type__c = 'Late Charge';
                   
                   rr.Rent_Roll_YYYY__c = ''+curYear;
                   rr.Rent_Roll_MM__c = (curMonth<10?'0'+curMonth:''+curMonth);
                   
                   
                   Integer IntIndex = 1;
                   if(prop.Rent_Roll_Index__c!=null && prop.Rent_Roll_Index__c>0){
                       intIndex = Integer.valueOf(prop.Rent_Roll_Index__c);
                   }
                    
                   Integer indexSize = string.valueOf(intIndex).length();
                   
                   string index = '';
                   for(integer i =1;i<=6-indexSize;i++){
                       index += '0';
                   }
                   index += string.valueOf(intIndex);
                   rr.Rent_Roll_Index__c = index;
                   prop.Rent_Roll_Index__c = intIndex + 1;
                   rr.Name = prop.Short_Code__c+'-RO-'+curYear+(curMonth<10?'0'+curMonth:''+curMonth)+'-'+rr.Rent_Roll_Index__c;
                   rr.Currency_Code__c = str;
                   
                   PropertyMap.put(prop.Id,prop);
                   Integer baseDays= 30;
                   if(prop.Late_Charge_By__c=='30 Days'){
                       baseDays = 30;
                   }else if(prop.Late_Charge_By__c=='By Month'){
                       baseDays = curDate.day();
                   }
                   rr.Total_Amount__c = 0;
                   for(Invoice__c inv:propToCurrCodeInvMap.get(propId).get(str)){
                       if(invToCashDetMap.containsKey(inv.Id)){
                           for(Cash_Detail__c cd:invToCashDetMap.get(inv.Id)){
                               Rent_Roll_Detail__c rrd = new Rent_Roll_Detail__c();
                               rrd.Active__c = true;
                               
                               //myat - 20171214 - add to check curYear as well.
                               if(inv.Payment_Due_Date__c.month()==curMonth && inv.Payment_Due_Date__c.month() == curYear){
                                   rrd.Start_Date__c = inv.Payment_Due_Date__c + 1;
                               }else{
                                   rrd.Start_Date__c = Date.newInstance(curYear,curMonth,1); //Invoice due for previous month. Example: Invoice PaymentDueDate 12thMay, Job Run: 12thNov.
                               }
                               
                               rrd.End_Date__c = cd.Payment_Date__c;
                               rrd.Billing_Date__c = cd.Payment_Date__c;
                               rrd.Billing_Type__c = 'Late Charge';
                               rrd.Charge_Type__c = 'Late Charge';
                               rrd.Status__c = 'Pending';
                               rrd.Default_Days__c = rrd.Start_Date__c.DaysBetween(rrd.End_Date__c) + 1;
                 
                 /* myat - 20171214
                 *if late charge base days in 30 setup in property and the late duration is full month, to calculate late amount based on base on 30 day regardless of 30 or 31 of the day.
                 * eg. property is base days in 30, tenant due whole december, calculate due amount with 30 for both base and due days.
                 **/
                 if(rrd.End_Date__c == Date.newInstance(rrd.End_Date__c.year(), rrd.End_Date__c.month(), Date.daysInMonth(rrd.End_Date__c.year(), rrd.End_Date__c.month())))
                 rrd.Default_Days__c = baseDays;
                 
                               rrd.Late_Percent_Rate__c = inv.lease__r.Late_Payment_Interest__c;
                               if(inv.lease__r.Late_Payment_Interest__c!=null){
                                   
                                   if(cd.Invoice__r.Currency_Code__c!=Label.Default_Currency && cd.Currency_Code__c==Label.Default_Currency && cd.Invoice__r.Exchange_Rate__c!=null){
                                       rrd.Amount__c = (cd.Amount_Paid__c/cd.Invoice__r.Exchange_Rate__c)*(rrd.Default_Days__c/baseDays)*inv.lease__r.Late_Payment_Interest__c/100.00;
                                   }else{
                                       rrd.Amount__c = cd.Amount_Paid__c*(rrd.Default_Days__c/baseDays)*inv.lease__r.Late_Payment_Interest__c/100.00;
                                   }
                                   rr.Total_Amount__c += rrd.Amount__c;
                               }
                               
                               rrd.Invoice__c = inv.Id;
                               rrd.Outstanding_Amount__c = cd.Amount_Paid__c;
                               rrd.Exchange_Rate__c = inv.Exchange_Rate__c;
                               rrd.Currency_Code__c = str;
                               rrd.Remarks__c = 'Late Charge for Invoice '+inv.Name+'; Duration:'+DateTime.newInstance(rrd.Start_Date__c.year(),rrd.Start_Date__c.month(),rrd.Start_Date__c.day()).format('d-MMMM-yyyy')+' ~ '+DateTime.newInstance(rrd.End_Date__c.year(),rrd.End_Date__c.month(),rrd.End_Date__c.day()).format('d-MMMM-yyyy');
                               
                               rrd.Property_Name_Text__c = prop.Name;
                               rrw.rrdList.add(rrd);
                           }
                       }
                       
                       if(inv.Outstanding_Amount__c > 0){
                           Rent_Roll_Detail__c rrd = new Rent_Roll_Detail__c();
                           rrd.Active__c = true;
                           
                           //myat - 20171214 - add to check curYear as well.
                           if(inv.Payment_Due_Date__c.month()==curMonth && inv.Payment_Due_Date__c.month() == curYear){
                               rrd.Start_Date__c = inv.Payment_Due_Date__c + 1;
                           }else{
                               rrd.Start_Date__c = Date.newInstance(curYear,curMonth,1);
                           }
                           
                           rrd.End_Date__c = curDate;
                           rrd.Billing_Date__c = curDate + 1;
                           rrd.Billing_Type__c = 'Late Charge';
                           rrd.Charge_Type__c = 'Late Charge';
                           rrd.Status__c = 'Pending';
                           
                           rrd.Default_Days__c = rrd.Start_Date__c.DaysBetween(rrd.End_Date__c) + 1;
               
               /* myat - 20171214
               *if late charge base days in 30 setup in property and the late duration is full month, to calculate late amount based on base on 30 day regardless of 30 or 31 of the day.
               * eg. property is base days in 30, tenant due whole december, calculate due amount with 30 for both base and due days.
               **/
               if(rrd.End_Date__c == Date.newInstance(rrd.End_Date__c.year(), rrd.End_Date__c.month(), Date.daysInMonth(rrd.End_Date__c.year(), rrd.End_Date__c.month())))
               rrd.Default_Days__c = baseDays;
               
                           rrd.Late_Percent_Rate__c = inv.lease__r.Late_Payment_Interest__c;
                           if(inv.lease__r.Late_Payment_Interest__c!=null){
                               rrd.Amount__c = inv.Outstanding_Amount__c*(rrd.Default_Days__c/baseDays)*inv.lease__r.Late_Payment_Interest__c/100.00;
                               rr.Total_Amount__c += rrd.Amount__c;
                           }
                           
                           rrd.Invoice__c = inv.Id;
                           rrd.Outstanding_Amount__c = inv.Outstanding_Amount__c;
                           rrd.Exchange_Rate__c = inv.Exchange_Rate__c;
                           rrd.Currency_Code__c = str;
                           System.debug('');
                           rrd.Remarks__c = 'Late Charge for Invoice '+inv.Name+'; Duration:'+DateTime.newInstance(rrd.Start_Date__c.year(),rrd.Start_Date__c.month(),rrd.Start_Date__c.day()).format('d-MMMM-yyyy')+' ~ '+DateTime.newInstance(rrd.End_Date__c.year(),rrd.End_Date__c.month(),rrd.End_Date__c.day()).format('d-MMMM-yyyy');
                           
                           rrd.Property_Name_Text__c = prop.Name;
                           rrw.rrdList.add(rrd);
                       }
                       inv.Last_Payment_Date__c = curDate;
                       invoiceList.add(inv);
                   }
                   rrw.RentRoll = rr;
                   rrWrapList.add(rrw);
               }
           }
           List<Rent_Roll_Detail__c> rentRollDetailList = new List<Rent_Roll_Detail__c>();
           if(rrWrapList.size()>0){
               List<Rent_Roll__c> rentRollList = new List<Rent_Roll__c>();
               for(RentRollWrapper rrw:rrWrapList){
                   rentRollList.add(rrw.rentRoll);
               }
               insert rentRollList;
               for(RentRollWrapper rrw:rrWrapList){
                   If(rrw.rentRoll.Id!=null){
                       for(Rent_Roll_Detail__c rrd:rrw.rrdList){
                           rrd.rent_Roll__c = rrw.rentRoll.Id;
                           rentRollDetailList.add(rrd);
                       }
                   }
               }
               insert rentRollDetailList;
               
               update PropertyMap.values();
           }
           update invoiceList;
       }
    }
    
   
    
    class RentRollWrapper{
        Rent_Roll__c rentRoll;
        List<Rent_Roll_Detail__c> rrdList;
        RentRollWrapper(){
            rentRoll = new Rent_Roll__c();
            rrdList = new List<Rent_Roll_Detail__c>();
        }
    }
}