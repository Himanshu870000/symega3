public without sharing class SubmitForFertCodeController {
    
    @AuraEnabled
    public static void updateUser(String userSAPcode, String userId){
        System.debug('Update User Method Called');
        try{
            User userRec = [SELECT Id, Name, SAP_USER_CODE__c FROM User WHERE Id=:userId LIMIT 1];
            userRec.SAP_USER_CODE__c = userSAPcode;
            update userRec;                
        }
        catch(exception e){
            System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ==> ' + e.getLineNumber());
        }
    }

    @AuraEnabled
    public static void updateAccount(String accId, String dlvryPlant, String custType, String accSeg){
        System.debug('Update Account Method Called');
        try{
            Account accRec = [SELECT Id, Account_Segment__c, Delivery_Plant__c, Customer_Type__c FROM Account WHERE Id =: accId LIMIT 1];
            accRec.Account_Segment__c = accSeg;
            accRec.Delivery_Plant__c = dlvryPlant;
            accRec.Customer_Type__c = custType;
            update accRec;                
        }
        catch(exception e){
            System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ==> ' + e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static oppProdWrapper getOpportunityprods(String OppId){
        
        try{
            List<string> missingFieldsList = new List<string>();
            List<OpportunityLineItem> oppLineItemList = [SELECT ID, Name,Product2.Name, Product2Id,Packaging_Type__c, Art_Work__c, OpportunityId, Opportunity.Customer_Billing_Address__c, Opportunity.Customer_Billing_Address__r.Customer_Code_SAP__c, Opportunity.Account_Billing_Address__c, 
                                                         Opportunity.Account.Customer_Code_SAP__c, Opportunity.Account_Shipping_Address__c, Opportunity.AccountId, Opportunity.Account.Name, Opportunity.Billing_Country__c, Opportunity.Billing_State__c, 
                                                         Opportunity.Billing_Street__c, Opportunity.Billing_City__c, Opportunity.Customer_Shipping_Address__c,Opportunity.Billing_Postal_Code__c,Quantity,Fert_Description__c,Unit_Of_Measure__c,ProductCode,
                                                         Packaging_Quantity__c, Product2.Shelf_Life__c, Product2.Allergen_Status_Required__c,Product2.Veg_Nonveg_Logo_In_Label__c,Ingredients_List_Declared_With_Customer__c,
                                                         Customized_Label__c,Ingredient_list__c,Reveal_Symega_Identity__c,Cusinery_identity__c,Label__c,Sales_Remarks__c, Product2.Plant__c,Product2.HSN_Code__c,
                                                         Primary__c,Secondary__c,Tertiary__c FROM OpportunityLineItem WHERE OpportunityId =: OppId];
            System.debug('oppLineItemList---->'+oppLineItemList);
            
            Id custId;
            Id accId;
            oppProdWrapper opWrap = new oppProdWrapper();
            if(oppLineItemList[0].Opportunity.Account_Billing_Address__c){
                accId = oppLineItemList[0].Opportunity.AccountId;
                opwrap.isAccount = true;
                opwrap.isCustomer = false;
            }
            else if(oppLineItemList[0].Opportunity.Customer_Billing_Address__c != null){
                custId = oppLineItemList[0].Opportunity.Customer_Billing_Address__c;
                opwrap.isAccount = false;
                opwrap.isCustomer = true;
            }

            if(oppLineItemList[0].Opportunity.Account_Shipping_Address__c){
                accId = oppLineItemList[0].Opportunity.AccountId;
                opwrap.isAccountShipping = true;
                opwrap.isCustomerShipping = false;
            }
            else if(oppLineItemList[0].Opportunity.Customer_Shipping_Address__c != null){
                custId = oppLineItemList[0].Opportunity.Customer_Shipping_Address__c;
                opwrap.isAccountShipping = false;
                opwrap.isCustomerShipping = true;
            }
            opWrap.oliList = oppLineItemList;

            missingListWrapper selectedAddressWrapper = getOppRelatedAccountDetails(accId, custId, opwrap.isAccount, opwrap.isCustomer, opwrap.isAccountShipping, opwrap.isCustomerShipping);
            
            opWrap.missingFieldsList = selectedAddressWrapper.missingFieldList;
            opWrap.missingFieldsListCustAddress = selectedAddressWrapper.missingFieldsListCustAddress;
            opWrap.missingFieldsListForUser = selectedAddressWrapper.missingFieldListForUser;
            opWrap.missingFieldsListForBH = selectedAddressWrapper.missingFieldsListForBH;
            opwrap.accId = oppLineItemList[0].Opportunity.AccountId;
            opwrap.dispId = custId;
            opwrap.userIdList = selectedAddressWrapper.userIdList;
            opwrap.bhIdList = selectedAddressWrapper.bhIdList;
            opwrap.onlyAccMissingFieldList = selectedAddressWrapper.onlyAccMissingFieldList;
            return opWrap;
        }
        catch(Exception e){
            System.debug('Exception Line Number-->'+e.getLineNumber());
            System.debug('Exception Message-->'+e.getMessage());
            return null;
        }
    }
    
    public class oppProdWrapper{
        @AuraEnabled
        public  List<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        @AuraEnabled
        public Id accId;
        @AuraEnabled 
        public Id dispId;
        @AuraEnabled
        public List<String> missingFieldsList = new list<string>();
        @AuraEnabled
        public List<String> missingFieldsListCustAddress = new list<string>();
        @AuraEnabled
        public List<String> missingFieldsListForUser = new list<string>();
        @AuraEnabled
        public List<String> userIdList = new list<string>();
        @AuraEnabled
        public List<String> missingFieldsListForBH = new list<string>();
        @AuraEnabled
        public List<String> bhIdList = new list<string>();
        @AuraEnabled
        public Boolean isAccount;
        @AuraEnabled
        public Boolean isCustomer;
        @AuraEnabled
        public Boolean isAccountShipping;
        @AuraEnabled
        public Boolean isCustomerShipping;
        @AuraEnabled
        public List<String> onlyAccMissingFieldList = new list<string>();
    }
    
    @AuraEnabled
    Public Static Map<String,Map<String,List<String>>> GetPicklistValues_Object(){
        string ObjectName,FieldApi_Name;
        
        ObjectName='OpportunityLineItem';FieldApi_Name='Label__c';
        getPickListValuesIntoList(ObjectName,FieldApi_Name);
        
        Map<String,Map<String,List<String>>> ObjectName_FieldApiName_PickListValue=new Map<String,Map<String,List<String>>>();
        
        if(FieldApi_Name=='Label__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name); 
            ObjectName_FieldApiName_PickListValue.put('Label',getPickListValuesIntoList);
            ObjectName='OpportunityLineItem';FieldApi_Name='Ingredients_List_Declared_With_Customer__c';
        }
        if(FieldApi_Name=='Ingredients_List_Declared_With_Customer__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Ingredients_List_Declared_With_Customer',getPickListValuesIntoList);
            ObjectName='OpportunityLineItem';FieldApi_Name='Packaging_Type__c';
            
        }
        if(FieldApi_Name=='Packaging_Type__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Packaging_Type',getPickListValuesIntoList);
            ObjectName='Product2';FieldApi_Name='Plant__c';  
            
        }
        if(FieldApi_Name=='Plant__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Plant',getPickListValuesIntoList);
            ObjectName='Product2';FieldApi_Name='Veg_Nonveg_Logo_In_Label__c';              
        }
        if(FieldApi_Name=='Veg_Nonveg_Logo_In_Label__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('veglogo',getPickListValuesIntoList);
            ObjectName='Account';FieldApi_Name='Delivery_Plant__c';              
        }

        if(FieldApi_Name=='Delivery_Plant__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Delivery_Plant__c',getPickListValuesIntoList);
            ObjectName='Account';FieldApi_Name='Customer_Type__c';  
        }
        if(FieldApi_Name=='Customer_Type__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Customer_Type__c',getPickListValuesIntoList);
            ObjectName='Account';FieldApi_Name='Account_Segment__c';              
        }
        if(FieldApi_Name=='Account_Segment__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name);   
            ObjectName_FieldApiName_PickListValue.put('Account_Segment__c',getPickListValuesIntoList);
              ObjectName='OpportunityLineItem';FieldApi_Name='Primary__c';
        }

        if(FieldApi_Name=='Primary__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name); 
            ObjectName_FieldApiName_PickListValue.put('Primary__c',getPickListValuesIntoList);
            ObjectName='OpportunityLineItem';FieldApi_Name='Secondary__c';
        }
         if(FieldApi_Name=='Secondary__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name); 
            ObjectName_FieldApiName_PickListValue.put('Secondary__c',getPickListValuesIntoList);
            ObjectName='OpportunityLineItem';FieldApi_Name='Tertiary__c';
        }

         if(FieldApi_Name=='Tertiary__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name); 
            ObjectName_FieldApiName_PickListValue.put('Tertiary__c',getPickListValuesIntoList);     
              ObjectName='OpportunityLineItem';FieldApi_Name='Unit_Of_Measure__c'; 
        }
         if(FieldApi_Name=='Unit_Of_Measure__c'){
            Map<String,List<String>> getPickListValuesIntoList= getPickListValuesIntoList(ObjectName,FieldApi_Name); 
            ObjectName_FieldApiName_PickListValue.put('Unit_Of_Measure__c',getPickListValuesIntoList);     
        } 
        return ObjectName_FieldApiName_PickListValue;
    }
    
    public static Map<String,List<String>> getPickListValuesIntoList(String ObjectName,String FieldApiName){
        
        Map<String,List<String>> ObjectName_FieldApiName_PickListValue=new  Map<String,List<String>>();
        List<String> pickListValuesList= new List<String>();
        
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(FieldApiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());  
        }
        ObjectName_FieldApiName_PickListValue.put(FieldApiName,pickListValuesList);
        return ObjectName_FieldApiName_PickListValue;
    }
    
    @AuraEnabled
    Public Static String updateOppProdList(List<OpportunityLineItem> oppLineList,List<Product2> prod2List){        
        String result;
        try{
            update oppLineList;
            update prod2List;
           result = GetFERTCodeController.sendFERTCodeReqEmailNotificaiton(oppLineList[0].OpportunityId);
            //result = 'SUCCESS';
        }
        catch(Exception e){
            System.debug('Exception Line Number-->'+e.getLineNumber());
            System.debug('Exception Message-->'+e.getMessage());
            result = e.getMessage();
        }    
        return result;
    }
    
    public class WrapperData{
        @AuraEnabled
        public  Id prodId ;
        @AuraEnabled
        public Boolean bool ;
        @AuraEnabled 
        public Id prod2Id;
    }
    
    public class missingListWrapper{
        @AuraEnabled
        public List<String> onlyAccMissingFieldList = new list<string>();
        @AuraEnabled
        public List<String> missingFieldList = new list<string>();
        @AuraEnabled
        public List<String> missingFieldsListCustAddress = new list<string>();
        @AuraEnabled
        public  List<String> missingFieldListForUser = new list<string>(); 
        @AuraEnabled
        public  List<String> userIdList = new list<string>();
        @AuraEnabled
        public  List<String> missingFieldsListForBH = new list<string>();
        @AuraEnabled
        public  List<String> bhIdList = new list<string>();
        
    }
        
    private static missingListWrapper getOppRelatedAccountDetails(String accId, String custId, Boolean isAccount, Boolean isCustomer, Boolean isAccountShipping, Boolean isCustomerShipping){
        
        List<String> missingFieldsList = new List<String>();
        List<String> missingFieldsListCustAddress = new List<String>();
        List<String> onlyAccMissingFieldList = new List<String>();
        List<string> missingFieldsListForUser = new List<string>();
        List<string> userIdList = new List<string>();
        List<string> missingFieldsListForBH = new List<string>();
        List<string> bhIdList = new List<string>();
        
        missingListWrapper mlw = new missingListWrapper();
        try{
            Id userId;
            Id bhId;
            
            if(isAccount || isAccountShipping){
                Account accRec = [Select Id, Name, User__c, Customer_Contact__c, Customer_Type__c,OwnerId,CurrencyIsoCode,BillingCity,BillingCountry,BillingStreet,BillingPostalCode,BillingState,Delivery_Plant__c,Account_Segment__c,Transportation_Terms__c,PAN_Number__c,GST_number__c From Account Where Id =: accId];
                userId = accRec.OwnerId;
                bhId = accRec.User__c;
                
                if((accRec.Name == null) || (accRec.Name == '')){
                    missingFieldsList.add('Name');
                }
                
                if((accRec.BillingCity == null) || (accRec.BillingCity == '')){
                    missingFieldsList.add('BillingCity');
                }
                
                if(((accRec.BillingState == null) || (accRec.BillingState == '')) && accRec.Customer_Type__c!='Export'){
                    missingFieldsList.add('BillingState');
                    
                }               
                
                if((accRec.BillingStreet == null) || (accRec.BillingStreet == '')){
                    missingFieldsList.add('BillingStreet');
                }
                
                if((accRec.BillingCountry == null) || (accRec.BillingCountry == '')){
                    missingFieldsList.add('BillingCountry');
                }
                
                if((accRec.BillingPostalCode == null) || (accRec.BillingPostalCode == '')){
                    missingFieldsList.add('BillingPostalCode');
                }
                
                if((accRec.Customer_Type__c == null) || (accRec.Customer_Type__c == '')){
                    missingFieldsList.add('Customer_Type__c');
                }
                
                if((accRec.Account_Segment__c == null) || (accRec.Account_Segment__c == '')){
                    missingFieldsList.add('Account_Segment__c');
                }
                
                if((accRec.CurrencyIsoCode == null) || (accRec.CurrencyIsoCode == '')){
                    missingFieldsList.add('CurrencyIsoCode');
                }
                if(accRec.Customer_Contact__c == null){
                    missingFieldsList.add('Customer_Contact__c');
                }                
                
                if((accRec.Delivery_Plant__c == null) || (accRec.Delivery_Plant__c == '')){
                    missingFieldsList.add('Delivery_Plant__c');
                }
                
            }
            if(isCustomer || isCustomerShipping){
                Dispatch_Address__c disRec = [select id, Customer_Category__c, Account__r.User__c, Address__city__s, Address__Street__s, Address__PostalCode__s, Address__CountryCode__s, Address__StateCode__s,
                Contact__c,Account__c,Type__c, OwnerId, Account__r.Customer_Type__c, Account__r.Account_Segment__c, Account__r.Delivery_Plant__c, CurrencyIsoCode
                from Dispatch_Address__c WHERE Id =:custId];

                userId = disRec.OwnerId;
                bhId = disRec.Account__r.User__c;
                
                if((disRec.Address__city__s == null) || (disRec.Address__city__s == '')){
                    missingFieldsListCustAddress.add('Address__city__s');
                }
                
                if(((disRec.Address__StateCode__s == null) || (disRec.Address__StateCode__s == '')) && disRec.Account__r.Customer_Type__c!='Export'){
                    missingFieldsListCustAddress.add('Address__StateCode__s');
                }               
                
                if((disRec.Address__Street__s == null) || (disRec.Address__Street__s == '')){
                    missingFieldsListCustAddress.add('Address__Street__s');
                }
                
                if((disRec.Address__CountryCode__s == null) || (disRec.Address__CountryCode__s == '')){
                    missingFieldsListCustAddress.add('Address__CountryCode__s');
                }
                
                if((disRec.Address__PostalCode__s == null) || (disRec.Address__PostalCode__s == '')){
                    missingFieldsListCustAddress.add('Address__PostalCode__s');
                }

                if(String.isBlank(disRec.Customer_Category__c)){
                    missingFieldsListCustAddress.add('Customer_Category__c');
                }

                if(disRec.Contact__c == null){
                    missingFieldsListCustAddress.add('Contact__c');
                } 

                if((disRec.CurrencyIsoCode == null) || (disRec.CurrencyIsoCode == '')){
                    missingFieldsListCustAddress.add('CurrencyIsoCode');
                }
                
                if((disRec.Account__r.Customer_Type__c == null) || (disRec.Account__r.Customer_Type__c == '')){
                    onlyAccMissingFieldList.add('Customer_Type__c');
                }
                
                if((disRec.Account__r.Account_Segment__c == null) || (disRec.Account__r.Account_Segment__c == '')){
                    onlyAccMissingFieldList.add('Account_Segment__c');
                }
                
                if((disRec.Account__r.Delivery_Plant__c == null) || (disRec.Account__r.Delivery_Plant__c == '')){
                    onlyAccMissingFieldList.add('Delivery_Plant__c');
                }

                             
            }
            
            System.debug('missingFieldsList---->'+missingFieldsList); 
            System.debug('missingFieldsListCustAddress---->'+missingFieldsListCustAddress);
            
            userIdList.add(userId);
            List<User> userRec = [SELECT Id, Name, SAP_USER_CODE__c FROM User WHERE Id =: userId];
            if(userRec.size()>0 && userRec[0].SAP_USER_CODE__c == null){
                missingFieldsListForUser.add('SAP_USER_CODE__c');
                mlw.missingFieldListForUser = missingFieldsListForUser;
                mlw.userIdList = userIdList;
            }
            
            bhIdList.add(bhId);
            List<User> bhRec = [SELECT Id, Name, SAP_USER_CODE__c FROM User WHERE Id =: bhId];
            if(bhRec.size()>0 && bhRec[0].SAP_USER_CODE__c == null){
                missingFieldsListForBH.add('SAP_USER_CODE__c');
                mlw.missingFieldsListForBH = missingFieldsListForBH;
                mlw.bhIdList = bhIdList;
            }
            
            
            mlw.missingFieldList = missingFieldsList;
            mlw.missingFieldsListCustAddress = missingFieldsListCustAddress;
            mlw.onlyAccMissingFieldList = onlyAccMissingFieldList;
            System.debug('mlw.missingFieldList---->'+mlw.missingFieldList); 
            System.debug('mlw.missingFieldsListCustAddress---->'+mlw.missingFieldsListCustAddress);
            return mlw;
        }
        catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return mlw;
    }
    
    
}