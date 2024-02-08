global with sharing class CaseRestResource implements IRestResource {

    private static final String CASE_STATUS_NEW = 'New';

    /**
     * This implementation of the doPost() method 
     * Parses JSON from the request body and creates Cases in Salesforce
     * @return List of strings containing success/fail messages
     */
    public static List<String> doPost(RestRequest request) {

        //Get the request body
        String requestBody = request.requestBody.toString();

        //Deseralize the request JSON into a wrapper
        CaseRequest caseRequest = (CaseRequest) JSON.deserialize(requestBody, CaseRequest.class);

        //For each SingleCase, create a new Case record and add to a list
        List<Case> casesToInsert = new List<Case>();
        for(SingleCase theSingleCase : caseRequest.singleCaseList){
            casesToInsert.add(initCaseRecords(theSingleCase));
        }

        //Enforce object-level access and FLS
        casesToInsert = (List<Case>)Security.stripInaccessible(AccessType.CREATABLE, casesToInsert).getRecords();

        List<String> responseStringList = new List<String>();

        //Insert Cases, add success/failures to list for return
        List<Database.SaveResult> caseInsertResults = Database.insert(casesToInsert, false);
        for(Database.SaveResult theSaveResult: caseInsertResults){
            if(theSaveResult.isSuccess()){
                responseStringList.add('Case created successfully! Id = ' + theSaveResult.getId());
            }else{
                responseStringList.add('Case creation failed: ' + theSaveResult.getErrors());
            }
        }
        
        return responseStringList;
    }

    /**
     * Helper method to init Case record from SingleCase wrapper
     * @param singleCase - the SingleCase wrapper
     * @return instantiated Case
     */
    private static Case initCaseRecords(SingleCase theSingleCase){

        Case theCase = new Case(Subject = theSingleCase.subject, 
                                    Description= theSingleCase.description, 
                                    Status = CASE_STATUS_NEW, 
                                    Origin = theSingleCase.origin,
                                    SuppliedName = theSingleCase.name, 
                                    SuppliedPhone = theSingleCase.phone, 
                                    SuppliedEmail = theSingleCase.email);

        return theCase;
    }

    /**
     * Inner class used to represent single Case records to be inserted
     */
    private class SingleCase{
        private String subject;
        private String description;
        private String origin;
        private String name;
        private String phone;
        private String email;
    }

    /**
     * Inner class used to represent Request with list of Case records to be inserted
     */
    private class CaseRequest{
        List<SingleCase> singleCaseList;
    }
}