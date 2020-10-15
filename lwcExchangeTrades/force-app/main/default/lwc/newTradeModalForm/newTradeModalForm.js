import { LightningElement, api } from 'lwc';

//labels:
import labelCreateNewTradeTitle from '@salesforce/label/c.Create_New_Trade_Title';
import labelCreateButton from '@salesforce/label/c.Create_Button';
import labelCancelButton from '@salesforce/label/c.Cancel_Button';

const TRADE_FORM = 'c-trade-form';

export default class NewTradeModalForm extends LightningElement {

    labels = {
        createNewTradeTitle: labelCreateNewTradeTitle,
        createButton: labelCreateButton,
        cancelButton: labelCancelButton
    };

    showModal = false;

    @api
    openModal() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    submitNewTradeCreation() {
        this.template.querySelector(TRADE_FORM).createNewTrade();
    }
}