import { LightningElement, api } from 'lwc';
import chartjs from '@salesforce/resourceUrl/chartJS_280';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAssetsAndLiabilities from '@salesforce/apex/x7sAssetAllocationController.getAssetsAndLiabilities';
import formFactorPropertyName from '@salesforce/client/formFactor';
import Id from '@salesforce/user/Id';
import FORM_FACTOR from '@salesforce/client/formFactor';
import {NavigationMixin} from 'lightning/navigation';


export default class X7sAssetAllocation extends NavigationMixin(LightningElement) {
    @api wealthUrl;
    chartConfiguration;
 
    isChartJsInitialized;
    userId = Id;
    legendPosition = 'bottom';
    formFactor;

    renderedCallback() {
        this.formFactor = FORM_FACTOR;
        if (this.isChartJsInitialized) {
            return;
        }

        console.log('formFactorPropertyName = '+formFactorPropertyName);
        console.log('user id = '+ this.userId);
        if(formFactorPropertyName === 'Small') {
            this.legendPosition = 'bottom';
        }
        else {
            this.legendPosition = 'right';
        }
        
        // load chartjs from the static resource
        Promise.all([loadScript(this, chartjs)])
            .then(() => {
                this.isChartJsInitialized = true;
                this.drawChart();
                
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Chart',
                        message: error.message,
                        variant: 'error',
                    })
                );
            });
    }

    goToMyAccount(){
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
                attributes: {
              name: this.wealthUrl,
            }
          });
    }

    goToContact(){
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
                attributes: {
              name: 'Contact_Us',
            }
          });
    }

    drawChart() {
        //this.userId = '0052f000001sMKHAA2';
        getAssetsAndLiabilities({ userId: this.userId })
        .then(data => {
            //data = [{"amount":581800,"color":"#E5AC80","label":"Bank Accounts"},{"amount":1000000,"color":"#DA8A77","label":"Investments with us"},{"amount":2085450.48,"color":"#EED386","label":"Investments Held Away"},{"amount":200000,"color":"#35485E","label":"Personal Properties"},{"amount":676668,"color":"#07777A","label":"Other Assets"}];
            
            console.log(' data = '+JSON.stringify(data));
            console.log(' data length= '+data.length);
            
            let chartAmtData = [];
            let chartLabel = [];
            let chartColors = [];
            let totalAmt = 0;
            let assets = data.assets;
            console.log('assets = '+JSON.stringify(assets));
            assets.forEach(asset => {
                totalAmt +=asset.amount;
            });
            
            assets.forEach(asset => {
                chartAmtData.push(asset.amount);
                let chartPerAmtData = parseFloat(((asset.amount / totalAmt)*100).toFixed(1));
                chartLabel.push(asset.label +' - '+chartPerAmtData+'%');
                chartColors.push(asset.color);
            });
            console.log('chartLabel = '+chartLabel);
            this.chartConfiguration = {
                type: 'doughnut',
                data: {
                    labels: chartLabel,
                    datasets: [{
                    data: chartAmtData,
                    backgroundColor: chartColors,
                    hoverOffset: 4
                    }]
                },
                options: {
                    tooltips: {
                        enabled: false
                    } ,
                    legend: {
                        position: 'right',
                        align: 'end',
                        maxWidth: 50,
                        labels: {
                            fontSize: 16,
                            padding: 20,
                            lineWidth: 5
                        }
                        
                    }
                },
            };

            console.log('data => ', JSON.stringify(data));
            const ctx = this.template.querySelector('canvas.doughnutChartHome').getContext('2d');
            this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfiguration)));
        })
        .catch(error => {
            this.error = error;
            console.error("error:", error);
        });
    }
}