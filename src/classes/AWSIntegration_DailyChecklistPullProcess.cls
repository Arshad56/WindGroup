/*
Description  : This class is created to prepare the Daily Checklist Pull request by callout to AWS system and 
update the information based on Dates
Date created : 09th Feb 2016 
*/
public class AWSIntegration_DailyChecklistPullProcess implements Schedulable 
{
    public void execute(SchedulableContext SC) 
    {
        processPull(AWSIntegration_TestClass_New.isTestRunning);
    }
    @future(callout=true)
    public static void processPull(Boolean isTestRunning)
    {
        Utility.lastUpdatedFromAwsIntegration='iOPS';
        Map<String,String> dailyChecklistMap = new Map<String,String>();
        Integration_AWS_Log__c logRec= new Integration_AWS_Log__c();
        String responseString='';
        String ErrorMessage='';
        try{
            String AWSAccessToken = AWSIntegration_IntegrationHelper.getAccessToken(isTestRunning,'');
            Http h2 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setHeader('Authorization','Bearer '+AWSAccessToken);
            req1.setHeader('Content-Type','application/json');
            // req1.setBody(jsonstr);
            req1.setMethod('GET');
            req1.setTimeout(90000); // timeout in milliseconds - this is one minute
            String fromDate='',toDate='';
            String PullEndPoint='http://13.228.56.148/api/pulldailychecktransaction';
            for(AWS_Credentials__c awsRec : AWS_Credentials__c.getAll().Values())
            {
                DateTime dt =System.now().addMinutes(-30);
                if(awsRec.Last_Daily_Checklist_Pull_Start_Datetime__c!=null)
                    dt=awsRec.Last_Daily_Checklist_Pull_Start_Datetime__c;
                
                if(dt!=null)
                {
                    String Month='',day='';
                    if(dt.Month()>9)
                        Month=dt.Month()+'';
                    else
                        Month='0'+dt.Month();
                    
                    if(dt.Day()>9)
                        day=dt.Day()+'';
                    else
                        day='0'+dt.Day();
                    fromDate=''+dt.Year()+'-'+Month+'-'+day+'%20'+dt.Hour()+':'+dt.Minute()+':00';
                } 
                dt =System.now();
                if(awsRec.Last_Daily_Checklist_Pull_End_Datetime__c!=null)
                    dt=awsRec.Last_Daily_Checklist_Pull_End_Datetime__c;
                if(dt>System.now())
                    dt=System.now();
                if(dt!=null)
                {
                    String Month='',day='';
                    if(dt.Month()>9)
                        Month=dt.Month()+'';
                    else
                        Month='0'+dt.Month();
                    
                    if(dt.Day()>9)
                        day=dt.Day()+'';
                    else
                        day='0'+dt.Day();
                    toDate=''+dt.Year()+'-'+Month+'-'+day+'%20'+dt.Hour()+':'+dt.Minute()+':00';  
                }
                
                if(awsRec.Daily_Checklist_EndPoint__c!=null)
                    PullEndPoint=awsRec.Daily_Checklist_EndPoint__c;
            }
          
            req1.setEndpoint(PullEndPoint+'/'+fromDate+'/'+toDate);
            req1.setTimeout(90000); // timeout in milliseconds - this is one minute
            
            HttpResponse res1 =null;
            if(isTestRunning==false)
                res1 = h2.send(req1);
            else
            {
                String cmID=[Select Id from Checklist_Master__c LIMIT 1].Id;
                String dcId=[Select Id from Daily_Checklist__c LIMIT 1].Id;
                
                res1 = new HttpResponse();
                res1.setHeader('Content-Type', 'application/json');
                res1.setBody('{"daily_checklist":[{"aws_id":"0000","target_date":"2017-01-01","description":"TEST","checklist_master_id":"'+cmID+'","percentage_completed": "70%"},{"id":"'+dcId+'","target_date":"2017-01-01","description":"TEST2","percentage_completed": "70%"}]}');
                res1.setStatusCode(200);
            }
            
            logRec.Target_URL__c=PullEndPoint+'/'+fromDate+'/'+toDate;
            logRec.Integration_Call_Type__c='Daily Checklist Pull';
            if(res1.getBody().length()>1000)
                logRec.Response_String__c=res1.getBody().subString(0,1000);
            else
                logRec.Response_String__c=res1.getBody();
            for(AWS_Credentials__c awsRec : [Select Id,Last_Daily_Checklist_Pull_Start_Datetime__c,Last_Daily_Checklist_Pull_End_Datetime__c,Push_EndPoint__c from AWS_Credentials__c Limit 1])
            {
                logRec.Last_Synch_Datetime_Criteria__c=awsRec.Last_Daily_Checklist_Pull_Start_Datetime__c;
                if(res1.getBody().contains('Exception'))
                    logRec.Status__c='Exception';
                else
                {
                    logRec.Status__c='Success';          
                }    
            }
            responseString=res1.getBody();
            JSONParser jsonParser= JSON.createParser(res1.getBody());
            
            System.JSONToken token;
            string text;
            Map<String,String> objectNameMap = new Map<String,String>();
            Map<String,String> fieldNameMap = new Map<String,String>();
            for(Daily_Checklist_Object_Mapping__c objMapRec : Daily_Checklist_Object_Mapping__c.getAll().values())
            {
                if(objMapRec.AWS_Object_Label__c!=null)
                {
                    objectNameMap.put(objMapRec.AWS_Object_Label__c,objMapRec.Salesforce_Object_Name__c);
                    fieldNameMap.put(objMapRec.Salesforce_Object_Name__c+'-'+objMapRec.AWS_Field_Label__c,objMapRec.Salesforce_Field__c);
                }
            }
            List<Sobject> sobjectList = new List<Sobject>();
            
            String fieldName='';
            String fieldAPIName='';
            TimeZone tz = UserInfo.getTimeZone();
            try{
                while((token = jsonParser.nextToken()) != null)
                {
                    if(jsonParser.getCurrentToken() == JSONToken.START_OBJECT)
                    {
                        system.debug('1 --> jsonParser.getCurrentToken():'+jsonParser.getCurrentToken());
                        system.debug('1 --> jsonParser.getText():'+jsonParser.getText());
                        
                        while(jsonParser.nextToken() != JSONToken.END_OBJECT)
                        {
                            if(jsonParser.getCurrentToken() == JSONToken.START_ARRAY )
                            {

                                String SobjApiName=jsonParser.getCurrentName();
                                System.debug('1 --> jsonParser.getCurrentName():'+ jsonParser.getCurrentName());
                                if(SobjApiName!='' && SobjApiName!=null && objectNameMap.get(SobjApiName)!=null)
                                {
                                    SobjApiName=objectNameMap.get(SobjApiName);
                                    String SobjApiNameLower = SobjApiName.ToLowerCase();
 
                                    Type sObjectListType = Type.ForName('List<'+SobjApiName+'>');
                                    List<SObject> sobjectInsertList = (List<SObject>) sObjectListType.newInstance();
                                    
                                    //  List<Sobject> sobjectInsertList = new List<Sobject>();
                                    Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe(); 
                                    Schema.sObjectType sObjType = globalDescription.get(SobjApiName); 
                                    Schema.DescribeSObjectResult res = sObjType.getDescribe(); 
                                    Map<String , Schema.SObjectField> mapFieldList = res.fields.getMap();                                    
                                    while(jsonParser.nextToken() != JSONToken.END_ARRAY)
                                    {
                                        
                                        if(jsonParser.getCurrentToken() == JSONToken.START_OBJECT)
                                        {
                                            Sobject objRec = Schema.getGlobalDescribe().get(SobjApiName).newSObject();

                                            while(jsonParser.nextToken() != JSONToken.END_OBJECT)
                                            {
                                                
                                                if(jsonParser.getCurrentToken()==JSONToken.FIELD_NAME)
                                                {
                                                    
                                                    fieldName=SobjApiName+'-'+jsonParser.getText();
                                                    system.debug('7 -->:'+fieldName);
                                                    if(jsonParser.nextToken()==JSONToken.VALUE_STRING)
                                                    {
                                                        system.debug('8 -->:'+fieldName);
                                                        system.debug('6 --> '+fieldName+' --'+fieldNameMap.get(fieldName));
                                                        
                                                        if(fieldNameMap.get(fieldName)!=null)
                                                        {
                                                            fieldAPIName=fieldNameMap.get(fieldName);
                                                            fieldAPIName=fieldAPIName.toLowerCase();
                                                            Schema.DisplayType fielddataType = mapFieldList.get(fieldAPIName).getDescribe().getType();
                                                            system.debug('5 --> '+fieldName);
                                                            if(fieldName=='aws_id__c')
                                                            {
                                                                system.debug('AWS ID Issue:'+fieldAPIName);
                                                                system.debug('AWS ID Issue updatable:'+mapFieldList.get(fieldAPIName).getDescribe().isUpdateable());
                                                            }
                                                            if(mapFieldList.get(fieldAPIName).getDescribe().isUpdateable() || fieldAPIName=='id' || (fielddataType == Schema.DisplayType.Reference && (fieldAPIName=='checklist_item__c' || fieldAPIName=='checklist_master__c' || fieldAPIName=='daily_checklist__c'))) 
                                                            {
                                                                
                                                                if(fieldAPIName!='id')
                                                                {
                                                                    system.debug('fielddataType:'+fielddataType);
                                                                    system.debug('jsonParser.getText():'+jsonParser.getText());
                                                                    
                                                                    if(fielddataType == Schema.DisplayType.Percent)
                                                                    {
                                                                        String percentageValue=jsonParser.getText();
                                                                        if(percentageValue.contains('%'))
                                                                            percentageValue=percentageValue.replaceall('%','');
                                                                        objRec.put(fieldAPIName, Decimal.Valueof(percentageValue));
                                                                    }
                                                                    else if(fielddataType == Schema.DisplayType.DateTime)
                                                                    {
                                                                        String dt=jsonParser.getText();
                                                                        Datetime dtime =Datetime.newinstance(Integer.valueof(dt.substring(0,4)),Integer.valueof(dt.substring(5,7)),Integer.valueof(dt.substring(8,10)),Integer.valueof(dt.substring(11,13)),Integer.valueof(dt.substring(14,16)),Integer.valueof(dt.substring(17,19)));
                                                                        objRec.put(fieldAPIName,dtime);
                                                                    }
                                                                    else if(fielddataType == Schema.DisplayType.Double)
                                                                    {
                                                                        objRec.put(fieldAPIName, Double.Valueof(jsonParser.getText()));
                                                                    }
                                                                    else if(fielddataType == Schema.DisplayType.Date)
                                                                    {
                                                                        String dt=jsonParser.getText();
                                                                        Date dtVal =Date.newinstance(Integer.valueof(dt.substring(0,4)),Integer.valueof(dt.substring(5,7)),Integer.valueof(dt.substring(8,10)));
                                                                        objRec.put(fieldAPIName,dtVal);
                                                                    }
                                                                    else if(fielddataType != Schema.DisplayType.Boolean)
                                                                    {
                                                                        objRec.put(fieldAPIName, jsonParser.getText());
                                                                        if(fieldName=='aws_id__c')
                                                                            system.debug('AWS Id Issue Value Check:'+jsonParser.getText());
                                                                    }
                                                                    else
                                                                    {
                                                                        if(jsonParser.getText()=='false')
                                                                            objRec.put(fieldAPIName, false);
                                                                        else 
                                                                            objRec.put(fieldAPIName, true);
                                                                    }
                                                                } 
                                                                else if(jsonParser.getText()!=null && jsonParser.getText()!='')
                                                                {
                                                                    objRec.put(fieldAPIName, jsonParser.getText());
                                                                }
                                                            }
                                                        }
                                                    }
                                                    else
                                                    {
                                                        system.debug('8 -->:'+fieldName);
                                                        system.debug('6 --> '+fieldName+' --'+fieldNameMap.get(fieldName));
                                                        
                                                        if(fieldNameMap.get(fieldName)!=null)
                                                        {
                                                            fieldAPIName=fieldNameMap.get(fieldName);
                                                            fieldAPIName=fieldAPIName.toLowerCase();
                                                            Schema.DisplayType fielddataType = mapFieldList.get(fieldAPIName).getDescribe().getType();
                                                            system.debug('5 --> '+fieldName);

                                                            if(mapFieldList.get(fieldAPIName).getDescribe().isUpdateable() && fielddataType == Schema.DisplayType.String)
                                                            {
                                                                system.debug('9-->fieldAPIName'+fieldAPIName);
                                                                if(jsonParser.getText()!=null && jsonParser.getText()!='')
                                                                {
                                                                    objRec.put(fieldAPIName, jsonParser.getText());
                                                                    system.debug('10-->'+jsonParser.getText());
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            if(SobjApiNameLower=='daily_checklist_item__c')
                                            {
                                                daily_checklist_item__c tempRec2 = (daily_checklist_item__c) objRec;
                                                if(tempRec2.daily_checklist_aws_id__c!=null)
                                                    if(dailychecklistMap.get(tempRec2.daily_checklist_aws_id__c)!=null)
                                                {
                                                    objRec.put('Daily_Checklist__c', dailychecklistMap.get(tempRec2.daily_checklist_aws_id__c));
                                                }  
                                            }
                                            
                                            if(objRec!=null && objRec.Id!=null)
                                                sobjectList.add(objRec);
                                            else
                                                sobjectInsertList.add(objRec);
                                            
                                        }
                                    }
                                    list<Database.upsertResult> upsertresult =null;
                                    if(sobjectInsertList.size()>0)
                                    {
                                        Schema.SObjectField f =null;
                                        if(SobjApiNameLower=='daily_checklist__c')
                                            f = Daily_Checklist__c.Fields.AWS_Id__c;
                                        else if(SobjApiNameLower=='daily_checklist_item__c')
                                        {
                                            f = Daily_Checklist_item__c.Fields.AWS_Id__c;
                                        }
                                        else if(SobjApiNameLower=='checklist_remarks__c')
                                        {
                                            f = Checklist_Remarks__c.Fields.AWS_Id__c;
                                        }
                                        upsertresult = Database.upsert(sobjectInsertList,f);
                                        
                                        for ( Integer i = 0; i < upsertresult.size(); i++ ) 
                                        {
                                            if ( !upsertresult.get(i).isSuccess() ) 
                                            {
                                                for ( Database.Error theError : upsertresult.get(i).getErrors())
                                                    if(!theError.getMessage().contains('This is record stopped to update to avoid overriding of Salesforce latest updates by iOPS'))
                                                    if(ErrorMessage.length()<1000)
                                                    ErrorMessage=ErrorMessage+'-- Record Id:'+upsertresult[i].id+'==>'+theError.getMessage();
                                            }
                                            else if(SobjApiNameLower=='daily_checklist__c')
                                            {
                                                daily_checklist__c recTemp =(daily_checklist__c) sobjectInsertList[i];
                                                dailychecklistMap.put(recTemp.AWS_ID__c,recTemp.Id);
                                            }
                                        } 
  
                                    }
                                    
                                } 
                            }
                        }
                    }             
                }   
                list<Database.SaveResult> results =null;
                
                if(sobjectList.size()>0)
                {
                    results = Database.update(sobjectList,false);
                    for ( Integer i = 0; i < results.size(); i++ ) 
                    {
                        if ( !results.get(i).isSuccess() ) 
                        {
                            for ( Database.Error theError : results.get(i).getErrors() )
                            {
                                if(!theError.getMessage().contains('This is record stopped to update to avoid overriding of Salesforce latest updates by iOPS'))
                                    ErrorMessage=ErrorMessage+'-- Record Id:'+results[i].id+'==>'+theError.getMessage();
                                
                            }    
                        }
                    }     
                }

                if(ErrorMessage!='')
                {
                    logRec.Status__c='Salesforce Exception';
                    logRec.Response_String__c=logRec.Response_String__c+'--->Salesforce Exception:'+ErrorMessage;
                }
                else
                {
                    for(AWS_Credentials__c awsRec : [Select Id,Last_Daily_Checklist_Pull_Start_Datetime__c,Last_Daily_Checklist_Pull_End_Datetime__c,Push_EndPoint__c from AWS_Credentials__c Limit 1])
                    {
                        if(awsRec.Last_Daily_Checklist_Pull_End_Datetime__c==null)
                            awsRec.Last_Daily_Checklist_Pull_Start_Datetime__c=System.now();
                        else
                        {
                            awsRec.Last_Daily_Checklist_Pull_Start_Datetime__c=awsRec.Last_Daily_Checklist_Pull_End_Datetime__c;
                            awsRec.Last_Daily_Checklist_Pull_End_Datetime__c=awsRec.Last_Daily_Checklist_Pull_End_Datetime__c.addHours(15);
                        }
                        update awsRec;
                    }
                }
            }catch(Exception e)
            {
                System.debug('Exception:'+e.getMessage());
                logRec.Status__c='Salesforce Exception';
                logRec.Response_String__c=logRec.Response_String__c+'--->Salesforce Exception'+e.getMessage()+'--'+e.getStackTraceString();
            }
            if(system.label.Create_Pull_Log=='TRUE')
                insert logRec;    
            //system.debug(res1.getBody());
        }catch(Exception e)
        {
            System.debug('Exception:'+e.getMessage());
            System.debug('Exception:'+e.getLinenumber());
        }
        if(logRec!=null && logRec.id!=null)
        {
            Attachment attachment = new Attachment();
            attachment.Body = Blob.valueOf(responseString);
            attachment.Name = String.valueOf('Daily Checklist Pull Jason String.txt');
            attachment.ParentId = logRec.id; 
            insert attachment;
        }
    }
}