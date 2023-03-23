' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' Component initialization, setting default properties, configuring observers (handlers)
sub init()
    print ">>> RokuSignUp :: init()"
    m.top.visible = false
    m.billingProducts = {}

    m.billing = m.top.FindNode("billing")
    m.billing.ObserveField("userData", "On_billing_partialUserData")
    m.billing.ObserveField("catalog", "On_billing_catalog")
    m.billing.ObserveField("purchases", "On_billing_purchases")
    m.billing.ObserveField("orderStatus", "On_billing_purchaseResult")
    
    m.authScreen = m.top.FindNode("authScreen")
    m.authScreen.buttonLogin.ObserveField("buttonSelected", "On_Login")
    m.authScreen.buttonSignup.ObserveField("buttonSelected", "On_Signup")
    m.authScreen.buttonLogin.SetFocus(true)
    
    m.loginAuthFlow = m.top.FindNode("loginAuthFlow")
    m.loginAuthFlow.dialogAuthFailed.title = "Login failed"
    m.loginAuthFlow.ObserveField("isAuthorized", "On_loginAuthFlow_isAuthorized")
    
    m.signupAuthFlow = m.top.FindNode("signupAuthFlow")
    m.signupAuthFlow.kbdialogEmail.title = "Enter the email address for new account creation"
    m.signupAuthFlow.kbdialogPassword.title = "Create the password"
    m.signupAuthFlow.dialogAuthFailed.title = "User account creation failed"
    m.signupAuthFlow.ObserveField("isAuthorized", "On_signupAuthFlow_isAuthorized")
    
    m.top.dialogSelectSub = CreateObject("roSGNode", "BackDialog")
    m.top.dialogSelectSub.title = "Subscription"
    m.top.dialogSelectSub.message = "Please select subscription type"
    m.top.dialogSelectSub.ObserveField("buttonSelected", "On_dialogSelectSub_buttonSelected")
    
    m.top.dialogNoSubToPurchase = CreateObject("roSGNode", "BackDialog")
    m.top.dialogNoSubToPurchase.title = "No available subscriptions to purchase"
    m.top.dialogNoSubToPurchase.message = "Please check your Roku account for previously purchased products."
    m.top.dialogNoSubToPurchase.buttons = ["OK"]
    m.top.dialogNoSubToPurchase.ObserveField("buttonSelected", "On_SignupNoSub")
    
    m.top.dialogBillingNA = CreateObject("roSGNode", "BackDialog")
    m.top.dialogBillingNA.title = "Service unavailable"
    m.top.dialogBillingNA.message = "Subscription service is currently unavailable, please try again later."
    m.top.dialogBillingNA.buttons = ["OK"]
    m.top.dialogBillingNA.ObserveField("buttonSelected", "On_SubscriptionFailed")
    
    m.top.pdialogCheckSubs = CreateObject("roSGNode", "ProgressDialog")
    m.top.pdialogCheckSubs.title = "Checking subscriptions..."
    
    m.top.pdialogPurchase = CreateObject("roSGNode", "ProgressDialog")
    m.top.pdialogPurchase.title = "Purchasing subscription..."
    
    m.allDialogs = [
        m.loginAuthFlow.kbdialogEmail
        m.loginAuthFlow.kbdialogPassword
        m.loginAuthFlow.dialogErrEmail
        m.loginAuthFlow.dialogErrPassword
        m.loginAuthFlow.dialogAuthFailed
        
        m.signupAuthFlow.kbdialogEmail
        m.signupAuthFlow.kbdialogPassword
        m.signupAuthFlow.dialogErrEmail
        m.signupAuthFlow.dialogErrPassword
        m.signupAuthFlow.dialogTermsOfUse
        m.signupAuthFlow.dialogAuthFailed
        
        m.top.dialogSelectSub
        m.top.dialogNoSubToPurchase
        m.top.dialogBillingNA
    ]
    
    print "<<< RokuSignUp :: init()"
end sub


' onChange handler for "show" field
sub On_show()
    m.top.visible = m.top.show
    m.top.setFocus(m.top.show)
    
    if m.top.show then
        if m.top.isAuthNeeded AND not m.top.isAuthorized then
            m.authScreen.show = m.top.show
        else
            m.loginAuthFlow.isAuthorized = true
        end if
    end if
end sub


