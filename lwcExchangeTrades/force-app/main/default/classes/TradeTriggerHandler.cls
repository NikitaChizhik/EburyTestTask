public with sharing class TradeTriggerHandler {

    private static final String ID_PREFIX = 'TR';
    private static final Integer AMOUNT_OF_ZEROS = 7;
    private static final String STRING_ZERO = '0';
    
    
    public static void fillId (List<Trade__c> trades) {
        List<Trade__c> otherTrades = [
            SELECT Id, ID__c 
            FROM Trade__c 
            ORDER BY ID__c DESC
        ];

        Integer digitalPart = 0;
        if(!otherTrades.isEmpty()) {
            digitalPart = getDigitalPart(otherTrades[0].ID__c);
        } 

        for (Trade__c trade: trades) {
            trade.ID__c = ID_PREFIX + zeroFormatter(++digitalPart);
        }

    }

    private static Integer getDigitalPart (String id) {
        Integer result = 0; 
        if (id != '') {
            result = Integer.valueOf(id.substring(2));
        } 
        return result;
    }

    private static String zeroFormatter (Integer inputNumber) {
        String stringNumber = String.valueOF(inputNumber);
        while(stringNumber.length() < AMOUNT_OF_ZEROS) {
            stringNumber = STRING_ZERO + stringNumber;
        }
        return stringNumber;
    }


}
