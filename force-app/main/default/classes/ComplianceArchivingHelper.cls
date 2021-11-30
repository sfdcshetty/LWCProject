//TestClassName: ComplianceArchivingHelper_TC  
Public class ComplianceArchivingHelper {
    
    public static void JournalSecureMessageToClient (List <Secure_Messaging__c> secureMsgs) {
        system.debug('FIRING EMAIL TO CLIENT FROM HELPER====>'+userinfo.getUserType());
        List <WEG_Journal_EC__c> journalECrecords = new List <WEG_Journal_EC__c> ();
        for (Secure_Messaging__c msg : [SELECT Account__c, 
                                        Account__r.WEGP1_Primary_Household__c,
                                        Customer_User__c, Customer_User__r.Email,
                                        CreatedBy.Email, CreatedBy.Name, createdDate,
                                        Name, IP_Address__c, createdBy.WEG_IsRIA_Only__c,
                                        Customer_User__r.Name, Message__c, Send_to_User__c
                                        FROM Secure_Messaging__c 
                                        WHERE ID IN :secureMsgs
                                       ]) 
        {

            WEG_Journal_EC__c journal = fieldMapping (msg);
            journal.WEG_Is_Incoming__c = False;
            journal.WEG_RIA_Only__c = msg.createdBy.WEG_IsRIA_Only__c;
            journal.WEG_ToAddress__c = msg.Customer_User__r.Email; 
            journal.WEG_ToName__c = msg.Customer_User__r.Name;
            String emailTextBody = '';
            emailTextBody = 'Dear '+msg.Send_to_User__c+', Your advisory team at Wealth Enhancement Group has sent a secure message via our client portal. Please log in via the following link to review the message:';
            emailTextBody += Label.Community_URL;
            emailTextBody += ' Your username is your primary email address on file at Wealth Enhancement Group.';
            emailTextBody += ' If you have any questions or trouble logging in to the portal, please call 1-800-492-1222 and ask to be directed to your advisory team.';
            emailTextBody = emailTextBody.replace('null','');
            journal.WEG_TextBody__c  = emailTextBody;
            journal.WEG_HouseHold_AccountID__c = msg.Account__r.WEGP1_Primary_Household__c;
            journal.WEG_IndividualAccountID__c = msg.Account__c;
            journalECrecords.add (journal);
        }
        Insert journalECrecords;
    } 
    
    public static void JournalSecureMessageFromClient (List <Secure_Messaging__c> secureMsgs, id portalUserID) {
        system.debug('FIRING EMAIL FROM CLIENT FROM HELPER====>'+userinfo.getUserType());

        List <WEG_Journal_EC__c> journalECrecords = new List <WEG_Journal_EC__c> ();
        User u = new user();
        if(portalUserID != null)
            u = [SELECT Contact.AccountID,Contact.Account.WEGP1_Primary_Household__c,
                 Contact.Account.WEGP1_Primary_Individual__c, Contact.Owner.WEG_IsRIA_Only__c
                 FROM User 
                 WHERE id =: portalUserID
                ];
        for (Secure_Messaging__c msg : [SELECT Account__c,Account__r.owner.Email,
                                        Account__r.owner.Name, Account__r.RecordType.Name,
                                        CreatedBy.Email, CreatedBy.Name, createdDate,
                                        Name, IP_Address__c, Message__c,
                                        Household_Account__r.Owner.Email,
                                        Household_Account__r.Owner.Name
                                        FROM Secure_Messaging__c 
                                        WHERE ID IN :secureMsgs]) 
        {
            WEG_Journal_EC__c journal = fieldMapping (msg);
            journal.WEG_Is_Incoming__c = True;
            journal.WEG_RIA_Only__c = u.Contact.Owner.WEG_IsRIA_Only__c;
            journal.WEG_HouseHold_AccountID__c = u.Contact.Account.WEGP1_Primary_Household__c;
            journal.WEG_IndividualAccountID__c = u.Contact.Account.WEGP1_Primary_Individual__c;
            journal.WEG_ToAddress__c = msg.Household_Account__r.Owner.Email;
            journal.WEG_ToName__c = msg.Household_Account__r.Owner.Name;
                    
            journalECrecords.add (journal);
        }
        Insert journalECrecords;
    }   
    
    public static WEG_Journal_EC__c fieldMapping (Secure_Messaging__c msg) {
        WEG_Journal_EC__c journal = new WEG_Journal_EC__c ();
        journal.WEG_From_Address__c = msg.CreatedBy.Email;
        journal.WEG_From_Name__c = msg.CreatedBy.Name;
        journal.WEG_Has_Attachment__c = False;
        journal.WEG_Message_Date__c = msg.createdDate;
        journal.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Secure Message').getRecordTypeId();
        journal.WEG_Related_To__c = 'Secure Message';
        journal.WEG_Related_To_ID__c = msg.ID;
        journal.WEG_Subject__c = msg.Name;
        journal.WEG_TextBody__c = msg.Message__c;
        journal.WEG_IP_Address__c = msg.IP_Address__c;
        return journal;
    }
    Public static void documentShare (Set<Id> cloudFileIdSet, Map <ID, ID> portalUsers,
                                     String type, String ipAddress) 
    {
        Map <ID, User> userMap = new Map <ID, User> ();
        if (portalUsers != NULL) {
            List <ID> userIds = new List <ID> ();
            userIds = portalUsers.values ();
            userMap = new Map <ID, User> ([SELECT Email, Name, Contact.AccountID,
                                            Contact.Account.WEGP1_Primary_Household__c,
                                            Contact.Account.WEGP1_Primary_Individual__c,
                                            Contact.Account.WEGP1_Primary_Household__r.owner.Name,
                                            Contact.Account.WEGP1_Primary_Household__r.owner.Email
                                            FROM User 
                                            WHERE id IN : userIds AND isActive = TRUE
                                           ]);
        }
        
        List <WEG_Journal_EC__c> journalEcRecordsInsertList = New List <WEG_Journal_EC__c> ();
        Map <Id, WEG_Journal_EC__c> cloudFileJournalMap = New Map <ID, WEG_Journal_EC__c> ();
        
        List <TVA_CFB__Cloud_Files__c> cloudFilesList = new List <TVA_CFB__Cloud_Files__c> ();
        cloudFilesList = [SELECT Name, Createdby.Email, CreatedBy.Name, CreatedDate,
                          TVA_CFB__File_Type__c, TVA_CFB__File_Size__c, 
                          owner.Email, WEGP1PrimaryIndividual__c,
                          Portal_Document__r.Account__c,
                          Portal_Document__r.Account__r.Owner.Email,
                          Portal_Document__r.Account__r.Owner.name,
                          TVA_CFB__Download_File__c, TVA_CFB__File_Size_in_Bytes__c, 
                          TVA_CFB__File_Request__c, Email__c, WEGP1_Household__c,
                          WEGP1_Household__r.Owner.Email, WEGP1_Household__r.Owner.Name,
                          WEGP1_Household__r.WEGP1_Primary_Individual__c,
                          TVA_CFB__File_Request__r.owner.Email, TVA_CFB__File_Request__r.owner.Name,
                          TVA_CFB__File_Request__r.TVA_CFB__Email__c, createdBy.WEG_IsRIA_Only__c,
                          TVA_CFB__File_Request__r.createdBy.WEG_IsRIA_Only__c,
                          TVA_CFB__File_Request__r.TVA_CFB__Account__c,
                          Primary_Portal_User__r.Email, Primary_Portal_User__r.Name,
                          Secondary_Portal_User__r.Email, Secondary_Portal_User__r.Name,
                          OwnerId, Shared_By_Name__c, Shared_By_Email__c, Primary_Portal_User_Name__c,
                          Primary_Portal_User_Username__c, Owner_Name2__c, Owner_Email__c, Short_Description__c,
                          WEG_Document_Name__c
                          FROM  TVA_CFB__Cloud_Files__c
                          WHERE ID IN : cloudFileIdSet 
                          AND (((not WEG_Document_Name__c  like 'QAMR%')
                          AND (not WEG_Document_Name__c  like 'CCPY%'))
                          OR Primary_Portal_User__c != null)
                         ];
                         
        Map <ID, Boolean> contactOwnermap = new Map <ID, Boolean> ();
            for (User u: [SELECT Contact.Owner.WEG_IsRIA_Only__c FROM User WHERE ID =: UserInfo.getUserID ()]) {
                contactOwnerMap.put (u.ID, u.Contact.Owner.WEG_IsRIA_Only__c);
            }
                 
        for (TVA_CFB__Cloud_Files__c cloudFile : cloudFilesList) {
            WEG_Journal_EC__c journal = new WEG_Journal_EC__c ();
            journal.WEG_From_Name__c = cloudFile.CreatedBy.Name; 
            journal.WEG_From_Address__c = cloudFile.CreatedBy.Email;           
            journal.WEG_Has_Attachment__c = True;
            journal.WEG_Message_Date__c = cloudFile.CreatedDate;
            journal.WEG_Related_To_ID__c = cloudFile.id;
            journal.WEG_Related_To__c = 'Cloud File';
            journal.WEG_IP_Address__c = ipAddress;
            journal.WEG_Type__c = type;
            if(Type == 'Document Share') {
                journal.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Document Share').getRecordTypeId();
                journal.WEG_ToAddress__c  = cloudFile.Primary_Portal_User__r.Email;
                journal.WEG_ToName__c = cloudFile.Primary_Portal_User__r.Name;
                
                journal.WEG_Subject__c = 'A File has been shared to Client Portal.';
                journal.WEG_TextBody__c = 'The attached Document was shared with Wealth Enhancement Group Client Portal with the following details.<br/><br/>'
                                            +'<b> Shared By : </b> '+cloudFile.Shared_By_Name__c+'<br/>'
                                            +'<b> Shared By Email: </b> '+cloudFile.Shared_By_Email__c+'<br/>'
                                            +'<b> Shared With : </b> '+cloudFile.Primary_Portal_User_Name__c+'<br/>'
                                            +'<b> Shared with Email : </b> '+cloudFile.Primary_Portal_User_Username__c+'<br/>'
                                            +'<b> File Name : </b> '+cloudFile.Name+' <br/>'
                                            +'<b> File Type : </b> '+cloudFile.TVA_CFB__File_Type__c+' <br/>';
                
                journal.WEG_RIA_Only__c = cloudFile.CreatedBy.WEG_IsRIA_Only__c;
                journal.WEG_HouseHold_AccountID__c = cloudFile.WEGP1_Household__c;
                journal.WEG_IndividualAccountID__c = cloudFile.WEGP1PrimaryIndividual__c;
                journal.WEG_Is_Incoming__c = False;
            }
            if(Type == 'Document Share Secondary') {
                journal.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Document Share').getRecordTypeId();
                journal.WEG_ToAddress__c  = cloudFile.Secondary_Portal_User__r.Email;
                journal.WEG_ToName__c = cloudFile.Secondary_Portal_User__r.Name;
                
                journal.WEG_Subject__c = 'A File has been shared to Client Portal.';
                journal.WEG_TextBody__c = 'The attached Document was shared with Wealth Enhancement Group Client Portal with the following details.<br/><br/>'
                                            +'<b> Shared By : </b> '+cloudFile.Shared_By_Name__c+'<br/>'
                                            +'<b> Shared By Email: </b> '+cloudFile.Shared_By_Email__c+'<br/>'
                                            +'<b> Shared With : </b> '+cloudFile.Secondary_Portal_User__r.Name+'<br/>'
                                            +'<b> Shared with Email : </b> '+cloudFile.Secondary_Portal_User__r.Email+'<br/>'
                                            +'<b> File Name : </b> '+cloudFile.Name+' <br/>'
                                            +'<b> File Type : </b> '+cloudFile.TVA_CFB__File_Type__c+' <br/>';
                
                journal.WEG_RIA_Only__c = cloudFile.CreatedBy.WEG_IsRIA_Only__c;
                journal.WEG_HouseHold_AccountID__c = cloudFile.WEGP1_Household__c;
                journal.WEG_IndividualAccountID__c = cloudFile.WEGP1PrimaryIndividual__c;
                journal.WEG_Is_Incoming__c = False;
            }
            if(Type == 'Document Receipt') {
                journal.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Document Share').getRecordTypeId();
                journal.WEG_ToAddress__c = cloudFile.Portal_Document__r.Account__r.Owner.Email;
                journal.WEG_ToName__c = cloudFile.Portal_Document__r.Account__r.Owner.Name;
                
                journal.WEG_Subject__c = 'A File has been shared from Client Portal.';
                journal.WEG_TextBody__c = 'A file owned by '+cloudFile.Owner_Name2__c
                                        + ' with email address '+cloudFile.Owner_Email__c
                                        +' has been uploaded through Client Portal with the following details:' 
                                        +'<br/><b>File Name : </b> '+cloudFile.Name
                                        +'<br/><b>File Size :</b> '+ cloudFile.TVA_CFB__File_Size__c
                                        +'<br/><b>File Type :</b> '+cloudFile.TVA_CFB__File_Type__c
                                        +'<br/><b>Short Description : </b> '+cloudFile.Short_Description__c;
                
                if (contactOwnerMap.containsKey (cloudFile.OwnerID))
                    journal.WEG_RIA_Only__c = contactOwnerMap.get (cloudFile.OwnerId);
                journal.WEG_HouseHold_AccountID__c = cloudFile.Portal_Document__r.Account__c;
                journal.WEG_IndividualAccountID__c = cloudFile.WEGP1PrimaryIndividual__c;
                journal.WEG_Is_Incoming__c = True;
            }
            if(Type == 'Secure File Send') {
                User u = new user ();
                u = [SELECT Name, Email,WEG_IsRIA_Only__c FROM User WHERE ID =: UserInfo.getUserID () AND IsActive = TRUE LIMIT 1];
                journal.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Secure File Share').getRecordTypeId();
                journal.WEG_From_Name__c = u.Name;
                journal.WEG_From_Address__c = u.Email;
                journal.WEG_Message_Date__c = System.Now ();
                
                journal.WEG_ToAddress__c  = cloudFile.Email__c;
                journal.WEG_ToName__c = NULL;
                
                journal.WEG_Subject__c = 'A file has been shared using secure file share.';
                journal.WEG_TextBody__c = 'A secure file has been shared using secure file share.';
                
                
                journal.WEG_RIA_Only__c = u.WEG_IsRIA_Only__c;
                journal.WEG_HouseHold_AccountID__c = cloudFile.WEGP1_Household__c;
                journal.WEG_IndividualAccountID__c = cloudFile.WEGP1PrimaryIndividual__c;
                journal.WEG_Is_Incoming__c = False;
            }
            
            if(Type == 'Secure File Share') {
                journal.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Secure File Share').getRecordTypeId();
                journal.WEG_ToAddress__c  = cloudFile.Email__c;
                journal.WEG_ToName__c = NULL;
                
                journal.WEG_Subject__c = 'A file has been downloaded using secure file share.';
                journal.WEG_TextBody__c = 'Hi,<br/><br/>' 
                                        +'A file owned by '+cloudFile.Owner_Name2__c
                                        +' with email address '+cloudFile.Owner_Email__c
                                        +' has been downloaded through secure download password protected link with the following details: '
                                        +'<br/><b>File Name :</b>'+cloudFile.Name
                                        +'<br/><b>File Size :</b>'+cloudFile.TVA_CFB__File_Size__c
                                        +'<br/><b>File Type :</b>'+cloudFile.TVA_CFB__File_Type__c;
                
                
                journal.WEG_RIA_Only__c = cloudFile.CreatedBy.WEG_IsRIA_Only__c;
                journal.WEG_HouseHold_AccountID__c = cloudFile.WEGP1_Household__c;
                journal.WEG_IndividualAccountID__c = cloudFile.WEGP1PrimaryIndividual__c;
                journal.WEG_Is_Incoming__c = False;
            }
            if(Type == 'Secure File Receipt') {
                journal.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Secure File Share').getRecordTypeId();
                journal.WEG_Related_To__c = 'Request Cloud File';
                
                journal.WEG_From_Name__c = NULL;
                journal.WEG_From_Address__c = cloudFile.TVA_CFB__File_Request__r.TVA_CFB__Email__c;            
                
                journal.WEG_ToAddress__c = cloudFile.TVA_CFB__File_Request__r.owner.Email;
                journal.WEG_ToName__c = cloudFile.TVA_CFB__File_Request__r.owner.Name;
                
                journal.WEG_Subject__c = 'A file has been uploaded using secure file share.';
                journal.WEG_TextBody__c = 'A file has been uploaded via secure file request with the details below as requested by '
                                            +cloudFile.Owner_Name2__c
                                            +' with email address  '+cloudFile.Owner_Email__c+' <br/><br/>'
                                            +'<b> File Name : </b> '+cloudFile.Name+' <br/>'
                                            +'<b> File Type : </b> '+cloudFile.TVA_CFB__File_Type__c+' <br/>';
                                
                journal.WEG_RIA_Only__c = cloudFile.TVA_CFB__File_Request__r.CreatedBy.WEG_IsRIA_Only__c;
                journal.WEG_HouseHold_AccountID__c = cloudFile.TVA_CFB__File_Request__r.TVA_CFB__Account__c;
                journal.WEG_Is_Incoming__c = True;                
            }
            
            if(Type == 'File Upload') {
                User u = new user ();
                u = [SELECT Name, Email,WEG_IsRIA_Only__c FROM User WHERE ID =: UserInfo.getUserID () AND IsActive = TRUE LIMIT 1];
                journal.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Secure File Share').getRecordTypeId();
                journal.WEG_From_Name__c = u.Name;
                journal.WEG_From_Address__c = u.Email;
                journal.WEG_Message_Date__c = System.Now ();
                
                journal.WEG_ToAddress__c  = cloudFile.Email__c;
                journal.WEG_ToName__c = NULL;
                
                journal.WEG_Subject__c = 'A file has been shared using secure file share.';
                journal.WEG_TextBody__c = 'A file owned by '
                                            +cloudFile.Owner_Name2__c
                                            +' with email address  '+cloudFile.Owner_Email__c+'has been uploaded through Client Portal with the following details: <br/><br/>'
                                            +'<b> File Name : </b> '+cloudFile.Name+' <br/>'
                                            +'<b> File Type : </b> '+cloudFile.TVA_CFB__File_Type__c+' <br/>'
                                            +'<b> Short Description : </b> '+cloudFile.Short_Description__c+' <br/>';
                                
                
                
                journal.WEG_RIA_Only__c = u.WEG_IsRIA_Only__c;
                journal.WEG_HouseHold_AccountID__c = cloudFile.WEGP1_Household__c;
                journal.WEG_IndividualAccountID__c = cloudFile.WEGP1PrimaryIndividual__c;
                journal.WEG_Is_Incoming__c = False;
            }
            
            if(Type == 'File View' || Type =='File Download') {
                User u = new user ();
                u = [SELECT Name, Email,WEG_IsRIA_Only__c FROM User WHERE ID =: UserInfo.getUserID () AND IsActive = TRUE LIMIT 1];
                journal.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Secure File Share').getRecordTypeId();
                journal.WEG_From_Name__c = u.Name;
                journal.WEG_From_Address__c = u.Email;
                journal.WEG_Message_Date__c = System.Now ();
                
                journal.WEG_ToAddress__c  = cloudFile.Email__c;
                journal.WEG_ToName__c = NULL;
                
                journal.WEG_Subject__c = 'A file has been shared using secure file share.';
                journal.WEG_TextBody__c = 'A file owned by '
                                            +cloudFile.Owner_Name2__c
                                            +' with email address  '+cloudFile.Owner_Email__c+'has been downloaded through Client Portal with the following details: <br/><br/>'
                                            +'<b> File Name : </b> '+cloudFile.Name+' <br/>'
                                            +'<b> File Type : </b> '+cloudFile.TVA_CFB__File_Type__c+' <br/>';
                                
                
                
                journal.WEG_RIA_Only__c = u.WEG_IsRIA_Only__c;
                journal.WEG_HouseHold_AccountID__c = cloudFile.WEGP1_Household__c;
                journal.WEG_IndividualAccountID__c = cloudFile.WEGP1PrimaryIndividual__c;
                journal.WEG_Is_Incoming__c = False;
            }
            
            if(Type == 'Share on Portal') {
                User u = new user ();
                u = [SELECT Name, Email,WEG_IsRIA_Only__c FROM User WHERE ID =: UserInfo.getUserID () AND IsActive = TRUE LIMIT 1];
                journal.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Secure File Share').getRecordTypeId();
                journal.WEG_From_Name__c = u.Name;
                journal.WEG_From_Address__c = u.Email;
                journal.WEG_Message_Date__c = System.Now ();
                
                journal.WEG_ToAddress__c  = cloudFile.Email__c;
                journal.WEG_ToName__c = NULL;
                
                journal.WEG_Subject__c = 'A file has been shared using secure file share.';
                journal.WEG_TextBody__c = 'A file owned by '
                                            +cloudFile.Owner_Name2__c
                                            +' with email address  '+cloudFile.Owner_Email__c+'has been downloaded through Client Portal with the following details: <br/><br/>'
                                            +'<b> File Name : </b> '+cloudFile.Name+' <br/>'
                                            +'<b> File Type : </b> '+cloudFile.TVA_CFB__File_Type__c+' <br/>';
                                
                
                
                journal.WEG_RIA_Only__c = u.WEG_IsRIA_Only__c;
                journal.WEG_HouseHold_AccountID__c = cloudFile.WEGP1_Household__c;
                journal.WEG_IndividualAccountID__c = cloudFile.WEGP1PrimaryIndividual__c;
                journal.WEG_Is_Incoming__c = False;
            }
            
            journalEcRecordsInsertList.add (journal);
            
        }
  
        if (journalEcRecordsInsertList.size () > 0)
            insert journalEcRecordsInsertList;
        
        for (WEG_journal_EC__c journal : [select WEG_Related_To_ID__c from WEG_journal_EC__c where 
                                          id IN :journalEcRecordsInsertList]) {
            cloudFileJournalMap.put (journal.WEG_Related_To_ID__c, journal);  
        }
        List <WEG_Journal_Attachment_Reference__c> attachmentsToInsert = new List <WEG_Journal_Attachment_Reference__c> ();
        Set <ID> attachmentsIdSet = New Set <ID> ();
        for (TVA_CFB__Cloud_Files__c cloudFile :cloudFilesList) {
            WEG_Journal_Attachment_Reference__c ref = new WEG_Journal_Attachment_Reference__c ();
            ref.WEG_JournalEC__c = cloudFileJournalMap.get (cloudFile.id).ID;
            ref.WEG_File_Name__c = cloudFile.Name;
            ref.WEG_File_Type__c = cloudFile.TVA_CFB__File_Type__c;
            ref.WEG_File_Size_in_Bytes__c = cloudFile.TVA_CFB__File_Size_in_Bytes__c;
            attachmentsToInsert.add (ref);
        }
        insert attachmentsToInsert;
        for(WEG_Journal_Attachment_Reference__c attachId : attachmentsToInsert ) {
            attachmentsIdSet.add(attachId.id);
        }
        attachmentsUpload(attachmentsIdSet);
    }
   
    public static void attachmentsUpload (Set<ID> journalAttachIds) {
        
        Map <ID, Map <String, String>> fileDetailsMap = NEW Map <ID, Map <String, String>> ();
        Map <ID, WEG_Journal_Attachment_Reference__c> journalWIthCloudFIle = new Map <id, WEG_Journal_Attachment_Reference__c> ();
        for( WEG_Journal_Attachment_Reference__c journalAttachRec : [SELECT WEG_JournalEC__c ,WEG_JournalEC__r.WEG_Related_To_ID__c
                                                                     FROM WEG_Journal_Attachment_Reference__c
                                                                     WHERE ID IN : journalAttachIds])
        {
            journalWIthCloudFIle.put (journalAttachRec.WEG_JournalEC__r.WEG_Related_To_ID__c, journalAttachRec);                             
        }
        List<TVA_CFB__Cloud_Files__c> cloudFilesList = NEW List <TVA_CFB__Cloud_Files__c> ();
        TVA_CFB__CloudFiles_Settings__c s3Credentials = TVA_CFB__CloudFiles_Settings__c.getInstance (userInfo.getUserID ());
        cloudFilesList = [ SELECT TVA_CFB__Bucket_Name__c, Name, TVA_CFB__File_type__c, TVA_CFB__Region__c
                          FROM TVA_CFB__Cloud_Files__c
                          WHERE ID IN :journalWIthCloudFIle.keySet () ];
        for (SObject cloudFile :cloudFilesList) {
            Map <String, String> innerMap = NEW Map <String, String> ();
            innerMap.put ('currentBucketName', (String) cloudFile.get ('TVA_CFB__Bucket_Name__c'));
            innerMap.put ('currentFileName',  cloudFile.ID+'.'+(String) cloudFile.get ('TVA_CFB__File_type__c'));
            innerMap.put ('newBucketName', s3Credentials.Journal_Bucket_name__c);
            innerMap.put ('newFileName', journalWIthCloudFIle.get (cloudFIle.ID).ID+'.'+(String) cloudFile.get ('TVA_CFB__File_type__c'));
            innerMap.put ('region', (String) cloudFile.get ('TVA_CFB__Region__c'));                
            fileDetailsMap.put (journalWIthCloudFIle.get (cloudFIle.ID).ID, innerMap);
            
        }  
        List <String> fileDetails = NEW List <String> ();
        
        for (ID key :fileDetailsMap.keySet ()) {
            fileDetails.add (fileDetailsMap.get (key).get ('currentBucketName'));
            fileDetails.add (fileDetailsMap.get (key).get ('currentFileName'));
            fileDetails.add (fileDetailsMap.get (key).get ('newBucketName'));
            fileDetails.add (fileDetailsMap.get (key).get ('newFileName'));
            fileDetails.add (fileDetailsMap.get (key).get ('region'));
            fileDetails.add (key);
        }
        copyAWSObject (fileDetails);
    }
    @Future (Callout = TRUE)
    public static Void copyAWSObject(List <String> fileDetails) {
        
        List <SObject> cloudFilesToUpdate = NEW List <SObject> ();  
        List <Messaging.SingleEmailMessage> mails = New List <Messaging.SingleEmailMessage> ();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String currentFileName = '';
            for (Integer i=0; i < fileDetails.size(); i = i+6) {
                
                String currentBucketName = fileDetails[i+0];
                currentFileName = fileDetails[i+1];
                String newBucketName = fileDetails[i+2];
                String newFileName = fileDetails[i+3];
                String region = fileDetails[i+4];
                ID cloudFileId = fileDetails[i+5];
                    TVA_CFB__CloudFiles_Settings__c s3Credentials = TVA_CFB__CloudFiles_Settings__c.getInstance (userInfo.getUserID ());
                    Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndPoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll ();
                    
                    Boolean encryptionFlag = s3Credentials.TVA_CFB__Server_Side_Encryption__c;
                    String versionTypeFlag = TVA_CFB.checkLicense.checkPremiumLicense();
                    
                    Datetime now = Datetime.now ();
                    String amzDate = now.formatGmt ('yyyyMMdd')+'T'+now.formatGmt ('HHmmss')+'Z';
                    
                    Blob hash = Crypto.generateDigest ('SHA-256', Blob.valueOf (''));
                    String Payloadaction = EncodingUtil.convertToHex (hash);
                    
                    String amazonUrl = regionEndpoints.get (region).TVA_CFB__Endpoint_URL__c;                    
                    String CanonicalRequest = 'PUT\n/'+newBucketName+'/'+newFileName 
                        +'\n\ncontent-type:application/json'+
                        +'\nhost:'+amazonUrl.removeStart ('https://')
                        
                        +'\nx-amz-content-sha256:'+Payloadaction
                        +'\nx-amz-copy-source:/'+currentBucketName+'/'+currentFileName
                        +'\nx-amz-date:'+amzDate
                        +'\nx-amz-metadata-directive:COPY';
                    String storageValue = 'STANDARD';
                    if (encryptionFlag && versionTypeFlag == '')
                        CanonicalRequest += '\nx-amz-server-side-encryption:AES256';
                    
                    CanonicalRequest += '\nx-amz-storage-class:'+storageValue
                        +'\nx-amz-target:s3:*'
                        +'\n\ncontent-type;host;x-amz-content-sha256;x-amz-copy-source;'
                        +'x-amz-date;x-amz-metadata-directive;';
                    if (encryptionFlag && versionTypeFlag == '')
                        CanonicalRequest += 'x-amz-server-side-encryption;';
                    
                    CanonicalRequest += 'x-amz-storage-class;x-amz-target\n'+Payloadaction;
                    
                    Blob hashCanonical = Crypto.generateDigest ('SHA-256', Blob.valueOf (CanonicalRequest));
                    String canonicalHash = EncodingUtil.convertToHex (hashCanonical);
                    
                    String StringtoSign = 'AWS4-HMAC-SHA256\n'+amzDate+'\n'
                        +DateTime.Now().formatGmt('yyyyMMdd')
                        +'/'+region+'/s3/aws4_request\n'+canonicalHash;
                    
                    Blob kDate     = Crypto.generateMac ('HMAC-SHA256', 
                                                         Blob.valueOf (DateTime.Now ().formatGmt ('yyyyMMdd')),
                                                         Blob.valueOf ('AWS4'+s3Credentials.TVA_CFB__secret_key__c)); 
                    
                    Blob kRegion   = Crypto.generateMac ('HMAC-SHA256', Blob.valueOf (region), kDate);
                    blob kService  = Crypto.generateMac ('HMAC-SHA256', Blob.valueOf ('s3'), kRegion);
                    blob kSigning  = Crypto.generateMac ('HMAC-SHA256', Blob.valueOf ('aws4_request'), kService);
                    Blob bsig      = Crypto.generateMac ('HMAC-SHA256', Blob.valueOf (StringtoSign), kSigning);  
                    
                    String signature = EncodingUtil.convertToHex (bsig);
                    
                    String AuthHeader = 'AWS4-HMAC-SHA256 Credential='+s3Credentials.TVA_CFB__Access_Key__c+'/'
                        +DateTime.Now ().formatGmt ('yyyyMMdd')+'/'+region
                        +'/s3/aws4_request,'
                        +'SignedHeaders=content-type;host;x-amz-target;x-amz-content-sha256;'
                        +'x-amz-metadata-directive;x-amz-copy-source;';
                    if (encryptionFlag && versionTypeFlag == '')
                        AuthHeader += 'x-amz-server-side-encryption;';                    
                    AuthHeader += 'x-amz-storage-class;x-amz-date,Signature=';         
                    AuthHeader = AuthHeader+signature;   
                    HttpRequest con = NEW HttpRequest ();
                    con.setMethod ('PUT');   
                    con.setEndPoint (regionEndpoints.get (region).TVA_CFB__Endpoint_URL__c+'/'+newBucketName+'/'+newFileName ) ;
                    con.setHeader ('x-amz-copy-source', '/'+currentBucketName+'/'+currentFileName);
                    con.setHeader ('host', amazonUrl.removeStart('https://'));  
                    con.setHeader ('Content-Type', 'application/json');  
                    con.setHeader ('x-amz-target','s3:*');
                    con.setHeader ('x-amz-content-sha256', Payloadaction);
                    con.setHeader ('x-amz-date', amzDate);
                    con.setHeader ('x-amz-metadata-directive', 'COPY');
                    con.setHeader ('x-amz-storage-class', storageValue);
                    con.setHeader ('Authorization', AuthHeader );
                    if (encryptionFlag && versionTypeFlag == '')
                        con.setHeader ('x-amz-server-side-encryption', 'AES256');                    
                    con.setHeader ('Connection', 'keep-alive');
                    con.setTimeOut (120000);
                    Http http = NEW Http ();
                    HTTPResponse res = NEW HTTPResponse ();
                    if (!Test.isRunningTest ())
                        res = http.send (con);
                    if (Test.isRunningTest()) {
                        res.setStatusCode (200);
                        res.setBody('<ETag>&quot;adsfasfadsacsdf2321dafsf&quot;</ETag>');
                    }
                    if (res.getStatusCode () == 200) {
                        String eTag = res.getBody ();
                        eTag = eTag.subStringBetween ('<ETag>&quot;', '&quot;</ETag>');
                        String versionId = res.getHeader ('x-amz-version-id');
                        SObject cloudFile = new WEG_Journal_Attachment_Reference__c ();
                        cloudFile.id = cloudFileID ;                        
                        
                        cloudFile.put ('WEG_Region__c', region);
                        cloudFile.put ('WEG_E_Tag__c', eTag);
                        cloudFile.put ('WEG_Bucket_Name__c', newBucketName);
                        cloudFile.put ('WEG_VersionID__c', versionId);
                        cloudFilesToUpdate.add (cloudFile);                        
                    }           
            }
            if (cloudFilesToUpdate.size () > 0)
                Update cloudFilesToUpdate; 
              
    }
    
    public static void emailMessageShare (List <EmailMessage> emailMessages) {
        List <String> systemEmails = new List <String> ();
        for (Journaling_System_Emails__mdt msg :[SELECT Email_Address__c FROM Journaling_System_Emails__mdt 
                                                WHERE Email_Address__c != NULL]) {
            systemEmails.add (msg.Email_Address__c);
        }
        List <WEG_Journal_EC__c> journalECrecords = new List <WEG_Journal_EC__c> ();
        Set <ID> contactIds = new Set <ID> ();
        for (EMailMessage msg :emailMessages) {
            if (msg.relatedToId != NULL) {
                if (String.valueOf ((msg.relatedToId)).startsWith ('003'))
                    contactIds.add (msg.relatedToId);
            }
        }
        
        Set <ID> emailMessageIds = new Set <ID> ();
        Map <ID, Contact> emailMsgMap = new Map <ID, Contact> ([SELECT Account.WEGP1_Primary_Household__c,
                                                        Account.WEGP1_Primary_Individual__c,
                                                        Owner.WEG_IsRIA_Only__c
                                                 FROM Contact WHERE ID IN: contactIds]);
        for (EMailMessage msg :emailMessages) {
            emailMessageIds.add (msg.ID);
            WEG_Journal_EC__c journal = new WEG_Journal_EC__c ();
            if (systemEmails.contains (msg.FromAddress)) {
                journal.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Email - System').getRecordTypeId();
                journal.WEG_Has_Attachment__c = FALSE;
            } else {
                journal.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Email - User').getRecordTypeId();
                journal.WEG_Has_Attachment__c = msg.hasAttachment;
            }
            journal.WEG_From_Address__c = msg.FromAddress;
            journal.WEG_From_Name__c  = msg.FromName;
            journal.WEG_Header__c = msg.Headers;
            journal.WEG_Html_Body__c = msg.HtmlBody;
            journal.WEG_Is_Incoming__c = False;
            journal.WEG_Message_Date__c = msg.createdDate;
            journal.WEG_Related_To__c = 'Email Message';
            journal.WEG_Related_To_ID__c = msg.ID;
            if (emailMsgMap.containsKey (msg.relatedToId)) {
                journal.WEG_HouseHold_AccountID__c = emailMsgMap.get (msg.relatedToId).Account.WEGP1_Primary_Household__c;
                journal.WEG_IndividualAccountID__c = emailMsgMap.get (msg.relatedToId).Account.WEGP1_Primary_Individual__c ;
                journal.WEG_RIA_Only__c = emailMsgMap.get (msg.relatedToId).Owner.WEG_IsRIA_Only__c;
            }
            
            journal.WEG_Subject__c = msg.Subject;
            journal.WEG_TextBody__c = msg.TextBody;
            journal.WEG_ToAddress__c = msg.ToAddress;
            journalECrecords.add (journal);
        }
        if (journalECrecords.size () > 0) 
            insert journalECrecords;
          
       
    }
    
    @InvocableMethod
    public static void createJournalRec(List<IdListReturned> IdsReturned) {
        List<ID> idsReturned1 = New List<ID> ();
        String stringReturned = '';
        for(IdListReturned returnParam : IdsReturned) {
            stringReturned = returnParam.returnedObj;
            idsReturned1.add(returnParam.returnIds);
        }
        List<WEG_Journal_EC__c> journalECRecords = New List<WEG_Journal_EC__c> ();
        if(idsReturned1 != null && stringReturned  == 'Cloud File') {
            for(TVA_CFB__Cloud_Files__c cloudFile : [SELECT ID,Primary_Portal_User__c,Secondary_Portal_User_Name__c,Primary_Portal_User_Name__c,Primary_Portal_User__r.Email,WEGP1_Household__c,Secondary_Portal_User__c,Secondary_Portal_User__r.Email FROM TVA_CFB__Cloud_Files__c WHERE ID IN : idsReturned1  AND (not WEG_Document_Name__c  like 'QAMR%')
                          AND (not WEG_Document_Name__c  like 'CCPY%')]) {
                WEG_Journal_EC__c journalRec = New WEG_Journal_EC__c ();
                    journalRec.WEG_From_Address__c = UserInfo.getUserEmail();
                    journalRec.WEG_From_Name__c = UserInfo.getUserName();
                    journalRec.WEG_HouseHold_AccountID__c = cloudFile.WEGP1_Household__c;
                    journalRec.WEG_Message_Date__c = datetime.now();
                    journalRec.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Email - User').getRecordTypeId();
                    journalRec.WEG_Related_To__c  = 'Email Message';
                    journalRec.WEG_Related_To_ID__c = cloudFile.id;
                    
                    if(cloudFile.Primary_Portal_User__c != null) {
                        journalRec.WEG_ToAddress__c = cloudFile.Primary_Portal_User__r.Email;
                        journalRec.WEG_Subject__c = 'You have a new document to review';
                        String emailBody = '';
                        emailBody= 'Dear '+cloudFile.Primary_Portal_User_Name__c+', Your advisory team at Wealth Enhancement Group has shared a document with you on our client portal. Please follow the link and log in to the portal to review the document: '+Label.Community_URL+' Your username is your primary email address on file at Wealth Enhancement Group. If you have any questions or trouble logging in to the portal, please call 1-800-492-1222 and ask to be directed to your advisory team. Advisory services offered through Wealth Enhancement Advisory Services, LLC (WEAS), a registered investment advisor. Certain, but not all, investment advisor representatives (IARs) of WEAS are also registered representatives of and offer securities through LPL Financial, member FINRA/SIPC. Wealth Enhancement Group and WEAS are separate entities from LPL. Wealth Enhancement Group is a registered trademark of Wealth Enhancement Group, LLC.';

                        emailBody= emailBody.replace('null','');
                        journalRec.WEG_TextBody__c  = emailBody;
                        journalRec.WEG_ToName__c = cloudFile.Primary_Portal_User_Name__c;
                    }
                journalECRecords.add(journalRec);
            }
        }
        if(idsReturned1 != null && stringReturned  == 'Cloud File Secondary') {
            for(TVA_CFB__Cloud_Files__c cloudFile : [SELECT ID,Primary_Portal_User__c,Secondary_Portal_User_Name__c,Primary_Portal_User_Name__c,Primary_Portal_User__r.Email,WEGP1_Household__c,Secondary_Portal_User__c,Secondary_Portal_User__r.Email FROM TVA_CFB__Cloud_Files__c WHERE ID IN : idsReturned1  AND (not WEG_Document_Name__c  like 'QAMR%')
                          AND (not WEG_Document_Name__c  like 'CCPY%')]) {
                WEG_Journal_EC__c journalRec = New WEG_Journal_EC__c ();
                    journalRec.WEG_From_Address__c = UserInfo.getUserEmail();
                    journalRec.WEG_From_Name__c = UserInfo.getUserName();
                    journalRec.WEG_HouseHold_AccountID__c = cloudFile.WEGP1_Household__c;
                    journalRec.WEG_Message_Date__c = datetime.now();
                    journalRec.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Email - User').getRecordTypeId();
                    journalRec.WEG_Related_To__c  = 'Email Message';
                    journalRec.WEG_Related_To_ID__c = cloudFile.id;
                    
                    if(cloudFile.Secondary_Portal_User__c != null) {
                        journalRec.WEG_ToAddress__c = cloudFile.Secondary_Portal_User__r.Email ;
                        journalRec.WEG_Subject__c = 'You have a new document to review';
                        String emailBody1 = '';
                        emailBody1 = 'Dear '+cloudFile.Secondary_Portal_User_Name__c+' Your advisory team at Wealth Enhancement Group has shared a document with you on our client portal. Please follow the link and log in to the portal to review the document:'+Label.Community_URL+' Your username is your primary email address on file at Wealth Enhancement Group. If you have any questions or trouble logging in to the portal, please call 1-800-492-1222 and ask to be directed to your advisory team. Advisory services offered through Wealth Enhancement Advisory Services, LLC (WEAS), a registered investment advisor. Certain, but not all, investment advisor representatives (IARs) of WEAS are also registered representatives of and offer securities through LPL Financial, member FINRA/SIPC. Wealth Enhancement Group and WEAS are separate entities from LPL. Wealth Enhancement Group is a registered trademark of Wealth Enhancement Group, LLC.';
                        emailBody1 = emailBody1.replace('null','');
                        journalRec.WEG_TextBody__c  = emailBody1 ;
                        journalRec.WEG_ToName__c = cloudFile.Secondary_Portal_User_Name__c;                    
                    }
                journalECRecords.add(journalRec);
            }
        }
        if(idsReturned1 != null && stringReturned == 'Secure Message') {
            for(Secure_Messaging__c secureMsgFile : [SELECT ID,Name,Account__c,Account__r.owner.Email,
                                                        Household_Account__r.Owner.Email,
                                                        Household_Account__r.Owner.Name,Household_Account__c,
                                                        Account__r.WEGP1_Primary_Household__c,Created_By__c,
                                                        Created_By_Username__c,Send_to_User__c, 
                                                        Receipient_Username__c,CreatedDate,X18_Digit_ID__c,
                                                        Operating_System__c,Browser__c,Customer_User__r.Email, Customer_User__r.Name,
                                                        IP_Address__c,Address__c,Message__c
                                                     FROM Secure_Messaging__c
                                                     WHERE ID IN : idsReturned1]) {
                WEG_Journal_EC__c journalRec1 = New WEG_Journal_EC__c ();
                    journalRec1.WEG_From_Address__c = UserInfo.getUserEmail();
                    journalRec1.WEG_From_Name__c = UserInfo.getUserName();
                    journalRec1.WEG_HouseHold_AccountID__c = secureMsgFile.Household_Account__c;
                    journalRec1.WEG_Message_Date__c = datetime.now();
                    journalRec1.recordTypeId = Schema.SObjectType.WEG_Journal_EC__c.getRecordTypeInfosByName().get('Email - User').getRecordTypeId();
                    journalRec1.WEG_Related_To__c  = 'Email Message';
                    journalRec1.WEG_Related_To_ID__c = secureMsgFile.id;
                    journalRec1.WEG_Subject__c = 'Secure Message Compliance';
                    String emailTextBody = '';
                    emailTextBody ='The following secure message has been sent using the Wealth Enhancement Group client portal.Created by - ';
                    emailTextBody += secureMsgFile.Created_By__c +'• Created by Username - '+secureMsgFile.Created_By_Username__c+'  Recipient - ';
                    emailTextBody += secureMsgFile.Send_to_User__c+'.  Recipient Username - '+secureMsgFile.Receipient_Username__c+' . Created date - '+secureMsgFile.CreatedDate+' . Unique ID/SFDC ID of record - '+secureMsgFile.X18_Digit_ID__c+' . Operating System - '+secureMsgFile.Operating_System__c+' . Browser - '+secureMsgFile.Browser__c+' .IP Address - '+secureMsgFile.IP_Address__c+' . Address - '+secureMsgFile.Address__c+' . Secure Message subject - '+secureMsgFile.Name+' . Secure Message content - '+secureMsgFile.Message__c+' Advisory services offered through Wealth Enhancement Advisory Services, LLC (WEAS), a registered investment advisor. Certain, but not all, investment advisor representatives (IARs) of WEAS are also registered representatives of and offer securities through LPL Financial, member FINRA/SIPC. Wealth Enhancement Group and WEAS are separate entities from LPL. Wealth Enhancement Group is a registered trademark of Wealth Enhancement Group, LLC.'; 
                    emailTextBody = emailTextBody.replace('null','');
                    journalRec1.WEG_TextBody__c  = emailTextBody;
                    
                    
                    if(userinfo.getUserType() == 'PowerCustomerSuccess'){
                        journalRec1.WEG_ToAddress__c = secureMsgFile.Household_Account__r.Owner.Email;
                        journalRec1.WEG_ToName__c = secureMsgFile.Household_Account__r.Owner.Name;
                    } else {
                        journalRec1.WEG_ToAddress__c = secureMsgFile.Customer_User__r.Email; 
                        journalRec1.WEG_ToName__c = secureMsgFile.Customer_User__r.Name;
                    }
                journalECRecords.add(journalRec1);
            }
        }      
        if (journalECRecords.size () > 0)
            insert journalECRecords;
       
        
        if(idsReturned1 != null && stringReturned  == 'Cloud File') {
            
        } 
      }
      public class IdListReturned{
    
        @InvocableVariable
        public String returnedObj;
        
        @InvocableVariable
        public Id returnIds;
        
    }
    
    
   
}