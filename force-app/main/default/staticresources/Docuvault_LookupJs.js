
var advRecordList = [];
var pattern ='';
function lookup_data (elem) {
	$("#"+objName+'_table').empty();
	 pattern = elem.value;
	if (pattern !== '') {
		var objName = elem.getAttribute ('data-objectName');
		if (objName.indexOf('[') != -1) {
			objName = objName.split ('[')[1];
		}

		if (objName.indexOf(']') != -1) {
			objName = objName.split (']')[0];
		}

		var objNameLowerCase = objName.toLowerCase ();
		
		var searchableField = elem.getAttribute ('data-searchField');
		var isCustomObject = elem.getAttribute ('data-objectType');
		var resultLabel = elem.getAttribute ('data-resultLabel');
		var lookupFieldId = elem.getAttribute ('data-apexField');
		var staticResourceURL = elem.getAttribute ('data-staticResourceURL');
		var advSearchUrl = elem.getAttribute ('data-staticResourceURL');
		var recordTypeName = elem.getAttribute ('data-recordtype');
		var objType = '';
		if (!objNameLowerCase.includes ('__c')) {
			objType = 'standard-'+objNameLowerCase;
			staticResourceURL += 'standard-sprite/svg/symbols.svg#'+objNameLowerCase;
		} else {
			objType = 'custom-custom73';
			staticResourceURL += 'custom-sprite/svg/symbols.svg#custom73';
		}
		
		Docuvault_LookupController.getlookupRecords (objName, recordTypeName, searchableField, pattern, function (result, event) {
			
			if (event.status) {
				if(pattern.length > 1){
					$('#'+elem.id+'_lookupList').html ('');
				
				if (result != null) {
					var hasMoreThanFive = (result.length >= 5 ? true : false);
					if (hasMoreThanFive) {
						$('#'+elem.id+'_lookupList').addClass ('slds-listbox_vertical--5-options');
					} else {
						$('#'+elem.id+'_lookupList').removeClass ('slds-listbox_vertical--5-options');
					}
					$('#'+elem.id+'_lookupList').html ('');
					var lookupData = '' ;
					lookupData += '<li role="presentation" class="slds-listbox__item" id="'+elem.id+'_advSearch" '+
									 'data-comboboxid="'+elem.id+'" onClick="advanceSearch (this);">'+
									 '<span id="listbox-option-unique-id-01" style="padding-left: 18px;" class="slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta"   role="option">'+
									 '<span class="slds-media__figure">'+
									 '<span class="slds-icon__svg--default slds-icon_container" title="'+elem.value+' in '+objName+'">'+
									 '<svg class="slds-icon slds-icon--x-small slds-icon-text-default " aria-hidden="true">'+
									 '<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="'+advSearchUrl+'utility-sprite/svg/symbols.svg#search"></use></svg>'+
									 '<span class="slds-assistive-text">'+elem.value+' in '+objName+'</span></span></span>'+
									 '<span class="slds-media__body" >'+
									 '<span class="slds-listbox__option-text slds-listbox__option-text_entity" style="padding-left: 8px;">'+elem.value+' in '+objName+' </span>'+
									 '</span></span></li>';
					for (var key in result) {
						if (key !== 'remove') {
							
							lookupData += '<li role="presentation" class="slds-listbox__item" id="'+result[key].Id+'_'+key+'" '+
											 'data-lookupRecord=\''+JSON.stringify(result[key])+'\' '+
											 'data-comboboxid="'+elem.id+'" onclick="selectLookupRecord (this);">'+
											 '<span id="listbox-option-unique-id-01" class="slds-media slds-listbox__option 																																slds-listbox__option_entity slds-listbox__option_has-meta" role="option">'+
											 '<span class="slds-media__figure">'+
											 '<span class="slds-icon_container slds-icon-'+objType+'" title="'+result[key].Name+'">'+
											 '<svg class="slds-icon slds-icon_small" aria-hidden="true">'+
											 '<use xmlns:xlink="http://www.w3.org/1999/xlink"xlink:href="'+staticResourceURL+'"></use></svg>'+
											 '<span class="slds-assistive-text">'+result[key].Name+'</span></span></span>'+'<span class="slds-media__body">'+
											 '<span class="slds-listbox__option-text slds-listbox__option-text_entity">'+result[key].Name+'</span>'+
											 '<span class="slds-listbox__option-meta slds-listbox__option-meta_entity"></span>'+
											 '</span></span></li>';
						}
					}
					 $('#'+elem.id+'_lookupList').append(lookupData);
					$('#'+elem.id+'_combobox').removeClass ('slds-combobox-lookup').addClass ('slds-is-open').attr ('aria-expanded', true);
					$('#'+elem.id+'_combobox').parent().addClass ('slds-has-input-focus');
					if(searchableField=='')
					iframeLoaded(objName,result.length,searchableField);
				}
				}else{
					$('#'+elem.id+'_combobox').addClass ('slds-combobox-lookup').removeClass ('slds-is-open').attr ('aria-expanded', false);
					$('#'+elem.id+'_combobox').parent().removeClass ('slds-has-input-focus');
					var iframeid = objName + '_frameId';
					
					if(searchableField=='')
					$("#"+iframeid,window.parent.document).css ('height','100px');
				}
			}
			
		}, {escape: false});
	} 
	else {
		$('#'+elem.id+'_combobox').addClass ('slds-combobox-lookup').removeClass ('slds-is-open').attr ('aria-expanded', false);
		$('#'+elem.id+'_combobox').parent().removeClass ('slds-has-input-focus');
		var iframeid = objName + '_frameId';
		if(searchableField=='')
		$("#"+iframeid,window.parent.document).css ('height','100px');
	}
	
}
function iframeLoaded(objName,totalresults,searchableField) {
	
		var iframeid = objName+'_frameId';
		var iFrameID = document.getElementById(iframeid);
	  if(iFrameID) {
            // here you can make the height, I delete it first, then I make it again
            iFrameID.height = "";
            iFrameID.height = iFrameID.contentWindow.document.body.scrollHeight +(totalresults*50) + "px";
			if(searchableField==''){
			$("#"+iframeid,window.parent.document).css ('height',iFrameID.contentWindow.document.body.scrollHeight +(totalresults*50) + 'px');
			}else{
				$("#"+iframeid).css ('height', '100px');
			}
      }   
  }
