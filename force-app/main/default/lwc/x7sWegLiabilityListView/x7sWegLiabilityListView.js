import { LightningElement,wire,api,track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import {refreshApex} from '@salesforce/apex';
import editLiability from '@salesforce/apex/x7sLiabilityController.editLiability';
import addLiability from '@salesforce/apex/x7sLiabilityController.addLiability';
//import getTypePickListValues from '@salesforce/apex/x7sLiabilityController.getTypePickListValues';
//import getLiabilityType from '@salesforce/apex/x7sLiabilityController.getLiabilityDescriptionType';
import getLiabilityDetails from '@salesforce/apex/x7sLiabilityController.getLiabilityDetails';
import personalPropertyDataTableStyle from '@salesforce/resourceUrl/x7sWegPersonalPropertyDataTableStyle';
import getLiabilityOwnerList from '@salesforce/apex/x7sOtherAssetsController.getOtherAssetsOwnerList';
import userId from '@salesforce/user/Id';
import {fireEvent} from 'c/x7sShrUtils';
import {CurrentPageReference} from 'lightning/navigation';
import LIABILITY_OBJECT from '@salesforce/schema/FinServ__AssetsAndLiabilities__c';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

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
    { label: 'Liability Name' , fieldName: 'Name', hideDefaultActions: true , initialWidth: 270 },
    { label: 'Liability Type' , fieldName: 'FinServ__AssetsAndLiabilitiesType__c', hideDefaultActions: true, initialWidth : 180},
    // { label: 'Description' , fieldName: 'FinServ__Description__c', hideDefaultActions: true},
    { label: 'Interest Rate' , fieldName: 'WEGP1_InterestRate__c', hideDefaultActions: true, initialWidth : 140},
    { label: 'Liability Owner', fieldName: 'WEGP1_Owner_Type__c', hideDefaultActions: true , initialWidth: 200 },
    { label: 'As Of Date', fieldName: 'WEGP1_AsOfDate__c', hideDefaultActions: true, type: "date-local", initialWidth : 150,
        typeAttributes: { month: "2-digit", day: "2-digit"},
        initialWidth : 200
    },
    { label: 'Amount', fieldName: 'FinServ__Amount__c', hideDefaultActions: true, type: 'currency', initialWidth : 150, 
        typeAttributes: { currencyCode: 'USD', minimumFractionDigits: '0', maximumFractionDigits: '0'},
        cellAttributes: { alignment: 'right' },
        sortable:true,
        initialWidth : 120
    },
];

export default class X7sWegLiabilityListView extends LightningElement {
    debug = true;

    //currentUserId = '0052f000001sMKHAA2'; // userId
    currentUserId = userId;
    accountId;
    isDisplayComponent = false;
    columns = columns;
    totalAmt = 0;
    isModalOpen = false;
    
    liabilityHeader = '';
    liabilityBtnLabel = '';

    row;
    //liabilityDescriptionList;
    liabilityDetail;
    isLoading = false;
    ownerList;
    typeListOptions;

    liabilityResponse;
    liabilityId;
    liabilityName;
    // liabilityDescription;
    liabilityAsOfDate;
    liabilityOwner;
    liabilityInterestRate;
    liabilityBalance;
    liabilityType;

    defaultSortedBy = 'FinServ__Amount__c';
    sortedBy;
    defaultSortDirection = 'desc';
    sortDirection = 'desc';
    isRequiredFieldsFill = false;

    @track dataList;
    @api componentTitle = 'Liabilities';
    @api buttonLabel = 'Add Liability'; // not used
    @api addLiabilityHeader = 'Add Liability';
    @api addLiabilityButtonLabel = 'Add Liability';
    @api editLiabilityHeader = 'Edit Liability';
    @api editLiabilityButtonLabel = 'Save Liability';
    @api cancelButtonLabel = 'Cancel';

    objectRecordTypeName = 'Liability';
    liablityRecordTypeId;
    liabilityPicklistFieldName = 'FinServ__AssetsAndLiabilitiesType__c';

    @wire(CurrentPageReference) pageRef;
    
    renderedCallback() {
        Promise.all([
            loadStyle(this, personalPropertyDataTableStyle)
        ]);
    }

    // get object info for unifi questionnaire
    @wire(getObjectInfo, { objectApiName: LIABILITY_OBJECT })
    objectInfo({data,error}) {
        if (error) console.error(error);
        if (data) {
            const liabilityRecordType = Object.values(data.recordTypeInfos).find(i=>i.name===this.objectRecordTypeName); // undefined if there's no matching record type
            this.liablityRecordTypeId = liabilityRecordType ? liabilityRecordType.recordTypeId : '';
            console.log('this.liablityRecordTypeId',this.liablityRecordTypeId);
        }
    };

