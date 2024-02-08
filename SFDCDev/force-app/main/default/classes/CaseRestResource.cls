@RestResource(UrlMapping='/CaseRestResource/*')
global with sharing class CaseRestResource {

    private static final String CASE_STATUS_NEW = 'New';

    /**
     * Parses JSON request string and creates Cases in Salesforce
     * @return JSON string containing SaveResults of Case inserts
     */
    @HttpPost
    global static List<String> insertCases() {

        //Get the request body
        RestRequest request = RestContext.request;
        String requestBody = request.requestBody.toString();

        //Deseralize the request JSON into a wrapper
        CaseRequest caseRequest = (CaseRequest) JSON.deserialize(requestBody, CaseRequest.class);

        //For each SingleCase, create a new Case record and add to a list
        List<Case> casesToInsert = new List<Case>();
    
        for(SingleCase theSingleCase : caseRequest.singleCaseList){
            Case theCase = new Case(Subject = theSingleCase.subject, 
                                    Description= theSingleCase.description, 
                                    Status = CASE_STATUS_NEW, 
                                    Origin = theSingleCase.origin,
                                    SuppliedName = theSingleCase.name, 
                                    SuppliedPhone = theSingleCase.phone, 
                                    SuppliedEmail = theSingleCase.email);

            casesToInsert.add(theCase);
        }

        //Enforce object-level access and FLS
        casesToInsert = (List<Case>)Security.stripInaccessible(AccessType.CREATABLE, casesToInsert).getRecords();

        List<String> responseStringList = new List<String>();

        try{
            //Insert Cases, add success/failures to list for return
            List<Database.SaveResult> caseInsertResults = Database.insert(casesToInsert, false);
            for(Database.SaveResult theSaveResult: caseInsertResults){
                if(theSaveResult.isSuccess()){
                    responseStringList.add('Case created successfully! Id = ' + theSaveResult.getId());
                }else{
                    responseStringList.add('Case creation failed: ' + theSaveResult.getErrors());
                }
            }
        }catch(Exception e){
            responseStringList.add('An error occurred:' + e.getMessage());
        } 
        return responseStringList;
    }

    /**
     * Inner class used to represent single Case records to be inserted
     */
    global class SingleCase{
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
    global class CaseRequest{
        List<SingleCase> singleCaseList;
    }
}