import BANK_ACCOUNTS_HEADER from '@salesforce/label/c.x7sFinancialProfile_BankAccounts_Header';
import INVESTMENT_ACCOUNTS_HEADER from '@salesforce/label/c.x7sFinancialProfile_InvestmentAccounts_Header';
import RETIREMENT_ACCOUNTS_HEADER from '@salesforce/label/c.x7sFinancialProfile_RetirementAccounts_Header';
import CHILDREN_ACCOUNTS_HEADER from '@salesforce/label/c.x7sFinancialProfile_ChildrenAccounts_Header';
import OTHER_ACCOUNTS_HEADER from '@salesforce/label/c.x7sFinancialProfile_OtherAccounts_Header';

import FINANCIAL_ACCOUNTS_OBJECT from '@salesforce/schema/Financial_Profile_Financial_Account__c';
import { fireEvent } from 'c/pubsub';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { api,track,wire,LightningElement } from 'lwc';

export default class X7sFinancialProfileAccountRows extends LightningElement {
    @api debug = false;
    @api financialAccountsType = '';
    //@api financialAccounts = [];
    @api primaryName = '';
    @api secondaryName = '';
    @api primaryContactId = '';
    @api secondaryContactId = '';

    @track optionsAccountType = [];

    showPrimary = true;
    showSecondary = true;

    /**
     * return the current header string based on the current incomeExpenseType
     */
     get header() {
        const headers = {
            'Bank': BANK_ACCOUNTS_HEADER,
            'Retirement': RETIREMENT_ACCOUNTS_HEADER,
            'Investment': INVESTMENT_ACCOUNTS_HEADER,
            'Children': CHILDREN_ACCOUNTS_HEADER,
            'Other Account': OTHER_ACCOUNTS_HEADER,
        };
        return headers[this.financialAccountsType];
    }

    get optionsOwner() {
        const opts = [];
        if (this.showPrimary) opts.push({ label: this.primaryName, value: this.primaryContactId });
        if (this.showSecondary) opts.push({ label: this.secondaryName, value: this.secondaryContactId });
        return opts;
    }

    get blankRow() { return { 
            Id: 0, 
            recordTypeId: this.objectRecordTypeId,
            Type__c: this.financialAccountsType, 
            Account_Type__c: '', 
            Name: '', 
            Financial_Institution__c: '', 
            Owner__c: '', 
            Current_Value__c: 0 
        }; 
    }
    
    // get object info for unifi questionnaire
    objectRecordTypeId = '';
    @wire(getObjectInfo, { objectApiName: FINANCIAL_ACCOUNTS_OBJECT })
    objectInfo({data,error}) {
        if (error) console.error(error);
        if (data) {
            const recordTypes = Object.values(data.recordTypeInfos).find(i=>i.name===this.financialAccountsType); // undefined if there's no matching record type
            this.objectRecordTypeId = recordTypes ? recordTypes.recordTypeId : '';
        }
    };
    // get picklist values using objectInfo
    @wire(getPicklistValuesByRecordType, {
        recordTypeId: '$objectRecordTypeId',
        objectApiName: FINANCIAL_ACCOUNTS_OBJECT,
    })
    getPicklistValues({ data, error }) {
        if (error) console.error(error);
        if (data) {
            this.optionsAccountType = data.picklistFieldValues.Account_Type__c.values; 
            this.optionsFinancialInstitutions = data.picklistFieldValues.Financial_Institution__c.values;
        }
    }
    

    @api allFinancialAccounts = [];
    @api set financialAccounts(arr) { 
        if (arr && arr.length) {
            this.allFinancialAccounts = arr.map(i=>({...i})).map(j=>({...j}));  // need to unroll this object twice to completely de-proxy it
        }
        if (!this.financialAccountsOfType.length) {
            this.allFinancialAccounts.push(this.blankRow);
        }
        this.deployTotalAssets();
    }
    get financialAccounts() { return this.allFinancialAccounts; }

    /**
     * return the financialAccounts records filtered by the current incomeExpenseType
     */
    get financialAccountsOfType() { 
        return this.allFinancialAccounts.filter(i=>i.Type__c===this.financialAccountsType)
                    .map(i=>({...i, recordTypeId: this.objectRecordTypeId })); // this might not be set in blankRow 
    }

    _assetsLiabilities = [];
    @api set assetsLiabilities(val) { 
        this._assetsLiabilities = val; 
        this.deployTotalAssets(); 
    }
    get assetsLiabilities() { return this._assetsLiabilities; }

    /**
     * Update the 'type' field for a specific row
     * @param {*} event 
     */
    handleChangeType(event) {
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allFinancialAccounts.findIndex(i=>i.Id==currId);
        this.allFinancialAccounts[currIndex].Account_Type__c = event.detail.value;
        this.deployRowData();
    }
    
    /**
     * Update the 'name' field for a specific row
     * @param {*} event 
     */
    handleChangeName(event) { 
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allFinancialAccounts.findIndex(i=>i.Id==currId);
        this.allFinancialAccounts[currIndex].Financial_Institution__c = event.detail.value;
        this.deployRowData();
    };

    /**
     * Update the 'owner' field for a specific row
     * @param {*} event 
     */
    handleChangeOwner(event) {
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allFinancialAccounts.findIndex(i=>i.Id==currId);
        this.allFinancialAccounts[currIndex].Owner__c = event.detail.value;
        this.deployRowData();
    }
    
     /**
      * Update the 'amount' field for a specific row
      * @param {*} event 
      */
     handleChangeAmount(event) { 
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allFinancialAccounts.findIndex(i=>i.Id==currId);
        this.allFinancialAccounts[currIndex].Current_Value__c = parseInt(event.detail.value,10) || 0;
        this.deployRowData();
        this.deployTotalAssets();
    }

    /**
     * Add an extra blank row to the bottom
     * @param {*} event 
     */
    handleClickAddAnotherRow(event) {
        this.allFinancialAccounts = [
            ...this.allFinancialAccounts, {
                ...this.blankRow, 
                Id: this.allFinancialAccounts.length
            }
        ];
    }

    /**
     * Remove a given row, with a prompt to confirm
     * @param {*} event 
     */
    handleClickRemoveRow(event) {
        if (window.confirm('Are you sure you want to completely delete this row of data?')) {
            const rowId = event.currentTarget.dataset.rowId;
            this.allFinancialAccounts = this.allFinancialAccounts.filter(i=>i.Id!=rowId);
            this.deployRowData();
        }
    }

    deployRowData() {
        this.dispatchEvent(new CustomEvent('savetempdata', { detail: {
            financialAccounts: this.financialAccountsOfType,
            financialAccountsType: this.financialAccountsType,
        }}) );
    }

    deployTotalAssets() {
        if (this.debug) console.log('all accounts:',this.allFinancialAccounts);
        const assets = this.assetsLiabilities.reduce((acc,curr)=>acc+curr.Value__c, 0);
        const accounts = this.allFinancialAccounts.reduce((acc,curr)=>acc+curr.Current_Value__c, 0);
        fireEvent('updateTotalAssets',assets+accounts); 
    }

}