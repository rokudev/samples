'********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub init()
    m.top.observeField("orders", "startAsyncDoOrder")  'startAsyncDoOrder in RPayUtils.brs'
    m.top.observeField("groups", "onGroupsChange")
    m.top.observeField("result", "handleReturnFromOrder")

    m.dialogBox = CreateObject("roSGNode", "Dialog")
    m.dialogBox.id = "dialogBox"
    m.dialogBox.title = "Purchase Status Info"
    m.dialogBox.observeField("buttonSelected","dismissdialog")

    ' this contains the products UI (RadioButtonList) for each product group'
    m.listProducts = []
    m.listProductsItemInFocus = -1

    '  this contains the data coming from getProductList'
    m.catalog = {}

    '  this contains the data coming from getPurchaseList'
    m.purchases = {}
end sub

function onGroupsChange(msg)
    m.groups = m.top.groups
    m.listNames = m.top.groups.keys()
    setupCommandList(m.listNames)

    m.homeScreen = m.top.findNode("homeScreen")
    m.titleLabel = m.top.findNode("titleLabel")
    m.titleLabel.font.size = 40
    m.descriptionLabel = m.top.findNode("descriptionLabel")
    m.descriptionLabel.font.size = 30
    m.descriptionLabel.text = "Demonstrates Roku Pay Upgrade/Downgrade" + chr(10) + chr(10) + "Preparation: go to Manage My In-Channel Products on the developer dashboard, set up a product group, and add your products to the group."
    m.howToUseLabel = m.top.findNode("howToUseLabel")
    m.howToUseLabel.font.size = 30
    m.howToUseLabel.text = "How to use: go to Subscriptions menu and select one product for purchase. When one product is already purchased (has a check mark), next product selected is an upgrade or downgrade."

    ' delay setting up product lists until product and purchase lists are back'
    'setupProductLists(m.groups, m.listNames)
    'm.commandList.SetFocus(true)

    m.productInfoText = m.top.findNode("productInfoText")
    m.productInfoText.text = ""

    ' Get catalog, purchases requested after plans and products received'
    m.billing = m.top.billing
    m.billing.observeField("productList", "handleProductListResponse")
    m.billing.callFunc("getProductList", {})
end function

sub handleProductListResponse(event)
    'print "called handleProductListReponse()"
    m.billing.unobserveField("productList")
    'Temporarily save  catalogData'
    m.catalogData = event.getData()
    ' Create catalog, save it in m.catalog'
    m.catalog = createCatalog(m.catalogData)

    'print "request list of purchases"
    m.billing.observeField("purchaseList", "handlePurchaseListResponse")
    m.billing.callFunc("getPurchaseList", {})
end sub

sub handlePurchaseListResponse(event)
    'print "called handlePurchaseListResponse"
    m.billing.unobserveField("purchaseList")
    purchaseData = event.getData()

    'm.purchases = purchaseData
    m.purchases = createActivePurchases(purchaseData)
    updateProductInfoText(m.catalogData, m.purchases)

    ' Build list of products using m.catalog and m.purchases'
    ' (data from groups[x] from config.json is optional)'
    setupProductLists(m.groups, m.listNames, m.catalog)
    m.commandList.SetFocus(true)
    m.top.getScene().signalBeacon("AppLaunchComplete")

    'print "request list of purchases"
    m.billing.observeField("extPurchaseList", "handleExtPurchaseListResponse")
    m.billing.callFunc("getExtPurchaseList", {})
end sub

sub handleExtPurchaseListResponse(event)
    'print "called handleExtPurchaseListResponse"
    m.billing.unobserveField("extPurchaseList")
    purchaseData = event.getData()
    activeProductCode = getActivePurchase(m.purchases)
    m.purchases = updatePurchases(purchaseData, activeProductCode)
    updateProductInfoText(m.catalogData, m.purchases)
end sub

sub handleReturnFromOrder(event)
  m.top.visible = true
  'print "Return - request list of purchases"
  m.billing.observeField("purchaseList", "handlePurchaseListResponseAtReturnFromOrder")
  m.billing.callFunc("getPurchaseList", {})
end sub

