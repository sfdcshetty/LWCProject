import HEADER from '@salesforce/label/c.x7sFinancialProfile_Insurance_Header';
import TIP from '@salesforce/label/c.x7sFinancialProfile_Insurance_Tip';
import { fireEvent } from 'c/pubsub';
import { api,LightningElement } from 'lwc';

export default class X7sFinancialProfileInsurance extends LightningElement {
    @api debug = false;
    header = HEADER;
    tips = TIP.split(/[\r\n]+/);

    handleClickContinue() {
        fireEvent('goNext','skipping ahead');
    }
}