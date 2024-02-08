
@isTest
private class CaseRestResource_Test {

    @isTest
    private static void testDoPost() {

        String requestBodyJSON = '{"singleCaseList" : [{"subject": "test subject",' +
         '"description": "test description","origin": "web", "name": "test name", "phone": "9998675309", "email": "testCaseRestResource@test.com"}]}';

        RestRequest req = new RestRequest();        
        req.requestBody = Blob.valueof(requestBodyJSON);

        Test.startTest();

        CaseRestResource.doPost(req);

        Test.stopTest();

        List<Case> casesAfterInsert = [SELECT Id, SuppliedEmail FROM Case WHERE SuppliedEmail = 'testCaseRestResource@test.com'];
        Assert.areEqual(casesAfterInsert.size(), 1, 'Expect one case was created');
    }
}