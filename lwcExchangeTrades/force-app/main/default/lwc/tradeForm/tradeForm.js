import { LightningElement, api, wire } from 'lwc';

import getCurrentRate from '@salesforce/apex/TradeController.getCurrentRate';
import createTrade from '@salesforce/apex/TradeController.createTrade';

import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import TRADE_OBJECT from '@salesforce/schema/Trade__c';
import BUY_FIELD from '@salesforce/schema/Trade__c.Buy_Currency__c';

//labels:
import labelSellCurrencyCombobox from '@salesforce/label/c.Sell_Currency_Combobox';
import labelBuyCurrencyCombobox from '@salesforce/label/c.Buy_Currency_Combobox';
import labelCurrencyPlaceholder from '@salesforce/label/c.Currency_Placeholder';
import labelRateInput from '@salesforce/label/c.Rate_Input';
import labelRatePlaceholder from '@salesforce/label/c.Rate_Placeholder';
import labelSellAmountInput from '@salesforce/label/c.Sell_Amount_Input';
import labelSellAmountPlaceholder from '@salesforce/label/c.Sell_Amount_Placeholder';
import labelBuyAmountInput from '@salesforce/label/c.Buy_Amount_Input';


const COMBOBOX_SELL_NAME = 'sell-currency';
const COMBOBOX_BUY_NAME = 'buy-currency';

export default class TradeForm extends LightningElement {

    labels = {
        sellCurrencyCombobox: labelSellCurrencyCombobox,
        currencyPlaceholder: labelCurrencyPlaceholder,
        buyCurrencyCombobox: labelBuyCurrencyCombobox,
        rateInput: labelRateInput,
        ratePlaceholder: labelRatePlaceholder,
        sellAmountInput: labelSellAmountInput,
        sellAmountPlaceholder: labelSellAmountPlaceholder,
        buyAmountInput: labelBuyAmountInput
    };

    sellCurrencyType = '';
    buyCurrencyType = '';
    rateValue = 0;
    isRateLoading = false;
    sellAmountValue = '';
    buyAmountValue = 0;
    currencySymbolValues;

    @wire(getObjectInfo, {
        objectApiName: TRADE_OBJECT
    }) tradeObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$tradeObjectInfo.data.defaultRecordTypeId',
        fieldApiName: BUY_FIELD
    }) wiredCurrencySymbols({ error, data }) {
        if (data) {
            this.currencySymbolValues = data.values;
        } else if (error) {
            console.error(error);
        }
    };

    @api
    createNewTrade() {
        if (this.sellCurrencyType && this.sellAmountValue && this.buyCurrencyType && this.buyAmountValue && this.rateValue) {
            const trade = {
                sellCurrency: this.sellCurrencyType,
                sellAmount: Number(this.sellAmountValue).toFixed(2),
                buyCurrency: this.buyCurrencyType,
                buyAmount: this.buyAmountValue.toFixed(2),
                rate: this.rateValue.toFixed(4)
            }

            createTrade({ trade })
                .then(() => {
                    this.dispatchEvent(new CustomEvent('tradecreated', { bubbles: true, composed: true }));
                })
                .catch((error) => {
                    this.dispatchEvent(new CustomEvent('formerror', { detail: error, bubbles: true, composed: true }));
                    console.error(error);
                    this.cleanWindow();
                })
        } else {
            this.dispatchEvent(new CustomEvent('formerror', { bubbles: true, composed: true }));
        }
    }

    cleanWindow() {
        this.sellCurrencyType = '';
        this.buyCurrencyType = '';
        this.rateValue = 0;
        this.sellAmountValue = '';
        this.buyAmountValue = 0;
    }

    get options() {
        function Option(value) {
            this.label = value;
            this.value = value;
        }

        return this.currencySymbolValues ? this.currencySymbolValues.map(elem => new Option(elem.value)) : {};
    }

    comboboxesChangeHandler(event) {
        if (event.target.name === COMBOBOX_SELL_NAME) {
            this.sellCurrencyType = event.detail.value;
        } else if (event.target.name === COMBOBOX_BUY_NAME) {
            this.buyCurrencyType = event.detail.value;
        }
        this.updateRate();
    }

    updateRate() {
        if (this.sellCurrencyType && this.buyCurrencyType) {
            this.isRateLoading = true;

            getCurrentRate({
                sellCurrencyType: this.sellCurrencyType,
                buyCurrencyType: this.buyCurrencyType
            })
                .then((result) => {
                    const rates = JSON.parse(result).rates;
                    if (rates && rates.hasOwnProperty(this.sellCurrencyType) && rates.hasOwnProperty(this.buyCurrencyType)) {
                        this.rateValue = rates[this.buyCurrencyType] / rates[this.sellCurrencyType];
                    } else {
                        this.rateValue = 0;
                    }
                    this.updateBuyAmountValue();
                })
                .catch((error) => {
                    this.dispatchEvent(new CustomEvent('formerror', { detail: error, bubbles: true, composed: true }));
                    console.error(error);
                })
                .finally(() => {
                    this.isRateLoading = false;
                });
        }
    }

    sellAmountChangeHandler(event) {
        this.sellAmountValue = event.target.value;
        this.updateBuyAmountValue();
    }

    updateBuyAmountValue() {
        if (this.rateValue && Number(this.sellAmountValue)) {
            this.buyAmountValue = this.rateValue * this.sellAmountValue;
        } else {
            this.buyAmountValue = 0;
        }
    }
}