import { LightningElement,track,api,wire } from 'lwc';
import getAssetsAndLiabilities from '@salesforce/apex/x7sAssetAllocationController.getAssetsAndLiabilities';
import Id from '@salesforce/user/Id';
import {refreshApex} from '@salesforce/apex';
import {registerListener} from 'c/x7sShrUtils';
import {CurrentPageReference} from 'lightning/navigation';

export default class X7sNetWorthSummary extends LightningElement {
    @api title = 'Net Worth Summary';
    @api labelTotal = 'Net Worth - Estimated';

    debug = true;

    assets = [];
    liability;
    userId = Id;
    @track totalAmt = 0;
    @track loadLiability =false;
    @track loadGrandTotal = false;
    myGrandTotal = 0;
    liabilityAmount = 0;
    netWorthyResponse;

    @wire(CurrentPageReference) pageRef;

    renderedCallback(){
        registerListener('changeBankAccountNetWorth', this.handleNetWorthChange, this);
        registerListener('changeOtherAssetNetWorth', this.handleNetWorthChange, this);
        registerListener('changePersonalPropertytNetWorth', this.handleNetWorthChange, this);
        registerListener('changeLiabilitytNetWorth', this.handleNetWorthChange, this);
        registerListener('changeInvestmentHeldAwayNetWorth', this.handleNetWorthChange, this);




        //this.getAssetsAndLiabilities();
        //if(this.totalAmt && this.totalAmt>0) { this.calculateGrandTotal(); }
    }

    calculateGrandTotal(){
        this.myGrandTotal = this.totalAmt + this.liability.amount;
    }

    @wire(getAssetsAndLiabilities, { userId : '$userId' })
    wiredNetWorthyList(response) {
        this.netWorthyResponse = response;
        let error = response && response.error;
        let data = response && response.data;
        if (data) {
            //data = [{"amount":581800,"color":"#E5AC80","label":"Bank Accounts"},{"amount":1000000,"color":"#DA8A77","label":"Investments with us"},{"amount":2085450.48,"color":"#EED386","label":"Investments Held Away"},{"amount":200000,"color":"#35485E","label":"Personal Properties"},{"amount":676668,"color":"#07777A","label":"Other Assets"}];
            
            //console.log(' data = '+JSON.stringify(data));

            this.assets = data.assets.map(row => ({
                ...row,
                isNegativeValue: row.amount<0
            }));


            
            console.log('myAssets', this.assets);

            //this.record = result;
            


            this.loadLiability = true;
            this.liability = data.liability;
            if(this.liability){
                this.liabilityAmount = Math.abs(this.liability.amount);
            }
           
            //if (this.debug) console.log('assets = '+JSON.stringify(this.assets));
            this.assets.forEach(asset => {
                console.log('adding...', asset.amount);
                this.totalAmt +=asset.amount;
                if(asset.amount<0){
                    asset.amount = asset.amount*-1;
                }
            });

            this.loadGrandTotal = true;
            //this.grandTotal = this.totalAmt + this.liability.amount;

            if(this.totalAmt && this.totalAmt>0) { this.calculateGrandTotal(); }

            //if (this.debug) console.log('totalAssets = '+this.totalAmt);
            if (this.debug) {
                //console.log('totalliabilities = '+this.liability.amount);
            }
            if (this.debug) {
                 //console.log('grand total = '+(this.totalAmt + this.liability.amount));
            }
        } else if (error) {
            this.error = error;
            console.error("error:", error);
        }
    }

    /*getAssetsAndLiabilities(){
        getAssetsAndLiabilities({ userId: this.userId })
        .then(data => {
            //data = [{"amount":581800,"color":"#E5AC80","label":"Bank Accounts"},{"amount":1000000,"color":"#DA8A77","label":"Investments with us"},{"amount":2085450.48,"color":"#EED386","label":"Investments Held Away"},{"amount":200000,"color":"#35485E","label":"Personal Properties"},{"amount":676668,"color":"#07777A","label":"Other Assets"}];
            
            //console.log(' data = '+JSON.stringify(data));
            this.assets = data.assets;
            console.log('myAssets', this.assets);

            this.liability = data.liability;
            this.loadLiability = true;
            //if (this.debug) console.log('assets = '+JSON.stringify(this.assets));
            this.assets.forEach(asset => {
                console.log('adding...', asset.amount);
                this.totalAmt +=asset.amount;
            });
            this.loadGrandTotal = true;
            //this.grandTotal = this.totalAmt + this.liability.amount;

            //if (this.debug) console.log('totalAssets = '+this.totalAmt);
            if (this.debug) {
                //console.log('totalliabilities = '+this.liability.amount);
            }
            if (this.debug) {
                 //console.log('grand total = '+(this.totalAmt + this.liability.amount));
            }
        })
        .catch(error => {
            this.error = error;
            console.error("error:", error);
        });
    } */

    handleNetWorthChange(event){
        this.totalAmt = 0;
        console.log('Inside handle bank account::::', event.value);
        refreshApex(this.netWorthyResponse);
    }
}