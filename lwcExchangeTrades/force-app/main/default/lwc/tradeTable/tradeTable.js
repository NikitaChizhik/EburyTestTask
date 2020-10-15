import { LightningElement, wire, track, api } from 'lwc';
import getTrades from '@salesforce/apex/TradeController.getTrades';
import { refreshApex } from '@salesforce/apex';

//labels:
import labelSellCCYheader from '@salesforce/label/c.Sell_CCY_Header';
import labelSellAmountHeader from '@salesforce/label/c.Sell_Amount_Header';
import labelBuyCCYheader from '@salesforce/label/c.Buy_CCY_Header';
import labelBuyAmountHeader from '@salesforce/label/c.Buy_Amount_Header';
import labelRateHeader from '@salesforce/label/c.Rate_Header';
import labelDateBookedHeader from '@salesforce/label/c.Date_Booked_Header';


const COLUMNS = [
    { name: labelSellCCYheader },
    { name: labelSellAmountHeader },
    { name: labelBuyCCYheader },
    { name: labelBuyAmountHeader },
    { name: labelRateHeader },
    { name: labelDateBookedHeader }
];

export default class TradeTable extends LightningElement {

    isLoading = false;

    @track columns = COLUMNS;

    @wire(getTrades) trades;

    @api
    refresh() {
        return refreshApex(this.trades);
    }
}