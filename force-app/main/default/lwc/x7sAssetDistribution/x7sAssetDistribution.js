import { LightningElement } from 'lwc';
import chartjs from '@salesforce/resourceUrl/chartJS_280';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAssetAllocationData from '@salesforce/apex/x7sAssetAllocationController.getAssetAllocationData';
import formFactorPropertyName from '@salesforce/client/formFactor';
import Id from '@salesforce/user/Id';
import FORM_FACTOR from '@salesforce/client/formFactor';


export default class X7sAssetDistribution extends LightningElement {
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

    drawChart() {
        //this.userId = '0052f000001sMKHAA2';
        getAssetAllocationData({ userId: this.userId })
        .then(data => {
            let chartAmtData = [];
            let chartLabel = [];
            let chartColors = [];
            let totalAmt = 0;
            //let assets = data.assets;
            let assets = data;
            //let assets = [{"amount":60,"color":"#4472C4","label":"Equity"},{"amount":20,"color":"#ED7D32","label":"Fixed Income"},{"amount":30,"color":"#5B9BD5","label":"Real Estate"},{"amount":50,"color":"#A5A5A5","label":"Alternative Investment"},{"amount":10,"color":"#70AD47","label":"Cash And Equivalents"},{"amount":30,"color":"#FFC002","label":"Other"}];
            console.log('assets = '+JSON.stringify(assets));
            assets.forEach(asset => {
                totalAmt +=asset.amount;
            });
            
            assets.forEach(asset => {
                chartAmtData.push(asset.amount);
                let chartPerAmtData = parseFloat(((asset.amount / totalAmt)*100).toFixed(2));
                chartLabel.push(asset.label +'('+chartPerAmtData+'%)');
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
            const ctx = this.template.querySelector('canvas.doughnutChart').getContext('2d');
            this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfiguration)));
        })
        .catch(error => {
            this.error = error;
            console.error("error:", error);
        });
    }
}