import { api,LightningElement } from 'lwc';
import { fireEvent } from 'c/pubsub';

export default class X7sFinancialProfileLiquidityNeeds extends LightningElement {
    @api debug = false;
    @api liquidityNeeds = '';

    showLiquidityNeeds = false;
    get haveLiquidityNeeds() {
        return (this.showLiquidityNeeds || (this.liquidityNeeds && this.liquidityNeeds.length));
    }
    get haveLiquidityNeedsYesNo() {
        return (this.haveLiquidityNeeds) ? 'Yes' : 'No';
    }
    optionsYesNo = [
        { label:"Yes", value:"Yes" },
        { label:"No", value:"No" },
    ]

    connectedCallback() {
        if (this.debug) console.log('liquidityNeeds:',this.liquidityNeeds);
    }

    dispatchData() {
        const obj = { 
            Liquidity_Needs_Details__c: this.liquidityNeeds,
        };
        this.dispatchEvent(new CustomEvent('savetempdata', {
            detail: {
                personalInfo: obj
            }
        }));
    }

    handleChangeLiquidityNeedsYesNo(event) {
        if (event.detail.value==='Yes') {
            this.showLiquidityNeeds = true;
        } else {
            fireEvent('goNext','next screen');
        }
    }
    handleChangeDescription(event) {
        this.liquidityNeeds = event.detail.value;
        this.dispatchData();
    }
}