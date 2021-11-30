import { api, track, LightningElement, wire } from 'lwc';
import getAssetsAndLiabilities from '@salesforce/apex/x7sAssetAllocationController.getAssetsAndLiabilities';
import Id from '@salesforce/user/Id';
import {refreshApex} from '@salesforce/apex';
import {registerListener} from 'c/x7sShrUtils';
import {CurrentPageReference} from 'lightning/navigation';

export default class X7sWegMyWealthBannerInfo extends LightningElement {
    @api title = 'My Wealth';
    @api labelInvestments = 'Investments';
    @api subLabelInvestments = 'Held With Us';
    @api labelNetWorth = 'Net Worth';
    @api subLabelNetWorth = 'Estimated';

    assets;
    liability;
    @track totalAmt = 0;
    myTotalAmt;
    amountWithWeg;
    @track loadLiability =false;
    @track loadGrandTotal = false;
    myGrandTotal = 0;
    userId = Id;

    netWorthyResponse;

    @wire(CurrentPageReference) pageRef;

    connectedCallback(){
        //this.getAssetsAndLiabilities();
        //this.myTotalAmt = this.totalAmt;
    }

    renderedCallback(){
        registerListener('changeBankAccountNetWorth', this.handleNetWorthChange, this);
        registerListener('changeOtherAssetNetWorth', this.handleNetWorthChange, this);
        registerListener('changePersonalPropertytNetWorth', this.handleNetWorthChange, this);
        registerListener('changeLiabilitytNetWorth', this.handleNetWorthChange, this);
        registerListener('changeInvestmentHeldAwayNetWorth', this.handleNetWorthChange, this);

    }

    calculateGrandTotal(){
        this.myGrandTotal = this.totalAmt + this.liability.amount;
        this.myTotalAmt = this.totalAmt;
        console.log('myAmt', this.myTotalAmt);
    }

    @wire(getAssetsAndLiabilities, { userId : '$userId' })
    wiredNetWorthyList(response) {
        this.netWorthyResponse = response;
        let error = response && response.error;
        let data = response && response.data;
        if (data) {
            //data = [{"amount":581800,"color":"#E5AC80","label":"Bank Accounts"},{"amount":1000000,"color":"#DA8A77","label":"Investments with us"},{"amount":2085450.48,"color":"#EED386","label":"Investments Held Away"},{"amount":200000,"color":"#35485E","label":"Personal Properties"},{"amount":676668,"color":"#07777A","label":"Other Assets"}];
            
            //console.log('my financial data', data);
            this.assets = data.assets;
            this.amountWithWeg = (this.assets[1])? this.assets[1].amount : 0;

            this.liability = data.liability;
            this.loadLiability = true;
            //console.log('myassets = '+JSON.stringify(this.assets));
            this.assets.forEach(asset => {
                this.totalAmt += asset.amount;
            });
            this.loadGrandTotal = true;
            //this.grandTotal = this.totalAmt + this.liability.amount;

            //console.log('mytotalAssets = '+this.totalAmt);
            //console.log('mytotalliabilities = '+this.liability.amount);
            //console.log('mygrand total = '+(this.totalAmt + this.liability.amount));
            if(this.totalAmt && this.totalAmt>0) { this.calculateGrandTotal(); }
        } else if (error) {
            this.error = error;
            console.error("error:", error);
        }
    }

    handleNetWorthChange(event){
        this.totalAmt = 0;
        console.log('Inside Banner Short', event.value);
        refreshApex(this.netWorthyResponse);
    }



    /* getAssetsAndLiabilities(){
        getAssetsAndLiabilities({ userId: this.userId })
        .then(data => {
            //data = [{"amount":581800,"color":"#E5AC80","label":"Bank Accounts"},{"amount":1000000,"color":"#DA8A77","label":"Investments with us"},{"amount":2085450.48,"color":"#EED386","label":"Investments Held Away"},{"amount":200000,"color":"#35485E","label":"Personal Properties"},{"amount":676668,"color":"#07777A","label":"Other Assets"}];
            
            //console.log('my financial data', data);
            this.assets = data.assets;
            this.amountWithWeg = this.assets[1].amount;

            this.liability = data.liability;
            this.loadLiability = true;
            //console.log('myassets = '+JSON.stringify(this.assets));
            this.assets.forEach(asset => {
                this.totalAmt += asset.amount;
            });
            this.loadGrandTotal = true;
            //this.grandTotal = this.totalAmt + this.liability.amount;

            //console.log('mytotalAssets = '+this.totalAmt);
            //console.log('mytotalliabilities = '+this.liability.amount);
            //console.log('mygrand total = '+(this.totalAmt + this.liability.amount));
            if(this.totalAmt && this.totalAmt>0) { this.calculateGrandTotal(); }
        })
        .catch(error => {
            this.error = error;
            //console.error("error:", error);
        });
    } */
}