'********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub init()
  m.top.observeField("productName", "handleProductNameSet")
  m.upgradeButton = m.top.findNode("upgradeButton")
  m.upgradeButton.observeField("buttonSelected", "onUpgradeButtonSelected")
  m.backButton = m.top.findNode("backUpgButton")
  m.backButton.observeField("buttonSelected", "onBackButtonSelected")
  m.buttonSelected = ""
end sub

sub handleProductNameSet(msg)
  m.productName = msg.getData()
  'm.planName = m.top.planName
  'm.purchasedPlanData = m.top.purchasedPlanData
  m.currentPurchasedName = m.top.purchasedName
  m.productCode = m.top.productCode
  m.requestType = m.top.requestType
  m.billing = m.top.billing
  'm.purchaseData = m.top.purchaseData
  'RPayUtilsSetTask(m.top.task)
  purchaseProductLabel = m.top.findNode("upgradeProductLabel")
  purchaseProductLabel.text =  m.requestType + " to product: " + m.productName
  currentProductLabel = m.top.findNode("currentProductLabel")
  currentProductLabel.text = "Current product purchase: " + m.currentPurchasedName
  upgradeButton = m.top.findNode("upgradeButton")
  upgradeButton.text = m.requestType
  m.buttonSelected = "Upgrade"
  m.upgradeButton.setFocus(true)
end sub

sub onUpgradeButtonSelected(msg)
  ''? "onUpgradeButtonSelected()"
  'entitlementId = m.purchaseData.entitlementId
  action = m.requestType
  'planName = m.planName
  changeOrder(m.productCode, action, 1)
end sub

sub returnToProductScreen()
  scene = m.top.getScene()
  productScreen = scene.findNode("productScreen")
  productScreen.result = {"ret": 0}
  m.top.visible = false
end sub

sub changeOrder(code as String, action as String, addQty as Integer)
    orderDetails = {ProductCode: code, action: action}
    ? "order details= "; orderDetails
    m.billing.observeField("upgradeResult", "handleUpgradeResult")
    m.billing.callFunc("makeUpgrade", orderDetails)
end sub

sub handleUpgradeResult(event)
    'print "called handleUpgradeResult()"
    ? "upgrade response= "; event.getData()
    m.billing.unobserveField("upgradeResult")
    returnToProductScreen()
end sub

sub onBackButtonSelected(msg)
  returnToProductScreen()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        ''? "Upgrade Screen - Key pressed: " + key
        if key = "back"
            ' return to the product screen'
            returnToProductScreen()
            handled = true
        else if key = "right" and m.buttonSelected = "Upgrade"
            m.buttonSelected = "Back"
            m.backButton.setFocus(true)
        else if key = "left" and m.buttonSelected = "Back"
            m.buttonSelected = "Upgrade"
            m.upgradeButton.setFocus(true)
        end if
    end if
    return handled
end function
