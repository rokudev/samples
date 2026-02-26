'********** Copyright 2020,2024 Roku Corp.  All Rights Reserved. **********

sub init()
  print "create channelStore object"
  m.store = createObject("roSGNode", "ChannelStore")
  m.store.id = "store"
  m.store.fakeserver = false

  ' Observe the ChannelStore generic request status
  m.store.observeField("requestStatus", "onRequestStatus")

  m.orderType = ""
  m.getPurchaseType = ""
end sub

' Generic SDK API request callback
function onRequestStatus()
  requestStatus = m.store.requestStatus
  if requestStatus = Invalid
      print "Invalid requestStatus"
  else
      print "requestStatus", requestStatus
      print "requestStatus.command", requestStatus.command
      print "requestStatus.status", requestStatus.status
      print "requestStatus.statusMessage", requestStatus.statusMessage
      print "requestStatus.context", requestStatus.context
      ' requestStatus.status:
      ' 2: Interrupted
      ' 1: Success
      ' 0: Network error
      ' -1: HTTP Error/Timeout
      ' -2: Timeout
      ' -3: Unknown error
      ' -4: Invalid request
      ' Propagate the generic request status
      'if requestStatus.status = 1
          print "requestStatus.status", requestStatus.status
          print "requestStatus.result", requestStatus.result
          if requestStatus.command = "GetCatalog"
              onGetCatalog(requestStatus.result)
          else if requestStatus.command = "DoOrder"
              onOrderStatus(requestStatus.result)
          else if requestStatus.command = "GetPurchases" or requestStatus.command = "GetAllPurchases" then
              onGetPurchases(requestStatus.result)
          else if requestStatus.command = "QueryPurchaseOptions"
              onQueryPurchaseOptions(requestStatus.context, requestStatus.result)
          else if requestStatus.command = "DoRecovery"
          end if
      'end if 
    end if
end function


sub getCatalog()
  print  "calling getCatalog (v2)"
  request = {}
  request.command = "GetCatalog"
  request.params = {"version": 2}
  m.store.request = request
end sub


sub onGetCatalog(requestResult as object)
  print "requestResult.status", requestResult.status
  print "requestResult.statusMessage", requestResult.statusMessage
 
  m.purchaseOptions = {}
  m.products = {}

  ' GetCatalog succeeded
  REM print "requestResult.result.products", requestResult.result.products
  REM print "requestResult.result.productsMap", requestResult.result.productsMap
  for each product in requestResult.result.productsMap
    print "product", product
  end for
  REM print "requestResult.result.purchaseOptions", requestResult.result.purchaseOptions
  REM print "requestResult.result.purchaseOptionsMap", requestResult.result.purchaseOptionsMap

  if requestResult.status = 1 and type(requestResult.result) = "roAssociativeArray" then
    m.purchaseOptions = requestResult.result.purchaseOptionsMap
    m.products = requestResult.result.productsMap
  end if

  m.top.productList = {
    "purchaseOptions": m.purchaseOptions,
    "productList": m.products,
    "status": requestResult.status
  }
end sub


sub QueryPurchaseOptions(requestData as dynamic)
    request = {
        "context": {
            "queryType": requestData.context
        }
        "params": {
            "purchaseOptionsMap": requestData.map1
            "productsMap": requestData.map2
            "query": requestData.query
        }
        "command": "QueryPurchaseOptions"
    }
    m.store.request = request
end sub

sub onQueryPurchaseOptions(context as object, requestResult as object)
    print "requestResult.status", requestResult.status
    print "requestResult.statusMessage", requestResult.statusMessage  
    if context.queryType = "Base" then
    else if context.queryType = "Addon"
    end if
    m.top.queryResult = {
        "purchaseOptions": requestResult.purchaseOptionsMap,
        "status": requestResult.status
    }
end sub