function advanceSearch (record){
		
	var id = record.getAttribute ('data-comboboxid');
	var search = $('#'+id).attr ('data-searchfield');
	var objName = $('#'+id).attr ('data-objectName');
	var recordTypeName = $('#'+id).attr ('data-recordtype');
	var lookupId = id;
	var iframeid = objName + '_frameId';
	if(search=='')
		$("#"+iframeid,window.parent.document).css ('height','100px');
	
	if(pattern=='')
		pattern = $('#'+id).val();
	
	if(pattern!=''){
	Docuvault_LookupController.getAdvSearchRecords(objName, recordTypeName, pattern, function (result, event) {
	advRecordList = result;
	
	var tablebody = '';
		/*for(var  i =0 ;i = advRecordList.length ;i++){
			tablebody += '<tr><td>'+advRecordList[i].Name+'</td></tr>';
		}*/
		var Recordslist = [];
		 Recordslist =  $.parseJSON(JSON.parse(advRecordList).records);
		var headerslist =   $.parseJSON(JSON.parse(advRecordList).headers);
		var headerslabels =   $.parseJSON(JSON.parse(advRecordList).headerlabels);
		
	var table = '<table style = "width:100%; line-height:2" id="indexFieldsTable" class="slds-table slds-table_bordered slds-table--fixed-layout slds-max-medium-table_stacked-horizontal">'+
				'<tr class="slds-text-title_caps">';
				for (var i=0; i < headerslabels.length ;i++) {
							table +='<th scope="row" style="width: 18rem;">'+headerslabels[i]+'</th>';
				 
				}
				table += '</tr>';
			for (var i = 0; i  < Recordslist.length ;i ++) {
				table += '<tr class="slds-text-title_caps">';
				var count = 0;
				for(var j = 0 ; j < headerslist.length ; j++ ){
				
					table +='<td scope="row" >'+
					'<div class="slds-truncate" title="'+Recordslist[i][headerslist[j]]+'"><a role="presentation" data-lookupRecord=\''+JSON.stringify(Recordslist[i])+'\' href="javascript:void(0);" id="'+Recordslist[i].Id+'_'+count+'" data-comboboxid="'+id+'" data-objectName="'+objName+'" onclick="selectLookupRecord (this);">';
					
						if(headerslist[j].includes(".")){
							
							var innerheader = headerslist[j].split('.');
							if (typeof Recordslist[i][innerheader[0]][innerheader[1]] != "undefined") 
							table +=Recordslist[i][innerheader[0]][innerheader[1]];
							
						}else{
							if (typeof Recordslist[i][headerslist[j]] != "undefined") 
							table +=Recordslist[i][headerslist[j]];
						}
					
					table +='</a></div>'+
					'</td>';
					count++
				}
				table +='</tr>';
			
		}
		table += '</table>';
		
				$("#"+objName+'_table').html(table);	
		
		

	$("#"+objName+'_frameId').attr ('src', '/apex/AdvancedLookup?objName='+objName+'&comboboxId='+id+'&lookupId='+lookupId+'&pattern='+pattern+'&recordTypeName='+recordTypeName);
	if(search==''){
	$("#"+objName+'_details',window.parent.document).html(Recordslist.length +'+ results for '+pattern);
	}
	else{
		$("#"+objName+'_details').html(Recordslist.length +'+ results for '+pattern);
	}
	if (search != '') {
	
	$ ("#"+objName+'_modalId').removeClass ('slds-hide');
	} else {
		$("#"+objName+'_table', window.parent.document).html('');
	//$("#table").html('');
	Docuvault_LookupController.getAdvSearchRecords(objName, recordTypeName,pattern, function (result, event) {
	advRecordList = result;
	
	var tablebody = '';
		/*for(var  i =0 ;i = advRecordList.length ;i++){
			tablebody += '<tr><td>'+advRecordList[i].Name+'</td></tr>';
		}*/
	var Recordslist = [];
	Recordslist =  $.parseJSON(JSON.parse(advRecordList).records);
		var headerslist =  $.parseJSON(JSON.parse(advRecordList).headers);
		var headerslabels =  $.parseJSON(JSON.parse(advRecordList).headerlabels);
		var table = '<table style = "width:100%; line-height:2" id="indexFieldsTable" class="slds-table slds-table_bordered slds-table--fixed-layout slds-max-medium-table_stacked-horizontal">'+
				'<tr class="slds-text-title_caps">';
				for (var i=0; i < headerslabels.length ;i++) {
							table +='<th scope="row" style="width: 18rem;">'+headerslabels[i]+'</th>';
				 
				}
				table += '</tr>';
				
		$("#indexFieldsTable tr").remove();
			for (var i = 0 ; i < Recordslist.length;i++) {
				table += '<tr class="slds-text-title_caps">';
				var count = 0;
				for(var j = 0 ; j < headerslist.length ; j++ ){
					table +='<td scope="row" >'+
					'<div class="slds-truncate" title="'+Recordslist[i][headerslist[j]]+'"><a role="presentation" data-lookupRecord=\''+JSON.stringify(Recordslist[i])+'\' href="javascript:void(0);" id="'+Recordslist[i].Id+'_'+count+'" data-comboboxid="'+id+'" data-objectName="'+objName+'" onclick="selectLookupRecord (this);">';
						if(headerslist[j].includes(".")){
							var innerheader = headerslist[j].split('.');
							if (typeof Recordslist[i][innerheader[0]][innerheader[1]] != "undefined") 
							table +=Recordslist[i][innerheader[0]][innerheader[1]];
							}else{
							if (typeof Recordslist[i][headerslist[j]] != "undefined") 
							table +=Recordslist[i][headerslist[j]];
						}
					
					table +='</a></div>'+
					'</td>';
					count++
				}
						
				table +='</tr>';
			
		}
		table += '</table>';
		$("#"+objName+'_table', window.parent.document).html(table);
				
		
	}, {escape: false});
	}
	
}, {escape: false});
}
}

