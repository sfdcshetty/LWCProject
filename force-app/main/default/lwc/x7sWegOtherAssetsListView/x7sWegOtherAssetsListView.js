import { LightningElement,wire,api,track} from 'lwc';
import { showToast } from 'c/x7sShrUtils';
import { getRecord } from 'lightning/uiRecordApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import {refreshApex} from '@salesforce/apex';
import editOtherAsset from '@salesforce/apex/x7sOtherAssetsController.editOtherAsset';
import addOtherAsset from '@salesforce/apex/x7sOtherAssetsController.addOtherAsset';

import getAccountType from '@salesforce/apex/x7sOtherAssetsController.getAccountType';
import ASSET_OBJECT from '@salesforce/schema/FinServ__AssetsAndLiabilities__c';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getOtherAssetsOwnerList from '@salesforce/apex/x7sOtherAssetsController.getOtherAssetsOwnerList';
import getOtherAssetsDetails from '@salesforce/apex/x7sOtherAssetsController.getOtherAssetsDetails';
import otherAssetsDataTableStyle from '@salesforce/resourceUrl/x7sWegOtherAssetsDataTableStyle';
import userId from '@salesforce/user/Id';
import {fireEvent} from 'c/x7sShrUtils';
import {CurrentPageReference} from 'lightning/navigation';

const USER_FIELDS = ['User.AccountId'];

const columns = [
    { label: 'Edit', name: 'Edit', hideDefaultActions: true, 
            type: 'button', initialWidth: 80,
            typeAttributes: {
                iconName: 'utility:edit', name: 'Edit',
                iconPosition: 'left',
                title: 'Edit'
            },
    }, 

    { label: 'Asset Name', fieldName: 'Account', hideDefaultActions: true, initialWidth: 310 },
    { label: 'Asset Type', name: 'Type',fieldName: 'Type', hideDefaultActions: true, initialWidth: 200},
    { label: 'Asset Owner', fieldName: 'OwnerName', hideDefaultActions: true , initialWidth: 200},
    { label: 'As Of Date', fieldName: 'AsOfDate', hideDefaultActions: true, type: "date-local",
        typeAttributes: { month: "2-digit", day: "2-digit"},
        initialWidth : 300
    },
    { label: 'Value', fieldName: 'Amount', hideDefaultActions: true, type: 'currency', 
        typeAttributes: { currencyCode: 'USD', minimumFractionDigits: '0', maximumFractionDigits: '0'},
        cellAttributes: { alignment: 'right' },
        sortable:true,
    },
];
export default class X7sWegOtherAssetsListView extends LightningElement {
    @api addHeader = 'Add Other Asset';
    @api addBtnLabel = 'Save Other Asset';
    @api editHeader = 'Edit Other Asset';
    @api editBtnLabel = 'Save Other Asset';
    
    currentUserId = userId;
    //currentUserId = '0052f000001sMKHAA2';
    accountId;
    isDisplayComponent = false;
    columns = columns;
    totalAmt = 0;
    isModalOpen = false;
    otherAssetsHeader = '';
    otherAssetBtnLabel = '';

    accountTypeList;
    isLoading = false;
    ownerList;

    otherAssetsResponse;
    
    otherAssetId;
    otherAssetAccType;
    otherAssetOwnerId;
    otherAssetOwnerName;
    otherAssetAccNo;
    otherAssetAsOfDt;
    otherAssetValue;

    sortedBy;
    defaultSortDirection = 'desc';
    sortDirection = 'desc';
    isRequiredFieldsFill = false;

    @track dataList;
    @api componentTitle = 'Other Assets';
    @api requiredFieldValidationMessage = 'Please fill all the required field.';

    objectRecordTypeName = 'Asset';
    objectPicklistFieldName = 'FinServ__AssetsAndLiabilitiesType__c';
    objectRecordTypeId = '';
    optionsAlreadyFiltered = false;
    myOptionList = [];
    accountTypeOptions = [];

    @wire(CurrentPageReference) pageRef;

    renderedCallback() {
        Promise.all([
            loadStyle(this, otherAssetsDataTableStyle)
        ]);
    }

