import HEADER from '@salesforce/label/c.x7sFinancialProfile_BankAccounts_Header';
import { api,LightningElement } from 'lwc';

export default class X7sFinancialProfileBankAccounts extends LightningElement {
    @api debug = false;
    @api assetsLiabilitiesType = '';
    @api assetsLiabilities = [];
    @api primaryName = '';
    @api secondaryName = '';
    @api primaryContactId = '';
    @api secondaryContactId = '';

    showPrimary = true;
    showSecondary = true;

    header = HEADER;

    /**
     * return an array of label/value options suitable for use in a combobox or radio group
     */
     get optionsOwner() {
        const opts = [];
        if (this.showPrimary) opts.push({ label: this.primaryName, value: this.primaryContactId });
        if (this.showSecondary) opts.push({ label: this.secondaryName, value: this.secondaryContactId });
        return opts;
    }
    
    optionsTypes = [ // TODO: retrieve these options from the org
        { label: 'Checking', value: 'Checking' },
        { label: 'Savings', value: 'Savings' },
        { label: 'Mutual Fund', value: 'Mutual Fund' },
        { label: 'Certificate of Deposit (CD)', value: 'Certificate of Deposit' },
        { label: 'Other', value: 'Other' },
    ];
    rowData = [{ id: 0, type: '', name: '', owner: '', amount: 0 }];

    handleUpdateRowData(event) {
        this.rowData = [...event.detail];
    }
}