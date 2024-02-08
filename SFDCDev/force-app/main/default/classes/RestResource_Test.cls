
@isTest
private class RestResource_Test {

    @isTest
    private static void testDoPostSuccess() {

        String requestBodyJSON = '{"singleCaseList" : [{"subject": "test subject",' +
         '"description": "test description","origin": "web", "name": "test name", "phone": "9998675309", "email": "testRestResource@test.com"}]}';

        RestRequest req = new RestRequest(); 
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/RestResource/';         
        req.requestBody = Blob.valueof(requestBodyJSON);
        RestContext.request = req;

        Test.startTest();

        RestResource.doPost();

        Test.stopTest();

        List<Case> casesAfterInsert = [SELECT Id, SuppliedEmail FROM Case WHERE SuppliedEmail = 'testRestResource@test.com'];
        Assert.areEqual(casesAfterInsert.size(), 1, 'Expect one case was created');
        
    }

    @isTest
    private static void testDoPostException() {

        String requestBodyJSON = '{"singleCaseList" : [{"subject": "test subject",' +
         '"description": "test description","origin": "web", "name": "test name", "phone": "9998675309", "email": "testRestResource@test.com"}]}';

        RestRequest req = new RestRequest(); 
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/RestResource/';         
        req.requestBody = Blob.valueof(requestBodyJSON);
        RestContext.request = req;

        Test.startTest();

        List<String> responseString = new List<String>();
       
        RestResource.restResource = new TestRestResource();
        responseString = RestResource.doPost();
            
        Test.stopTest();

        List<Case> casesAfterInsert = [SELECT Id, SuppliedEmail FROM Case WHERE SuppliedEmail = 'testRestResource@test.com'];
        Assert.areEqual(casesAfterInsert.size(), 0, 'Expect no case was created');
        
    }

    private class TestRestResourceException extends Exception{
    }

    //Inner class with doPost implementation that throws an exception
    public class TestRestResource implements IRestResource{
        public List<String> doPost(RestRequest request){
            List<String> response = new List<String>();

            //Wrapped in conditional to avoid Unreachable statement error
            if(Test.isRunningTest()){
                throw new TestRestResourceException();
            }
            return response;
        }
    
    }

}