public class AWSIntegrationVFController
{
    public string message{get;set;}
    public string logName{get;set;}
    public string logURL{get;set;}
    public Datetime startDatetime{get;set;}
    public Datetime EndDatetime{get;set;}
    public String endPointURL{get;set;}
    public AWS_Credentials__c awsCredRec{get;set;}
    public AWS_Credentials__c TempawsCredRec{get;set;}
    public String actionType{get;set;}
    
    public void AWSIntegrationVFController()
    {       
        awsCredRec = new AWS_Credentials__c();
        TempawsCredRec= new AWS_Credentials__c();
        actionType='Push Setup';

    }
    
    public pagereference assignDateTime()
    {
        if(TempawsCredRec==null)
        TempawsCredRec= new AWS_Credentials__c();
        
        if(awsCredRec==null)
        awsCredRec = [Select PUSH_Setup_EndPoint__c,PUSH_Setup_EndDateTime__c,PUSH_Setup_StartDateTime__c,PUSH_Transaction_EndDateTime__c,PUSH_Transaction_Endpoint__c,PUSH_Transaction_StartDateTime__c,PULL_FeedbackTransaction_EndPoint__c,
                    PULL_FeedbackTransaction_EndDateTime__c,PULL_FeedbackTransaction_StartDateTime__c,PULL_TOHOTransaction_Endpoint__c,PULL_TOHOTransaction_EndDateTime__c,PULL_TOHOTransaction_StartDateTime__c,PULL_Toilet_Feedback_End_Datetime__c,
                    PULL_Toilet_Feedback_EndPoint__c,PULL_Toilet_Feedback_Start_Datetime__c,Last_Daily_Checklist_Pull_End_Datetime__c,Last_Daily_Checklist_Pull_Start_Datetime__c,Daily_Checklist_EndPoint__c,PUSH_ReqTask_EndDateTime__c,PUSH_ReqTask_Endpoint__c,PUSH_ReqTask_StartDateTime__c,PULL_ReqTask_StartDateTime__c,PULL_ReqTask_EndDateTime__c,PULL_ReqTask_Endpoint__c  from AWS_Credentials__c where Name = 'AWS' LIMIT 1];

     
        if(actionType=='Push Setup')
        {
            TempawsCredRec.PUSH_Setup_StartDateTime__c=awsCredRec.PUSH_Setup_StartDateTime__c;
            TempawsCredRec.PUSH_Setup_EndDateTime__c=awsCredRec.PUSH_Setup_EndDateTime__c;
            endPointURL=awsCredRec.PUSH_Setup_EndPoint__c;
        }
        else if(actionType=='Push Transaction')
        {
            TempawsCredRec.PUSH_Setup_StartDateTime__c=awsCredRec.PUSH_Transaction_StartDateTime__c;
            TempawsCredRec.PUSH_Setup_EndDateTime__c=awsCredRec.PUSH_Transaction_EndDateTime__c;
            endPointURL=awsCredRec.PUSH_Transaction_Endpoint__c;
        }
        else if(actionType=='Push Request')
        {
            TempawsCredRec.PUSH_Setup_StartDateTime__c=awsCredRec.PUSH_ReqTask_StartDateTime__c;
            TempawsCredRec.PUSH_Setup_EndDateTime__c=awsCredRec.PUSH_ReqTask_EndDateTime__c;
            endPointURL=awsCredRec.PUSH_ReqTask_Endpoint__c;
        }     
        else if(actionType=='Pull HOTO')
        {
            TempawsCredRec.PUSH_Setup_StartDateTime__c=awsCredRec.PULL_TOHOTransaction_StartDateTime__c;
            TempawsCredRec.PUSH_Setup_EndDateTime__c=awsCredRec.PULL_TOHOTransaction_EndDateTime__c;
            endPointURL=awsCredRec.PULL_TOHOTransaction_Endpoint__c;
        }
        else if(actionType=='Pull Daily Checklist')
        {
            TempawsCredRec.PUSH_Setup_StartDateTime__c=awsCredRec.Last_Daily_Checklist_Pull_Start_Datetime__c;
            TempawsCredRec.PUSH_Setup_EndDateTime__c=awsCredRec.Last_Daily_Checklist_Pull_End_Datetime__c;
            endPointURL=awsCredRec.Daily_Checklist_EndPoint__c;
        }
        else if(actionType=='Pull Toilet Feedback')
        {
            TempawsCredRec.PUSH_Setup_StartDateTime__c=awsCredRec.PULL_Toilet_Feedback_Start_Datetime__c;
            TempawsCredRec.PUSH_Setup_EndDateTime__c=awsCredRec.PULL_Toilet_Feedback_End_Datetime__c;
            endPointURL=awsCredRec.PULL_Toilet_Feedback_EndPoint__c;
        }
        else if(actionType=='Pull Request')
        {
            TempawsCredRec.PUSH_Setup_StartDateTime__c=awsCredRec.PULL_ReqTask_StartDateTime__c;
            TempawsCredRec.PUSH_Setup_EndDateTime__c=awsCredRec.PULL_ReqTask_EndDateTime__c;
            endPointURL=awsCredRec.PULL_ReqTask_Endpoint__c;
        }
        return null;
    }
    
