import REAL_ESTATE_HEADER from '@salesforce/label/c.x7sFinancialProfile_RealEstate_Header';
import VEHICLE_ASSETS_HEADER from '@salesforce/label/c.x7sFinancialProfile_VehicleAssets_Header';
import OTHER_ASSETS_HEADER from '@salesforce/label/c.x7sFinancialProfile_OtherAssets_Header';
import DEBT_LIABILITIES_HEADER from '@salesforce/label/c.x7sFinancialProfile_DebtLiabilities_Header';

import ASSETS_LIABILITIES_OBJECT from '@salesforce/schema/Financial_Profile_Assets_Liabilities__c';
import { fireEvent } from 'c/pubsub';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { api,track,wire,LightningElement } from 'lwc';
import Amount from '@salesforce/schema/Opportunity.Amount';

export default class X7sFinancialProfileAssetRows extends LightningElement {
    @api debug = false;
    @api assetsLiabilitiesType = '';
    //@api assetsLiabilities = [];
    @api primaryName = '';
    @api secondaryName = '';
    @api primaryContactId = '';
    @api secondaryContactId = '';

    @track optionsAssetType = [];

    showPrimary = true;
    showSecondary = true;

    /**
     * return the current header string based on the current incomeExpenseType
     */
     get header() {
        const headers = {
            'Real Estate': REAL_ESTATE_HEADER,
            'Vehicle': VEHICLE_ASSETS_HEADER,
            'Other Asset': OTHER_ASSETS_HEADER,
            'Debt': DEBT_LIABILITIES_HEADER,
        };
        return headers[this.assetsLiabilitiesType];
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
            Type__c: this.assetsLiabilitiesType, 
            Asset_Type__c: '', 
            Name: '', 
            Owner__c: '', 
            Value__c: 0,
            Has_Home_Equity_Line_Of_Credit__c: false,
            Has_Loan_For_Asset__c: false,
            Interest_Rate__c: null,
            Term__c: null,
        }; 
    }
    
    // get object info for unifi questionnaire
    objectRecordTypeId = '';
    @wire(getObjectInfo, { objectApiName: ASSETS_LIABILITIES_OBJECT })
    objectInfo({data,error}) {
        if (error) console.error(error);
        if (data) {
            const recordTypes = Object.values(data.recordTypeInfos).find(i=>i.name===this.assetsLiabilitiesType); // undefined if there's no matching record type
            this.objectRecordTypeId = recordTypes ? recordTypes.recordTypeId : '';
        }
    };
    // get picklist values using objectInfo
    @wire(getPicklistValuesByRecordType, {
        recordTypeId: '$objectRecordTypeId',
        objectApiName: ASSETS_LIABILITIES_OBJECT,
    })
    getPicklistValues({ data, error }) {
        if (error) console.error(error);
        if (data) this.optionsAssetType = data.picklistFieldValues.Asset_Type__c.values; 
    }
    
    @api allAssetsLiabilities = [];
    @api set assetsLiabilities(arr) { 
        if (arr && arr.length) {
            this.allAssetsLiabilities = arr.map(i=>({...i})).map(j=>({...j}));  // need to unroll this object twice to completely de-proxy it
        }
        if (!this.assetsLiabilitiesOfType.length) {
            this.allAssetsLiabilities.push(this.blankRow);
        }
        this.deployTotalAssets();
    }
    get assetsLiabilities() { return this.allAssetsLiabilities; }

    _financialAccounts = [];
    @api set financialAccounts(val) { 
        this._financialAccounts = val; 
        this.deployTotalAssets();
    }
    get financialAccounts() { return this._financialAccounts; }

    get labelCurrentValue() { return (this.assetsLiabilitiesType==='Debt') ? 'Current Balance' : 'Current Value'; }

    /**
     * return the assetsLiabilities records filtered by the current incomeExpenseType
     */
    get assetsLiabilitiesOfType() { 
        return this.allAssetsLiabilities.filter(i=>i.Type__c===this.assetsLiabilitiesType)
                .map(i=>({...i, recordTypeId: this.objectRecordTypeId })); // this might not be set in blankRow 
    }
    get isProperty() { return ['Real Estate','Vehicle','Other Asset'].includes(this.assetsLiabilitiesType); }
    get labelType() { return (this.isProperty ? 'Property Type' : 'Account Type') };
    get labelName() { return (this.isProperty ? 'Nickname' : 'Financial Institution') };
    get isRealEstate() { return (this.assetsLiabilitiesType==='Real Estate'); }
    get isVehicle() { return (this.assetsLiabilitiesType==='Vehicle'); }
    get isDebt() { return (this.assetsLiabilitiesType==='Debt'); }

    /**
     * Update the 'type' field for a specific row
     * @param {*} event 
     */
    handleChangeType(event) {
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allAssetsLiabilities.findIndex(i=>i.Id==currId);
        this.allAssetsLiabilities[currIndex].Asset_Type__c = event.detail.value;
        this.deployRowData();
    }
    
    /**
     * Update the 'name' field for a specific row
     * @param {*} event 
     */
    handleChangeName(event) { 
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allAssetsLiabilities.findIndex(i=>i.Id==currId);
        this.allAssetsLiabilities[currIndex].Name = event.detail.value;
        this.deployRowData();
    };

    /**
     * Update the 'owner' field for a specific row
     * @param {*} event 
     */
    handleChangeOwner(event) {
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allAssetsLiabilities.findIndex(i=>i.Id==currId);
        this.allAssetsLiabilities[currIndex].Owner__c = event.detail.value;
        this.deployRowData();
    }
    
     /**
      * Update the 'amount' field for a specific row
      * @param {*} event 
      */
     handleChangeAmount(event) { 
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allAssetsLiabilities.findIndex(i=>i.Id==currId);
        this.allAssetsLiabilities[currIndex].Value__c = parseInt(event.detail.value,10) || 0;
        this.deployRowData();
        this.deployTotalAssets();
    }
    
    /**
     * Update the 'has home equity line' field for a specific row
     * @param {*} event 
     */
    handleChangeHasHomeEquityLine(event) {
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allAssetsLiabilities.findIndex(i=>i.Id==currId);
        this.allAssetsLiabilities[currIndex].Has_Home_Equity_Line_Of_Credit__c = event.detail.checked;
        this.deployRowData();
    }
    
    /**
     * Update the 'has loan' field for a specific row
     * @param {*} event 
     */
    handleChangeHasLoan(event) {
        const currId = event.currentTarget.dataset.rowId;
        const currIndex = this.allAssetsLiabilities.findIndex(i=>i.Id==currId);
        this.allAssetsLiabilities[currIndex].Has_Loan_For_Asset__c = event.detail.checked;
        this.deployRowData();
    }
    
    /**
     * Update the 'loan term' field for a specific row
     * @param {*} event 
     */
    handleChangeTerm(event) { 
       const currId = event.currentTarget.dataset.rowId;
       const currIndex = this.allAssetsLiabilities.findIndex(i=>i.Id==currId);
       this.allAssetsLiabilities[currIndex].Term__c = parseInt(event.detail.value,10) || 0;
       this.deployRowData();
   }
    
   /**
    * Update the 'loan interest rate' field for a specific row
    * @param {*} event 
    */
   handleChangeInterestRate(event) { 
      const currId = event.currentTarget.dataset.rowId;
      const currIndex = this.allAssetsLiabilities.findIndex(i=>i.Id==currId);
      this.allAssetsLiabilities[currIndex].Interest_Rate__c = parseInt(event.detail.value,10) || 0;
      this.deployRowData();
  }

    /**
     * Add an extra blank row to the bottom
     * @param {*} event 
     */
    handleClickAddAnotherRow(event) {
        this.allAssetsLiabilities = [
            ...this.allAssetsLiabilities, {
                ...this.blankRow, 
                Id: this.allAssetsLiabilities.length
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
            this.allAssetsLiabilities = this.allAssetsLiabilities.filter(i=>i.Id!=rowId);
            this.deployRowData();
        }
    }

    deployRowData() {
        this.dispatchEvent(new CustomEvent('savetempdata', { detail: {
            assets: this.assetsLiabilitiesOfType,
            assetsType: this.assetsLiabilitiesType,
        }}) );
    }

    deployTotalAssets() {
        if (this.debug) console.log('all assets:',this.allAssetsLiabilities);
        const assets = this.allAssetsLiabilities.reduce((acc,curr)=>acc+curr.Value__c, 0);
        const accounts = this.financialAccounts.reduce((acc,curr)=>acc+curr.Current_Value__c, 0);
        fireEvent('updateTotalAssets',assets+accounts); 
    }

}