
/* TO hightlight the fields in red color if it has empty value */
var list = document.getElementsByTagName('input'); 
for (var i = 0 ; i < list.length; i++) {
	if (list[i].value == '') { 
		document.getElementById(list[i].id).style.borderColor = 'red'; 
	} 
}

/* To red highlight the forms which are having empty fields. Will work only when page loads */
var bb = document.querySelectorAll('[id^=FID]');
if (bb != null) {
	for (var i = 0; i < bb.length; i++) {
		var elem = bb[i];var inputchild = elem.querySelector('input.itemVisible');
		if (inputchild != null) {
			var idstr = elem.id;
			var form = idstr.substring(3, idstr.indexOf('p')); 
			var page = idstr.substring(idstr.indexOf('p') + 1);
			var data = '\"Form '+form+' Page '+page+'\"'; 
			$('div[Title='+data+']').css('border-color', 'red');
		}
	}
}

/* Spinner Code*/
var spinner = document.createElement('div');
spinner.setAttribute('id', 'spinner');
spinner.setAttribute('style', 'display:none;position: fixed;z-index: 1;padding-top: 230px;left: 0;top: 0;width: 100%;height: 100%;overflow: auto;background-color: rgba(0, 0, 0, 0.08);');

var innerDiv = document.createElement('div');
innerDiv.setAttribute('align', 'center');
spinner.appendChild(innerDiv);

var innerImg = document.createElement('img');
innerImg.setAttribute('src', 'https://wegroup--c.na129.visual.force.com/resource/1566281690000/QuikForms/loading.gif');
innerImg.setAttribute('style', 'width:75px');
innerDiv.appendChild(innerImg);

document.body.appendChild(spinner);

/* Toaster Code */
var ele = document.createElement('div');
ele.setAttribute("id", "toaster");
ele.setAttribute("style", "display: none;min-width: 250px; margin-top: 160px;margin-left: -125px;background-color: #04844b;color: #fff;text-align: center;border-radius: 4px; position: fixed;left: 50%;bottom: 400px;font-size: 17px;");
ele.innerHTML = "Form saved successfully!!!";
document.body.appendChild(ele);

/* Styling change for Save and Print Button */
document.getElementById('btnSave').setAttribute('style', 'height: 28px;border-radius: 4px;padding-left: 0.7rem!important;padding-right: 0.7rem!important;margin-top: 5px!important;text-align: center!important;vertical-align: middle!important;border: 1px solid #d8dde6!important;background-color: rgba(15, 25, 49, 1);width:41pt!important;min-width:40pt!important;text-align:left!important;font-family:"Salesforce Sans",Arial,sans-serif!important;font-size:small!important;font-weight:normal !important;color: white;visibility:visible;');
document.getElementById('btnPrint').setAttribute('style', 'height: 28px;border-radius: 4px;padding-left: 0.7rem!important;padding-right: 0.7rem!important;margin-top: 5px!important;text-align: center!important;vertical-align: middle!important;border: 1px solid #d8dde6!important;background-color: rgb(135, 135, 135);width:41pt!important;min-width:40pt!important;text-align:left!important;font-family:"Salesforce Sans",Arial,sans-serif!important;font-size:small!important;font-weight:normal !important;color: white;visibility:visible;');
