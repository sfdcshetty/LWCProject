import { LightningElement, track } from 'lwc';
import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";
import getAssetsAndLiabilities from '@salesforce/apex/x7sAssetAllocationController.getAssetsAndLiabilities';
import getMyHouseholdInfo2 from '@salesforce/apex/x7sAssetAllocationController.getMyHouseholdInfo2';
import NET_WORTH from '@salesforce/schema/Account.FinServ__NetWorth__c';
import Id from '@salesforce/user/Id';

export default class X7sWegMyWealthBannerInfo extends LightningElement {
    assets;
    liability;
    @track totalAmt = 0;
    myTotalAmt;
    @track loadLiability =false;
    @track loadGrandTotal = false;
    myGrandTotal = 0;
    netWorthIcon = WEG_LOGO_PATH + '/WEG_Assets/icons/est-net-icon.png';
    invIcon = WEG_LOGO_PATH + '/WEG_Assets/icons/inv-icon.png';
    userId = Id;
    amountWithWeg;

    connectedCallback(){
        console.log('Inside connected call back banner::::');
        this.getAssetsAndLiabilities();
        this.myTotalAmt = this.totalAmt;
    }

    renderedCallback(){
        
    }

    calculateGrandTotal(){
        this.myGrandTotal = this.totalAmt + this.liability.amount;
        this.myTotalAmt = this.totalAmt;
        getMyHouseholdInfo2({ myNetWorth: this.myGrandTotal })
        .then(result=>{
            let myStuff = result;
            let myAccountNumber = myStuff;
        })
        .catch(error=>{
            console.error(error);
        });
        
    }
    

    getAssetsAndLiabilities(){
        getAssetsAndLiabilities({ userId: this.userId })
        .then(data => {
            this.assets = data.assets;
            this.liability = data.liability;
            this.loadLiability = true;
            //console.log('myassets = ', this.assets);
            this.amountWithWeg = this.assets[1].amount;
            this.assets.forEach(asset => {
                this.totalAmt +=asset.amount;
            });
            this.loadGrandTotal = true;
            if(this.totalAmt && this.totalAmt>0) { this.calculateGrandTotal(); }
        })
        .catch(error => {
            this.error = error;
        });
    }
}