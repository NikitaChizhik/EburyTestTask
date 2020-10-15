import { LightningElement } from 'lwc';

import { getSuccessToast, getErrorToast } from 'c/utils';

//labels:
import labelBookedTradesTitle from '@salesforce/label/c.Booked_Trades_Title';
import labelNewTradeButton from '@salesforce/label/c.New_Trade_Button';

const NEW_TRADE_MODAL_FORM = 'c-new-trade-modal-form';
const TRADE_TABLE = 'c-trade-table';

export default class TradeApp extends LightningElement {

    labels = {
        bookedTradesTitle: labelBookedTradesTitle,
        newTradeButton: labelNewTradeButton
    };

    newTradeBtnClickHandler() {
        this.template.querySelector(NEW_TRADE_MODAL_FORM).openModal();
    }

    refreshTrades() {
        this.template.querySelector(TRADE_TABLE).refresh();
        this.dispatchEvent(getSuccessToast());
    }

    showErrorToast(event) {
        this.dispatchEvent(getErrorToast(event.detail));
    }
}