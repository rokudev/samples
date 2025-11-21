'********** Copyright 2020, 2023 Roku Corp.  All Rights Reserved. **********

sub init()
  m.top.observeField("productName", "handleProductNameSet")
  m.upgradeButton = m.top.findNode("upgradeButton")
  m.upgradeButton.observeField("buttonSelected", "onUpgradeButtonSelected")
  m.downgradeButton = m.top.findNode("downgradeButton")
  m.downgradeButton.observeField("buttonSelected", "onDowngradeButtonSelected")
  m.backButton = m.top.findNode("backButton")
  m.backButton.observeField("buttonSelected", "onBackButtonSelected")
  m.vertLayout = m.top.findNode("vertLayout")
  m.includesLabel = m.top.findNode("includedInBundle")
  m.checkList = m.top.findNode("addonChecklist")
end sub

sub handleProductNameSet(msg)
  m.productName = msg.getData()
  m.currentPurchasedName = m.top.purchasedName
  m.productCode = m.top.productCode

  m.requestType = m.top.requestType
  m.replacedPurchase = m.top.replacedPurchase
  m.billing = m.top.billing
  'm.purchaseData = m.top.purchaseData
  'RPayUtilsSetTask(m.top.task)
  purchaseProductLabel = m.top.findNode("upgradeProductLabel")
  purchaseProductLabel.text =  "Update to product: " + m.productName + "  (" + m.top.productPrice + ")"
  currentProductLabel = m.top.findNode("currentProductLabel")
  currentProductLabel.text = "Current product purchase: " + m.currentPurchasedName
  
  ' If Bundle, display available products in bundle
  m.productsInBundle = m.top.productsInBundle
  if m.productsInBundle.count() > 0
    ' Display contents of the bundle
    m.vertLayout.translation = [130,350]
    m.includesLabel.visible = true
    text = "Bundle includes:" + chr(10)
    for each productAA in m.productsInBundle
      text += "    " + productAA.name + chr(10) 
    end for
    text += chr(10)
    print "text="; text
    m.includesLabel.text = text
  end if

  ' Display the addons as a checklist
  m.addOns = m.top.addOns
  m.purchasedAddonSkus = m.top.purchasedAddonSkus
  if m.addons.count() > 0
    m.vertLayout.visible = true
    listContent = CreateObject("roSGNode", "ContentNode")
    idx = 0
    arrayOfChecked = []
    for each addon in m.addOns.Items()
      ' Pre-check the add-ons previously purchased
      checked = false
      for each purchItem in m.purchasedAddonSkus
        if purchItem = addon.key
          checked = true
          exit for
        end if
      end for
      arrayOfChecked[idx] = checked
      idx += 1

      item = listContent.createChild("ContentNode")
      item.title = addon.value.name + "  (" + addon.value.cost + ")"
      item.addFields({"sku": addon.key})
    end for
    m.checklist.checkedState = arrayOfChecked
    m.checkList.content = listContent
    m.itemSelected = "Checklist"
    m.checkList.setFocus(true)
    m.checklist.setFocus(true)
  else
    m.itemSelected = "Upgrade"
    'm.upgradeButton.text = m.requestType
    m.upgradeButton.setFocus(true)
  end if
 
  print "m.itemSelected= "; m.itemSelected
  print "m.checkList.hasFocus()= "; m.checklist.hasFocus()
  print "m.upgradeButton.hasFocus()= "; m.upgradeButton.hasFocus()
end sub

sub onUpgradeButtonSelected()
  ''? "onUpgradeButtonSelected()"
  addOns = {}
  for idx=0 to m.addOns.Count()-1
    sku = m.checklist.content.GetChild(idx).sku
    addon = m.addOns[sku]
    if m.checklist.checkedState[idx] = true
      addOns.addReplace(sku, addon)
    end if
  end for
 
  orderDetails = {
    ProductCode: m.productCode, 
    action: "Upgrade", 
    replacedPurchase: m.replacedPurchase,
    addOns: addOns
  }

  m.billing.observeField("upgradeResult", "handleUpdateCompleted")
  m.billing.callFunc("makeUpgrade", orderDetails)
end sub

sub onDowngradeButtonSelected()
  ''? "onDowngradeButtonSelected()"
  addOns = {}
  for idx=0 to m.addOns.Count()-1
    sku = m.checklist.content.GetChild(idx).sku
    addon = m.addOns[sku]
    if m.checklist.checkedState[idx] = true
      addOns.addReplace(sku, addon)
    end if
  end for
 
  orderDetails = {
    ProductCode: m.productCode, 
    action: "Downgrade", 
    replacedPurchase: m.replacedPurchase,
    addOns: addOns
  }

  m.billing.observeField("upgradeResult", "handleUpdateCompleted")
  m.billing.callFunc("makeUpgrade", orderDetails)
end sub

sub clearBundleUI()
  ' Restore UI after bundle purchase, if needed
  if m.productsInBundle.count() > 0
    m.includesLabel.text = "Included products"
    m.includesLabel.visible = false
    m.vertLayout.translation = [130,200]
  end if
end sub

sub clearAddonUI()
  ' Cleanup required?
  m.vertLayout.visible = false
end sub

sub handleUpdateCompleted(event)
    print "called handleUpdateCompleted()"
    clearBundleUI()
    clearAddonUI()  
    m.purchaseData = event.getData()
    ? "purchase response= ";  m.purchaseData

    m.billing.unobserveField("upgradeResult")
    returnToProductScreen()
end sub

sub returnWithoutPurchase()
  clearBundleUI()
  m.purchaseData = {"status": {"status": 2}}
  returnToProductScreen()
end sub

sub returnToProductScreen()
  scene = m.top.getScene()
  productScreen = scene.findNode("productScreen")
  productScreen.result = m.purchaseData
  m.top.visible = false
end sub

sub onBackButtonSelected()
  returnWithoutPurchase()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
      ? "Upgrade Screen - Key pressed: " + key
      if key = "back"
        ' return to the product screen'
        returnWithoutPurchase()
        handled = true
      else if key = "down" and m.itemSelected = "Checklist"
        m.itemSelected = "Upgrade"
        m.upgradeButton.setFocus(true)
      else if key = "up" and (m.itemSelected = "Upgrade" or m.itemSelected = "Downgrade" or m.itemSelected = "Back")
        m.itemSelected = "Checklist"
        m.checklist.setFocus(true)
      else if key = "right" and m.itemSelected = "Upgrade"
        m.itemSelected = "Downgrade"
        m.downgradeButton.setFocus(true)
      else if key = "right" and m.itemSelected = "Downgrade"
        m.itemSelected = "Back"
        m.backButton.setFocus(true)
      else if key = "left" and m.itemSelected = "Downgrade"
        m.itemSelected = "Upgrade"
        m.upgradeButton.setFocus(true)
      else if key = "left" and m.itemSelected = "Back"
        m.itemSelected = "Downgrade"
        m.downgradeButton.setFocus(true)
      end if
    end if
    return handled
end function
