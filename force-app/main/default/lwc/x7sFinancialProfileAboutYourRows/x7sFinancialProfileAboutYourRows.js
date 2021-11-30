import PENSION_HEADER from '@salesforce/label/c.x7sFinancialProfile_AboutYourPension_Header';
import ALIMONY_HEADER from '@salesforce/label/c.x7sFinancialProfile_AboutYourAlimony_Header';
import CHILD_SUPPORT_HEADER from '@salesforce/label/c.x7sFinancialProfile_AboutYourChildSupport_Header';
import RENTAL_PROPERTY_HEADER from '@salesforce/label/c.x7sFinancialProfile_AboutYourRentalProperty_Header';
import DISABILITY_BENEFITS_HEADER from '@salesforce/label/c.x7sFinancialProfile_AboutYourDisabilityBenefits_Header';
import GIFTS_HEADER from '@salesforce/label/c.x7sFinancialProfile_AboutYourGifts_Header';
import OTHER_HEADER from '@salesforce/label/c.x7sFinancialProfile_AboutYourOtherIncome_Header';
import PLANNED_EXPENSES_YES_NO_HEADER from '@salesforce/label/c.x7sFinancialProfile_AnyLargeFutureExpenses_Header';
import PLANNED_EXPENSES_HEADER from '@salesforce/label/c.x7sFinancialProfile_AboutYourPlannedExpenses_Header';

import { fireEvent } from 'c/pubsub';
import { api, LightningElement } from 'lwc';

export default class X7sFinancialProfileAboutYourRows extends LightningElement {
    @api debug = false;
    @api isExpense = false;
    @api incomeExpenseType = '';

    @api primaryName = '';
    @api secondaryName = '';
    @api primaryContactId = '';
    @api secondaryContactId = '';
    @api showPrimary = false;
    @api showSecondary = false;

    _showYesNo = false; 
    @api set showYesNo(val) { this._showYesNo = (val && val!=='false'); this.showRows = !this._showYesNo; }
    get showYesNo() { return this._showYesNo; }
    
    _showRows = true;
    set showRows(val) { this._showRows = val; }
    get showRows() { return this._showRows || (this.incomeExpensesOfType.length && 0<this.incomeExpensesOfType[0].Amount__c); }


    optionsYesNo = [
        { label:"Yes", value:"Yes" },
        { label:"No",  value:"No" },
    ];

    @api allIncomeExpenses = [];
    @api set incomeExpenses(arr) { 
        if (arr && arr.length) {
            this.allIncomeExpenses = arr.map(i=>({...i})).map(j=>({...j}));  // need to unroll this object twice to completely de-proxy it
        }
        if (!this.incomeExpensesOfType.length) {
            this.allIncomeExpenses.push(this.blankRow);
        }

    }
    get incomeExpenses() { 
        return this.allIncomeExpenses/*.map(i=>({
            ...i,
            showRecord: i.Type__c===this.incomeExpenseType,
        }) );*/
    }

    /**
     * return the incomeExpenses records filtered by the current incomeExpenseType
     */
    get incomeExpensesOfType() { 
        return this.allIncomeExpenses.filter(i=>i.Type__c===this.incomeExpenseType); 
    }

    /**
     * return a blank record used when adding new rows
     */
    get blankRow() { return { Id: 0, Description__c: '', Owner__c: '', Amount__c: 0, Type__c: this.incomeExpenseType }; }

    /**
     * return an array of label/value options suitable for use in a combobox or radio group
     */
    get optionsOwner() {
        const opts = [];
        if (this.showPrimary) opts.push({ label: this.primaryName, value: this.primaryContactId });
        if (this.showSecondary) opts.push({ label: this.secondaryName, value: this.secondaryContactId });
        return opts;
    }

    /**
     * return the current header string based on the current incomeExpenseType
     */
    get header() {
        const headers = {
            'Pension': PENSION_HEADER,
            'Alimony': ALIMONY_HEADER,
            'Child Support': CHILD_SUPPORT_HEADER,
            'Rental Property': RENTAL_PROPERTY_HEADER,
            'Disability Benefits': DISABILITY_BENEFITS_HEADER,
            'Gifts': GIFTS_HEADER,
            'Other': OTHER_HEADER,
            'Planned Expense': PLANNED_EXPENSES_HEADER,
        };
        return headers[this.incomeExpenseType];
    }
    get headerYesNo() {
        const headers = {
            'Planned Expense': PLANNED_EXPENSES_YES_NO_HEADER,
        };
        return headers[this.incomeExpenseType];
    }

    /**
     * return a label for the "Amount" field based on whether this is an income or expense
     */
    get labelAmount() { return (this.isExpense) ? 'Amount' : 'Current monthly income' };


    connectedCallback() {
        // check if this is even necessary, or skip to the next screen if it's not
        if (this.showYesNo) { // original parameter as passed
            this.showPrimary = this.showSecondary = true;
        }
        if (!this.showPrimary && !this.showSecondary) {
            fireEvent('goSkip','skipping '+this.incomeExpenseType);
        }
    }

    /**
     * dispatch the latest data up to the parent component
     */
    deployRowData() {
        // need to pass to the backend ONLY records of the current type
        this.dispatchEvent(new CustomEvent('savetempdata', { 
            detail: { 
                incomeExpenses: this.incomeExpensesOfType, 
                incomeExpenseType: this.incomeExpenseType, 
            }
        }) );
    }

    /**
     * Update the 'description' field for a specific row
     * @param {*} event 
     */
    handleChangeDescription(event) { 
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allIncomeExpenses.findIndex(i=>i.Id==currId);
        this.allIncomeExpenses[currIndex].Description__c = event.detail.value;
        this.allIncomeExpenses[currIndex].Name = event.detail.value;
        this.deployRowData();
    };
    
     /**
      * Update the 'amount' field for a specific row
      * @param {*} event 
      */
     handleChangeAmount(event) { 
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allIncomeExpenses.findIndex(i=>i.Id==currId);
        this.allIncomeExpenses[currIndex].Amount__c = parseInt(event.detail.value,10) || 0;
        this.deployRowData();
    }
    
    /**
     * Update the 'owner' field for a specific row
     * @param {*} event 
     */
    handleChangeOwner(event) {
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allIncomeExpenses.findIndex(i=>i.Id==currId);
        this.allIncomeExpenses[currIndex].Owner__c = event.detail.value;
        this.deployRowData();
    }

    /**
     * handle a click on the yes/no buttons
     * @param {*} event 
     */
    handleChangeShowRows(event) {
        if (event.detail.value==='Yes') {
            this.showRows = true;
        } else {
            fireEvent('goNext','next screen');
        }
    }

    /**
     * Add an extra blank row to the bottom
     */
    handleClickAddAnotherRow() {
        this.allIncomeExpenses = [
            ...this.allIncomeExpenses, {
                ...this.blankRow, 
                Id: this.allIncomeExpenses.length
            }
        ];
    }

    /**
     * Remove a given row, with a prompt to confirm
     * @param {*} event 
     */
    handleClickRemoveRow(event) {
        if (window.confirm('Are you sure you want to completely delete this row of data?')) {
            //const currIndex = parseInt(event.currentTarget.dataset.rowIndex,10);
            const rowId = event.currentTarget.dataset.rowId;
            this.allIncomeExpenses = this.allIncomeExpenses.filter(i=>i.Id!=rowId);
            this.deployRowData();
        }
    }

}