public class InvoicingController{
    public Rent_Roll__c rentRoll{get;set;}
    public List<Rent_Roll__c> rentRollList{get;set;}
    public string selRentRollId{get;set;}
    public Boolean showInvoice{get;set;}
    public Boolean selectAll{get;set;}
    public List<Invoice__c> invoiceList{get;set;}
    public string AttachId{get;set;}
    public Integer month{get;set;}
    public Integer year{get;set;}
    public String billingType{get;set;}
    public String errorMsg{get;set;}
    public Boolean generateInvoiceClicked{get;set;}
    public Map<Id,Boolean> EmailCheckMap{get;set;}
    public Map<Id,string> invoicePDFAttMap{get;set;}
    public Boolean error{get;set;}
    
    public List<SelectOption> getBillingTypes(){
         List<selectOption> tempList = new List<selectOption>();
        Schema.DescribeFieldResult fieldResult = Rent_Roll__c.Billing_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        tempList.add(new SelectOption('','All'));
        for(Schema.PicklistEntry f : ple){
           tempList.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return tempList;
    }
    
    public List<SelectOption> getMonths(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new Selectoption('1','January'));
        options.add(new Selectoption('2','February'));
        options.add(new Selectoption('3','March'));
        options.add(new Selectoption('4','April'));
        options.add(new Selectoption('5','May'));
        options.add(new Selectoption('6','June'));
        options.add(new Selectoption('7','July'));
        options.add(new Selectoption('8','August'));
        options.add(new Selectoption('9','September'));
        options.add(new Selectoption('10','October'));
        options.add(new Selectoption('11','November'));
        options.add(new Selectoption('12','December'));
        return options;
    }
    
    public List<SelectOption> getYears(){
        List<SelectOption> options = new List<SelectOption>();
        for(Integer i=system.today().Year()-5;i<=system.today().Year() + 1;i++){
            options.add(new Selectoption(''+i+'',''+i+''));
        }
        
        return options;
    }
    
    public InvoicingController(){
        month = system.today().month();
        year = system.today().year();
        //billingType = 'Rent';
        EmailCheckMap = new Map<Id,Boolean>();
        invoicePDFAttMap = new Map<Id,string>();
        rentRoll = new Rent_Roll__c();
        rentRollList = new List<Rent_Roll__c>();
        invoiceList = new List<Invoice__c>();
        showInvoice = false;
        selectAll = false;
        error = false;
    }
    
    public void search(){
        error = false;
        rentRollList = new List<Rent_Roll__c>();
        if(rentRoll.Property__c!=null){ //added "Billing_Email__c in the query" by myat - oct-29
            string query = 'Select id,Invoices_Generated__c,Invoices_Emailed__c,Billing_Type__c,Name,Expected_Invoice_Date__c,Approved__c,Property__c,Approver__c,Total_Diesel_Rate__c,Total_Leased_Area_Sq_Ft__c,(Select id,Account__c,Name,Amount__c,Invoice_Generated__c,Invoice_Emailed__c,Invoice_Printed__c,Billing_Email__c,Comm_Tax_Amount__c from Invoices__r order by createddate asc) from Rent_Roll__c where Approved__c=true and Property__c=\''+rentRoll.Property__c+'\' ';
            //query += ' limit 1000';
            if(month!=null && year!=null){
                Date dt = Date.newInstance(year,month,Date.DaysInMonth(year,month));
                query += ' and Expected_Invoice_Date__c<=:dt';
                query += ' and Calendar_Month(Expected_Invoice_Date__c)=:month';
            }
            
            if(billingType!=null){
                query += ' and Billing_Type__c=:billingType';
            }
            
            query += ' order by createddate asc';
            for(Rent_Roll__c rr:database.query(query)){
                if(rr.Invoices__r.size()>0){
                    rentRollList.add(rr);
                }
            }
            if(rentRollList.size() < 1){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Rent Roll not found.'));
                error = true;
            }
        }
    }
    