sub handlePurchaseListResponseAtReturnFromOrder(event)
    'print "called handlePurchaseListResponseAtReturnFromOrder"
    m.billing.unobserveField("purchaseList")
    purchaseData = event.getData()

    m.purchases = createActivePurchases(purchaseData)
    updateProductInfoText(m.catalogData, m.purchases)

    m.commandList.SetFocus(true)

    m.billing.observeField("extPurchaseList", "handleExtPurchaseListResponse")
    m.billing.callFunc("getExtPurchaseList", {})
end sub

function getFloatCost(cost as String) as Float
    length = cost.len()
    ' skip the currency symbol'
    return mid(cost,2,length).toFloat()
end function

sub createCatalog(catalogData as object) as object
    catalog = {}
    for each item in catalogData.Items()
      'print "catalog key= "; item.key
      data = {}
      pInfoText = setupProductInfoText(item.key, item.value, invalid)
      data.name = item.value.name
      data.code = item.value.code
      data.cost = getFloatCost(item.value.cost)
      ''? "cost= "; data.cost
      data.pInfoText = pInfoText
      catalog.addReplace(item.key, data)
    end for

    return catalog
end sub

sub createActivePurchases(purchaseData as object) as object
    purchases = {}
    ' Expect only one active purchase'
    for each productCode in purchaseData
      'print "purchases key= "; productCode
      data = {}
      data.renewalDate = purchaseData[productCode].renewalDate
      data.expirationDate = purchaseData[productCode].expirationDate
      data.status = "Active"
      data.cost = purchaseData[productCode].cost
      purchases.addReplace(productCode, data)
    end for

    return purchases
end sub

sub getActivePurchase(purchaseData as object) as string
    result = ""
    for each item in purchaseData
      if purchaseData[item].status = "Active"
        result = item
        exit for
      end if
    end for

    return result
end sub

sub updatePurchases(purchaseData as object, activeProductCode as string) as object
    ' print "calling updatePurchases()"
    purchases = {}
    for each productCode in purchaseData
      data = {}
      data.renewalDate = purchaseData[productCode].renewalDate
      data.expirationDate = purchaseData[productCode].expirationDate
      data.cost = purchaseData[productCode].cost
      ' print "productCode= "; productCode
      if productCode = activeProductCode
        data.status = "Active"
      else
        if data.renewalDate = ""
          data.status = "Cancelled"
        else
          data.status = "Pending Active"
        end if
      end if
      purchases.addReplace(productCode, data)
    end for

    return purchases
end sub

sub updateProductInfoText(catalogData, purchases)
  for each item in m.catalog.Items()
    purchasedItem = purchases[item.key]
    productItem = catalogData[item.key]
    pInfoText = setupProductInfoText(item.key, productItem, purchasedItem)
    m.catalog[item.key].pInfoText = pInfoText
  end for
end sub

' Setup label list on the left side with commands
sub setupCommandList(groupNames)
    commandListContent = createObject("roSGNode", "ContentNode")
    addToCommandListItem("Home", commandListContent)
    ' The Subscriptions group is default'
    ' Other groups can be added to groups AA in config.json'
    for each item in groupNames
        addToCommandListItem(item, commandListContent)
    end for

    m.commandList = m.top.findNode("commandList")
    m.commandList.content = commandListContent
    m.commandList.observeField("itemFocused", "onCommandItemFocused")
end sub

' Setup list of products in the middle panel, one for each group'
sub setupProductLists(groups, groupNames, catalog)
    'config.json has only one group - Subscriptions'
    for i=0 to groupNames.count()-1
        ' this is the parent content node for checkboxlist, one per product group'
        radioButtonListContent = createObject("roSGNode", "ContentNode")
        'name = groupNames[i]
        'group = groups[name]
        for each name in m.catalog
            product = m.catalog[name]
            addRadioButtonListItem(product.name, product.code, radioButtonListContent)
        end for

        m.listProducts[i] = createObject("roSGNode", "RadioButtonList")
        m.listProducts[i].id = groupNames[i]
        m.listProducts[i].content = radioButtonListContent
        m.listProducts[i].itemSize = "[300,100]"
        m.listProducts[i].translation = "[280,100]"
        m.listProducts[i].observeField("itemFocused", "onProductFocused")
        m.listProducts[i].observeField("itemSelected", "onProductSelected")
        m.listProducts[i].visible = false
        m.top.appendChild(m.listProducts[i])
    end for