    public pagereference queryDateandEndPoint()
    {
        if(TempawsCredRec==null)
        TempawsCredRec= new AWS_Credentials__c();
        if(awsCredRec==null)
        awsCredRec= new AWS_Credentials__c();
        for(AWS_Credentials__c awsRec : [Select PUSH_Setup_EndPoint__c,PUSH_Setup_EndDateTime__c,PUSH_Setup_StartDateTime__c,PUSH_Transaction_EndDateTime__c,PUSH_Transaction_Endpoint__c,PUSH_Transaction_StartDateTime__c,PUSH_POSInfo_StartDateTime__c,PUSH_POSInfo_EndDateTime__c,PUSH_POSInfo_Endpoint__c,PULL_FeedbackTransaction_EndPoint__c,
                    PULL_FeedbackTransaction_EndDateTime__c,PULL_FeedbackTransaction_StartDateTime__c,PULL_TOHOTransaction_Endpoint__c,PULL_TOHOTransaction_EndDateTime__c,PULL_TOHOTransaction_StartDateTime__c,PULL_Toilet_Feedback_End_Datetime__c,
                    PULL_Toilet_Feedback_EndPoint__c,PULL_Toilet_Feedback_Start_Datetime__c,Last_Daily_Checklist_Pull_End_Datetime__c,Last_Daily_Checklist_Pull_Start_Datetime__c,Daily_Checklist_EndPoint__c,PUSH_ReqTask_StartDateTime__c,PUSH_ReqTask_EndDateTime__c,PUSH_ReqTask_Endpoint__c,PULL_ReqTask_StartDateTime__c,PULL_ReqTask_EndDateTime__c,PULL_ReqTask_Endpoint__c from AWS_Credentials__c  where Name = 'AWS' LIMIT 1])
        {
            awsCredRec=awsRec;
            TempawsCredRec.PUSH_Setup_StartDateTime__c=awsRec.PUSH_Setup_StartDateTime__c;
            TempawsCredRec.PUSH_Setup_EndDateTime__c=awsRec.PUSH_Setup_EndDateTime__c;
            endPointURL=awsRec.PUSH_Setup_EndPoint__c;
        }
        return null;
    }
    