    public void selectRentRoll(){
        invoiceList = new List<Invoice__c>();
        if(selRentRollId!=null){
            for(rent_Roll__c rr:rentRollList){
                if(rr.Id==selRentRollId){
                    rentRoll = rr;
                    fetchRentRollPDF();
                    rentRoll.Actual_Invoice_Date__c = rr.Expected_Invoice_Date__c;
                    showInvoice = true;
                    invoiceList = rentRoll.Invoices__r;
                    for(Invoice__c inv:invoiceList){
                        EmailCheckMap.put(inv.Id,false);
                    }
                    fetchInvoiceAttachmentPDF();
                    break;
                }
            }
        }
    }
    
    public void back(){
        InvoiceList = new List<Invoice__c>();
        //rentRoll = new Rent_Roll__c();
        showInvoice = false;
        attachId = null;
        error=false;
    }
    
    public void fetchRentRollPDF(){
        List<Attachment> attachList = [Select id from Attachment where parentId =:rentRoll.Id limit 1];
        if(attachList.size()>0){
            attachId = attachList[0].Id;
        }
    }
    
    public void fetchInvoiceAttachmentPDF(){
        if(attachId == null){
             fetchRentRollPDF();
        }
        invoicePDFAttMap = new Map<Id,string>();
        if(InvoiceList.size()>0){
            Set<Id> invIds = new Set<Id>();
            for(Invoice__c inv:invoiceList){
                invIds.add(inv.Id);
                invoicePDFAttMap.put(inv.Id,'');
                
            }
            if(invIds.size()>0){
                for(Attachment att:[Select id,parentId from Attachment where parentId in:invIds]){
                    invoicePDFAttMap.put(att.parentId,att.Id);
                }
            }
        }
    }
    
