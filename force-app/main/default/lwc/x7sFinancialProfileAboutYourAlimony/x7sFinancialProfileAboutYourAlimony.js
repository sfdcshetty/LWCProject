import HEADER from '@salesforce/label/c.x7sFinancialProfile_AboutYourAlimony_Header';
const INCOME_EXPENSE_TYPE = 'Alimony';
import { api,LightningElement } from 'lwc';

export default class AboutYourAlimony extends LightningElement {
    incomeExpenseType = INCOME_EXPENSE_TYPE;
    header = HEADER;

    @api debug = false;
    @api primaryName = '';
    @api secondaryName = '';
    @api primaryContactId = '';
    @api secondaryContactId = '';
    @api incomeExpenses = [];

}