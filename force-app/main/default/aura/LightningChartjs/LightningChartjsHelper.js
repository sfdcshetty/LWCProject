({
    fetchBrandColor : function(component, event, helper) {
        var action = component.get("c.getBrandColors");
        action.setCallback(this, function(response){
            var state = response.getState();
            var outputresponse = response.getReturnValue();
            if (state === "SUCCESS") {
                var colorMap = new Map();
                //alert('asdasd-->'+JSON.stringify(outputresponse));
                for(var i=0; i < outputresponse.length; i++){
                    colorMap.set(outputresponse[i].AccountType,outputresponse[i].Color);
                }    
                helper.displaydata(component,event,helper,colorMap);
            }
        });
        $A.enqueueAction(action);
    },
    displaydata : function(component, event, helper,colorMap) {
        	//alert(colorMap);
            var sobje = component.get("v.sObj");
            var field = component.get("v.field");
            var map = new Map();
            var listofpicklistvalues = component.get("v.picklistvalues")
            var action = component.get("c.generateDataa");
            action.setParams({
                selectedObject : sobje,
                selectedfield : field
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                var outputresponse = response.getReturnValue();
                if (state === "SUCCESS") {
                    for(var j=0; j< listofpicklistvalues.length; j++){
                        var openopps=0;
                        for(var i=0; i < outputresponse.length; i++){
                            console.log('res::'+outputresponse[i].selectedfield);
                            if(listofpicklistvalues[j] === outputresponse[i].selectedfield){
                                console.log('Amount =====================>'+outputresponse[i].Amount);
                                openopps = openopps+outputresponse[i].Amount;
                            }
                        }
                        var finalTotal = openopps.toString();
                        map.set(listofpicklistvalues[j],finalTotal);
                    }
                    this.helperMethod(component, event, helper, map, listofpicklistvalues,colorMap);
                } 
            });
            $A.enqueueAction(action);
           },
        
        
        helperMethod : function(component, event, helper, map, listofpicklistvalues,colorMap) {
            var doughnutData = [];
            var labelNames = [];
            var bcolor = [];
            var typeofchart = component.get("v.Charttype");
            var field = component.get("v.field");
            console.log('listofpicklistvalues====>'+JSON.stringify(listofpicklistvalues));
            for (var i = 0; i < listofpicklistvalues.length; i++) {
                //var color = this.getRandomColor();
                var color = colorMap.get(listofpicklistvalues[i]);
                labelNames.push(listofpicklistvalues[i]); 
                doughnutData.push(map.get(listofpicklistvalues[i])); 
                bcolor.push(color);
            }
            // chart code
          	var mydoughnutChart = new Chart(document.getElementById("doughnutChart"), {
                type: typeofchart,
                data: {
                    labels: labelNames,
                    datasets: [{
                        backgroundColor: bcolor,
                        data: doughnutData
                    }]
                },
                options: {
                    legend: { display: false },
                    
                    title: {
                        display: true,
                        text: 'Account Type',
                    }
                    /*,
                    tooltips: {
                          callbacks: {
                            label: function(tooltipItem, data) {
                              var label = data.datasets[tooltipItem.datasetIndex].labels[tooltipItem.index];
                              var value = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                              return 'Label';
                            }
                    	}
                	} */
                      
                }
            });
          },
       // This function will generate colors dynamically 
        getRandomColor : function(component) {
            var letters = '0123456789ABCDEF';
            var color = '#';
            for (var i = 0; i < 6; i++ ) {
                color += letters[Math.floor(Math.random() * 16)];
            }
            return color;
        }
    })