' DoOrder
' TODO: revise against doc version
sub makePurchase(requestData as dynamic)
  print  "calling makePurchase"
  'myOrder = { "code": request.productCode, "name": request.productName, "qty": 1}
  'myOrder = CreateObject("roSGNode", "ContentNode")
  
  print "request.sku: "; requestData.productCode
  newOrder = []
  order = {
    "sku": requestData.productCode, 
    "qty": 1
  }
  newOrder.push(order)

  for each addon in requestData.addons.Items()
    order = {"sku": addon.key, "qty": 1}
    newOrder.push(order)
  end for

  for each event in requestData.events.Items()
    order = {"sku": event.key, "qty": 1}
    newOrder.push(order)
  end for

  request = {}
  request.params = {
    "orderItems": newOrder,
    "version": 2
  }
  request.command = "DoOrder"
  m.store.request = request
  m.orderType = "purchase"
end sub

sub makeTVODPurchase(requestData as dynamic)
  print  "calling makeTVODPurchase"
  'myOrder = { "code": request.productCode, "name": request.productName, "qty": 1}
  'myOrder = CreateObject("roSGNode", "ContentNode")
  
  print "request.sku: "; requestData.productCode
  newOrder = []
  order = {
    "orderType": "TVOD",
    "sku": requestData.productCode,
    "contentKey": requestData.contentKey,
    "title": requestData.title,
    "price": requestData.price,
    "originalPrice": requestData.originalPrice,
    "qty": 1
  }
  newOrder.push(order)

  request = {}
  request.params = {
    "orderItems": newOrder,
    "version": 2
  }
  request.command = "DoOrder"
  m.store.request = request
  m.orderType = "purchaseTVOD"
end sub

sub makeUpgrade(requestData as dynamic)
  print "calling makeUpgrade"

  ? "processing " + requestData.action + " order ..."
  newOrder = []
  replacedPurchase = {
    "sku": requestData.replacedPurchase
  }   ' For v2, need to pass in the purchase to be replaced
  order = {
    "sku": requestData.productCode, 
    "qty": 1, 
    "action": requestData.action,
    "replacedPurchase": replacedPurchase
  }
  newOrder.push(order)

  for each addon in requestData.addons.Items()
    order = {
      "sku": addon.key,
      "qty": 1
    }
    newOrder.push(order)
  end for

  print "newOrder: "
  i = 0
  for each item in newOrder
    print "item "; i; ": - "; item
    print "replacedPurchase "; item.replacedPurchase
    i++
  end for
  request = {}
  request.params = {
    "orderItems": newOrder,
    "version": 2
  }
  request.command = "DoOrder"
  m.store.request = request
  m.orderType = "upgrade"
end sub

' From the doc
' DoOrder response parser/helpers
' ==================================
function onOrderStatus(requestResult as object) as void
  print chr(10) + "onOrderStatus"
  message = ""
  if requestResult.status <> 1
      message = "status: " + str(requestResult.status) + chr(10)
      message += "statusMessage: " + requestResult.statusMessage
      purchases = []
  else
      message = "Your Purchase completed successfully" + chr(10)
      message += "statusMessage: " + requestResult.statusMessage + chr(10)
      if type(requestResult.result) = "roAssociativeArray" then
          purchases = requestResult.result.purchases
          ' roArray
          if type(purchases) = "roArray" then
              for i = 0 to purchases.Count() - 1
                  message += chr(10) + "Product " + AnyToString(i+1) + ":" + chr(10)
                  item = purchases[i]
                  ' roAssociativeArray
                  print type(item)
                  print "item", item
                  if item.replacedPurchase <> invalid then
                      print "item.replacedPurchase", item.replacedPurchase
                  end if
                  keys = item.Keys()
                  for each key in keys
                      strField = AnyToString(item[key])
                      if strField <> Invalid
                          if strField.len() > 0
                              message += key + " = " + strField + chr(10)
                          else
                              message += key + " = " + chr(10)
                          end if
                      else
                          message += key + " = " + chr(10)
                      end if
                  end for
              end for
          end if
      end if
  end if
  print "message", message

  status = {"status": requestResult.status, "statusMessage": requestResult.statusMessage}
  if m.orderType =  "purchase" or m.orderType = "purchaseTVOD"
    m.top.purchaseResult = {"status": status, "purchases": purchases}
  else if  m.orderType = "upgrade"
    m.top.upgradeResult = {"status": status, "purchases": purchases}
  else
    print "Error - can't happen, orderType= "; m.orderType
  end if
  m.orderType = ""
  
