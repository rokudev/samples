'********** Copyright 2020, 2023 Roku Corp.  All Rights Reserved. **********

sub init()
  m.top.observeField("productName", "handleProductNameSet")
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
  m.contentKey = m.top.contentKey
  m.price = m.top.productPrice
  m.originalPrice = m.top.productOriginalPrice
  m.billing = m.top.billing

  purchaseProductLabel = m.top.findNode("purchaseProductLabel")
  purchaseProductLabel.text = "Purchase product: " + m.productName + "  (" + m.top.productPrice + ")"

  m.itemSelected = "Purchase"
  m.purchaseButton.setFocus(true)

end sub

sub onPurchaseButtonSelected()
 
  requestInfo = {productCode: m.productCode, contentKey: m.contentKey, 
    title: m.productName, price: m.price, originalPrice: m.originalPrice}
  ? "order details= "; requestInfo

  m.billing.observeField("purchaseResult", "handlePurchaseCompleted")
  m.billing.callFunc("makeTVODPurchase", requestInfo)
end sub

sub handlePurchaseCompleted(event)
  ''? "calling handlePurchaseCompleted()"
  m.purchaseData = event.getData()
  ? "purchase response= ";  m.purchaseData
  m.billing.unobserveField("purchaseResult")
  returnToProductScreen()
end sub

sub returnWithoutPurchase()
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
        else if key = "down"
          m.itemSelected = "Purchase"
          m.purchaseButton.setFocus(true)  
        end if
    end if
    return handled
end function
