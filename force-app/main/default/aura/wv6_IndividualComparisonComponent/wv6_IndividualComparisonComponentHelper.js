({
    init : function(component, event) {
        var fieldWrapList = [];
        var fieldString = $A.get("$Label.c.IndividualFields");
        var fieldArr = fieldString.split(',');
        var fieldAPINameLable = new Map();
        for (var i = 0; i < fieldArr.length; i++) {
            var arr = fieldArr[i].split(':');
            fieldAPINameLable.set(arr[0],arr[1]);
        }

        // get Account, Primary Individual & Secondary Individual records details
        var accRecord = component.get("v.accountRecord");
        for (var key of fieldAPINameLable.keys()) {
            var  priInd = '';
            var  secInd = '';
            if(accRecord['WEGP1_Primary_Individual__r']){
                priInd = accRecord['WEGP1_Primary_Individual__r'][key];
            }
            console.log('priInd:>>'+priInd);
            if(accRecord['WEGP1_Secondary_Individual__r']){
                secInd = accRecord['WEGP1_Secondary_Individual__r'][key];
            }
            console.log('secInd:>>'+secInd);

            if(key === 'Birthdate'){
              if(priInd !== '' && priInd !== 'undefined' && priInd !== null){
                if(priInd.includes('-')){
                   var strArr1 = priInd.split('-');
                   priInd = strArr1[1]+'/'+strArr1[2]+'/'+strArr1[0];
               }
              }
              if(secInd !== '' &&  secInd !== 'undefined' && secInd !== null){
                if(secInd.includes('-')){
                 var strArr2 = secInd.split('-');
                 secInd = strArr2[1]+'/'+strArr2[2]+'/'+strArr2[0];
               }
              }
						}

            fieldWrapList.push({
                "fieldLabel" : fieldAPINameLable.get(key),
                "primaryValue"  : priInd,
                "secondaryValue"  :  secInd,
            });
        }
        console.log('fieldWrapList:>>'+JSON.stringify(fieldWrapList));
        component.set("v.fieldWrapList",fieldWrapList);
    }
})