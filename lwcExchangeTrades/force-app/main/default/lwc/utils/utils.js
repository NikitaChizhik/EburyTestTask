import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const SUCCESS_VARIANT = 'success';
const SUCCESS_TITLE = 'Trade created!';
const SUCCESS_MESSAGE = 'The trade record created successfully!';

const ERROR_VARIANT = 'error';
const ERROR_TITLE = 'Creation error!';
const ERROR_MESSAGE = 'Cannot create a trade record! Not all fields have values!';


export default class ToastModule {

    static getSuccessToast() {
        const tostParams = {
            variant: SUCCESS_VARIANT,
            title: SUCCESS_TITLE,
            message: SUCCESS_MESSAGE
        }
        return new ShowToastEvent(tostParams);
    }

    static getErrorToast(error) {
        const tostParams = {
            variant: ERROR_VARIANT,
            title: ERROR_TITLE,
            message: error ? error.body.message : ERROR_MESSAGE
        }
        return new ShowToastEvent(tostParams);
    }
}

export const getSuccessToast = ToastModule.getSuccessToast;
export const getErrorToast = ToastModule.getErrorToast;