({
    generateForms : function (Component, event, helper, result, type) {
        var selectedType = Component.get('v.selectedRecord');
        var newResults = [];
        if (!$A.util.isEmpty(selectedType) && !$A.util.isUndefined(selectedType)) {
            var selectedFormsVal = Component.get('v.selectedForms');
            if (!$A.util.isEmpty(selectedFormsVal) && !$A.util.isUndefined(selectedFormsVal)) {
                if (selectedFormsVal.hasOwnProperty(selectedType)) {
                    var selectedFormIdsForType = selectedFormsVal[selectedType];
                    
                    for (var i = 0; i < result.length; i++) {
                        var newRes = result[i];
                        var qformIds = [];
                        for (var k = 0; k < selectedFormIdsForType.length; k++) {
                            qformIds.push(selectedFormIdsForType[k].formId);
                        }
                        if (qformIds.includes(result[i].formId)) {
                            newRes.iconName = 'utility:delete';
                        } else {
                            newRes.iconName = 'utility:add';
                        }
                        newResults.push(newRes);
                    }	
                } else {
                    newResults = result;
                }
            } else {
                newResults = result;
            }
        } else {
            newResults = result;
        }
        console.log(newResults);
        if (type == 'search')
        	Component.set("v.searchFormResults", newResults);	
        if (type == 'bundle')
        	Component.set("v.bundleFormResults", newResults);	
    },
	searchForms: function (Component, event, helper, type) {
		var categories = [];
		var dealers = [];
		var category = Component.get('v.selectedCategory');
		categories.push(category);
    
		var dealer = Component.get('v.selectedDealer');
		dealers.push(dealer);
    
		var formIds = Component.get('v.loadedForms');
		var formRecIds = [];
		
    	var pageNumberVal = Component.get('v.pageNumber');
		pageNumberVal = parseInt(pageNumberVal)+1;
		if (type == 'back') {
			if (!$A.util.isEmpty(formIds) && !$A.util.isUndefined(formIds)) {
				for (var key in formIds) {
					if (key >= pageNumberVal)
						delete formIds[key];
				}
				Component.set ('v.loadedForms', formIds);
				for (var key in formIds) {
					if (key != pageNumberVal) {
						for (var i = 0; i <formIds[key].length; i++) {
							formRecIds.push(formIds[key][i]);
						}
					}
				}
			}
		}
		if (type == 'next') {
			if (!$A.util.isEmpty(formIds) && !$A.util.isUndefined(formIds)) {
				for (var key in formIds) {
					for (var i = 0; i <formIds[key].length; i++) {
						formRecIds.push(formIds[key][i]);
					}
				}
			}
		}
		var action = Component.get("c.searchForms");
		action.setParams ({
			formName : Component.get('v.formNameKeyword'),
			categoryIds : categories,
			dealerIds : dealers,
			pageNumber : pageNumberVal,
			formIdsLoaded : formRecIds
		});
		action.setCallback(this, function(result){
			var result = result.getReturnValue();
			helper.generateForms (Component, event, helper, result, 'search');
			
            var totalRecords = 0;
			var currentFormIds = [];
			for (var i = 0; i < result.length; i++){
				totalRecords = result[i].totalCount;
				currentFormIds.push(result[i].formId);
			}
			if (!$A.util.isEmpty(formIds) && !$A.util.isUndefined(formIds)) {
				formIds[pageNumberVal] = currentFormIds;
			} else {
				formIds = new Object();
				formIds[pageNumberVal] = currentFormIds;
			}
			Component.set ('v.loadedForms', formIds);
			var lastPageNumberVal = Math.round(totalRecords/10);
			Component.set ('v.lastPageNumber', lastPageNumberVal);
			if (pageNumberVal == 1 && type != 'back') {
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "",
					"message": totalRecords +" forms found."
				});
				toastEvent.fire();
			}
			Component.set ('v.showSpinner', false);
		});
		$A.enqueueAction(action);
	},
	fetchBundledRecords : function (component, event, helper, pageNumberVal, pageSizeVal) {
		var selectedBundleId = component.get('v.selectedBundleGroup');
        
		component.set ('v.showSpinner', true);
		var action = component.get("c.getForms");
		action.setParams ({bundleId: selectedBundleId, pageNumber: pageNumberVal, pageSize: pageSizeVal});
        action.setCallback(this, function(result){
            var result = result.getReturnValue();
			helper.generateForms(component, event, helper, result, 'bundle');
            var totalRecords = 0;
			for (var i = 0; i < result.length; i++) {
                var newRes = result[i];
                totalRecords = newRes.totalRecords;
                component.set("v.bundlePageNumber", newRes.pageNumber);
                component.set("v.bundleTotalRecords", newRes.totalRecords);
                component.set("v.bundleRecordStart", newRes.recordStart);
                component.set("v.bundleRecordEnd", newRes.recordEnd);
                component.set("v.bundleTotalPages", Math.ceil(newRes.totalRecords / pageSizeVal));
            }
            if (pageNumberVal == 1) {
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "",
					"message": totalRecords +" forms found."
				});
				toastEvent.fire();
			}
			component.set ('v.showSpinner', false);
			
		});
		$A.enqueueAction(action);
	},
	addOrRemoveForms: function (component, event, helper, selectedFormId, selectedRecordVal) {

		var selectedFormsVal = component.get('v.selectedForms');
		var formRemoved = false;
		var formIds = [];
		if (!$A.util.isEmpty(selectedFormsVal) && !$A.util.isUndefined(selectedFormsVal)) {
			if (selectedFormsVal.hasOwnProperty(selectedRecordVal)) {
				formIds = selectedFormsVal[selectedRecordVal];
				var qformIds = [];
				for (var k = 0; k < formIds.length; k++) {
					qformIds.push(formIds[k].formId);
				}

				if (!qformIds.includes(selectedFormId)) {
					formIds.push (selectedFormId);
				} else {
					var newFormIds = [];
					for (var j = 0; j < formIds.length; j++) {
						if (formIds[j].formId != selectedFormId) {
							newFormIds.push(formIds[j]);
							formRemoved = true;
						}
					}
					if (formIds.length == 1) {
						formRemoved = true;
					}
					formIds = [];
					formIds = newFormIds;
				}
			} else {
				formIds.push (selectedFormId);
			}
		} else {
			selectedFormsVal = new Object();
			formIds.push (selectedFormId);
		}
		var result = component.get ('v.searchFormResults');
		var newResults = [];
		for (var i = 0; i < result.length; i++) {
			var newRes = result[i];
			for (var j = 0; j < formIds.length; j++) {
				if (formIds[j] == result[i].formId) {
					formIds[j] = result[i];
				}
			}
			if (result[i].formId == selectedFormId && formRemoved == false) {
				newRes.iconName = 'utility:delete';
			} 
			if (result[i].formId == selectedFormId && formRemoved) {
				newRes.iconName = 'utility:add';
			}
			newResults.push(newRes);
		}
		component.set('v.searchFormResults', newResults);
		
		var bundleResult = component.get ('v.bundleFormResults');
		var newBundleResults = [];
		for (var i = 0; i < bundleResult.length; i++) {
			var newBundleRes = bundleResult[i];
			for (var j = 0; j < formIds.length; j++) {
				if (formIds[j] == bundleResult[i].formId) {
					formIds[j] = bundleResult[i];
				}
			}
			if (bundleResult[i].formId == selectedFormId && formRemoved == false) {
				newBundleRes.iconName = 'utility:delete';
			} 
			if (bundleResult[i].formId == selectedFormId && formRemoved) {
				newBundleRes.iconName = 'utility:add';
			}
			newBundleResults.push(newBundleRes);
		}
		selectedFormsVal[selectedRecordVal] = formIds;
		component.set('v.selectedForms', selectedFormsVal);
		component.set('v.bundleFormResults', newBundleResults);
		
		helper.loadReviewScreen(component, event, helper);
	},
	loadReviewScreen: function (component, event, helper) {
		var forms = component.get('v.selectedForms');
		var options = component.get('v.records');
        
		var custodianMap = {};
		for (var key in forms) {
			var formIds = forms[key];
			var innerVal = [];
			for (var val in formIds) {
				var formTemp = {"formId" : formIds[val].formId, "formShortName": formIds[val].formShortName, 
								"formDesc" : formIds[val].formDesc, "dealerName" : formIds[val].dealerName};
				innerVal.push (formTemp);
			}
			var name = '';
			var custodian = '';
			for (var rec in options) {
				if (options[rec].value == key) {
					name = options[rec].label;
					custodian = options[rec].custodian;
				}
			}
			if (!$A.util.isEmpty(name) && !$A.util.isUndefined(name) && innerVal.length > 0) {
				var temp = { "key":name, "id":key, "records":innerVal };
				var innerTemp = [];
				if (custodianMap.hasOwnProperty(custodian)) {
					innerTemp = custodianMap[custodian];
					innerTemp.push (temp);
					custodianMap[custodian] = innerTemp;
				} else {
					innerTemp.push(temp);
					custodianMap[custodian] = innerTemp;
				}
			}
		}
		var custodianJson = [];
		var custodiansVal = {};
		var j = 1;
        for (var i in custodianMap) {
			var temp = {"name" : i, "records"  : custodianMap[i]};
			custodianJson.push(temp);
			custodiansVal[j] = i;
        	j = j + 1;
		}
        component.set('v.custodians', custodiansVal);
		component.set('v.selectedCustodianRecords', custodianJson);
		component.set ('v.selectedForms', forms);
		
        var stepNumber = component.get("v.selectedStep");
		if (stepNumber == 'step3') {            
            component.set('v.htmlURLs', '');  
            component.set('v.formNumber', 1);
            component.set('v.totalForms', j);
            var selectedStep2 = component.get("v.selectedStep2");
            if(selectedStep2 == true){
                var step1Id = component.find("step1Id");
                var step2Id = component.find("step2Id");
                var step3Id = component.find("step3Id");
                $A.util.addClass(step1Id, ('disableCls'));
                $A.util.addClass(step2Id, ('disableCls'));
                $A.util.addClass(step3Id, ('disableCls'));
                helper.generateHTML(component, event, helper, custodianJson, 1, j);
            }else{
                component.set ('v.showSpinner', false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Please select/review forms before you Fill.",
                    "type": "error"
                });
                toastEvent.fire();
                component.set("v.selectedStep", "step1");
            }
		}
	},
	generateHTML : function(component, event, helper, completeJson, key, totalCustodians){
		var custodianVals = component.get('v.custodians');
		var uniqueIdsVal = component.get('v.uniqueIds');

		var jsonReq = '';		
		for (var i = 0; i < completeJson.length; i++) {
			
			var temp = completeJson[i];
            console.log(custodianVals[key], temp.name);
			if (temp.name == custodianVals[key] && jsonReq == '') {
				jsonReq = JSON.stringify(temp.records);
			}
		}
        console.log(jsonReq);
		if (!$A.util.isEmpty(jsonReq) && !$A.util.isUndefined(jsonReq) && jsonReq != '[]') {
			var action = component.get("c.generateHTML");
			var asRecordId = component.get('v.recordId');
			var unIdsKey = '';

			if (!$A.util.isEmpty(uniqueIdsVal) && !$A.util.isUndefined(uniqueIdsVal) && uniqueIdsVal != null) {
				if(uniqueIdsVal.hasOwnProperty(custodianVals[key])) {
					unIdsKey = uniqueIdsVal[custodianVals[key]];
				}
			}
            console.log(custodianVals[key]+':::::'+key+'::::UNID::::'+unIdsKey);
			action.setParams ({
				jsonBody : '{"results":'+jsonReq+'}',
				urlId : unIdsKey,
				recordId : asRecordId
			});
			action.setCallback(this, function(result){
				var result = result.getReturnValue();
				if (!$A.util.isEmpty(result) && !$A.util.isUndefined(result)) {
					var resultRes = JSON.parse(result);
                    console.log(resultRes);
                    component.set('v.currentCustodianName', custodianVals[key]);
					component.set('v.htmlURLs', resultRes.URL);
					component.set('v.asQuikFormId', resultRes.recId);
                    
					var unIdsVal = component.get('v.uniqueIds');
					if (unIdsVal == null)
						unIdsVal = {};
					unIdsVal[custodianVals[key]] = resultRes.UNID;
					component.set('v.uniqueIds', unIdsVal);
                    component.set ('v.showSpinner', false);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    component.set ('v.showSpinner', false);
                    toastEvent.setParams({
                        "title": "",
                        "type" : "error",
                        "message": "Failed to generate the form. Please try again!!!"
                    });
                    toastEvent.fire();
                    component.set ('v.showSpinner', false);
                }
				
			});
			$A.enqueueAction(action);
        } else {
            component.set('v.selectedStep2', false);
            var step1Id = component.find("step1Id");
            var step2Id = component.find("step2Id");
            var step3Id = component.find("step3Id");
            $A.util.removeClass(step1Id, ('disableCls'));
            $A.util.removeClass(step2Id, ('disableCls'));
            $A.util.removeClass(step3Id, ('disableCls'));
			var toastEvent = $A.get("e.force:showToast");
			component.set ('v.showSpinner', false);
			toastEvent.setParams({
				"title": "",
				"type" : "warning",
				"message": "Please select the forms to fill."
			});
			toastEvent.fire();
			component.set("v.selectedStep", 'step1');
            
		}
	},
    formsNavigation : function (component, event, helper, pageNumber) {
        var pageNum = parseInt(pageNumber);
        console.log('Page Number: '+pageNumber);
        var custodianVals = component.get('v.custodians');
        var custodianJson = component.get('v.selectedCustodianRecords');
        component.set ('v.showSpinner', true);
        var totalFormsCount = component.get('v.totalForms');
        component.set('v.formNumber', pageNumber);   
        helper.generateHTML(component, event, helper, custodianJson, pageNum, totalFormsCount);
    }
})