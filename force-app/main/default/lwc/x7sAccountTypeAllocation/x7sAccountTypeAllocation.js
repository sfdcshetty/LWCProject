import { LightningElement } from 'lwc';
import chartjs from '@salesforce/resourceUrl/chartJS_280';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountTypeData from '@salesforce/apex/x7sAccountTypeAllocationController.getAccountTypeData';
import formFactorPropertyName from '@salesforce/client/formFactor';
import Id from '@salesforce/user/Id';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class X7sAccountTypeAllocation extends LightningElement {
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
        getAccountTypeData({ userId: this.userId })
        .then(data => {
            
            let chartAmtData = [];
            let chartLabel = [];
            let chartColors = [];
            let totalAmt = 0;
            let accountType = data;
            accountType.forEach(accType => {
                totalAmt +=accType.amount;
            });
            
            accountType.forEach(accType => {
                chartAmtData.push(accType.amount);
                let chartPerAmtData = parseFloat(((accType.amount / totalAmt)*100).toFixed(2));
                chartLabel.push(accType.label +'('+chartPerAmtData+'%)');
                chartColors.push(accType.color);
            });
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

            const ctx = this.template.querySelector('canvas.doughnutChart').getContext('2d');
            this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfiguration)));
        })
        .catch(error => {
            this.error = error;
            console.error("error:", error);
        });
    }
}