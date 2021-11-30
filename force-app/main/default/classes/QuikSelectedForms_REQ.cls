public class QuikSelectedForms_REQ{
	public cls_results[] results;
	public class cls_results {
		public String key;	//Household / Business
		public String id;	//a0p56000000OjWcAAK
		public cls_list[] records;
	}
	public class cls_list {
		public String formId;	//918
		public String formShortName;	//SEP-IRA Adoption Agreement
		public String formDesc;	//Used to establish SEP IRA, in addition to application and employer agreement
		public String dealerName;	//Charles Schwab & Co., Inc.
        public String fileCount;
	}
	public static QuikSelectedForms_REQ parse(String json){
		return (QuikSelectedForms_REQ) System.JSON.deserialize(json, QuikSelectedForms_REQ.class);
	}

	/*static testMethod void testParse() {
		String json=		'{'+
		'	"results": [{'+
		'		"key": "Household / Business",'+
		'		"id": "a0p56000000OjWcAAK",'+
		'		"list": [{'+
		'			"formId": "918",'+
		'			"formShortName": "SEP-IRA Adoption Agreement",'+
		'			"formDesc": "Used to establish SEP IRA, in addition to application and employer agreement",'+
		'			"dealerName": "Charles Schwab & Co., Inc."'+
		'		}, {'+
		'			"formId": "919",'+
		'			"formShortName": "SEP-IRA Transmittal",'+
		'			"formDesc": "To be sent to Schwab when employer contributions are being made",'+
		'			"dealerName": "Charles Schwab & Co., Inc."'+
		'		}]'+
		'	}]'+
		'}';
		QuikSelectedForms_REQ obj = parse(json);
		System.assert(obj != null);
	}*/
}