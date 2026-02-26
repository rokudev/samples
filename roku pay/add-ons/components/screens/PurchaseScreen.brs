'********** Copyright 2020, 2023 Roku Corp.  All Rights Reserved. **********

sub init()
  m.top.observeField("productName", "handleProductNameSet")
  m.purchaseButton = m.top.findNode("purchaseButton")
  m.purchaseButton.observeField("buttonSelected", "onPurchaseButtonSelected")
  m.backButton = m.top.findNode("backPurchButton")
  m.backButton.observeField("buttonSelected", "onBackButtonSelected")
  m.vertLayout = m.top.findNode("vertLayout")
  m.vertEventsLayout = m.top.findNode("vertEventsLayout")
  m.includesLabel = m.top.findNode("includedInBundle")
  m.checkList = m.top.findNode("addonChecklist")
  m.eventsChecklist = m.top.findNode("eventsChecklist")
end sub

sub handleProductNameSet(msg)
  m.productName = msg.getData()
  ''? "m.productName= "; m.productName
  m.productCode = m.top.productCode
  ''? "m.productCode= "; m.productCode
  ' Populate list of addons in purchase screen
  m.billing = m.top.billing

  purchaseProductLabel = m.top.findNode("purchaseProductLabel")
  purchaseProductLabel.text = "Purchase product: " + m.productName + "  (" + m.top.productPrice + ")"

  ' If Bundle, display available products in bundle
  m.productsInBundle = m.top.productsInBundle
  if m.productsInBundle.count() > 0
    ' Display contents of the bundle
    m.vertLayout.translation = [130,300]
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
  purchasedAddOnSkus = m.top.purchasedAddOnSkus
  if m.addons.count() > 0
    m.vertLayout.visible = true
    listContent = CreateObject("roSGNode", "ContentNode")
    idx = 0
    arrayOfChecked = []
    for each addon in m.addOns.Items()
      ' Pre-check the add-ons previously purchased
      arrayOfChecked[idx] = false
      for each purchItem in purchasedAddonSkus
        if purchItem = addon.key
          arrayOfChecked[idx] = true
          exit for
        end if
      end for
      idx += 1
      
      item = listContent.createChild("ContentNode")
      item.title = addon.value.name + "  (" + addon.value.cost + ")"
      item.addFields({"sku": addon.key})
    end for
    m.checklist.checkedState = arrayOfChecked
    m.checkList.content = listContent
    m.itemSelected = "Checklist"
    m.checkList.setFocus(true)
  else
    m.itemSelected = "Purchase"
    m.purchaseButton.setFocus(true)
  end if

  ' Don't include PPV events for bundles or single add-ons
  m.oneTimeEvents = m.top.oneTimeEvents
  if m.oneTimeEvents.count() > 0 and m.addons.count() > 0 and m.productsInBundle.count() = 0
    m.vertEventsLayout.visible = true
    listContent = CreateObject("roSGNode", "ContentNode")
    idx = 0
    arrayOfChecked = []
    for each oneTimeEvent in m.oneTimeEvents.Items()
      ' Pre-check the add-ons previously purchased
      arrayOfChecked[idx] = false
      idx += 1
      
      item = listContent.createChild("ContentNode")
      item.title = oneTimeEvent.value.name + "  (" + oneTimeEvent.value.cost + ")"
      item.addFields({"sku": oneTimeEvent.key})
    end for
    m.eventsChecklist.checkedState = arrayOfChecked
    m.eventsCheckList.content = listContent
  else
    'override the one time events array for bundle
    m.vertEventsLayout.visible = false
    m.oneTimeEvents = {}
  end if
end sub

sub onPurchaseButtonSelected()
  addOns = {}
  events = {}
  for idx=0 to m.addOns.Count()-1
    sku = m.checklist.content.GetChild(idx).sku
    addon = m.addOns[sku]
    if m.checklist.checkedState[idx] = true
      addOns.addReplace(sku, addon)
    end if
  end for
  for idx=0 to m.oneTimeEvents.Count()-1
    sku = m.eventsChecklist.content.GetChild(idx).sku
    addon = m.oneTimeEvents[sku]
    if m.eventsChecklist.checkedState[idx] = true
      events.addReplace(sku, addon)
    end if
  end for
 
  requestInfo = {productCode: m.productCode, addons: addOns, events: events}
  ? "order details= "; requestInfo

  m.billing.observeField("purchaseResult", "handlePurchaseCompleted")
  m.billing.callFunc("makePurchase", requestInfo)
end sub

sub clearBundleUI()
  ' Restore UI after bundle purchase, if needed
  if m.productsInBundle.count() > 0
    m.includesLabel.text = "Included products"
    m.includesLabel.visible = false
    m.vertLayout.translation = [130,150]
  end if
end sub

sub clearAddonUI()
  m.vertLayout.visible = false
end sub

sub clearOneTimeEventUI()
  m.vertEventsLayout.visible = false
end sub

sub handlePurchaseCompleted(event)
  ''? "calling handlePurchaseCompleted()"
  clearBundleUI()
  clearAddonUI()
  clearOneTimeEventUI()
  m.purchaseData = event.getData()
  ? "purchase response= ";  m.purchaseData
  m.billing.unobserveField("purchaseResult")
  returnToProductScreen()
end sub

sub returnWithoutPurchase()
  clearBundleUI()
  clearAddonUI()
  clearOneTimeEventUI()
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
        ''? "Purchase Screen - Key pressed: " + key
        if key = "back"
          ' return to the product screen'
          returnWithoutPurchase()
          handled = true
        else if key = "down" and m.itemSelected = "Checklist"
          if m.oneTimeEvents.count() > 0
            m.itemSelected = "EventsChecklist"
            m.eventsCheckList.setFocus(true)
          else
            m.itemSelected = "Purchase"
            m.purchaseButton.setFocus(true)  
          end if
        else if key = "down" and m.itemSelected = "EventsChecklist"
          m.itemSelected = "Purchase"
          m.purchaseButton.setFocus(true)
        else if key = "up" and (m.itemSelected = "Purchase" or m.itemSelected = "Back")
          if m.oneTimeEvents.count() > 0
            m.itemSelected = "EventsChecklist"
            m.eventsCheckList.setFocus(true)
          else
            m.itemSelected = "Checklist"
            m.checklist.setFocus(true)
          end if
        else if key = "up" and (m.itemSelected = "EventsChecklist")
          m.itemSelected = "Checklist"
          m.checklist.setFocus(true)
       else if key = "right" and m.itemSelected = "Purchase"
          m.itemSelected = "Back"
          m.backButton.setFocus(true)
        else if key = "left" and m.itemSelected = "Back"
          m.itemSelected = "Purchase"
          m.purchaseButton.setFocus(true)
        end if
    end if
    return handled
end function