function selectLookupRecord (record) {
	var comboboxid = record.getAttribute ('data-comboboxid');
	var elem = document.getElementById (comboboxid);
	var objName = elem.getAttribute ('data-objectname');
	
	if (objName.indexOf('[') != -1) {
			objName = objName.split ('[')[1];
		}

		if (objName.indexOf(']') != -1) {
			objName = objName.split (']')[0];
		}
	var objNameLowerCase = objName.toLowerCase ();
	
	var searchableField = elem.getAttribute ('data-searchField');
	var isCustomObject = elem.getAttribute ('data-objectType');
	var resultLabel = elem.getAttribute ('data-resultLabel');
	var lookupFieldId = elem.getAttribute ('data-apexField');
	var apexHiddenFieldId = elem.getAttribute ('data-apexHiddenField');
	
	var staticResourceURL = elem.getAttribute ('data-staticResourceURL');
	var objType = '', className = '';
	if (!objNameLowerCase.includes ('__c')) {
		objType = 'standard';
		className = 'standard-'+objNameLowerCase;
		staticResourceURL += 'standard-sprite/svg/symbols.svg#'+objNameLowerCase;
	} else {
		objType = 'custom';
		className = 'custom-custom73';
		staticResourceURL += 'custom-sprite/svg/symbols.svg#custom73';
	}
	var data = JSON.parse (record.getAttribute ('data-lookupRecord'));
	var selectedRecord = '<svg class="slds-icon slds-icon_small" aria-hidden="false">'+
						 '<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="'+staticResourceURL+'" />'+
						 '</svg><span class="slds-assistive-text">'+data.LastName+'</span>';
	if (searchableField == '') {
		$('#'+comboboxid+'_combobox', window.parent.document).addClass ('slds-combobox-lookup').removeClass ('slds-is-open').attr ('aria-expanded', false);
		$('#'+comboboxid+'_combobox', window.parent.document).parent().removeClass ('slds-has-input-focus');
		$('#'+comboboxid+'_iconClass', window.parent.document).removeClass ('slds-input-has-icon_right').addClass ('slds-input-has-icon_left-right');
		$('#'+comboboxid+'_selected', window.parent.document).removeClass ('slds-hide'). addClass ('slds-icon-'+className).html (selectedRecord);
		$('#'+comboboxid+'_removeBtn', window.parent.document).removeClass('slds-hide');
		$('#'+comboboxid+'_searchIcon', window.parent.document).removeClass('slds-show').addClass ('slds-hide');
		$('#'+comboboxid, window.parent.document).val(data.Name).attr ('readonly', true);
		$("#"+objName+'_modalId',window.parent.document).addClass ('slds-hide');
		$('#'+comboboxid,window.parent.document).attr ('data-lookupRecord', JSON.stringify(data));
	}
	 
	if (searchableField != '') {
		$('#'+comboboxid+'_combobox').addClass ('slds-combobox-lookup').removeClass ('slds-is-open').attr ('aria-expanded', false);
		$('#'+comboboxid+'_combobox').parent().removeClass ('slds-has-input-focus');
		$('#'+comboboxid+'_iconClass').removeClass ('slds-input-has-icon_right').addClass ('slds-input-has-icon_left-right');
		$('#'+comboboxid+'_selected').removeClass ('slds-hide'). addClass ('slds-icon-'+className).html (selectedRecord);
		$('#'+comboboxid+'_removeBtn').removeClass('slds-hide');
		$('#'+comboboxid+'_searchIcon').removeClass('slds-show').addClass ('slds-hide');
		$('#'+comboboxid).val(data.Name).attr ('readonly', true);
		$("#"+objName+'_modalId').addClass ('slds-hide');
		$('#'+comboboxid).attr ('data-lookupRecord', JSON.stringify(data));
	
	}
	
	if (lookupFieldId != '') {
		
		$('#'+objName+'_Lookup', window.parent.document).value(data.Id);
		
	}

	if (apexHiddenFieldId != '') {
		
		$('#'+objName+'_Lookup', window.parent.document).value(data.Id);
		$('#'+objName+'_Lookup', window.parent.document).value(data.Name);
		
	}
}

