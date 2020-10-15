@isTest
public class MockHttpResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setBody('{"success":true,"timestamp":1602596644,"base":"EUR","date":"2020-10-13","rates":{"USD":1.175233,"EUR":1}}');
        response.setStatusCode(200);
        return response;
    }
}
