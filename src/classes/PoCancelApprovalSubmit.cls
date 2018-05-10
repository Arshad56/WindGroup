global class PoCancelApprovalSubmit{
    WebService static void cancelPo(String poId){
        if(poId != NULL){
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for cancellation');
            req.setObjectId(poId);
            Id currentUserId = userInfo.getProfileId();
            req.setSubmitterId(currentUserId);
            
            
            
        }
    }
}