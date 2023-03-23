'********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub init()
  m.top.observeField("productName", "handleProductNameSet")
  ' one possibility: hide purchase button for standalone product'
  m.purchaseButton = m.top.findNode("purchaseButton")
  m.purchaseButton.observeField("buttonSelected", "onPurchaseButtonSelected")
  m.backButton = m.top.findNode("backPurchButton")
  m.backButton.observeField("buttonSelected", "onBackButtonSelected")
end sub

sub handleProductNameSet(msg)
  m.productName = msg.getData()
  ''? "m.productName= "; m.productName
  m.productCode = m.top.productCode
  ''? "m.productCode= "; m.productCode
  purchaseProductLabel = m.top.findNode("purchaseProductLabel")
  purchaseProductLabel.text = "Purchase product: " + m.productName
  m.buttonSelected = "Purchase"
  m.purchaseButton.setFocus(true)

  m.billing = m.top.billing
end sub

sub onPurchaseButtonSelected(msg)
  ''? "onPurchaseButtonSelected()"
  'print "productCode= "; m.productCode
  'print "productName= "; m.productName
  addToOrder(m.productCode, m.productName, 1)
end sub

sub addToOrder(code as String, name as String, addQty as Integer)
    requestInfo = {productCode: code, productName: name, qty: 1}
    ? "order details= "; orderDetails

    m.billing.observeField("purchaseResult", "handlePurchaseCompleted")
    m.billing.callFunc("makePurchase", requestInfo)
end sub

sub handlePurchaseCompleted(event)
    ''? "calling handlePurchaseCompleted()"
    ? "purchase response= "; event.getData()
    m.billing.unobserveField("purchaseResult")
    returnToProductScreen()
end sub

sub returnToProductScreen()
  scene = m.top.getScene()
  productScreen = scene.findNode("productScreen")
  productScreen.result = {"ret": 0}
  m.top.visible = false
end sub

sub onBackButtonSelected(msg)
  returnToProductScreen()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        ''? "Purchase Screen - Key pressed: " + key
        if key = "back"
            ' return to the product screen'
            returnToProductScreen()
            handled = true
        else if key = "right" and m.buttonSelected = "Purchase"
            m.buttonSelected = "BackCancel"
            m.backButton.setFocus(true)
        else if key = "left" and m.buttonSelected = "Back"
            m.buttonSelected = "Purchase"
            m.backButton.setFocus(true)
        end if
    end if
    return handled
end function
