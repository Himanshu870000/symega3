public class GetFERTCodeController {
    
    @AuraEnabled
    public static List<String> getPicklistValues(String ObjectApi_name, String Field_name){ 
        
        List<String> lstPickvals                        = new List<String>();
        Schema.SObjectType targetType                   = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name                             = targetType.newSObject();
        Schema.sObjectType sobject_type                 = Object_name.getSObjectType(); 
        Schema.DescribeSObjectResult sobject_describe   = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map      = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values     = field_map.get(Field_name).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : pick_list_values) {
            
            lstPickvals.add(String.ValueOf(a.getLabel()).trim());  
        }
        system.debug('lstPickvals'+lstPickvals);
        return lstPickvals;
    }
    
    static EmailTemplate FERTCodeTemplate;
    
    @AuraEnabled
    public static String sendFERTCodeReqEmailNotificaiton(string oppId) {
        
        //TODO: Anjali use this method to send notification, this method should be called from button on parent opportunity.
        String response = '';  //  Owner.Email,
        Opportunity opp = [Select Id,Name, OwnerId,  Send_Fert_Notification_Email__c, Owner.Email, Selected_Billing_Customer_Code__c, Selected_Shipping_Customer_Code__c, 

                           AccountId, Account.Customer_Code_SAP__c, Account_Billing_Address__c,Customer_Billing_Address__c,
                           Customer_Billing_Address__r.Customer_Code_SAP__c, Account.Submitted_to_SAP__c, Customer_Billing_Address__r.Submitted_to_SAP__c,

                           Account.Shipping_Customer_Code_SAP__c, Account_Shipping_Address__c, Customer_Shipping_Address__c,
                           Customer_Shipping_Address__r.SAP_Customer_Code_Shipping__c, Account.Shipping_Submitted_to_SAP__c, Customer_Shipping_Address__r.Shipping_Submitted_to_SAP__c

                           From Opportunity Where Id=:oppId];

        Boolean isBillingAccount;
        if(opp.Account_Billing_Address__c){
            isBillingAccount = true;
        }
        else if(opp.Customer_Billing_Address__c != null){
            isBillingAccount = false;
        }

        Boolean isShippingAccount;
        if(opp.Account_Shipping_Address__c){
            isShippingAccount = true;
        }
        else if(opp.Customer_Shipping_Address__c != null){
            isShippingAccount = false;
        }

        if(opp.Selected_Billing_Customer_Code__c && opp.Selected_Shipping_Customer_Code__c){
            system.debug('Hiiiiii...');
            sendFertCodeReqHelper(oppId, opp.OwnerId, opp.Owner.Email);
            response = 'Success';
        }
        else{

            if(!opp.Selected_Billing_Customer_Code__c){
                system.debug('Hiii... Inside Empty BILLING Customer Code Part... Test 123');

                if(isBillingAccount){ 
                    system.debug('Hiii... Inside Billing Account Part... Test 123278');
                    
                    String customerValidationRes = Utility.checkForInitialSubmission(opp.AccountId);
                    if(!opp.Account.Submitted_to_SAP__c){
                        if(customerValidationRes == 'Success'){
                            callFutureForAccount(opp.AccountId);
                            opp.Send_Fert_Notification_Email__c = true;
                            update opp;
                            response = 'create';
                        }
                        else{
                            response = customerValidationRes;
                        }
                    }
                    else{
                        response = 'progress';
                    }
                    
                    if(!opp.Selected_Shipping_Customer_Code__c){
                       system.debug('Hiii... Inside Empty Shipping Customer Code Part... Test 1232uoi2');

                        if(isShippingAccount){
                            system.debug('Hiii... Inside Shipping Acount Part... 2eu83ui');

                            String customerValidationResShipping = Utility.checkForInitialSubmission_ShippingAccount(opp.AccountId);
                            if(!opp.Account.Shipping_Submitted_to_SAP__c){
                                if(customerValidationResShipping == 'Success'){
                                    callFutureForShippingAccount(opp.AccountId);
                                    opp.Send_Fert_Notification_Email__c = true;
                                    update opp;
                                    response = 'create';
                                }
                                else{
                                    response = customerValidationResShipping;
                                }
                            }
                            else{
                                response = 'progress';
                            }
                        }
                        else{
                            system.debug('Hiii... Inside Shipping Address Part... 3872ujr');

                            String customerValidationResShipAdrs = Utility.checkForInitialSubmissionAddress(opp.Customer_Shipping_Address__c);
                            if(!opp.Customer_Shipping_Address__r.Shipping_Submitted_to_SAP__c){
                                if(customerValidationResShipAdrs == 'Success'){
                                    callFutureForAddress(opp.AccountId);
                                    opp.Send_Fert_Notification_Email__c = true;
                                    update opp;
                                    response = 'create';
                                }
                                else{
                                    response = customerValidationResShipAdrs;
                                }
                            }
                            else{
                                response = 'progress';
                            }
                        }
                    }   
                }
                else if(!isBillingAccount){
                    system.debug('Hiii... Inside Billing Address Part... 398ijkd');

                    String customerValidationRes = Utility.checkForInitialSubmissionAddress(opp.Customer_Billing_Address__c);
                    if(!opp.Customer_Billing_Address__r.Submitted_to_SAP__c){
                        if(customerValidationRes == 'Success'){                        
                            callFutureForAddress(opp.Customer_Billing_Address__c);
                            opp.Send_Fert_Notification_Email__c = true;
                            update opp;
                            response = 'create';
                        }
                        else{
                            response = customerValidationRes;
                        }
                    }
                    else{
                        response = 'progress';
                    }

                    if(!opp.Selected_Shipping_Customer_Code__c){
                        system.debug('Hiii... Inside Missing Shipping Customer Code Part... ieqjwqk');

                        if(isShippingAccount){
                            system.debug('Hiii... Inside Shipping Account Part NSMSNSMSNKKNS...');

                            String customerValidationResShip = Utility.checkForInitialSubmission_ShippingAccount(opp.AccountId);
                            if(!opp.Account.Shipping_Submitted_to_SAP__c){
                                if(customerValidationResShip == 'Success'){
                                    callFutureForShippingAccount(opp.AccountId);
                                    opp.Send_Fert_Notification_Email__c = true;
                                    update opp;
                                    response = 'create';
                                }
                                else{
                                    response = customerValidationResShip;
                                }
                            }
                            else{
                                response = 'progress';
                            }
                        }
                    } 
                }
            }
            else if(!opp.Selected_Shipping_Customer_Code__c){
    
                system.debug('Hiii... Inside Empty SHIPPING Customer Code Part... Test 123dks');

                if(isShippingAccount){ 
                    system.debug('Hiii... Inside Shipping Account Part... Test 123hgj278');
                    
                    String customerValidationRes = Utility.checkForInitialSubmission_ShippingAccount(opp.AccountId);
                    if(!opp.Account.Shipping_Submitted_to_SAP__c){
                        if(customerValidationRes == 'Success'){
                            callFutureForShippingAccount(opp.AccountId);
                            opp.Send_Fert_Notification_Email__c = true;
                            update opp;
                            response = 'create';
                        }
                        else{
                            response = customerValidationRes;
                        }
                    }
                    else{
                        response = 'progress';
                    }
                }
                else{
                    system.debug('Hiii... Inside Shipping Address Part... 398ijkdsdnfjs');

                    String customerValidationRes = Utility.checkForInitialSubmissionAddress(opp.Customer_Shipping_Address__c);
                    if(!opp.Customer_Shipping_Address__r.Shipping_Submitted_to_SAP__c){
                        if(customerValidationRes == 'Success'){                        
                            callFutureForAddress(opp.Customer_Shipping_Address__c);
                            opp.Send_Fert_Notification_Email__c = true;
                            update opp;
                            response = 'create';
                        }
                        else{
                            response = customerValidationRes;
                        }
                    }
                    else{
                        response = 'progress';
                    }
                }
            }

        }




        /*if(!String.isEmpty(customerCode)){
            system.debug('Hiiiiii...');
            sendFertCodeReqHelper(oppId, opp.OwnerId, opp.Owner.Email);
            response = 'Success';
        }
        else{
            if(isAccount){
                String customerValidationRes = Utility.checkForInitialSubmission(opp.AccountId);
                if(!opp.Account.Submitted_to_SAP__c){
                    if(customerValidationRes == 'Success'){
                        callFutureForAccount(opp.AccountId);
                        opp.Send_Fert_Notification_Email__c = true;
                        update opp;
                        response = 'create';
                    }
                    else{
                        response = customerValidationRes;
                    }
                }
                else{
                    response = 'progress';
                }
            }
            else if(!isAccount){
                String customerValidationRes = Utility.checkForInitialSubmissionAddress(opp.Customer_Billing_Address__c);
                if(!opp.Customer_Billing_Address__r.Submitted_to_SAP__c){
                    if(customerValidationRes == 'Success'){                        
                        callFutureForAddress(opp.Customer_Billing_Address__c);
                        opp.Send_Fert_Notification_Email__c = true;
                        update opp;
                        response = 'create';
                    }
                    else{
                        response = customerValidationRes;
                    }
                }
                else{
                    response = 'progress';
                }
            }
        } */
        
        return response;
    }
    
    
    @future(callout=true)
    public static void callFutureForAddress(Id caId){
        Dispatch_Address__c addrRec = [SELECT Id, Submitted_to_SAP__c, Initial_SAP_Update__c FROM Dispatch_Address__c WHERE Id =: caId];
        String resp = SAP_CreateAddressCustomerCallout.createCustomer(caId, true);
        if(resp.equalsIgnoreCase('Success')){
            if(addrRec.Submitted_to_SAP__c != true){
                addrRec.Submitted_to_SAP__c = true;
                update addrRec;
            }
        }
        if(addrRec.Initial_SAP_Update__c != true){
            addrRec.Initial_SAP_Update__c = true;
            update addrRec;
        }
    }

    @future(callout=true)
    public static void callFutureForAccount(Id accId){
        Account accRec = [SELECT Id, Submitted_to_SAP__c, Initial_SAP_Update__c FROM Account WHERE Id =: accId];
        String resp = SAP_CreateCustomerCallout.createCustomer(accId, true);
        if(resp.equalsIgnoreCase('Success')){
            if(accRec.Submitted_to_SAP__c != true){
                accRec.Submitted_to_SAP__c = true;
                update accRec;
            }
        }

        if(accRec.Initial_SAP_Update__c != true){
            accRec.Initial_SAP_Update__c = true;
            update accRec;
        }

    }

    @future(callout=true)
    public static void callFutureForShippingAccount(Id accId){
        Account accRec = [SELECT Id, Shipping_Submitted_to_SAP__c, Shipping_Initial_SAP_Update__c FROM Account WHERE Id =: accId];
        String resp = SAP_CreateShippingCustomerCallout_NEW.createCustomer(accId, true);
        if(resp.equalsIgnoreCase('Success')){
            if(accRec.Shipping_Submitted_to_SAP__c != true){
                accRec.Shipping_Submitted_to_SAP__c = true;
                update accRec;
            }
        }

        if(accRec.Shipping_Initial_SAP_Update__c != true){
            accRec.Shipping_Initial_SAP_Update__c = true;
            update accRec;
        }
    }

    public static void sendFertCodeEmailBulkAddress(List<Id> addrId){
        List<Opportunity> oppList = [Select Id, Name, OwnerId, Owner.Email, Send_Fert_Notification_Email__c From Opportunity Where Customer_Billing_Address__c IN : addrId AND Send_Fert_Notification_Email__c=true];
        for(Opportunity opp : oppList){
            sendFertCodeReqHelper(opp.Id, opp.OwnerId, opp.Owner.Email);
            opp.Send_Fert_Notification_Email__c = false;
        }
        update oppList;
    }
    
    public static void sendFertCodeEmailBulk(List<Id> accId){
        List<Opportunity> oppList = [Select Id, Name, OwnerId, Owner.Email, Send_Fert_Notification_Email__c From Opportunity Where AccountId IN : accId AND Send_Fert_Notification_Email__c=true];
        for(Opportunity opp : oppList){
            sendFertCodeReqHelper(opp.Id, opp.OwnerId, opp.Owner.Email);
            opp.Send_Fert_Notification_Email__c = false;
        }
        update oppList;
    }
    
    public static void sendFertCodeReqHelper(String oppId, Id senderUserId, String senderUserEmail){
        try{
            
            List<Sale_Order_Notification__mdt> mdtList = Sale_Order_Notification__mdt.getAll().Values();
            Map<String, Sale_Order_Notification__mdt> getMDTByProdFmlyMap = new Map<String, Sale_Order_Notification__mdt>();
            
            for(Sale_Order_Notification__mdt mdt : mdtList){
                getMDTByProdFmlyMap.put(mdt.Label, mdt);
            }
            
            if(mdtList==null){return;}
            List<OpportunityLineItem> oppLineItemList = [SELECT Id, Product2.Family FROM OpportunityLineItem WHERE OpportunityId =: oppId];
            Map <string, List<OpportunityLineItem>> prodFamilyByOppProdsMap = new Map <string, List<OpportunityLineItem>>();
            if(oppLineItemList.size()>0){
                for (OpportunityLineItem prod : oppLineItemList) {
                    if(prod.Product2.Family != null){
                        if(prodFamilyByOppProdsMap.containsKey(prod.Product2.Family)) {
                            prodFamilyByOppProdsMap.get(prod.Product2.Family).add(prod); 
                        }
                        else{
                            prodFamilyByOppProdsMap.put(prod.Product2.Family, new List<OpportunityLineItem> {prod});
                        }    
                    }
                }   
                
                if(prodFamilyByOppProdsMap.size()>0){
                    List<ContentDocumentLink> docLinks  = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: oppId ]; 
                    system.debug('docLinks -- ' + docLinks);
                    system.debug('docLinks.size() -- ' + docLinks.size());
                    
                    set<id> cdIdSet = new set<id>();
                    for(ContentDocumentLink cdl : docLinks){
                        cdIdSet.add(cdl.ContentDocumentId);
                    }
                    system.debug('cdIdSet -- ' + cdIdSet);
                    List<ContentVersion> cVerList = [SELECT ContentDocumentId, VersionData, FileExtension, FileType, Id, Title FROM ContentVersion WHERE ContentDocumentId IN: cdIdSet AND Title LIKE '%Purchase Order%'];
                    system.debug('cVerList -- ' + cVerList);
                    system.debug('cVerList.size() -- ' + cVerList.size());
                    
                    
                    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                    for (ContentVersion cVer: cVerList) {
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(cVer.Title + '.' + cVer.FileExtension);
                        efa.setBody(cVer.VersionData);
                        //efa.setContentType(cVer.ContentType);
                        attachments.add(efa);
                    }
                    
                    for(String prodFamily : prodFamilyByOppProdsMap.keyset()){
                        
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        system.debug('UserInfo.getUserId() -- ' + UserInfo.getUserId());
                        message.setTargetObjectId(senderUserId);
                        //message.setTreatTargetObjectAsRecipient(false);
                        message.setSenderDisplayName('Symega Foods');
                        message.setReplyTo(senderUserEmail);
                        message.setUseSignature(false);
                        message.setBccSender(false);
                        message.setSaveAsActivity(false);
                        
                        if(FERTCodeTemplate==null){
                            FERTCodeTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE name = 'Request for Fert Code'];
                        }
                        
                        if(FERTCodeTemplate == null){return;}
                        message.setTemplateID(FERTCodeTemplate.Id);
                        message.setWhatId(oppId);
                        
                        String emails = getMDTByProdFmlyMap.get(prodFamily).User_Emails__c;
                        List <String> emailRecipients = emails.split(',');
                        if(emailRecipients == null){return;}
                        message.setToAddresses(emailRecipients);
                        
                        List <String> cC_EmailRecipients = new List <String>();
                        if(getMDTByProdFmlyMap.get(prodFamily).cC_Email_Ids__c != null){
                            String cC_Emails = getMDTByProdFmlyMap.get(prodFamily).cC_Email_Ids__c;
                            cC_EmailRecipients = cC_Emails.split(',');
                            if(!cC_EmailRecipients.isEmpty()){
                                message.setCcAddresses(cC_EmailRecipients);
                            }
                        }
                        
                        if(attachments.size()>0)
                            message.setFileAttachments(attachments);
                        
                        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                            Messaging.SendEmailResult[] results =  Messaging.sendEmail(messages);
                        
                        if (results[0].success){
                            System.debug('The email was sent successfully.');
                        }
                        else{
                            System.debug('The email failed to send: ' + results[0].errors[0].message);
                        }
                    }               
                }
            }
        }
        catch(Exception e){
            HandleBusinessException.captureError('GetFERTCodeController', 'sendFertCodeReqHelper', e);
            system.debug('Email Error : ' + e.getMessage() + ' At Line No : ' + e.getLineNumber()); 
        }
    }
    
    @AuraEnabled
    public static List<OpportunityLineItem> getProductList(string oppId){
        system.debug('oppId ====>' + oppId);
        List<OpportunityLineItem> productList = [SELECT Id, Name, Quantity, UnitPrice, TotalPrice, Primary__c, Secondary__c, Tertiary__c, Customized_Label__c, Symega_Logo__c, Material_Sector__c, Plant__c,
                                                 If_Organised_set_Micro_as_Long_Term__c,Opportunity.AccountID FROM OpportunityLineItem WHERE OpportunityId =: oppId];
        return productList;
    }
    
    @AuraEnabled
    public static string OppLineItemUpdate (List<OpportunityLineItem> OLIRecords){        
        try{
            system.debug('OLIRecords Records ====>' + OLIRecords);
            update OLIRecords;
            return 'Success';
        } 
        catch(Exception e){
            HandleBusinessException.captureError('GetFERTCodeController', 'OppLineItemUpdate', e);
            system.debug('Email Error : ' + e.getMessage() + ' At Line No : ' + e.getLineNumber()); 
            return e.getMessage();
        }
    }
    
    // Method for get Opp related Account Details
    @AuraEnabled
    public static Boolean getOppRelatedAccountDetails(String oppId){
        Opportunity opp = new Opportunity();
        Account accRec = new Account();
        List<String> missingReqField = new List<String>();
        try{
            if(String.isNotBlank(oppId))
                opp = [SELECT Id, AccountId,Name FROM Opportunity WHERE Id=:oppId];
            if(string.isNotBlank(opp.AccountId)){

                string accValidationsResp = Utility.checkForInitialSubmission(opp.AccountId);
                if(accValidationsResp.equalsIgnoreCase('Success')){
                    return false;
                }
                else{
                    return true;
                }
                
                /*accRec = [Select Id,Customer_Type__c,BillingCountry,BillingPostalCode,BillingState,Delivery_Plant__c,Account_Segment__c,Transportation_Terms__c,PAN_Number__c,GST_number__c From Account Where ID=:opp.AccountId];
                // system.debug('Yes Found Blank accRec.PAN_Number__c ==>'+accRec.PAN_Number__c);
                if((accRec.Customer_Type__c == null) || (accRec.Customer_Type__c =='')){
                    missingReqField.add('Customer_Type__c');
                    system.debug('Yes Found  accRec.Customer_Type__c ==>'+accRec.Customer_Type__c);
                }
                if((accRec.BillingCountry == null) || (accRec.BillingCountry == '')){
                    missingReqField.add('BillingCountry');
                    system.debug('Yes Found  accRec.BillingCountry ==>'+accRec.BillingCountry);
                }
                
                if((accRec.BillingPostalCode == null) || (accRec.BillingPostalCode == '')){
                    missingReqField.add('BillingPostalCode');
                    system.debug('Yes Found  accRec.BillingPostalCode ==>'+accRec.BillingPostalCode);
                }
                
                if((accRec.BillingState == null) || (accRec.BillingState == '')){
                    missingReqField.add('BillingState');
                    system.debug('Yes Found  accRec.CustoBillingStatemer_Type__c ==>'+accRec.BillingState);
                }
                if((accRec.Delivery_Plant__c == null) || (accRec.Delivery_Plant__c == '')){
                    missingReqField.add('Delivery_Plant__c');
                    system.debug('Yes Found  accRec.Delivery_Plant__c ==>'+accRec.Delivery_Plant__c);
                }
                if((accRec.Account_Segment__c == null) || (accRec.Account_Segment__c == '')){
                    missingReqField.add('Account_Segment__c');
                    system.debug('Yes Found  accRec.Account_Segment__c ==>'+accRec.Account_Segment__c);
                }
                if((accRec.Transportation_Terms__c == null) || (accRec.Transportation_Terms__c == '')){
                    missingReqField.add('Transportation_Terms__c');
                    system.debug('Yes Found  accRec.Transportation_Terms__c ==>'+accRec.Transportation_Terms__c);
                }
                if((accRec.PAN_Number__c == null) || (accRec.PAN_Number__c == '')){
                    missingReqField.add('PAN_Number__c');
                    system.debug('Yes Found  accRec.PAN_Number__c ==>'+accRec.PAN_Number__c);
                }
                if((accRec.GST_number__c == null) || (accRec.GST_number__c == '')){
                    missingReqField.add('GST_number__c');
                    system.debug('Yes Found  accRec.GST_number__c ==>'+accRec.GST_number__c);
                }
                system.debug('Missing Field List === >'+missingReqField);
                return missingReqField;*/
            }
        }
        catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static Opportunity updateOppRelatedAccountRecords(String oppId){
        try{
            Opportunity oppRec = [SELECT Id,AccountId,Name FROM Opportunity WHERE Id=:oppId];
            
            return oppRec;
        }
        catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
}