        // get Insured picklist values using objectInfo
    @wire(getPicklistValuesByRecordType, {
        recordTypeId: '$liablityRecordTypeId',
        objectApiName: LIABILITY_OBJECT,
    })
    getPicklistValues({ data, error }) {
        if (error) console.error(error);
        if (data) {
            this.liabilityTypeOptions = data.picklistFieldValues[this.liabilityPicklistFieldName].values; 
        }
    }

    // @wire(getLiabilityType)
    // LiabilityTypeRecord({ error, data }) {
    //     if (data) {
    //         this.liabilityDescriptionList = data;
    //     }
    //     else if (error) {
    //         console.error(error);
    //     }
    // }

    @wire(getRecord, { recordId: '$currentUserId', fields: USER_FIELDS })
    wiredUserRecord({ error, data }) {
        if (error) {
            console.error('Error in getRecord:', error);
        } else if (data) {
            this.accountId = data.fields.AccountId.value;
        }
    }

    @wire(getLiabilityOwnerList, { accountId : '$accountId' })
    wiredOwnerList(response) {
        if (response) {
            this.ownerList = response['data'];
        } else if (error) {
            if (this.debug) console.log('ownerList error = '+error);
            console.error('Error in get owner lists:', error);

        }
    }

    @wire(getLiabilityDetails, { accountId : '$accountId' })
    wiredProfileDetails(response) {  
        this.isLoading = true;
        this.liabilityResponse = response;
        this.totalAmt = 0.0;
        let error = response && response.error;
        let result = response && response.data;
        if (result) {
            this.isDisplayComponent = true;
            let mainData = [...result];
            for (let i = 0; i < mainData.length; i++) {
                if ( mainData[i].FinServ__Amount__c && typeof mainData[i].FinServ__Amount__c === 'number') {
                  this.totalAmt = this.totalAmt + mainData[i].FinServ__Amount__c;
                }
            }
            // pre-sort the data according to the field named in this.defaultSortedBy
            if (this.defaultSortedBy) {
                mainData.sort((a,b)=>{
                    let cmp = (a[this.defaultSortedBy]<b[this.defaultSortedBy]) ? -1 : a[this.defaultSortedBy]>b[this.defaultSortedBy] ? 1 : 0;
                    if (this.defaultSortDirection==='desc') cmp *= -1;
                    return cmp;
                });
            }
            //this.dataList =[...result];
            /*let copyData = JSON.parse(JSON.stringify(this.dataList));
            copyData.forEach(element => {
                this.totalAmt += element.FinServ__Amount__c;
            });
            this.dataList = [...copyData];;*/
            //this.totalAmt = mainData.reduce((acc,curr)=>acc+curr.FinServ__Amount__c,0);
            this.dataList = mainData;
            if (this.debug) console.log('this.dataList',this.dataList);
        } else if (error) {
            console.error('Error in getRecord:', error);
        }
        this.isLoading = false;
    }


    /*@wire(getTypePickListValues, {})
    wiredPicklistVals(response) {
        
        if (response) {
            console.log('my picklist valss', response);
            this.typeListOptions = response['data'];
        } else if (error) {
            console.log('pickList error = '+error);
            console.error('Error in get picklist vals:', error);

        }
    } */

    // get liabilityDescriptionOptions() {
    //     var liabilityTypeValues = [];
    //     for (let key in this.liabilityDescriptionList) {
    //         liabilityTypeValues.push({ label: this.liabilityDescriptionList[key], value: this.liabilityDescriptionList[key] });
    //     }
    //     return liabilityTypeValues;
    // }
    get liabilityOwnerOptions() {
        var ownerListValues = [];
        for (let key in this.ownerList) {
            ownerListValues.push({ label: this.ownerList[key], value: key });
        }
        return ownerListValues;
    }

    getParam() {
        let amount=this.liabilityBalance;
        //amount=amount.replace(/\,/g,''); //convert it to number
        this.liabilityBalance = amount;

        let params = {
            Name: this.liabilityName,
            Type: this.liabilityType,
            // Description: this.liabilityDescription,
            Owner: this.liabilityOwner,
            Amount: Math.round(this.liabilityBalance),
            AsOfDate: this.liabilityAsOfDate,
            InterestRate: this.liabilityInterestRate,
        }
        return params;
    }

    clearFormData(){
        this.liabilityId = '';
        this.liabilityName = '';
        this.liabilityBalance = 0.00;
        this.liabilityOwner = '';
        this.liabilityType = '';
        // this.liabilityDescription = '';
        this.liabilityInterestRate = 0.00;
        this.liabilityAsOfDate = '';
    }

