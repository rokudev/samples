'********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

function init()
    configAA = ReadConfigFile("pkg:/config.json")
    m.groups = GetProductGroups(configAA)
    'setupCommandList(m.groups)''

    ' create billing component node'
    m.billing = createObject("roSGNode", "Billing")

    ' Set product screen as the initial screen'
    m.productScreen = m.top.FindNode("productScreen")
    m.productScreen.billing = m.billing
    m.productScreen.groups = m.groups
    'm.productScreen.ObserveField("itemSelected", "onProductSelected")
    'm.purchaseGrid = m.top.FindNode("purchaseGrid")
    'm.purchaseGrid.ObserveField("itemSelected", "onPurchaseSelected")
    'm.userGrid = m.top.FindNode("userGrid")
    'm.userGrid.ObserveField("itemSelected", "onUserItemSelected")

    m.purchaseScreen = m.top.FindNode("purchaseScreen")
    m.purchaseScreen.visible = false

    m.top.observeField("orders", "startAsyncDoOrder")

    'm.billing.callFunc("getProductList", {})
    'm.billing.callFunc("getPurchaseList", {})
end function

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        ? "Scene - Key pressed: " + key
    end if
    return handled
end function