' onChange handler for "regexEmail" field
sub On_regexEmail()
    m.loginAuthFlow.regexEmail = m.top.regexEmail
    m.signupAuthFlow.regexEmail = m.top.regexEmail
end sub


' onChange handler for "regexPassword" field
sub On_regexPassword()
    m.loginAuthFlow.regexPassword = m.top.regexPassword
    m.signupAuthFlow.regexPassword = m.top.regexPassword
end sub


' onChange handler for "textTermsOfUse" field
sub On_textTermsOfUse()
    m.signupAuthFlow.dialogTermsOfUse.message = m.top.textTermsOfUse
end sub


' onChange handler for "dialogsConfig" field
sub On_dialogsConfig()
    if m.allDialogs = invalid OR m.top.dialogsConfig = invalid then
        return
    end if
    
    for each dialog in m.allDialogs
        dialog.SetFields(m.top.dialogsConfig)
    end for
end sub


' onChange handler for "dialogsButtonConfig" field
sub On_dialogsButtonConfig()
    if m.allDialogs = invalid OR m.top.dialogsButtonConfig = invalid then
        return
    end if
    
    for each dialog in m.allDialogs
        dialog.buttonGroup.SetFields(m.top.dialogsButtonConfig)
    end for
end sub


' Handler for processing login flow button selection 
sub On_Login()  
    m.loginAuthFlow.kbdialogEmail.text = ""
    m.loginAuthFlow.show = true
end sub


' Handler for processing signup flow button selection
sub On_Signup()
    if GetParentScene() = invalid then
        return
    end if

    print ">> Check subscription"
    m.parentScene.dialog = m.top.pdialogCheckSubs
    GetCatalog()
end sub

' Handler for processing signup flow without subscribtion avaliable
sub On_SignupNoSub()
    m.signupAuthFlow.kbdialogEmail.text = ""
    m.signupAuthFlow.show = true
end sub


' Handler for processing partialUserData returned from user data sharing dialog
sub On_billing_partialUserData()
    userEmail = ""
    if m.billing.userData <> invalid then
        userEmail = m.billing.userData.email
    end if
    m.signupAuthFlow.kbdialogEmail.text = userEmail
    m.signupAuthFlow.show = true
    print "<< Getting User Data"
end sub


' Handler for processing authorization by login API (also invoked if only Roku Billing subscription used)
sub On_loginAuthFlow_isAuthorized()
    m.top.isAuthorized = m.loginAuthFlow.isAuthorized
    m.top.isAfterLoginAuthFlow = true
end sub


' Handler for processing authorization by signup API
sub On_signupAuthFlow_isAuthorized()
    m.top.isAuthorized = m.signupAuthFlow.isAuthorized
    m.top.isAfterLoginAuthFlow = false
end sub


' Handler for processing completion of authorization flow using login/signup API
sub On_isAfterLoginAuthFlow()
    if GetParentScene() = invalid then
        return
    end if

    if m.top.isAuthorized AND m.billing.catalog <> invalid AND m.billing.purchases <> invalid then
        if m.top.dialogSelectSub <> invalid AND m.top.dialogSelectSub.buttonSelected <> invalid then
            m.parentScene.dialog = m.top.pdialogPurchase
            PurchaseProduct(m.top.dialogSelectSub.buttonSelected)
        end if
    end if
end sub


' Handler for processing catalog result.
' Catalog field is ContentNode containing command completion status. 
' If successful, the catalog field's ContentNode will have child ContentNode's containing information about each available item.
' Then we need to requests the list of purchases associated with the current user account.
sub On_billing_catalog()
    if m.billing.catalog = invalid OR m.billing.catalog.status = invalid then
        m.top.isSubscribed = false
        return
    end if

    if m.billing.catalog.status = 1 then
        m.billing.command = "getPurchases"
    else
        m.top.isSubscribed = false
    end if

end sub


' Handler for processing purchases result.
' When the command completes,the purchases field will be set to a ContentNode 
' containing information about the command's completion as shown in the table below. 
' In addition, that ContentNode will have child ContentNode's that contain information about each purchased item.
sub On_billing_purchases()
    if m.billing.purchases = invalid OR m.billing.purchases.status = invalid then
        m.top.isSubscribed = false
        return
    end if

    if m.billing.purchases.status = 1 then
        On_billing_products()
    else
        m.top.isSubscribed = false
    end if