    public pageReference generateInvoice(){
        error = false;
        try{
            if(rentRoll.Id!=null){
                if(invoiceList.size()>0){
                    rentRoll.Invoices_Generated__c = true;
                    update rentRoll;
                    for(Invoice__c inv:invoiceList){
                        inv.Invoice_Generated__c = true;
                    }
                    update invoiceList;
                    generateInvoiceClicked = true;
                    return null;
                    //return new pageReference('/'+rentRoll.Id);
                }else{
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Invoice not found.'));
                    error = true;
                }
            }else{
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Rent Roll not found.'));
                error = true;
            }
        }catch(exception e){
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,e.getMessage()));
            error = true;
        }
        
        return null;
    }
    
    public void emailInvoice(){
        try{
            if(rentRoll.Id!=null){
                if(invoiceList.size()>0){
                    List<EmailTemplate> emailTemplates = [Select id from EmailTemplate where name='Invoice Notification'];
                    if(emailTemplates.size()>0){
                        Set<Id> invIds = new Set<Id>();
                        Integer selectedRows = 0;
                        Boolean allInvEmailed = true;
                        for(Invoice__c inv:invoiceList){
                            if(!inv.Invoice_Emailed__c && inv.Billing_Email__c!=null && EmailCheckMap.containsKey(inv.Id) && EmailCheckMap.get(inv.Id)){
                                invIds.add(inv.Id);
                                
                            }
                            if(!inv.Invoice_Emailed__c){
                                allInvEmailed =false;
                            }
                            if(EmailCheckMap.containsKey(inv.Id) && EmailCheckMap.get(inv.Id)){
                                selectedRows++;
                            }
                            
                        }
                        
                        if(allInvEmailed){
                            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Info,'Invoice(s) already emailed.'));
                            error = true;
                            return ;
                        }
                        errorMsg = '';
                        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                        if(invIds.size()>0){
                            Map<Id,Attachment> attachMap = new Map<Id,Attachment>();
                            List<Attachment> attachList = [Select id,parentId,Name,Body from Attachment where parentId in:invIds];
                            for(Attachment att:attachList){
                                attachMap.put(att.parentId,att);
                            }
                            
                            system.debug('invIds ==>'+invIds);
                            system.debug('attachMap ==> ' + attachMap);
                            
                            Contact con = new Contact();
                            con.email = 'Test@gmail.com';
                            con.lastName = 'Test';
                            insert con;
                            
                            List<TaskWrapper> tskWrapList = new List<TaskWrapper>();
                            for(Invoice__c inv:invoiceList){
                                if(invIds.contains(inv.Id) && attachMap.containsKey(inv.Id)){
                                    List<string> addresses = new List<String>();
                                    addresses.add(inv.Billing_Email__c);
                                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage ();
                                    email.setTemplateId(emailTemplates[0].Id);
                                    email.setSaveAsActivity(false);
                                    email.setToAddresses(addresses);
                                    email.setTargetObjectId(con.Id);
                                    email.setWhatId(inv.Id);
                                    email.setTreatTargetObjectAsRecipient(false);
                                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                                    efa.setFileName(attachMap.get(inv.Id).Name);
                                    efa.setBody(attachMap.get(inv.Id).Body);
                                    fileAttachments.add(efa);
                                    email.setFileAttachments(fileAttachments);
                                    emails.add(email);
                                    inv.Invoice_Emailed__c = true;
                                    
                                    TaskWrapper tskWrap = new TaskWrapper();
                                    tskWrap.email = email;
                                    tskWrap.tsk.whatId = inv.Id;
                                    
                                    tskWrap.att.Name = attachMap.get(inv.Id).Name;
                                    tskWrap.att.Body = attachMap.get(inv.Id).Body;
                                    
                                    tskWrapList.add(tskWrap);
                                }
                            }
                            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
                            delete con;
                            update invoiceList;
                            rentRoll.Invoices_Emailed__c = true;
                            update rentRoll;
                            List<Task> taskList = new List<Task>();
                            if(tskWrapList.size()>0){
                                for(TaskWrapper tskWrap:tskWrapList){
                                    tskWrap.tsk.Description = tskWrap.email.getPlainTextBody();
                                    tskWrap.tsk.status = 'Completed';
                                    tskWrap.tsk.Subject = tskWrap.email.subject;
                                    taskList.add(tskWrap.tsk);
                                }
                                insert taskList;
                                
                                List<Attachment> attList = new List<Attachment>();
                                for(TaskWrapper tskWrap:tskWrapList){
                                    if(tskWrap.tsk.Id!=null){
                                        tskWrap.att.parentId = tskWrap.tsk.Id;
                                        attList.add(tskWrap.att);
                                    }
                                }
                                insert attList;
                            }
                            
                            if(emails.size() > 0){
                                errorMsg = emails.size()+' email(s) sent out of  '+selectedRows+'. ';                                
                            }
                            
                            //Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Info,emails.size()+' email(s) sent out of '+invIds.size()+'.'));
                        }
                        String errorMsg1 ='';
                        if(selectedRows == 0){
                            errorMsg1 += 'Please select at least one invoice to send email.';
                        }else if(emails.size() == 0 ){
                            errorMsg1 += 'Please generate Invoice PDF and update Billing Email before sending email.';
                        }else if(emails.size() != selectedRows){
                            //errorMsg1 += 'Please generate Invoice PDF and update Billing Email before sending email';
                            errorMsg1 = emails.size()+' email(s) sent out of  '+selectedRows+'. ';   
                        }
                        
                        if( errorMsg != ''){
                        Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Info,errorMsg+''));
                        error = true;
                        }
                        
                        if( errorMsg1 != ''){
                        Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Info,errorMsg1+''));
                        error = true;
                        }
                        
                    }else{
                        Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Email Template not found. Please contact Your Administrator.'));
                        error = true;
                    }
                }else{
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Invoice not found.'));
                    error = true;
                }
            }else{
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Rent Roll not found.'));
                error = true;
            }
        }catch(exception e){
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,e.getMessage()));
            error = true;
        }
    }
    
    public class TaskWrapper{
        public Task tsk{get;set;}
        public Attachment att{get;set;}
        public Messaging.SingleEmailMessage email{get;set;}
        public TaskWrapper(){
            tsk = new Task();
            att = new Attachment();
            email = new Messaging.SingleEmailMessage ();
        }
    }
}