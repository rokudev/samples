'********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub init()
  print "create channelStore object"
  m.store = createObject("roSGNode", "ChannelStore")
  m.store.id = "store"
  m.store.fakeserver = false

  m.store.observeField("catalog", "onGetCatalog")
  m.store.ObserveField("purchases", "onGetPurchases")
  m.store.observeField("orderStatus", "onOrderStatus")

  m.orderType = ""
  m.getPurchaseType = ""
end sub

sub getProductList(request as dynamic)
  print  "calling getProductList"
  m.store.command = "getCatalog"
end sub

function onGetCatalog(event)
  print "onGetCatalog"
  catalogData = event.getData()
  productList = {}
  if catalogData.GetChildCount() > 0 then
    for index = 0 to catalogData.GetChildCount() - 1
      product = catalogData.getChild(index)
      productList[product.code] = product
      'print "product "; index; " - product= "; product
    end for
  end if
  m.top.productList = productList
end function

sub getPurchaseList(request as dynamic)
  print  "calling getPurchaseList"
  m.store.command = "getPurchases"
  m.getPurchaseType = "getPurchases"
end sub

sub getExtPurchaseList(request as dynamic)
  print  "calling getExtPurchaseList"
  m.store.command = "getAllPurchases"
  m.getPurchaseType = "getAllPurchases"
end sub

function onGetPurchases(event)
  print "onGetPurchases"
  purchaseData = event.getData()
  purchaseList = {}
  if purchaseData.GetChildCount() > 0 then
    for index = 0 to purchaseData.GetChildCount() - 1
      purchase = purchaseData.getChild(index)
      purchaseList[purchase.code] = purchase
      'print "purchase "; index; " - purchase= "; purchase
    end for
  end if
  ' print "m.getPurchaseType= "; m.getPurchaseType
  if m.getPurchaseType = "getPurchases"
    m.top.purchaseList = purchaseList
  else if m.getPurchaseType = "getAllPurchases"
    m.top.extPurchaseList = purchaseList
  end if
  m.getPurchasesType = ""
end function

sub makePurchase(request as dynamic)
  print  "calling makePurchase"
  myOrder = CreateObject("roSGNode", "ContentNode")
  itemPurchased = myOrder.createChild("ContentNode")
  ? "creating order ..."
  ? "> product code: " request.productCode
  ? "> product name: " request.productName
  itemPurchased.addFields({ "code": request.productCode, "name": request.productName, "qty": 1})
  m.store.order = myOrder
  ? "processing order ..."

  m.store.command = "doOrder"
  m.orderType = "purchase"
end sub

sub makeUpgrade(request as dynamic)
  print "calling makeUpgrade"
  myOrder = CreateObject("roSGNode", "ContentNode")
  myItem = myOrder.createChild("ContentNode")
  myItem.addFields({ "code": request.productCode, "qty": 1})

  myOrder.action = request.action ' action is Upgrade or Downgrade
  m.store.order = myOrder
  ? "processing " + request.action + " order ..."

  m.store.command = "doOrder"
  m.orderType = "upgrade"
end sub

function onOrderStatus(msg as Object)
  status = msg.getData().status
  tid =  msg.getData().purchaseId
  if status = 1 ' order success
      ? "> order success"
        tid = m.store.orderStatus.getChild(0).purchaseId
        ' validate the order by checking if it is now entitled on the roku side
        'makeRequest("url", {uri: Substitute("http://{0}:{1}/test/validateTransaction/{2}", m.hostIpAddr, m.hostPort, tid)}, "validateOrder")
        ? "tid= "; tid
  else 'error in doing order
      ? "> order error ..."
      ? "> error status " status ": " msg.getData().statusMessage
      'm.dialogBox.message = "Order Error: " + chr(10) + msg.getData().statusMessage
      'm.dialogBox.buttons = ["Go back to Channel Add-ons UI"]
      'm.top.dialog = m.dialogBox
      m.store.order = invalid 'clear order
  end if

  orderResult = {status: status, tid: tid}
  if m.orderType =  "purchase"
    m.top.purchaseResult = orderResult
  else if  m.orderType = "upgrade"
    m.top.upgradeResult = orderResult
  else
    print "Error - can't happen, orderType= "; orderType
  end if
  m.orderType = ""
end function