end sub

' Add new product to the radio button List'
sub addRadioButtonListItem(label as String, productCode as String, rootNode as Object)
    RadioButtonListItemNode = createObject("RoSGNode", "ContentNode")
    radioButtonListItemNode.id = productCode
    radioButtonListItemNode.title = label
    rootNode.AppendChild(radioButtonListItemNode)
end sub

' Add new command to the label List'
sub addToCommandListItem(label as String, rootNode as Object)
  listItemNode = createObject("RoSGNode", "ContentNode")
  listItemNode.title = label
  rootNode.AppendChild(listItemNode)
end sub

' Get the item purchased (if any) in each group. '
function getPurchasedItem()
  ' first get plans from m.purchases'
  ret = -1
  productsList = m.listProducts[0].content
  purchasesList = []
  ''? "productsList= "; productsList

  'for each item in m.purchases.items()
  for each key in m.purchases
      if m.purchases[key].status = "Active"
        purchasesList.push(key)
      end if
  end for
  'print "purchasesList= "; purchasesList

  if purchasesList.count() > 1
      print "Warning: two or more purchases on a group"
      print purchasesList
  else if purchasesList.count() = 1
      ' first get plans from m.purchases'
      purchasedId = purchasesList[0]

      for i=0 to productsList.getChildCount() - 1
          productId = productsList.getChild(i).id
          if productId = purchasedId
              ret = i
              exit for
          end if
      end for
  end if
  return ret
end function

function getProductListIndex(groupName)
  ret = -1
  for i=0 to listNames.count()-1
    if groupName = listNames[i]
      ret = i
      exit for
    end if
  end for
  return ret
end function

' Callback for when the command list is focused '
sub onCommandItemFocused(msg as Object)
    index = msg.getData()
    ''? "index = "; index; " is in focus"
    if index = 0   ' 0 is special home screen item'
        m.homeScreen.visible = true
        ? "Home screen is in focus"
        for i=0 to m.listNames.count()-1
            m.listProducts[i].visible = false
        end for
        if m.productInfoText <> invalid
            m.productInfoText.visible = false
        end if
    else if index >= 1
        m.homeScreen.visible = false
        ? "product group: "; m.listNames[index-1]; " is in focus"
        for i=0 to m.listNames.count()-1
            if i=index-1
                m.listProducts[i].visible = true
                m.listProductsItemInFocus = index-1
                ' mark the purchased item in each group (if any)'
                'groupName = m.listNames[i]
                purchasedIndex = getPurchasedItem()
                m.listProducts[i].checkedItem = purchasedIndex
                m.productInfoText.visible = true
            else
                m.listProducts[i].visible = false
                ' do we need to unobserve?'
            end if
        end for

    end if
end sub

' Callback for an item in focus '
sub onProductFocused(msg)
    index = msg.getData()
    ''? "onProductFocused index= "; index
    ' Get the product title from the focused list of products
    productId = m.listProducts[m.listProductsItemInFocus].content.getchild(index).id
    productName = m.catalog[productId].name
    displayProductInfo(productId)
end sub

