import { LightningElement, wire,track, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import userId from '@salesforce/user/Id';
import { loadStyle } from 'lightning/platformResourceLoader';
import getTrustType from '@salesforce/apex/x7sTrustController.getTrustType';
import getTrustDetails from '@salesforce/apex/x7sTrustController.getTrustDetails';
import trustDataTableStyle from '@salesforce/resourceUrl/x7sWegTrustDataTableStyle';

const USER_FIELDS = ['User.AccountId'];

const columns = [
    { label: 'Description' , fieldName: 'Name', hideDefaultActions: true, initialWidth: 275 },
    { label: 'Trustee' , fieldName: 'WEG_Trust_Scenario__c', hideDefaultActions: true, initialWidth: 275 },
    { label: 'Trustor' , fieldName: 'trustor', hideDefaultActions: true, initialWidth: 275 },
    { label: 'Type' , fieldName: 'WEG_Trust_Category__c', hideDefaultActions: true, initialWidth: 275 },
    // { label: 'As Of Date', fieldName: 'Date_of_Trust__c', hideDefaultActions: true, type: "date-local",
    //     typeAttributes: { month: "2-digit", day: "2-digit"}
    // },
    { label: 'Value', fieldName: 'WEGP1_Total_AUM__c', hideDefaultActions: true, type: 'number',
        typeAttributes: { currencyCode: 'USD', step: '1'},
        cellAttributes: { alignment: 'right' },
        sortable:true,
        initialWidth: 100
    }
];

export default class X7sWegTrustListView extends LightningElement {

    currentUserId = userId;
    accountId;
    trustRespose;
    columns = columns;
    isLoading = false;
    isDisplayComponent = false;
    isModalOpen = false;

    trustHeader;
    trustBtnLabel;

    trustId;
    trustee;
    trustorId;
    trustorName;
    trustType;
    totalAmt;

    @api componentTitle = 'Trust';
    @track dataList;

    renderedCallback() {
        Promise.all([
            loadStyle(this, trustDataTableStyle)
        ]);
    }

    @wire(getTrustDetails)
    wiredTrustDetails(response) {  
        this.isLoading = true;
        this.trustRespose = response;
        this.totalAmt = 0;
        let error = response && response.error;
        let result = response && response.data;
        if (result && response.data.length > 0) {
            this.isDisplayComponent = true;
            this.dataList =[...result];
            //console.log('Trust Data:::', JSON.stringify(this.dataList));
            let copyData = JSON.parse(JSON.stringify(this.dataList));
            copyData.forEach(element => {
                this.totalAmt += element.WEGP1_Total_AUM__c;
                if(element.Parent.Name){
                    element.trustor = element.Parent.Name;
                }else{
                    element.trustor = 'N/A';
                }
            }); 
           this.dataList = [...copyData];
           //console.log('this.dataList',this.dataList);

        } else if (error) {
            //console.error('Error in getRecord:', error);
           
        }
        this.isLoading = false;
    }

}