end sub


' Handler for processing Roku Billing subscription products
sub On_billing_products()
    if GetParentScene() = invalid then
        return
    end if

    m.billingProducts = GetParsedProducts()

    if m.bAfterAuthLogin <> invalid AND m.bAfterAuthLogin AND m.billingProducts.validPurchased.list.Count() > 0 then
        m.top.isSubscribed = true
    else if m.billingProducts.availForPurchase.list.Count() > 0 then
        subscriptions = []
        for each item in m.billingProducts.availForPurchase.list
            subscriptions.Push(item.name + " " + item.cost) 
        end for
        m.top.dialogSelectSub.buttons = subscriptions
        m.parentScene.dialog = m.top.dialogSelectSub
    else if m.billingProducts.validPurchased.list.Count() > 0 then
        m.parentScene.dialog = m.top.dialogNoSubToPurchase
    else
        m.parentScene.dialog = m.top.dialogBillingNA
    end if

end sub


' Handler for processing subscription selected from subscription selection dialog
sub On_dialogSelectSub_buttonSelected()
    if GetParentScene() = invalid then
        return
    end if
    print "<< Check subscription"
    if m.top.dialogSelectSub.buttonSelected < 0 then
        On_SubscriptionFailed()
    else
        print ">> Getting User Data"
        m.billing.requestedUserData = "email"
        m.billing.command = "getUserData"
    end if
end sub


' Handler for processing subscription failure
sub On_SubscriptionFailed()
    m.top.isSubscribed = false
end sub


' Handler for processing subscription product purchase result
sub On_billing_purchaseResult()
    if m.billing.orderStatus = invalid OR m.billing.orderStatus.status = invalid then
        m.top.isSubscribed = false
        return
    end if

    if m.billing.orderStatus.status = 1 then
        m.top.isSubscribed = true
    else
        m.top.isSubscribed = false
    end if
end sub


' Requests the list of In-Channel products that are linked to the running channel.
sub GetCatalog()
    print ">> Getting Products (Catalog and Purchases)"
    m.billing.command = "getCatalog"
end sub


' Filter catalog and purchases and show avaliable products.
Function GetParsedProducts() As Object
    result = {
        availForPurchase : {
            list : []
            map  : {}
        }
        validPurchased : {
            list : []
            map  : {}
        }
    }

    allProducts = []
    if m.billing <> invalid AND m.billing.catalog <> invalid then
        catalogCount = m.billing.catalog.getChildCount()
        for i = 0 to catalogCount - 1
            catalogItem = m.billing.catalog.getChild(i).getFields()
            if catalogItem <> invalid then allProducts.push(catalogItem)
        end for
    end if

    purchasedProducts = []
    if m.purchases <> invalid AND m.billing.purchases <> invalid then
        purchasesCount = m.billing.purchases.getChildCount()
        for i = 0 to purchasesCount - 1
            purchasesItem = m.billing.purchases.getChild(i).getFields()
            if purchasesItem <> invalid then purchasedProducts.push(purchasesItem)
        end for
    end if
    
    datetime = CreateObject("roDateTime")
    utimeNow = datetime.AsSeconds()

    for each product in allProducts
        bAddToAvail = true
        for each purchase in purchasedProducts
            if purchase.code = product.code then
                bAddToAvail = false
                if purchase.expirationDate <> invalid then
                    datetime.FromISO8601String(purchase.expirationDate)
                    utimeExpire = datetime.AsSeconds()
                    if utimeExpire > utimeNow then
                        result.validPurchased.list.Push(purchase)
                        result.validPurchased.map[purchase.code] = purchase
                    end if
                end if
                exit for
            end if
        end for
        
        if bAddToAvail then
            result.availForPurchase.list.Push(product)
            result.availForPurchase.map[product.code] = product
        end if
    end for
    
    return result
End Function


' Purchasing Roku Billing product specified by "indexPurchase".
sub PurchaseProduct(index As Integer)   
    ' clear order
    m.billing.order = invalid

    myOrder = CreateObject("roSGNode", "ContentNode")
    myFirstItem = myOrder.createChild("ContentNode")
    myFirstItem.addFields({ "code": m.billingProducts.availForPurchase.list[index].code, "qty": 1})
    
    m.billing.order = myOrder

    m.billing.command = "doOrder"
end sub