function removeLookUpRecord (apexFieldId, comboboxid) {
	var elem = document.getElementById (comboboxid);
	var objName = elem.getAttribute ('data-objectName');
	if (objName.indexOf('[') != -1) {
			objName = objName.split ('[')[1];
		}

		if (objName.indexOf(']') != -1) {
			objName = objName.split (']')[0];
		}
	var objNameLowerCase = objName.toLowerCase ();
	var searchableField = elem.getAttribute ('data-searchField');
	var isCustomObject = elem.getAttribute ('data-objectType');
	var resultLabel = elem.getAttribute ('data-resultLabel');
	var lookupFieldId = elem.getAttribute ('data-apexField');
	var apexHiddenFieldId = elem.getAttribute ('data-apexHiddenField');
	var staticResourceURL = elem.getAttribute ('data-staticResourceURL');
	
	var objType = '', className = '';
	if (!objNameLowerCase.includes ('__c')) {
		objType = 'standard';
		className = 'standard-'+objNameLowerCase;
		staticResourceURL += 'standard-sprite/svg/symbols.svg#'+objNameLowerCase;
	} else {
		objType = 'custom';
		className = 'custom-custom73';
		staticResourceURL += 'custom-sprite/svg/symbols.svg#custom73';
	}
	var selectedRecord = '<svg class="slds-icon slds-icon_small" aria-hidden="true">'+
						 '<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="" />'+
						 '</svg><span class="slds-assistive-text"></span>';
	$('#'+comboboxid+'_iconClass').addClass ('slds-input-has-icon_right').removeClass ('slds-input-has-icon_left-right');
	$('#'+comboboxid+'_selected').addClass ('slds-hide').removeClass ('slds-icon-'+className).html (selectedRecord);
	$('#'+comboboxid+'_removeBtn').addClass('slds-hide');
	if ($('#'+comboboxid+'_removeBtn').hasClass ('slds-show')) {
		$('#'+comboboxid+'_removeBtn').removeClass('slds-show');
	}
	$('#'+comboboxid+'_searchIcon').addClass('slds-show').removeClass ('slds-hide');
	$('#'+comboboxid).val ('').attr ('readonly', false);
	$('#'+comboboxid).attr ('data-lookupRecord', '');
	if (apexFieldId != '') {
		document.getElementById(apexFieldId).value = '';
	}

	if (apexHiddenFieldId != '') {
		document.getElementById(apexHiddenFieldId+'_lkid').value = '';
		document.getElementById(apexHiddenFieldId+'_lkold').value = '';
	}
}