    public List<selectoption> getActionTypes()
    {
        List<selectoption> options = new List<selectoption>();
        options.add(new selectoption('Push Setup','Push Setup'));
        options.add(new selectoption('Push Transaction','Push Transaction'));
        options.add(new selectoption('Push Request','Push Request'));
        options.add(new selectoption('Pull HOTO','PullHOTO'));
        options.add(new selectoption('Pull Daily Checklist','Pull Daily Checklist'));
        options.add(new selectoption('Pull Toilet Feedback','Pull Toilet Feedback'));
        options.add(new selectoption('Pull Request','Pull Request'));
        return options;
    }
    public pagereference invokeAction()
    {
        if(actionType=='Push Setup')
        {
            awsCredRec.PUSH_Setup_StartDateTime__c=TempawsCredRec.PUSH_Setup_StartDateTime__c;
            awsCredRec.PUSH_Setup_EndDateTime__c=TempawsCredRec.PUSH_Setup_EndDateTime__c;
            awsCredRec.PUSH_Setup_EndPoint__c=endPointURL;
            update awsCredRec;
            
            AWSIntegration_PushSetup rec = new AWSIntegration_PushSetup();
            rec.execute(null);
        }
        else if(actionType=='Push Transaction')
        {
            awsCredRec.PUSH_Transaction_StartDateTime__c=TempawsCredRec.PUSH_Setup_StartDateTime__c;
            awsCredRec.PUSH_Transaction_EndDateTime__c=TempawsCredRec.PUSH_Setup_EndDateTime__c;
            awsCredRec.PUSH_Transaction_Endpoint__c=endPointURL;
            update awsCredRec;
            
            AWSIntegration_PushTransaction rec = new AWSIntegration_PushTransaction();
            rec.execute(null);
        }
        else if(actionType=='Push Request')
        {
            awsCredRec.PUSH_ReqTask_StartDateTime__c=TempawsCredRec.PUSH_Setup_StartDateTime__c;
            awsCredRec.PUSH_ReqTask_EndDateTime__c=TempawsCredRec.PUSH_Setup_EndDateTime__c;
            awsCredRec.PUSH_ReqTask_Endpoint__c=endPointURL;
            update awsCredRec;
            
            AWSIntegration_PushRequest rec = new AWSIntegration_PushRequest();
            rec.execute(null);
        }      
        else if(actionType=='Pull HOTO')
        {
            awsCredRec.PULL_TOHOTransaction_StartDateTime__c=TempawsCredRec.PUSH_Setup_StartDateTime__c;
            awsCredRec.PULL_TOHOTransaction_EndDateTime__c=TempawsCredRec.PUSH_Setup_EndDateTime__c;
            awsCredRec.PULL_TOHOTransaction_Endpoint__c=endPointURL;
            update awsCredRec;
            
            AWSIntegration_PullHOTOProcess rec = new AWSIntegration_PullHOTOProcess();
            rec.execute(null);
        }
        else if(actionType=='Pull Daily Checklist')
        {
            awsCredRec.Last_Daily_Checklist_Pull_Start_Datetime__c=TempawsCredRec.PUSH_Setup_StartDateTime__c;
            awsCredRec.Last_Daily_Checklist_Pull_End_Datetime__c=TempawsCredRec.PUSH_Setup_EndDateTime__c;
            awsCredRec.Daily_Checklist_EndPoint__c=endPointURL;
            update awsCredRec;
            
            AWSIntegration_DailyChecklistPullProcess rec = new AWSIntegration_DailyChecklistPullProcess();
            rec.execute(null);
        }
        else if(actionType=='Pull Toilet Feedback')
        {
            awsCredRec.PULL_Toilet_Feedback_Start_Datetime__c=TempawsCredRec.PUSH_Setup_StartDateTime__c;
            awsCredRec.PULL_Toilet_Feedback_End_Datetime__c=TempawsCredRec.PUSH_Setup_EndDateTime__c;
            awsCredRec.PULL_Toilet_Feedback_EndPoint__c=endPointURL;
            update awsCredRec;
            
            AWSIntegration_PullToiletFdbkProcess rec = new AWSIntegration_PullToiletFdbkProcess();
            rec.execute(null);
        }
        else if(actionType=='Pull Request')
        {
            awsCredRec.PULL_ReqTask_StartDateTime__c=TempawsCredRec.PUSH_Setup_StartDateTime__c;
            awsCredRec.PULL_ReqTask_EndDateTime__c=TempawsCredRec.PUSH_Setup_EndDateTime__c;
            awsCredRec.PULL_ReqTask_Endpoint__c=endPointURL;
            update awsCredRec;
            
            AWSIntegration_PullRequestProcess rec = new AWSIntegration_PullRequestProcess ();
            rec.execute(null);
        }
        for(Integration_AWS_Log__c logRec : [Select Id,Name from Integration_AWS_Log__c Order by CreatedDate Desc Limit 1])
        {
           logName=logRec.Name;
           logUrl='/'+logRec.Id; 
        }
        message='Action invoked successfully. Please check latest log record for more details';
        return null;
    }
}