' Callback for an item selection '
sub onProductSelected(msg)
    index = msg.getData()
    ''? "onProductSelected index= "; index
    m.top.visible = false
    ' Get the product title from the focused list of products
    productId = m.listProducts[m.listProductsItemInFocus].content.getchild(index).id
    productName = m.catalog[productId].name
    productCode = m.catalog[productId].code
    productCost = m.catalog[productId].cost
    groupName = m.listNames[m.listProductsItemInFocus]
    purchasedIndex = getPurchasedItem()
    if purchasedIndex <> -1
      purchasedId = m.listProducts[m.listProductsItemInFocus].content.getchild(purchasedIndex).id
      purchasedName = m.listProducts[m.listProductsItemInFocus].content.getchild(purchasedIndex).TITLE
    else
      purchasedId = ""
      purchasedName = ""
    end if
    ''? "purchasedId= "; purchasedId
    ''? "purchasedName="; purchasedName

    scene = m.top.getScene()
    if index = purchasedIndex or purchasedIndex = -1
      'Purchase operation'
      if purchasedName = productName
      ' Display status dialog'
        print "No operations are available on a product already purchased."
        m.dialogBox.message = "Error: " + chr(10) + "No operations are available, you already purchased this product."
        m.dialogBox.buttons = ["Dismiss"]
        scene.dialog = m.dialogBox
      else
        'Switch to the purchase screen'
        purchaseScreen = scene.findNode("purchaseScreen")
        if purchaseScreen <> invalid
          purchaseScreen.billing = m.billing
          purchaseScreen.productCode = productCode
          purchaseScreen.productName = productName
          purchaseScreen.visible = true

          purchaseButton = purchaseScreen.findNode("purchaseButton")
          purchaseButton.setFocus(true)
        else
          print "Could not find the purchase screen!"
        end if
      end if

    else  ' Upgrade/Downgrade operation'
      purchasedCost = getFloatCost(m.purchases[purchasedId].cost)
      if productCost > purchasedCost
        requestType = "Upgrade"
      else
        requestType = "Downgrade"
      end if

      ' Don't allow upgrade/downgrade if selected product is cancelled
#if blockBk2BkDownUpgrade
      if m.purchases[productId] <> invalid and m.purchases[productId].status = "Cancelled"
        ' Display status dialog'
        print "Upgrade/downgrade not allowed, only on next billing cycle"
        m.dialogBox.message = requestType + " error: " + chr(10) + "Operation not allowed until next billing cycle"
        m.dialogBox.buttons = ["Dismiss"]
        scene.dialog = m.dialogBox
      else
#else
      if 1
#end if
        ' Switch to the upgrade screen'
        upgradeScreen = scene.findNode("upgradeScreen")
        if upgradeScreen <> invalid
          'purchasedName = m.catalog[purchasedName].planName
          ''? "purchasedName= "; purchasedName
          'upgradeScreen.purchaseData = m.purchases[purchasedName]
          upgradeScreen.requestType = requestType
          upgradeScreen.billing = m.billing
          upgradeScreen.purchasedName = purchasedName
          upgradeScreen.productCode = productCode
          upgradeScreen.productName = productName
          upgradeScreen.visible = true
          upgradeButton = upgradeScreen.findNode("upgradeButton")
          upgradeButton.setFocus(true)
        else
          print "Could not find the upgrade screen!"
        end if
      end if
    end if
end sub

sub dismissdialog()
  scene = m.top.getScene()
  scene.dialog.close = true
  m.top.result = {"ret": 0}
end sub

' This function sets up the product information left panel
' called in the product catalog creation'
function setupProductInfoText(code, productData = {} as object, purchaseData = {} as object)
  ' Get all info productData
    text = "Product Info" + chr(10)
    text += "  Code: " + code + chr(10)
    text += "  Name: " + productData.name + chr(10)
    'productItem = m.products[name]

    text += chr(10)   ' blank line'
    text += "Type" + chr(10)
    text += "  " + productData.productType + chr(10)
    text += "  Price: " + productData.cost + chr(10)

    if productData.trialType <> "None"
      text += chr(10)   ' blank line'
      text += "Trial period" + chr(10)
      text += "  Duration: " + productData.trialQuantity.toStr()
      text += " " + productData.trialType + chr(10)
    end if

    if purchaseData <> invalid
      text += chr(10)   ' blank line'
      text += "Additional info" + chr(10)
      text += "  Status: " + purchaseData.Status + chr(10)
      text += "  Expiration date: " + purchaseData.expirationDate
    end if

    return text
end function

sub displayProductInfo(id)
  item = m.catalog[id]
  text = item.pInfoText
  m.productInfoText.text = text
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        ? "Product Screen - Key pressed: " + key
        if key = "left"
            ? "left key - command list has focus "
            m.commandList.setFocus(true)
            handled = true
        end if
        if key = "right"
            index = m.commandList.ItemFocused
            print "Item selected: ", stri(index)
            if index = 0  ' Home
                print "Home screen has focus"
            else if index >= 1
                m.listProducts[index-1].setFocus(true)
            end if
            handled = true
        end if
    end if
    return handled
end function
