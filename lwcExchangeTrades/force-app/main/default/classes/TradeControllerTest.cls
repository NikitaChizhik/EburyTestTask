@IsTest
private with sharing class TradeControllerTest {
    
    private static final Integer GENERATED_RECORDS_AMOUT = 10;

    private static final String CURRENCY_CNY = 'CNY';
    private static final String CURRENCY_USD = 'USD';
    private static final String CURRENCY_EUR = 'EUR';

    private static final String CHATTER_GROUP_NAME = 'Trade reviewers Test';
    private static final String COLLABORATION_TYPE_PUBLIC = 'Public';

    private static final Integer SELL_AMMOUNT = 1000;
    private static final Integer RATE = 2;

    private static final String RATES_PROPERTY_NAME = 'rates';
    private static final Decimal EXPECTED_RATE = 1.175233;


    @TestSetup
    private static void createTrades() {
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
        insert trades;
    }

    @IsTest
    private static void getTradesTest() {
        Test.startTest();
            List<TradeController.WrappedTrade> wrappedTrades = TradeController.getTrades();
        Test.stopTest();

        System.assertEquals(GENERATED_RECORDS_AMOUT, wrappedTrades.size());
    }

    @IsTest
    private static void createTradeTest() {
        TradeController.WrappedTrade wrappedTrade = new TradeController.WrappedTrade();
        wrappedTrade.sellCurrency = CURRENCY_CNY;
        wrappedTrade.sellAmount = SELL_AMMOUNT;
        wrappedTrade.buyCurrency = CURRENCY_USD;
        wrappedTrade.buyAmount = SELL_AMMOUNT / RATE;
        wrappedTrade.rate = RATE;

        CollaborationGroup newCollaborationGroup = new CollaborationGroup();
        newCollaborationGroup.Name = CHATTER_GROUP_NAME;
        newCollaborationGroup.CollaborationType = COLLABORATION_TYPE_PUBLIC;
        insert newCollaborationGroup;

        Test.startTest();
            TradeController.createTrade(wrappedTrade);
        Test.stopTest();

        Integer actualFeedAmount = [SELECT COUNT() FROM FeedItem];
        Integer actualTradeAmount = [SELECT COUNT() FROM Trade__c];

        System.assertEquals(1, actualFeedAmount);
        System.assertEquals(GENERATED_RECORDS_AMOUT + 1, actualTradeAmount);
    }

    @IsTest
    private static void getCurrentRateTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
            String response = TradeController.getCurrentRate(CURRENCY_USD, CURRENCY_EUR);
        Test.stopTest();

        Map<String, Object> objectsByProperties = (Map<String, Object>) JSON.deserializeUntyped(response);
        Map<String, Object> ratesByCodes = (Map<String, Object>) objectsByProperties.get(RATES_PROPERTY_NAME);
        Decimal actualResult = Decimal.valueOf(String.valueOf(ratesByCodes.get(CURRENCY_USD)));
        
        System.assertEquals(EXPECTED_RATE, actualResult);
    }
}
