@IsTest
public with sharing class TradeTriggerTest {

    private static final Integer GENERATED_RECORDS_AMOUT = 20;

    private static final String CURRENCY_USD = 'USD';
    private static final String CURRENCY_EUR = 'EUR';
    private static final Integer SELL_AMMOUNT = 500;
    private static final Integer RATE = 2;

    private static final String EXPECTED_ID_VALUE = 'TR0000001';


    @IsTest
    private static void createTradeTest() {
        Trade__c newTrade = new Trade__c(
                Sell_Currency__c = CURRENCY_USD, 
                Sell_Amount__c = SELL_AMMOUNT, 
                Buy_Currency__c = CURRENCY_EUR, 
                Buy_Amount__c = SELL_AMMOUNT / RATE, 
                Rate__c = SELL_AMMOUNT, 
                Date_Booked__c = System.now()
        );

        Test.startTest();
            insert newTrade;
        Test.stopTest();

        List<Trade__c> createdTrades = [SELECT Id, ID__c FROM Trade__c];

        String actualIdValue;
        if (!createdTrades.isEmpty()) {
            actualIdValue = createdTrades[0].ID__c;
        }

        System.assertEquals(1, createdTrades.size());
        System.assertEquals(EXPECTED_ID_VALUE, actualIdValue);
    }

    @IsTest
    private static void createMultitudeTradesTest() {
        List<Trade__c> trades = new List<Trade__c>();
        for (Integer i = 1; i < GENERATED_RECORDS_AMOUT + 1; i++) {
            Trade__c newTrade = new Trade__c(
                Sell_Currency__c = CURRENCY_USD, 
                Sell_Amount__c = i * i, 
                Buy_Currency__c = CURRENCY_EUR , 
                Buy_Amount__c = i, 
                Rate__c = i, 
                Date_Booked__c = System.now()
            );
            trades.add(newTrade);
        }

        Test.startTest();
            insert trades;
        Test.stopTest();

        List<Trade__c> createdTrades = [SELECT Id, ID__c FROM Trade__c];

        Set<String> uniqueIds = new Set<String>();
        for (Trade__c trade : createdTrades) {
            uniqueIds.add(trade.ID__c);
        }
        
        System.assertEquals(GENERATED_RECORDS_AMOUT, uniqueIds.size());
    }
}