    // @wire(getAccountType)
    // accountTypeRecord({ error, data }) {
    //     if (data) {
    //         this.accountTypeList = data;
    //     }
    //     else if (error) {
    //         console.log(error);
    //     }
    // }
    // objectRecordTypeName = 'Asset';
    // objectPicklistFieldName = 'FinServ__AssetsAndLiabilitiesType__c';
    // objectRecordTypeId = '';
    // accountTypeOptions = [];
    // get object info for unifi questionnaire
    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    objectInfo({data,error}) {
        if (error) console.error(error);
        if (data) {
            const recordTypes = Object.values(data.recordTypeInfos).find(i=>i.name===this.objectRecordTypeName); // undefined if there's no matching record type
            this.objectRecordTypeId = recordTypes ? recordTypes.recordTypeId : '';
        }
    };
    // get picklist values using objectInfo
    @wire(getPicklistValuesByRecordType, {
        recordTypeId: '$objectRecordTypeId',
        objectApiName: ASSET_OBJECT,
    })
    getPicklistValues({ data, error }) {
        if (error) console.error(error);
        if (data) {
            this.myOptionList = data.picklistFieldValues[this.objectPicklistFieldName].values;
            //console.log('this.myOptionList', this.myOptionList);
            if(this.myOptionList.length && this.myOptionList.length>0){
                for(let i=0; i<this.myOptionList.length; i++ ){
                    //console.log('WHAT IS THIS:'+this.myOptionList[i].label.indexOf('Trust'));
                    if(this.myOptionList[i].label == 'Cash' || this.myOptionList[i].label == 'Collection' || this.myOptionList[i].label == 'Equipment' || this.myOptionList[i].label == 'Gold' || this.myOptionList[i].label == 'Other - Asset' || this.myOptionList[i].label == 'Real Estate - Investment' || this.myOptionList[i].label == 'Virtual Currency'){
                        this.accountTypeOptions.push({ label: this.myOptionList[i].label, value: this.myOptionList[i].value });
                    }
                }
            }

        }
    }

    @wire(getRecord, { recordId: '$currentUserId', fields: USER_FIELDS })
    wiredUserRecord({ error, data }) {
        if (error) {
            console.error('Error in getRecord:', error);
        } else if (data) {
            this.accountId = data.fields.AccountId.value;
        }
    }

    @wire(getOtherAssetsOwnerList, { accountId : '$accountId' })
    wiredtOtherAssetsOwnerList(response) {  
        if (response) {
            this.ownerList = response['data'];
        } else if (error) {
            //console.log('ownerList error = '+error);
            console.error('Error in get owner lists:', error);
           
        }
    }

    @wire(getOtherAssetsDetails, { accountId : '$accountId' })
    wiredtOtherAssetsDetails(response) {  
        this.isLoading = true;
        
        this.otherAssetsResponse = response;
        this.totalAmt = 0.0;
        let error = response && response.error;
        let result = response && response.data;
        if (result) {
            this.isDisplayComponent = true;
            this.dataList =[...result];
            let copyData = JSON.parse(JSON.stringify(this.dataList));
            copyData.forEach(element => {
                if(element.Amount && typeof element.Amount === 'number') this.totalAmt += element.Amount;
            });
            this.dataList = [...copyData];
        } else if (error) {
            console.error('Error in getRecord:', error); 
        }
        this.isLoading = false;
    }

    get otherAssetOwnerOptions() {
        var ownerListValues = [];
        for (let key in this.ownerList) {
            ownerListValues.push({ label: this.ownerList[key], value: key });
        }
        return ownerListValues;
    }

    getParam() {
        let params = {
            Type: this.otherAssetAccType,
            OwnerId: this.otherAssetOwnerId,
            OwnerName: this.otherAssetOwnerName,
            Account: this.otherAssetAccNo,
            AsOfDate: this.otherAssetAsOfDt,
            Amount: Math.round(this.otherAssetValue),
        }
        if(params.AsOfDate===""){
            params.AsOfDate = null;
        }
        return params;
    }

    // filterOptions(){
    //     if(this.myOptionList.length && this.myOptionList.length>0){
    //         for(let i=0; i<this.myOptionList.length; i++ ){
    //             if(this.myOptionList[i].label.indexOf('Trust')<0){
    //                 this.accountTypeOptions.push(this.myOptionList[i]);
    //             }
    //         }
    //         this.optionsAlreadyFiltered = true;
    //     }
    // }

    clearFormData(){
        this.otherAssetId = '';
        this.otherAssetAccType = '';
        this.otherAssetOwnerId = '';
        this.otherAssetOwnerName = '';
        this.otherAssetAccNo = '';
        this.otherAssetAsOfDt = '';
        this.otherAssetValue = 0.00;
    }

