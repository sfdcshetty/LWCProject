import HEADER from '@salesforce/label/c.x7sFinancialProfile_IncomeExpenses_Header';
import TIP from '@salesforce/label/c.x7sFinancialProfile_IncomeExpenses_Tip';

import { fireEvent } from 'c/pubsub';
import { LightningElement } from 'lwc';

export default class X7sFinancialProfileIncomeExpenses extends LightningElement {
    header = HEADER;
    tips = TIP.split(/[\r\n]+/);

    handleClickContinue() {
        fireEvent('goNext','skipping ahead');
    }
}