end function

' GetPurchases / GetAllPurchases
' TODO: revise against doc version
sub getPurchases()
  print  "calling getPurchases"
  request = {}
  request.command = "GetPurchases"
  request.params = {
    "version": 2,
    "includeExpired": false
  }
  m.store.request = request
  m.getPurchaseType = "getPurchases"
end sub

sub getAllPurchases()
  print  "calling getAllPurchases"
  request = {}
  request.command = "GetPurchases"
  request.params = {
    "version": 2,
    "includeExpired": true
  }
  m.store.request = request
  m.getPurchaseType = "getAllPurchases"
end sub

' From the doc
' GetPurchases response parser/helpers
' ==================================
function onGetPurchases(requestResult as object) as void
  m.purchases = {}
  m.purchasedProducts = {}
  m.entitlements = []

  print chr(10) + "onGetPurchases"
  message = ""
  if requestResult.status <> 1
      message = "status: " + str(requestResult.status) + chr(10)
      message += "statusMessage: " + requestResult.statusMessage
  else
      purchaseResult = requestResult.result
      ' AA
      print chr(10) + "purchaseResult", type(purchaseResult)
      if type(purchaseResult) <> "roAssociativeArray" or purchaseResult.purchases = invalid then
          print chr(10) + "invalid purchaseResult.purchases"
          return
      end if
      ' roArray
      print chr(10) + "purchaseResult.purchases", type(purchaseResult.purchases)
      print "purchaseResult.purchases.Count()", purchaseResult.purchases.Count()
      for i = 0 to purchaseResult.purchases.Count() - 1
          purchase = purchaseResult.purchases[i]
          m.purchases.AddReplace(purchase.sku, purchase)
          ' message for purchases
          message += chr(10) + "Purchase " + AnyToString(i+1) + ":" + chr(10)
          fields = purchase.items()
          for each field in fields
              strKey = AnyToString(field.key)
              strValue = AnyToString(field.value)
              if strValue <> Invalid
                  if strValue.len() > 0
                      message += strKey + " = " + strValue + chr(10)
                  else
                      message += strKey + " = " + chr(10)
                  end if
              else if type(field.value) = "roArray" then
                  ' billingPlans
                  for j = 0 to field.value.Count() - 1
                      message += strKey + "[" + j.ToStr() + "]" + chr(10)
                      fields1 = field.value[j].items()
                      for each field1 in fields1
                          strKey1 = AnyToString(field1.key)
                          strValue1 = AnyToString(field1.value)
                          if strValue1 <> Invalid
                              if strValue1.len() > 0
                                  message += "- " + strKey1 + " = " + strValue1 + chr(10)
                              else
                                  message += "- " + strKey1 + " = " + chr(10)
                              end if
                          else if type(field1.value) = "roArray" then
                              for k = 0 to field1.value.Count() - 1
                                  if type(field1.value[k]) = "roAssociativeArray" then
                                      ' phases
                                      message += "-- " + strKey1 + "[" + k.ToStr() + "]" + chr(10)
                                      fields2 = field1.value[k].items()
                                      for each field2 in fields2
                                          strKey2 = AnyToString(field2.key)
                                          strValue2 = AnyToString(field2.value)
                                          if strValue2 <> Invalid
                                              if strValue2.len() > 0
                                                  message += "--- " + strKey2 + " = " + strValue2 + chr(10)
                                              else
                                                  message += "--- " + strKey2 + " = " + chr(10)
                                              end if
                                          else if type(field2.value) = "roAssociativeArray" then
                                              ' duration
                                              message += "--- " + strKey2 + chr(10)
                                              fields3 = field2.value.items()
                                              for each field3 in fields3
                                                  strKey3 = AnyToString(field3.key)
                                                  strValue3 = AnyToString(field3.value)
                                                  if strValue3 <> Invalid
                                                      if strValue3.len() > 0
                                                          message += "---- " + strKey3 + " = " + strValue3 + chr(10)
                                                      else
                                                          message += "---- " + strKey3 + " = " + chr(10)
                                                      end if
                                                  end if
                                              end for
                                          end if
                                      end for
                                  else
                                      ' productIds
                                      message += "- " + strKey1 + "[" + k.ToStr() + "]" + ": " + field1.value[k] + chr(10)
                                  end if
                              end for
                          else
                          end if
                      end for
                  end for
              end if
          end for
      end for
      ' roArray
      print chr(10) + "purchaseResult.products", type(purchaseResult.products)
      print "purchaseResult.products.Count()", purchaseResult.products.Count()
      for i = 0 to purchaseResult.products.Count() - 1
          product = purchaseResult.products[i]
          m.purchasedProducts.AddReplace(product.productId, product)
          ' AA
          ' message for products
          message += chr(10) + "product " + AnyToString(i+1) + ":" + chr(10)
          fields = product.items()
          for each field in fields
              strKey = AnyToString(field.key)
              strValue = AnyToString(field.value)
              if strValue <> Invalid
                  if strValue.len() > 0
                      message += strKey + " = " + strValue + chr(10)
                  else
                      message += strKey + " = " + chr(10)
                  end if
              else if type(field.value) = "roArray" then
                  for j = 0 to field.value.Count() - 1
                      if type(field.value[j]) = "roAssociativeArray" then
                          ' entitlementIds
                          message += "- " + strKey + "[" + j.ToStr() + "]" + chr(10)
                          fields1 = field.value[j].items()
                          for each field1 in fields1
                              strKey1 = AnyToString(field1.key)
                              strValue1 = AnyToString(field1.value)
                              if strValue1 <> Invalid
                                  if strValue1.len() > 0
                                      message += "-- " + strKey1 + " = " + strValue1 + chr(10)
                                  else
                                      message += "-- " + strKey1 + " = " + chr(10)
                                  end if
                              end if
                          end for
                      else
                          ' purchaseOptions
                          message += strKey + "[" + j.ToStr() + "]" + ": " + field.value[j] + chr(10)
                      end if
                  end for
              end if
          end for
      end for
      ' roArray
      print chr(10) + "purchaseResult.entitlements", type(purchaseResult.entitlements)
      print "purchaseResult.entitlements.Count()", purchaseResult.entitlements.Count()
      for i = 0 to purchaseResult.entitlements.Count() - 1
          entitlement = purchaseResult.entitlements[i]
          m.entitlements.push(entitlement)
          ' AA
          ' message for entitlements
          message += chr(10) + "entitlement " + AnyToString(i+1) + ":" + chr(10)
          fields = entitlement.items()
          for each field in fields
              strKey = AnyToString(field.key)
              strValue = AnyToString(field.value)
              if strValue <> Invalid
                  if strValue.len() > 0
                      message += strKey + " = " + strValue + chr(10)
                  else
                      message += strKey + " = " + chr(10)
                  end if
              end if
          end for
      end for
  endif
  print "message", message

  returnPurchaseList = {
    "purchaseList": m.purchases,
    "productList": m.purchasedProducts,
    "entitlementList": m.entitlements,
    "status": requestResult.status
  }
  print "m.getPurchaseType= "; m.getPurchaseType

  if m.getPurchaseType = "getPurchases"
    m.top.purchaseList = returnPurchaseList
  else if m.getPurchaseType = "getAllPurchases"
    m.top.extPurchaseList = returnPurchaseList
  end if
end function

function runDoRecovery()
  print  "calling runDoRecovery"
  request = {}
  request.command = "DoRecovery"
  request.context = {
    "id": "DoRecovery_1"
  }
  m.store.request = request
end function

function onRecoveryStatus(result)
  print "onRecoveryStatus"
  print "result";result
end function
