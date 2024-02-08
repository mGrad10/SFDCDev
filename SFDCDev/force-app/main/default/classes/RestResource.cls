@RestResource(UrlMapping='/RestResource/*')
global class RestResource {

    public static IRestResource restResource = new CaseRestResource();

    @HttpPost
    global static List<String> doPost(){

        List<String> responseString = new List<String>();
        try {
            //doPost for Case implementation
            responseString = restResource.doPost(RestContext.request);
            
        }catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
            responseString.add('An error occurred:' + e.getMessage());
        }
        return responseString;
    }
}