    handleRowAction(event) {
        this.isModalOpen = true;
        //console.log('ASSET TYPES', this.accountTypeOptions);
        this.otherAssetsHeader = this.editHeader;
        this.otherAssetBtnLabel = this.editBtnLabel;
    
        this.row = event.detail.row;
        this.otherAssetId = event.detail.row.Id;
        this.otherAssetAccType = event.detail.row.Type;
        this.otherAssetOwnerName = event.detail.row.OwnerName;


        this.otherAssetOwnerId = event.detail.row.OwnerId;
        this.otherAssetAccNo = event.detail.row.Account;
        this.otherAssetAsOfDt = event.detail.row.AsOfDate;
        this.otherAssetValue = event.detail.row.Amount;
        //this.ownerList = [event.detail.row.FinServ__Household__r.WEGP1_Primary_Individual__r.Name, event.detail.row.FinServ__Household__r.WEGP1_Primary_Individual__r.Name];

    }

    handleOtherAssetAccTypeChange(event){  this.otherAssetAccType = event.target.value; }
    handleOtherAssetOwnerChange(event){ 
         this.otherAssetOwnerId = event.target.value;
         //this.otherAssetOwnerId = event.target.value; 
    }
    //handleOtherAssetOwnerChange(event){  this.otherAssetOwnerName = event.target.value; }
    handleOtherAssetAccNoChange(event){  this.otherAssetAccNo = event.target.value; }
    handleOtherAssetAsOfDtChange(event){  this.otherAssetAsOfDt = event.target.value; }
    handleOtherAssetValueChange(event){  this.otherAssetValue = event.target.value; }

    handleAddOtherAssetClick(event){
        //if(!this.optionsAlreadyFiltered) this.filterOptions();
        this.clearFormData();
        this.isModalOpen = true;
        this.otherAssetsHeader = this.addHeader;
        this.otherAssetBtnLabel = this.addBtnLabel;
    }

    closeModal() {
        this.clearFormData();
        this.isModalOpen = false;
    }

    validateAssetsRequiredFields() {
        var validateCmp = '';
        if (!this.otherAssetAccNo) {
            validateCmp = ".validateAccountName";
        }else if(!this.otherAssetAccType){
            validateCmp = ".validateAccountType";
        }else if (!this.otherAssetOwnerId) {
            validateCmp = ".validateAccountOwner";
        }
        
        // else if (!this.otherAssetAsOfDt) {
        //     validateCmp = ".validateAsOfDate";
        // } 
        else {
            this.isRequiredFieldsFill = true;
        }
  	    if (validateCmp != '' ) {
            var inputCmp = this.template.querySelector(validateCmp);
            inputCmp.reportValidity();
            this.template.querySelector(validateCmp).focus();
            this.validateRequireFields = false;
        }
    }

    submitDetails(){
        this.isLoading = true;
        this.validateAssetsRequiredFields();
        if (!this.isRequiredFieldsFill) {
            this.isLoading = false;
            return false;
        }

        if(this.otherAssetId){
            this.isLoading = true;
            console.log('Inside Edit',JSON.stringify(this.getParam()));
            editOtherAsset({otherAssetId : this.otherAssetId,accountId : this.accountId,otherAssetInfo : JSON.stringify(this.getParam())})
            .then(result => {
                refreshApex(this.otherAssetsResponse);
                fireEvent(this.pageRef, 'changeOtherAssetNetWorth', { value: this.totalAmt });
                this.clearFormData();
            })
            .catch(error => {
                console.error('Other Asset Detail error::',error);
            })
            .finally(() => {
                this.isLoading = false;
            });
        }
        else{
            this.isLoading = true;
            console.log('Inside Add',JSON.stringify(this.getParam()));
            addOtherAsset({accountId : this.accountId,  otherAssetInfo : JSON.stringify(this.getParam())})
            .then(result => {
                refreshApex(this.otherAssetsResponse);
                fireEvent(this.pageRef, 'changeOtherAssetNetWorth', { value: this.totalAmt });
                this.clearFormData();
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Other Asset Detail error::',error);
            })
            .finally(() => {
                this.isLoading = false;
            });
        }
        this.isModalOpen = false;
    }

    onHandleSort( event ) {

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.dataList];

        cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
        this.dataList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;

    }

    sortBy( field, reverse, primer ) {
        const key = primer
            ? function( x ) {
                  return primer(x[field]);
              }
            : function( x ) {
                  return x[field];
              };

        return function( a, b ) {
            a = key(a);
            b = key(b);
            return reverse * ( ( a > b ) - ( b > a ) );
        };

    }

}