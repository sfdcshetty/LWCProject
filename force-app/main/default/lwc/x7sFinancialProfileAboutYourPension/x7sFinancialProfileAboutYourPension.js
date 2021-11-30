import HEADER from '@salesforce/label/c.x7sFinancialProfile_AboutYourPension_Header';
const INCOME_EXPENSE_TYPE = 'Pension';
import { api,LightningElement } from 'lwc';

export default class AboutYourPension extends LightningElement {
    incomeExpenseType = INCOME_EXPENSE_TYPE;
    header = HEADER;

    @api debug = false;
    @api primaryName = '';
    @api secondaryName = '';
    @api primaryContactId = '';
    @api secondaryContactId = '';
    @api incomeExpenses = [];

}