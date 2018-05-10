public class HRISOnOffboardingStep1Extension {
    
    public List<Personnel_Action__c> onoffboardingList {get;set;}
    public List <Employee_Checklist__c> employeeChecklist{get;set;}
    public String headerValue {get;set;}
    public Personnel_Action__c pa {get;set;}
    
    public HRISOnOffboardingStep1Extension (ApexPages.standardController std) { 
        
        this.pa = (Personnel_Action__c) std.getRecord();
        pa = this.pa;
        pa.Property__c ='a1O7F000000MWxk';
        employeeChecklist = new List <Employee_Checklist__c>();
        employeeChecklist = HRISUtil.getHireChecklistbyId(this.pa.Id);
        
    }
    
    public void searchOffboard(){
        search(HRISUtil.HRIS_Offboard);
    }
    
    public void searchOnboard(){
        search(HRISUtil.HRIS_Onboard);
    }
    
    public void sendNotification(){
        sendEmail();
        pa.Notified__c = true;
        upsert pa;
        
    }
    
    public PageReference cancelOffboard(){
        PageReference MyNewPage = new PageReference('/apex/HRISOffboardingStep1');          
        MyNewPage.setRedirect(true);
        return MyNewPage;
    }
    
    public PageReference cancelOnboard(){
        PageReference MyNewPage = new PageReference('/apex/HRISOnboardingStep1');          
        MyNewPage.setRedirect(true);
        return MyNewPage;
    }
    
    public PageReference updateChecklistOnboard(){
        upsert employeeChecklist;
        
        List <Course_Registration__c> courserRegistrationList = new List <Course_Registration__c>();
        
        for(Employee_Checklist__c ec : employeeChecklist){
            if(ec.S_N__c == 17 && ec.Completed__c == true){
                Course_Registration__c cr = new Course_Registration__c();
                cr.Contact__c = pa.Employee__c;
                cr.Course__c = [Select Id from Course__c where Name__c = 'New Colleagues Orientation'].Id;
                cr.Course_Date__c = System.today();
                cr.Type__c ='New';
                courserRegistrationList.add(cr);
                
                cr = new Course_Registration__c();
                cr.Contact__c = pa.Employee__c;
                cr.Course__c = [Select Id from Course__c where Name__c = 'Fire Life Safety'].Id;
                cr.Course_Date__c = System.today();
                cr.Type__c ='New';
                courserRegistrationList.add(cr);
                
                cr = new Course_Registration__c();
                cr.Contact__c = pa.Employee__c;
                cr.Course__c = [Select Id from Course__c where Name__c = 'Security'].Id;
                cr.Course_Date__c = System.today();
                cr.Type__c ='New';
                courserRegistrationList.add(cr);
            }
            
            if(ec.S_N__c == 18 && ec.Completed__c == true){
                sendWelcomeEmail();
            }
        }
        
        upsert courserRegistrationList;
        
        return HRISUtil.getMyNewPage('HRISOnboarding', this.pa.Id);
    }
    
    public PageReference updateChecklistOffboard(){
        upsert employeeChecklist;
        
        return HRISUtil.getMyNewPage('HRISOffboarding', this.pa.Id);
    }
    
    public void sendWelcomeEmail(){
        
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] ccAddresses = new String[] {'seowhooi.tan@shangri-la.com'};
      
        mail.setToAddresses(ccAddresses);
        //mail.setCcAddresses(ccAddresses);
        mail.setReplyTo('tan.seowhooi@wind.com.sg');
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('Level 1 Announcement - South East Asia, North Asia, Philippines & Pacific Regions');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody('Dear Colleagues, <br/><br/>' +
                         'Please join us in extending a warm welcome to our new joiners and congratulating our colleagues on their new appointments.<br/><br/><br/>'+
                         'Employee Name: ' +pa.Employee__c+'<br/>'+
                         'Property: ' + pa.Property__c  +'<br/>'+
                         'Division: ' + pa.Division__c +'<br/>'+
                         'Deparment: ' + pa.Department__c +'<br/>'+
                         'Position: ' + pa.Position__c +'<br/>'+
                         'Job Level: ' + pa.Job_Level__c +'<br/>'+
                         'Date Join: ' + pa.Date_of_Join__c +'<br/><br/>'+
                         'Regards. <br/> Vice President - Human Resource <br/> <b>Shangri-La International Hotel Management</b> <br/> 22 Orange Grove Road Singapore 258350 <br/> +65 6213 4929 www.shangri-la.com');
        
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        
    }
    
    public void sendEmail(){
        
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] ccAddresses = new String[] {'seowhooi.tan@shangri-la.com'};
      
        mail.setToAddresses(ccAddresses);
        //mail.setCcAddresses(ccAddresses);
        mail.setReplyTo('tan.seowhooi@wind.com.sg');
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('Employee On-boarding Checklist: '+ pa.Name);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody('Dear Team, <br/><br/> Pending employee checklist task for your action. <br/> Please see details below: <br/><br/>' +
                         'Employee Checklist No: <b>' + pa.Name +'</b> <br/>'+
                         'Employee Name: ' +pa.Employee__c+'<br/>'+
                         'Property: ' + pa.Property__c  +'<br/>'+
                         'Division: ' + pa.Division__c +'<br/>'+
                         'Deparment: ' + pa.Department__c +'<br/>'+
                         'Position: ' + pa.Position__c +'<br/>'+
                         'Job Level: ' + pa.Job_Level__c +'<br/>'+
                         'Date Join: ' + pa.Date_of_Join__c +'<br/><br/>'+
                         'Instruction: <br/>'+
                         '=============================================================================<br/>'+
                         'Please click on <a href=https://sglfull-servicecloudtrial-155c0807bf-15aec281bbf.cs72.force.com/HRISEmployeeChecklist?id='+this.pa.Id+'>View</a> to update employee checklist item status. <br/><br/>'+
                         'Thank you. <br/> System Admin <br/> <b>Futian Shangri-La, Shenzhen</b> <br/> 4088 Yi Tian Road, Futian District, Shenzhen, Guangdong Province, China <br/> +86 755 8828 4088 www.shangri-la.com/futian/');
        
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        
    }
    
    private static String [] getEmail (Map<Id,Id> emailteamId){
        
        String [] email = new String[]{};
            Map<String,String> emailMap = new Map<String,String>();   
        
        List <Team_Member__c> teammemberList = [Select email__c from Team_Member__c where team__c in :emailteamId.keySet()];
        for(Team_Member__c tm : teammemberList){
            emailMap.put(tm.email__c, tm.email__c);
        }
        email.addAll(emailMap.keySet());
        return email;
    }
    
    
    private void search(String type){
       headerValue = '';
       onoffboardingList = new List<Personnel_Action__c>();
        
       String query = 'Select Id, Name, Property__c, Requisition_No__c,Employee__c, Employee_No__c from Personnel_Action__c where Property__c=\''+pa.Property__c+'\'';
        
       //if(pa.Requisition_No__c != null)
           //query = query + ' and Requisition_No__c=\''+pa.Requisition_No__c+'\'';
       if(pa.Employee__c != null)
           query = query + ' and Employee__c=\''+pa.Employee__c+'\'';
       if(pa.Employee_No__c != null && !''.equals(pa.Employee_No__c))
           query = query + ' and Employee_No__c=\''+pa.Employee_No__c+'\'';
        
       query = query + ' and Approval_Status__c =\''+HRISUtil.HRIS_Approval_Approved+'\'';
        
       if(type == HRISUtil.HRIS_Onboard)
       		query = query + ' and Checklist_Type__c =\''+ HRISUtil.HRIS_Onboard + '\'';
       else if (type == HRISUtil.HRIS_Offboard)
            query = query + ' and Checklist_Type__c =\''+ HRISUtil.HRIS_Offboard +'\'';
        
       List<Personnel_Action__c> obdinglist = Database.query(query);
      
        if(obdinglist.isEmpty()){
           if(type == HRISUtil.HRIS_Onboard)
       			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No on-boarding record.'));
       	   else if (type == HRISUtil.HRIS_Offboard)
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No off-boarding record.'));
           
        }else{
           if(type == HRISUtil.HRIS_Onboard)
       		   headerValue = 'On-boarding No';
       	   else if (type == HRISUtil.HRIS_Offboard)
               headerValue = 'Off-boarding No';
           onoffboardingList = obdinglist;
       }
   }

}