    handleRowAction(event) {

        if (this.debug) console.log('inside Edit::::');
        
        this.isModalOpen = true;
    
        this.liabilityHeader = this.editLiabilityHeader;
        this.liabilityBtnLabel = this.editLiabilityButtonLabel;

        this.row = event.detail.row;
        this.liabilityId = event.detail.row.Id
        this.liabilityName = event.detail.row.Name;
        this.liabilityType = event.detail.row.FinServ__AssetsAndLiabilitiesType__c;
        //this.liabilityDescription = event.detail.row.FinServ__AssetsAndLiabilitiesType__c;
        // this.liabilityDescription = event.detail.row.FinServ__Description__c;
        if(event.detail.row.WEGP1_Owner_Type__c === 'Joint') {
            this.liabilityOwner = 'Joint';
        } else {
            this.liabilityOwner = event.detail.row.FinServ__PrimaryOwner__c;
        }
        this.liabilityBalance = event.detail.row.FinServ__Amount__c;
        this.liabilityAsOfDate = event.detail.row.WEGP1_AsOfDate__c;
        this.liabilityInterestRate = event.detail.row.WEGP1_InterestRate__c;

    }

    validateAccountRequiredFields() {
        var validateCmp = '';
        if (!this.liabilityName) {
            validateCmp = ".validateLiabilityName";
        } 
        else if (!this.liabilityOwner) {
            validateCmp = ".validateLiabilityOwner";
        } 
        else if (!this.liabilityType) {
            validateCmp = ".validateLiabilityType";
        } 
        // else if (!this.liabilityDescription) {
        //     validateCmp = ".validateLiabilityDescription";
        // } else if (!this.liabilityInterestRate) {
        //     validateCmp = ".validateLiabilityInterestRate";
        // } else if (!this.liabilityAsOfDate) {
        //     validateCmp = ".validateLiabilityAsOfDate";
        // } else if (!this.liabilityBalance) {
        //     validateCmp = ".validateLiabilityBalance";
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

    handleLiabilityNameChange(event){  this.liabilityName = event.target.value; }
    handleLiabilityTypeChange(event){  this.liabilityType = event.target.value; }
    //handleLiabilityDescriptionChange(event){  this.liabilityDescription = event.target.value; }
    handleLiabilityInterestRateChange(event){  this.liabilityInterestRate = event.target.value; }
    handleLiabilityOwnerChange(event){  this.liabilityOwner = event.target.value; }
    handleLiabilityAsOfDtChange(event){  this.liabilityAsOfDate = event.target.value; }
    handleAmountChange(event){  this.liabilityBalance = event.target.value; }


    handleAddPropertyClick(event){
        this.clearFormData();
        this.isModalOpen = true;
        this.liabilityHeader = this.addLiabilityHeader;
        this.liabilityBtnLabel = this.addLiabilityButtonLabel;

    }

    closeModal() {
        this.clearFormData();
        this.isModalOpen = false;
    }

    submitDetails(){
        //console.log('propertyid='+this.propertyId);
        this.isLoading = true;
        this.validateAccountRequiredFields();
        if (!this.isRequiredFieldsFill) {
            this.isLoading = false;
            return false;
        }
        
        if(this.liabilityId){
            if (this.debug) console.log('Inside Edit');
            if (this.debug) console.log('liabilityId='+this.liabilityId);
            if (this.debug) console.log('liabilityInfo='+JSON.parse(JSON.stringify(this.getParam())));
            editLiability({liabilityId : this.liabilityId,accountId : this.accountId,liabilityInfo : JSON.stringify(this.getParam())})
            
            .then(result => {
                console.log('has result');
                refreshApex(this.liabilityResponse);
                fireEvent(this.pageRef, 'changeLiabilitytNetWorth', { value: this.totalAmt });
                this.clearFormData();
            })
            .catch(error => {
                console.error('Liability Detail error::',error);
            })
            .finally(() => {
               this.isLoading = false;
            });
        }
        else{
            if (this.debug) console.log('Inside Add');
            if (this.debug) console.log('accountId='+this.accountId);
            if (this.debug) console.log('liability data', this.getParam());
            addLiability({accountId : this.accountId,liabilityInfo : JSON.stringify(this.getParam())})
            .then(result => {
                if (this.debug) console.log('has result');
                if (this.debug) console.log('liabilityResponse='+JSON.parse(JSON.stringify(this.liabilityResponse)))
                refreshApex(this.liabilityResponse);
                fireEvent(this.pageRef, 'changeLiabilitytNetWorth', { value: this.totalAmt });
                this.clearFormData();
            })
            .catch(error => {
                console.error('Liability Detail error::',error);
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