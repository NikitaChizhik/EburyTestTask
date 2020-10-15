String endPoint = 'http://data.fixer.io/api/latest?access_key=43091eeaa9c10ec09714a53259ba6dcc&base=EUR&symbols=USD';
HttpRequest request = new HttpRequest();
request.setEndpoint(endPoint);
request.setMethod('GET');
request.setTimeout(120000);
Http http = new Http();
HttpResponse response = http.send(request);

String strResponse;
if (response.getStatusCode() == 200) {
    strResponse = JSON.serialize(response.getBody());
}
System.debug(strResponse);