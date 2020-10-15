public with sharing class TradeController {
    
    private static final String SERVICE_NAME = 'fixer.io';
    private static final String AURA_EXCEPTION_MESSAGE = 'Something went wrong. Please, contact your system administrator.';
    private static final String DATE_FORMAT = 'yyyy/MM/dd, HH:mm:ss';

    private static final String CHATTER_GROUP_NAME = 'Trade reviewers';
    private static final String CHATTER_GROUP_NAME_TEST = 'Trade reviewers Test';
    private static final String LINK_URL_PATTERN = '/lightning/r/Trade__c/{0}/view';

    @AuraEnabled(Cacheable=true)
    public static List<WrappedTrade> getTrades() {
        List<Trade__c> trades = [
            SELECT Id, Name, Sell_Currency__c, Sell_Amount__c, Buy_Currency__c, 
                Buy_Amount__c, Rate__c, Date_Booked__c 
            FROM Trade__c 
            WITH SECURITY_ENFORCED
            ORDER BY Date_Booked__c DESC
        ];

        List<WrappedTrade> wrappedTrades = new List<WrappedTrade>();
        for (Trade__c tradeItem : trades) {
            wrappedTrades.add(new WrappedTrade(tradeItem));
        }
        return wrappedTrades;
    }

    @AuraEnabled
    public static void createTrade(WrappedTrade trade) {
        Trade__c newTrade = new Trade__c(
            Sell_Currency__c = trade.sellCurrency,  
            Sell_Amount__c = trade.sellAmount, 
            Buy_Currency__c = trade.buyCurrency,
            Buy_Amount__c = trade.buyAmount, 
            Rate__c = trade.rate,
            Date_Booked__c = System.now()
        );

        try {
            insert newTrade;
        } catch (DmlException ex) {
            throw new AuraHandledException(AURA_EXCEPTION_MESSAGE);
        }

        sendChatterPost(newTrade.Id);
    }

    
    private static void sendChatterPost(Id tradeId) {
        String chatterGroupName = !Test.isRunningTest() ? CHATTER_GROUP_NAME : CHATTER_GROUP_NAME_TEST;

        CollaborationGroup chatterGroup;
        try {
            chatterGroup = [
                SELECT Id, Name 
                FROM CollaborationGroup 
                WHERE Name = :chatterGroupName
                LIMIT 1
            ];
        } catch (QueryException ex) {
            throw new AuraHandledException(AURA_EXCEPTION_MESSAGE);
        }
        
        Trade__c trade;
        try {
            trade = [
                SELECT Id, Sell_Currency__c, Sell_Amount__c, Buy_Currency__c, 
                       Buy_Amount__c, Rate__c, Date_Booked__c
                FROM Trade__c 
                WHERE Id = :tradeId
            ];
        } catch (QueryException ex) {
            throw new AuraHandledException(AURA_EXCEPTION_MESSAGE);
        }
        
        FeedItem post = new FeedItem();
        post.ParentId = chatterGroup.Id;
        post.Title = Label.Post_Title;
        post.LinkUrl = String.format(LINK_URL_PATTERN, new List<Object> { tradeId });

        String strBody = String.format(Label.Post_Body_Pattern, new List<Object> {
            trade.Sell_Currency__c,
            trade.Sell_Amount__c,
            trade.Buy_Currency__c,
            trade.Buy_Amount__c,
            trade.Rate__c,
            trade.Date_Booked__c.format(DATE_FORMAT)
        });

        post.Body = strBody;

        try {
            insert post;
        } catch (DmlException ex) {
            throw new AuraHandledException(AURA_EXCEPTION_MESSAGE);
        }
        
    }

    @AuraEnabled
    public static String getCurrentRate(String sellCurrencyType, String buyCurrencyType) {
        TradeExchangeClient client = new TradeExchangeClient(SERVICE_NAME);
        return client.getCurrentRate(sellCurrencyType, buyCurrencyType);
    }

    @TestVisible
    private class WrappedTrade {
        private final String DATE_FORMAT = 'yyyy/MM/dd, HH:mm:ss'; 

        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String sellCurrency { get; set; }
        @AuraEnabled public Decimal sellAmount { get; set; }
        @AuraEnabled public String buyCurrency { get; set; }
        @AuraEnabled public Decimal buyAmount { get; set; }
        @AuraEnabled public Decimal rate { get; set; }
        @AuraEnabled public String dateBooked { get; set; }

        public WrappedTrade(Trade__c trade) {
            this.id = trade.Id;
            this.sellCurrency = trade.Sell_Currency__c;
            this.sellAmount = trade.Sell_Amount__c;
            this.buyCurrency = trade.Buy_Currency__c;
            this.buyAmount = trade.Buy_Amount__c;
            this.rate = trade.Rate__c;
            this.dateBooked = trade.Date_Booked__c.format(DATE_FORMAT);
        }

        public WrappedTrade() { }
    }
}
