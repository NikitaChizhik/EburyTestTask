public with sharing class TradeExchangeClient {

    private final String REQUEST_METHOD_GET = 'GET';
    private final Integer REQUEST_TIMEOUT = 120000;
    private final String AURA_EXCEPTION_MESSAGE = 'Something went wrong. Please, contact your system administrator.';
    
    private String endPointPattern { get; set; } 
    private String acessKey { get; set; }

    public TradeExchangeClient(String  serviceName) {

        Token__mdt serviceParams;
        try {
            serviceParams = [
                SELECT End_Point_Pattern__r.Pattern__c, Access_Key__c 
                FROM Token__mdt 
                WHERE End_Point_Pattern__r.Label = :serviceName
                ORDER BY Key_Added_Date__c DESC
                LIMIT 1
            ];
        } catch (QueryException ex) {
            throw new AuraHandledException(AURA_EXCEPTION_MESSAGE);
        }

        this.endPointPattern = serviceParams.End_Point_Pattern__r.Pattern__c;
        this.acessKey = serviceParams.Access_Key__c;
    }

    public String getCurrentRate(String sellCurrencyType, String buyCurrencyType) {
        List<Object> endPointParams = new List<Object> { this.acessKey, sellCurrencyType, buyCurrencyType };
        String endPoint = String.format(this.endPointPattern, endPointParams);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(REQUEST_METHOD_GET);
        request.setTimeout(REQUEST_TIMEOUT);

        Http http = new Http();
        HttpResponse response = http.send(request);
    
        String strResponse;
        if (response.getStatusCode() == 200) {
            strResponse = response.getBody();
        }
        return strResponse;
    }
}