function setLookupData (apexFieldId, id) {
	if (apexFieldId != '') {
		var data = document.getElementById (apexFieldId).value;
		if (data != '') {
			var elem = document.getElementById (id);
			var objName = elem.getAttribute ('data-objectName');
				objName = objName.split ('[')[1];
				objName = objName.split (']')[0];
			var objNameLowerCase = objName.toLowerCase ();
			
			var searchableField = elem.getAttribute ('data-searchField');
			var isCustomObject = elem.getAttribute ('data-objectType');
			var resultLabel = elem.getAttribute ('data-resultLabel');
			var lookupFieldId = elem.getAttribute ('data-apexField');
			var staticResourceURL = elem.getAttribute ('data-staticResourceURL');
			
			var objType = '', className = '';
			if (!objNameLowerCase.includes ('__c')) {
				objType = 'standard';
				className = 'standard-'+objNameLowerCase;
				staticResourceURL += 'standard-sprite/svg/symbols.svg#'+objNameLowerCase;
			} else {
				objType = 'custom';
				className = 'custom-custom73';
				staticResourceURL += 'custom-sprite/svg/symbols.svg#custom73';
			}
	
			var selectedRecord = '<svg class="slds-icon slds-icon_small" aria-hidden="false">'+
								 '<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="'+staticResourceURL+'" />'+
								 '</svg><span class="slds-assistive-text">'+data+'</span>';
			
			$('#'+id+'_iconClass').addClass ('slds-input-has-icon_left-right slds-show');
			$('#'+id+'_selected').removeClass ('slds-hide').addClass ('slds-icon-'+className).html (selectedRecord);
			$('#'+id+'_removeBtn').removeClass('slds-hide').addClass('slds-show');
			$('#'+id+'_searchIcon').addClass ('slds-hide');
			$('#'+id).val(data).attr ('readonly', true);
		}
	}
}
function closeLookupList () {
            $('.slds-is-open').each (function() {
                $(this).addClass ('slds-combobox-lookup').removeClass ('slds-is-open').attr ('aria-expanded', false);
                $(this).parent().removeClass ('slds-has-input-focus');
            });
        }
		
	