window.customScript = (function(){

    return { 
        
        processValueChange : function(sections, wrappers, editables, fieldAPIName, fieldValue) {
			console.log("fieldValue is: " + fieldValue);
			// list of legal to mailing address maps
			if(fieldAPIName == "SkienceFinSln__Use_Mailing_Address__c" && fieldValue){
				this.processAddressMap(editables);
			}else if(fieldAPIName == "SkienceFinSln__Legal_Address__c" 
				&& this.getEditableFieldValue("SkienceFinSln__Use_Mailing_Address__c", editables)){
				this.mapFieldToField("SkienceFinSln__Legal_Address__c", "SkienceFinSln__Mailing_Address__c", editables);
			}else if(fieldAPIName == "SkienceFinSln__Legal_City__c" 
				&& this.getEditableFieldValue("SkienceFinSln__Use_Mailing_Address__c", editables)){
				this.mapFieldToField("SkienceFinSln__Legal_City__c", "SkienceFinSln__Mailing_City__c", editables);
			}else if(fieldAPIName == "SkienceFinSln__Legal_State__c" 
				&& this.getEditableFieldValue("SkienceFinSln__Use_Mailing_Address__c", editables)){
				this.mapFieldToField("SkienceFinSln__Legal_State__c", "SkienceFinSln__Mailing_State__c", editables);
			}else if(fieldAPIName == "SkienceFinSln__Legal_Zip__c" 
				&& this.getEditableFieldValue("SkienceFinSln__Use_Mailing_Address__c", editables)){
				this.mapFieldToField("SkienceFinSln__Legal_Zip__c", "SkienceFinSln__Mailing_Zip__c", editables);
			}else if(fieldAPIName == "SkienceFinSln__Legal_Country__c" 
				&& this.getEditableFieldValue("SkienceFinSln__Use_Mailing_Address__c", editables)){
				this.mapFieldToField("SkienceFinSln__Legal_Country__c", "SkienceFinSln__Mailing_Country__c", editables);
			}else if(fieldAPIName == "SkienceFinSln__Legal_Attention__c" 
				&& this.getEditableFieldValue("SkienceFinSln__Use_Mailing_Address__c", editables)){
				this.mapFieldToField("SkienceFinSln__Legal_Attention__c", "SkienceFinSln__Mailing_Attention__c", editables);
			}else if(fieldAPIName == "SkienceFinSln__Legal_Province__c" 
				&& this.getEditableFieldValue("SkienceFinSln__Use_Mailing_Address__c", editables)){
				this.mapFieldToField("SkienceFinSln__Legal_Province__c", "SkienceFinSln__Mailing_Province__c", editables);
			}else if(fieldAPIName == "SkienceFinSln__Legal_Address_Line_1__c" 
				&& this.getEditableFieldValue("SkienceFinSln__Use_Mailing_Address__c", editables)){
				this.mapFieldToField("SkienceFinSln__Legal_Address_Line_1__c", "SkienceFinSln__Mailing_Address_Line_1__c", editables);
			}else if(fieldAPIName == "SkienceFinSln__Legal_Address_Line_2__c" 
				&& this.getEditableFieldValue("SkienceFinSln__Use_Mailing_Address__c", editables)){
				this.mapFieldToField("SkienceFinSln__Legal_Address_Line_2__c", "SkienceFinSln__Mailing_Address_Line_2__c", editables);
			}else if(fieldAPIName == "SkienceFinSln__LegalCity__c" 
				&& this.getEditableFieldValue("SkienceFinSln__Use_Mailing_Address__c", editables)){
				this.mapFieldToField("SkienceFinSln__LegalCity__c", "SkienceFinSln__Mailing_City__c", editables);
			} 
			
			//Copy Employer Address and Name to Affiliation Address and Company Name
			else if(fieldAPIName == "SkienceFinSln__Employment_Status__c" && fieldValue == "Employed" && this.getEditableFieldValue("SkienceFinSln__Same_as_Employer__c", editables) 
			|| fieldAPIName == "SkienceFinSln__Same_as_Employer__c" && fieldValue && this.getEditableFieldValue("SkienceFinSln__Employment_Status__c", editables) == "Employed"){
				this.mapFieldToField("SkienceFinSln__CurrentEmployer__c", "SkienceFinSln__Affiliated_Company_Name__c", editables);
				this.mapFieldToField("SkienceFinSln__Address_1__c", "SkienceFinSln__Affiliated_Company_Address__c", editables);
				this.mapFieldToField("SkienceFinSln__City__c", "SkienceFinSln__Affiliated_Company_City__c", editables);
				this.mapFieldToField("SkienceFinSln__State_Province__c", "SkienceFinSln__Affiliated_Company_State__c", editables);
				this.mapFieldToField("SkienceFinSln__Zip__c", "SkienceFinSln__Affiliated_Company_ZIP_Code__c", editables);
				this.mapFieldToField("SkienceFinSln__Country__c", "SkienceFinSln__Affiliated_Company_Country__c", editables);
			}
			else if(fieldAPIName == "SkienceFinSln__CurrentEmployer__c" && this.getEditableFieldValue("SkienceFinSln__Same_as_Employer__c", editables) && this.getEditableFieldValue("SkienceFinSln__Employment_Status__c", editables) == "Employed"){
				this.mapFieldToField("SkienceFinSln__CurrentEmployer__c", "SkienceFinSln__Affiliated_Company_Name__c", editables);
			}
			else if(fieldAPIName == "SkienceFinSln__Address_1__c" && this.getEditableFieldValue("SkienceFinSln__Same_as_Employer__c", editables) && this.getEditableFieldValue("SkienceFinSln__Employment_Status__c", editables) == "Employed"){
				this.mapFieldToField("SkienceFinSln__Address_1__c", "SkienceFinSln__Affiliated_Company_Address__c", editables);
			}
			else if(fieldAPIName == "SkienceFinSln__City__c" && this.getEditableFieldValue("SkienceFinSln__Same_as_Employer__c", editables) && this.getEditableFieldValue("SkienceFinSln__Employment_Status__c", editables) == "Employed"){
				this.mapFieldToField("SkienceFinSln__City__c", "SkienceFinSln__Affiliated_Company_City__c", editables);
			}
			else if(fieldAPIName == "SkienceFinSln__State_Province__c" && this.getEditableFieldValue("SkienceFinSln__Same_as_Employer__c", editables) && this.getEditableFieldValue("SkienceFinSln__Employment_Status__c", editables) == "Employed"){
				this.mapFieldToField("SkienceFinSln__State_Province__c", "SkienceFinSln__Affiliated_Company_State__c", editables);
			}
			else if(fieldAPIName == "SkienceFinSln__Zip__c" && this.getEditableFieldValue("SkienceFinSln__Same_as_Employer__c", editables) && this.getEditableFieldValue("SkienceFinSln__Employment_Status__c", editables) == "Employed"){
				this.mapFieldToField("SkienceFinSln__Zip__c", "SkienceFinSln__Affiliated_Company_ZIP_Code__c", editables);
			}
			else if(fieldAPIName == "SkienceFinSln__Country__c" && this.getEditableFieldValue("SkienceFinSln__Same_as_Employer__c", editables) && this.getEditableFieldValue("SkienceFinSln__Employment_Status__c", editables) == "Employed"){
				this.mapFieldToField("SkienceFinSln__Country__c", "SkienceFinSln__Affiliated_Company_Country__c", editables);
			}
			//Copy Employment Status to Occupation
			//else if(fieldAPIName == "SkienceFinSln__Employment_Status__c" && fieldValue != "Employed"){
			//	this.mapFieldToField("SkienceFinSln__Employment_Status__c", "SkienceFinSln__Occupation__c", editables);		
			//}
			//copy Employment Status 'Self Employed' or 'US Military' to Employer Name
			//if(fieldAPIName == "SkienceFinSln__Employment_Status__c" && fieldValue == "Self-Employed" || fieldValue == "US Military"){
			//		this.mapFieldToField("SkienceFinSln__Employment_Status__c", "SkienceFinSln__CurrentEmployer__c", editables);	
			//		console.log("fieldValue is*******: " + fieldValue);	
							
			//}
			
			//Default e-Delivery fields when No
			else if(fieldAPIName == "SkienceFinSln__e_Delivery_of_Brokerage_Account_Document__c" && fieldValue == "No"){
				this.mapValueToField("Confirm is Not Suppressed", "SkienceFinSln__e_Delivery_Confirms__c", editables);	
				this.mapValueToField("Shareholder Documents are Not Suppressed", "SkienceFinSln__e_Delivery_Shareholder_Documents__c", editables);
				this.mapValueToField("Statement is Not Suppressed", "SkienceFinSln__e_Delivery_Statements__c", editables);
				this.mapValueToField("Tax Forms are Not Suppressed", "SkienceFinSln__e_Delivery_Tax_Documents__c", editables);
				this.mapValueToField("Not Enrolled in e-Notification", "SkienceFinSln__e_Delivery_Customer_Correspondence__c", editables);	
			}
			//Default e-Delivery fields when Yes
			else if(fieldAPIName == "SkienceFinSln__e_Delivery_of_Brokerage_Account_Document__c" && fieldValue == "Yes"){
				this.mapValueToField("Confirm Suppression is Pending", "SkienceFinSln__e_Delivery_Confirms__c", editables);	
				this.mapValueToField("Pending Enrollment in e-Notification", "SkienceFinSln__e_Delivery_Customer_Correspondence__c", editables);
				this.mapValueToField("Shareholder Document Suppression is Pending", "SkienceFinSln__e_Delivery_Shareholder_Documents__c", editables);
				this.mapValueToField("Statement Suppression is Pending", "SkienceFinSln__e_Delivery_Statements__c", editables);
				this.mapValueToField("Tax Form Suppression is Pending", "SkienceFinSln__e_Delivery_Tax_Documents__c", editables);	
			}
			//Default Product Level Sub-Type
			else if(fieldAPIName == "SkienceFinSln__Product_Level__c" && fieldValue == "UNMGD ACCT"){
				this.mapValueToField("A - Advisory", "SkienceFinSln__Product_Level_Sub_Type__c", editables);
			}

		},
		processAddressMap : function(editables){
			// copy legal address to mailing address
			this.mapFieldToField("SkienceFinSln__Legal_Address__c", "SkienceFinSln__Mailing_Address__c", editables);
			this.mapFieldToField("SkienceFinSln__Legal_City__c", "SkienceFinSln__Mailing_City__c", editables);
			this.mapFieldToField("SkienceFinSln__Legal_State__c", "SkienceFinSln__Mailing_State__c", editables);
			this.mapFieldToField("SkienceFinSln__Legal_Zip__c", "SkienceFinSln__Mailing_Zip__c", editables);
			this.mapFieldToField("SkienceFinSln__Legal_Country__c", "SkienceFinSln__Mailing_Country__c", editables);
			this.mapFieldToField("SkienceFinSln__Legal_Attention__c", "SkienceFinSln__Mailing_Attention__c", editables);
			this.mapFieldToField("SkienceFinSln__Legal_Province__c", "SkienceFinSln__Mailing_Province__c", editables);
			this.mapFieldToField("SkienceFinSln__Legal_Address_Line_1__c", "SkienceFinSln__Mailing_Address_Line_1__c", editables);
			this.mapFieldToField("SkienceFinSln__Legal_Address_Line_2__c", "SkienceFinSln__Mailing_Address_Line_2__c", editables);
			this.mapFieldToField("SkienceFinSln__LegalCity__c", "SkienceFinSln__Mailing_City__c", editables);
		},
		getEditable : function(fieldAPIName, editables) {
			for(var i=0; i<editables.length; i++){
				if(editables[i].get("v.customField") && editables[i].get("v.customField").fieldAPIName == fieldAPIName){
					return editables[i];
				}
			}
		},
        mapFieldToField : function(sourceFieldAPIName, targetFieldAPIName, editables){
			var sourceFieldEditable = this.getEditable(sourceFieldAPIName, editables);
			var targetFieldEditable = this.getEditable(targetFieldAPIName, editables);
			if(sourceFieldEditable && sourceFieldEditable.get("v.customField") && targetFieldEditable){
				var sourceFieldValue = sourceFieldEditable.get("v.customField").fieldValue;
				targetFieldEditable.setFieldValue(sourceFieldValue);
			}
		},
		mapValueToField : function(sourceFieldValue, targetFieldAPIName, editables){
			var targetFieldEditable = this.getEditable(targetFieldAPIName, editables);
			if(targetFieldEditable){
				targetFieldEditable.setFieldValue(sourceFieldValue);
			}
		},
		getEditableFieldValue : function(fieldAPIName, editables) {
			var fieldEditable = this.getEditable(fieldAPIName, editables);
			if(fieldEditable && fieldEditable.get("v.customField")){
				return fieldEditable.get("v.customField").fieldValue;
			}else{
				return null;
			}
		}
    };

}());