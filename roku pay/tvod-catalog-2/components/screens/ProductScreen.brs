'********** Copyright 2020, 2023 Roku Corp.  All Rights Reserved. **********

sub init()
    m.top.observeField("orders", "startAsyncDoOrder")  'startAsyncDoOrder in RPayUtils.brs'
    m.top.observeField("menus", "onMenusChange")
    m.top.observeField("result", "handleReturnFromOrder")
    m.top.observeField("queries", "handleReturnFromQuery")

    m.dialogBox = CreateObject("roSGNode", "Dialog")
    m.dialogBox.id = "dialogBox"
    m.dialogBox.title = "Purchase Status Info"
    m.dialogBox.observeField("buttonSelected","dismissdialog")

    ' this contains the products UI (RadioButtonList) for each menu'
    m.listProducts = []
    m.listProductsItemInFocus = -1

    '  this contains the data coming from getProductList'
    m.catalog = {}

    '  this contains the data coming from getPurchaseList'
    m.purchases = {}
end sub

function onMenusChange()
    m.menus = m.top.menus
    m.listNames = m.top.menus
    setupCommandList(m.listNames)

    m.homeScreen = m.top.findNode("homeScreen")
    m.titleLabel = m.top.findNode("titleLabel")
    m.titleLabel.font.size = 40
    m.descriptionLabel = m.top.findNode("descriptionLabel")
    m.descriptionLabel.font.size = 30
    m.descriptionLabel.text = "1.  In the Developer Dashboard, go to the Product Catalog and create products and one or more purchase options for each product."
    m.howToUseLabel = m.top.findNode("howToUseLabel")
    m.howToUseLabel.font.size = 30
    m.howToUseLabel.text = "2.  Select Base/Bundle to purchase base products." + chr(10) + chr(10) + "3.  Select Add-ons to purchase eligible add-ons for any existing base product purchases."

    ' delay setting up product lists until product and purchase lists are back'
    'setupProductLists(m.menus, m.listNames)
    'm.commandList.SetFocus(true)

    m.productInfoText = m.top.findNode("productInfoText")
    m.productInfoText.text = ""

    ' Get the TVOD catalog
    m.tvodAA = m.top.tvodAA

    ' Get catalog, purchases requested after plans and products received'
    m.billing = m.top.billing

    'm.billing.callFunc("runDoRecovery")
    
    m.billing.observeField("productList", "handleGetCatalogResponse")
    m.billing.callFunc("getCatalog")
end function

sub handleGetCatalogResponse(event)
    'print "called handleGetCatalogReponse()"
    m.billing.unobserveField("productList")
    'Temporarily save  catalogData'
    m.catalogData = event.getData()
    print "m.catalogData.status= "; m.catalogData.status
    if m.catalogData.status <> 1
      showContactRokuDialog()
    else
      ' Create catalog, save it in m.catalog'
      ' TODO: Add TVOD titles to the catalog '
      m.catalog = createCatalog(m.catalogData, m.tvodAA)

      if m.catalog.count() = 0
        showNoProductDialog()
      else
        query = [
          {"billingType":"Subscription","base":true},
          {"billingType":"Subscription","bundle":true}
        ]  
        getPurchaseOptions(m.catalogData.purchaseOptions, m.catalogData.productList, "Base", query)
      end if
    end if
end sub

sub getPurchaseOptions(purchaseOptions, products, queryType, query)
    m.queryRequestInfo = {map1: purchaseOptions, map2: products, context: queryType, query: query}
    m.billing.observeField("queryResult", "handleQueryResult")
    m.billing.callFunc("queryPurchaseOptions", m.queryRequestInfo)
end sub

sub handleQueryResult(event)
    print "called handleQueryResult()"
    m.billing.unobserveField("queryResult")
    queryResult = event.getData()
    if m.queryRequestInfo.context = "Base"
      ' Store base purchase options, query addons
      m.baseAA = queryResult
#if includePPV
      query = [
       {"type": "NonConsumable"}
      ]  
      getPurchaseOptions(m.catalogData.purchaseOptions, m.catalogData.productList, "PPV", query)
    else if m.queryRequestInfo.context = "PPV"
      m.ppvAA = queryResult
#endif
      query = [
       {"billingType":"Subscription","addon":true}
      ]  
      getPurchaseOptions(m.catalogData.purchaseOptions, m.catalogData.productList, "Addon", query)
   
    else if m.queryRequestInfo.context = "Addon"
      ' Store addon purchase options, run getAllPurchases
      m.addonAA = queryResult
      m.billing.observeField("extPurchaseList", "handleExtPurchaseListResponse")
      m.billing.callFunc("getAllPurchases")  
    end if
end sub

sub handleExtPurchaseListResponse(event)
    print "called handleExtPurchaseListResponse"
    purchaseData = event.getData()
    print "purchases: "; purchaseData

     'TODO: find active purchase, there should be only one
     m.purchases = createActivePurchases(purchaseData)
     updateProductInfoText(m.catalogData, m.purchases)
 
     ' Build list of products using m.catalog and m.purchases'
     ' (data from menus[x] from config.json is optional)'
     setupProductLists(m.menus, m.listNames, m.catalog)
     m.commandList.SetFocus(true)
     m.top.getScene().signalBeacon("AppLaunchComplete")
 
    m.billing.unobserveField("extPurchaseList")
    purchaseData = event.getData()
    activeProductCode = getActivePurchase(m.purchases)
    m.purchases = updatePurchases(purchaseData, activeProductCode)
end sub

sub handleReturnFromOrder(event)
  m.top.visible = true
  print "Return - request list of purchases"
  purchaseData = event.getData()
  print "purchaseData: "; purchaseData

  ' Fill in the purchases info from doOrder result
  status = purchaseData.status
  if status.status = 1
    m.purchases = getPurchasesFromOrder(purchaseData.purchases)
    updateProductInfoText(m.catalogData, m.purchases)
  else if status.status = 2
    print "status: 2 - message: backed out of purchase"
  else
    ' Purchase error - display error dialog
    print "status: "; status.status; " - message: "; status.statusMessage
  end if

  m.commandList.SetFocus(true)
end sub

function getPurchasesFromOrder(purchasesList as Object) as Object
  purchases = {}
  for each purchase in purchasesList
    print "purchase: ", purchase
    data = {}
    data.sku = purchase.sku
    data.name = purchase.name
    data.description = purchase.name
    data.amount = purchase.amount
    data.type = purchase.type
    data.total = purchase.total
    data.tid = purchase.purchaseId
    data.cid = purchase.rokuCustomerId
    data.status = "Active"
    data.state_display = "Active (New)"
    data.renewalDate = "TBD"
    purchases.addReplace(data.sku, data)
  end for

  return purchases
end function

function getFloatCost(cost as String) as Float
    length = cost.len()
    ' skip the currency symbol'
    return mid(cost,2,length).toFloat()
end function

sub createCatalog(catalogData as object, tvodData as object) as object
    catalog = {}
    purchaseOptions = catalogData.purchaseOptions
    for each item in purchaseOptions.Items()
      'print "catalog key= "; item.key
      data = {}
      pInfoText = setupProductInfoText(item.value)
      data.name = item.value.name
      data.sku = item.value.sku
      data.cost = item.value.cost
      data.isAddOn = item.value.addOn
      data.isTvod = false

      '? "cost= "; data.cost
      data.type = item.value.billingPlans[0].billingType
      data.productIds = item.value.billingPlans[0].productIds
      '? "catalog productIds= "; data.productIds

      ' build list of products in a bundle
      productIds = item.value.billingPlans[0].productIds
      data.productsInBundle = []
      if productIds.Count() > 1
        data.productsInBundle = buildBundle(catalogData.productList, productIds)
        'collect the skus for add-ons that are not in the bundle
        '(do it now or later?)
      end if
      'data.productsInBundle = productsInBundle
      data.pInfoText = pInfoText
      catalog.addReplace(item.key, data)
    end for

    for each item in tvodData.TVOD
      data = {}
      pInfoText = setupTVODProductInfoText(item)
      data.isTvod = true
      data.name = item.title
      data.cost = item.price
      data.originalCost = item.originalPrice
      data.sku = item.sku
      data.contentKey = item.contentKey
      data.pInfoText = pInfoText
      catalog.addReplace(data.contentKey, data)
    end for

    return catalog
end sub

sub buildBundle(products, productIds) as object
  productsInBundle = []
  for each productId in productIds
    if products[productId].addon = true
      product = {"include": productId, "name": products[productId].name}
    else
      product = {"base": productId, "name": products[productId].name}    
    end if
    productsInBundle.push(product)
  end for

  return productsInBundle
end sub

sub createActivePurchases(purchasedData as object) as object
    purchases = {}
    ' Expect only one active purchase'
    purchasedList = purchasedData.purchaseList
    'productList = purchasedData.productList
    'entitlementList = purchasedData.entitlementList
    for each productCode in purchasedList
      'print "purchases key= "; productCode

      ' Some places in the code may still rely on this status
      purchaseState = purchasedList[productCode].billingPlans[0].state
      tempState = purchaseState.Left(6)
      if purchaseState.Left(6) = "Active"
        data = {}
        data.renewalDate = purchasedList[productCode].billingPlans[0].renewalDate
        data.status = "Active"
        data.state_display = purchaseState
        data.cost = purchasedList[productCode].cost
        data.source = purchasedList[productCode].purchaseChannel + " / " + purchasedList[productCode].purchaseContext

        purchases.addReplace(productCode, data)
      endif
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

sub updatePurchases(purchasedData as object, activeProductCode as string) as object
    ' print "calling updatePurchases()"
    purchases = {}

    purchasedList = purchasedData.purchaseList
    ' productList = purchasedData.productList
    ' entitlementList = purchasedData.entitlementList

    for each productCode in purchasedList
      purchaseState = purchasedList[productCode].billingPlans[0].state
      if purchaseState.Left(6) = "Active" and m.catalog.Lookup(productCode) <> invalid
        'print "purchased productCode= "; productCode
        'print "state= "; purchaseState
        data = {}
        data.cost = purchasedList[productCode].cost
        data.source = purchasedList[productCode].purchaseChannel + " / " + purchasedList[productCode].purchaseContext
        data.status = "Active"
        data.isAddOn = m.catalog[productCode].isAddOn
  
        purchases.addReplace(productCode, data)
      end if
    end for

    return purchases
end sub

sub updateProductInfoText(catalogData, purchases)
  for each item in m.catalog.Items()
    purchasedItem = purchases[item.key]
    productItem = catalogData[item.key]
    pInfoText = setupProductInfoTextWithPurchases(m.catalog[item.key], purchasedItem)
    m.catalog[item.key].pInfoText = pInfoText
  end for
end sub

' Setup label list on the left side with commands
sub setupCommandList(menuNames)
    commandListContent = createObject("roSGNode", "ContentNode")
    addToCommandListItem("Home", commandListContent)
    ' The Subscriptions menu (base, addons) is default'
    ' Other menus can be added to menuss AA in config.json'
    for each item in menuNames
        addToCommandListItem(item, commandListContent)
    end for

    m.commandList = m.top.findNode("commandList")
    m.commandList.content = commandListContent
    m.commandList.observeField("itemFocused", "onCommandItemFocused")
end sub

' Setup list of products in the middle panel, one for each menu'
sub setupProductLists(menus, menuNames, catalog)

  radioButtonListContent = []
  for i=0 to menuNames.count()-1
    ' this is the parent content node for checkboxlist, one per product menu'
    content = createObject("roSGNode", "ContentNode")
    radioButtonListContent.push(content)
  end for

  'Assign the products to one of the 4 menus: Subscriptions (0), Add-ons (1), PPV (2), TVOD
  for i=0 to menuNames.count()-1
    if menuNames[i] = "Add-ons"
      for each item in m.addonAA.purchaseOptions.Items()
        addRadioButtonListItem(item.value.name, item.value.sku, radioButtonListContent[i])
      end for
#if includePPV
    else if menuNames[i] = "PPV"
      for each item in m.ppvAA.purchaseOptions.Items()
        addRadioButtonListItem(item.value.name, item.value.sku, radioButtonListContent[i])
      end for
#endif
'#if includeTVOD
    else if menuNames[i] = "TVOD"
      ' TODO: finish TVOD implementation
      tvods = m.tvodAA.TVOD
      for each item in tvods
        addRadioButtonListItem(item.title, item.contentKey, radioButtonListContent[i])
      end for
'#endif
    else if menuNames[i] = "Base/Bundle"
      for each item in m.baseAA.purchaseOptions.Items()
        addRadioButtonListItem(item.value.name, item.value.sku, radioButtonListContent[i])
      end for
    end if

    m.listProducts[i] = createObject("roSGNode", "RadioButtonList")
    m.listProducts[i].id = menuNames[i]
    m.listProducts[i].content = radioButtonListContent[i]
    m.listProducts[i].itemSize = "[300,100]"
    m.listProducts[i].translation = "[280,100]"
    m.listProducts[i].observeField("itemFocused", "onProductFocused")
    m.listProducts[i].observeField("itemSelected", "onProductSelected")
    m.listProducts[i].visible = false
    m.top.appendChild(m.listProducts[i])
  end for
end sub

sub cleanupProductsList()
  for i=0 to m.menus.count()-1
    m.top.removechild(m.listProducts[i])
    m.listProducts[i] = invalid
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

' Get the item purchased (if any) in each menu. '
function getPurchasedItems()
  ' first get plans from m.purchases'
  'productsList = m.listProducts[0].content
  purchasesList = []
  ''? "productsList= "; productsList

  for each key in m.purchases
      if m.purchases[key].status = "Active"
        purchasesList.push(key)
      end if
  end for
  print "purchasesList= "; purchasesList

  return purchasesList
end function

function getBaseProductIndexFromPurchases(list)
  index = -1
  productsList = m.listProducts[0].content
  for i=0 to productsList.getChildCount() - 1
      productId = productsList.getChild(i).id
      for each purchasedId in list
        if productId = purchasedId and m.catalog[productId].isAddOn = false
            index = i
            exit for
        end if
      end for
  end for
  return index
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
        ? "product menu: "; m.listNames[index-1]; " is in focus"
        for i=0 to m.listNames.count()-1
            if i=index-1
                m.listProducts[i].visible = true
                m.listProductsItemInFocus = index-1
                ' mark the purchased item in each menu (if any)'
                'menuName = m.listNames[i]
                purchasedList = getPurchasedItems()
                baseProductIndex = getBaseProductIndexFromPurchases(purchasedList)
                m.listProducts[i].checkedItem = baseProductIndex
                m.productInfoText.text = ""
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
    '? "onProductFocused index= "; index
    ' Get the product title from the focused list of products
    if index >= 0
      productId = m.listProducts[m.listProductsItemInFocus].content.getchild(index).id
      displayProductInfo(productId)
    end if
end sub

' Callback for an item selection '
sub onProductSelected(msg)
    index = msg.getData()
    ? "onProductSelected index= "; index

    ' Get the product title from the focused list of products
    productId = m.listProducts[m.listProductsItemInFocus].content.getchild(index).id
    productName = m.catalog[productId].name
    productSku = m.catalog[productId].sku
    productCost = m.catalog[productId].cost
    isAddOn = m.catalog[productId].isAddOn
    isTVOD = m.catalog[productId].isTVOD
    billingType = m.catalog[productId].type
    'menuName = m.listNames[m.listProductsItemInFocus]

    purchasedList = getPurchasedItems()
    baseProductIndex = getBaseProductIndexFromPurchases(purchasedList)
    if baseProductIndex = -1 or isAddOn = true or isTVOD = true or billingType = "DigitalProducts"
      purchasedId = ""
      purchasedName = ""
    else
      purchasedId = m.listProducts[m.listProductsItemInFocus].content.getchild(baseProductIndex).id
      purchasedName = m.listProducts[m.listProductsItemInFocus].content.getchild(baseProductIndex).TITLE
    end if
    ''? "purchasedId= "; purchasedId
    ''? "purchasedName="; purchasedName
    ? "productSku: "; productSku
    ? "productName: "; productName

    scene = m.top.getScene()
    if billingType = "Subscription" and isAddOn = false
      productsInBundle = m.catalog[productSku].productsInBundle
      addOns = GetAddOnsForBaseProductAA(productSku)
      'addOns = m.catalog[productSku].addOns
      purchasedAddonSkus = GetPurchasedAddonSkus()
      oneTimeEvents = GetOneTimeEventsAA()
    else if isTVOD = true
      addOns = {}
      purchasedAddonSkus = []
      oneTimeEvents = {}      
    else 'billingType = DigitalProducts or isAddOn
      addOns = {}
      purchasedAddonSkus = []
      oneTimeEvents = {}
    end if

    if isTVOD
      purchaseScreen = scene.findNode("purchaseTVODScreen")
      productOriginalCost = m.catalog[productId].originalCost
      contentKey = m.catalog[productId].contentKey
      if purchaseScreen <> invalid
          purchaseScreen.billing = m.billing
          purchaseScreen.productCode = productSku
          purchaseScreen.productPrice = productCost
          purchaseScreen.productOriginalPrice = productOriginalCost
          purchaseScreen.contentKey = contentKey
          purchaseScreen.productName = productName

          m.top.visible = false
          purchaseScreen.visible = true
          purchaseButton = purchaseScreen.findNode("purchaseButton")
          purchaseButton.setFocus(true)
      end if
    else if index = baseProductIndex or baseProductIndex = -1 or isAddOn or billingType = "DigitalProducts"
      alreadyPurchased = false
      'Check if base product already purchased
      if productSku = purchasedId
        alreadyPurchased = true
        'Check if any add-on already purchased
        for each addonSku in purchasedAddonSkus
          if productSku = addonSku
            alreadyPurchased = true
          end if
        end for

        if alreadyPurchased = true
        ' Display status dialog'
          print "No operations are available on a product already purchased."
          m.dialogBox.message = "Error: " + chr(10) + "No operations are available, you already purchased this product."
          m.dialogBox.buttons = ["Dismiss"]
          scene.dialog = m.dialogBox
        else
        ' TODO: Add prerequisites check for addOn
        '  addOnEligible = true
        end if
      else

        purchaseScreen = scene.findNode("purchaseScreen")
        if purchaseScreen <> invalid
          purchaseScreen.billing = m.billing
          purchaseScreen.productCode = productSku
          purchaseScreen.productPrice = productCost
          purchaseScreen.addOns = addOns
          purchaseScreen.oneTimeEvents = oneTimeEvents
          purchaseScreen.purchasedAddonSkus = purchasedAddonSkus
          purchaseScreen.productsInBundle = productsInBundle
          purchaseScreen.productName = productName

          m.top.visible = false
          purchaseScreen.visible = true

          if isAddOn or billingType = "DigitalProducts" or addOns.count() = 0
            purchaseButton = purchaseScreen.findNode("purchaseButton")
            purchaseButton.setFocus(true)
          else
            addonChecklist = purchaseScreen.findNode("addonChecklist")
            addonChecklist.setFocus(true)
          end if
        end if
      end if

    else  ' Upgrade/Downgrade operation'
      ' The logic for upgrade/downgrade is now up to the user
      ' A separate upgrade and downgrad buttons were added in upgradeScreen

      ' Switch to the upgrade screen'
      upgradeScreen = scene.findNode("upgradeScreen")
      if upgradeScreen <> invalid
        upgradeScreen.billing = m.billing
        upgradeScreen.purchasedName = purchasedName
        upgradeScreen.productCode = productSku
        upgradeScreen.productPrice = productCost
        upgradeScreen.addOns = addOns
        upgradeScreen.purchasedAddonSkus = purchasedAddonSkus
        upgradeScreen.productsInBundle = productsInBundle
        upgradeScreen.replacedPurchase = purchasedId
        upgradeScreen.productName = productName

        m.top.visible = false
        upgradeScreen.visible = true

        if isAddOn or addOns.count() = 0
          upgradeButton = upgradeScreen.findNode("upgradeButton")
          upgradeButton.setFocus(true)
        else
          addOnChecklist = upgradeScreen.findNode("addOnCheckList")
          addOnChecklist.setFocus(true)
        end if
      else
        print "Could not find the upgrade screen!"
      end if
    end if
end sub

sub dismissdialog()
  scene = m.top.getScene()
  scene.dialog.close = true
end sub

function GetAddOnsForBaseProductAA(productSku) as object
  result = {}
  ' Assumption: add-on is by itself (purchase option for add-on has one product)
  if m.catalog[productSku].isAddon = true
    return result
  end if
  isBundle = false
  if m.catalog[productSku].productsInBundle.count() > 0
    isBundle = true
  end if
  for each item in m.catalog.Items()
    if item.value.isAddOn = true
      if isBundle
        'check if the productId exists in the bundle
        productIdInBundle = false
        for each productId in m.catalog[productSku].productIds
          if productId = item.value.productIds[0]
            productIdInBundle = true
          end if
        end for
        if productIdInBundle = false
          result.addReplace(item.key, item.value)
        end if
      else
        result.addReplace(item.key, item.value)
      end if
    endif
  endfor

  return result
end function

function GetPurchasedAddonSkus()
  addOns = []
  for each item in m.purchases.Items()
    if item.value.isAddOn = true
      addOns.push(item.key)
    end if
  end for
  return addOns
end function

function GetOneTimeEventsAA() as object
  result = {}
  for each item in m.catalog.Items()
    if item.value.type = "DigitalProducts"
      result.addReplace(item.key,item.value)
    end if
  end for
  return result
end function

sub showContactRokuDialog()
  print("entered showContactRokuDialog()")
  m.dialogContactRoku = CreateObject("roSGNode", "Dialog")
  m.dialogContactRoku.id = "dialogContactRoku"
  m.dialogContactRoku.title = "This channel needs to be added to the allowlist"
  m.dialogContactRoku.observeField("buttonSelected","dismissDialogAndExit")
  m.dialogContactRoku.message = "Please contact Roku Partner Management to get your channel added to the ChannelStore v2 APIs allowlist"
  m.dialogContactroku.buttons = ["Dismiss"]
  m.top.getScene().dialog = m.dialogContactRoku
end sub

sub showNoProductDialog()
  m.dialogNoProduct = CreateObject("roSGNode", "Dialog")
  m.dialogNoProduct.id = "dialogNoProduct"
  m.dialogNoProduct.title = "No Products are on this Channel"
  m.dialogNoProduct.observeField("buttonSelected","dismissDialogAndExit")
  m.dialogNoProduct.message = "Error: you need to add In App Purchase products in the developer dashboard."
  m.dialogNoProduct.buttons = ["Dismiss"]
  m.top.getScene().dialog = m.dialogNoProduct
end sub

sub dismissDialogAndExit()
  scene = m.top.getScene()
  scene.dialog.close = true
  scene.exitApp = true
end sub

' This function sets up the product information left panel
' called in the product catalog creation'
function setupProductInfoText(purchaseOption = {} as object)
  ' Get all info productData
    text = "Product Info" + chr(10)
    text += "  SKU: " + purchaseOption.sku + chr(10)
    text += "  Name: " + purchaseOption.name + chr(10)
    text += "  Product Id: " + purchaseOption.billingPlans[0].productIds[0] + chr(10)
    'productItem = m.products[name]

    text += chr(10)   ' blank line'
    text += "Billing Plans" + chr(10)
    if purchaseOption.billingPlans[0].billingType = "Subscription"
      for each phase in purchaseOption.billingPlans[0].phases
        text += "  " + phase.type + ": " + phase.cost
        if phase.Lookup("duration") <> Invalid
          text += " for " + StrI(phase.duration.quantity) + " " + phase.duration.unit + chr(10)
        else
          text += chr(10)  'blank line'
        end if
      end for
    else
      text += "  Price: " + purchaseOption.cost
    end if

    ' if productData.trialType <> "None"
    '   text += chr(10)   ' blank line'
    '   text += "Trial period" + chr(10)
    '   text += "  Duration: " + productData.trialQuantity.toStr()
    '   text += " " + productData.trialType + chr(10)
    '   text += "  Price: " + productData.trialCost + chr(10)
    ' end if
    return text
end function

function setupProductInfoTextWithPurchases(catalogData, purchaseData)
    text = catalogData.pInfoText
    if purchaseData <> invalid
       text += chr(10)   ' blank line'
       text += "Purchase info" + chr(10)
       text += "  Status: " + purchaseData.state_display + chr(10)

       'text += "  Status: " + purchaseData.status + chr(10)
       if purchaseData.renewalDate <> invalid
          renewalDate = purchaseData.renewalDate
       else
        renewalDate = ""
       end if
       text += "  Renewal date: " + renewalDate

       'text += chr(10)
       'Text += "  Source chan/ctx: " + purchaseData.source
    end if

    return text
end function

function setupTVODProductInfoText(tvodAA as object)
  ' Get all info productData
    text = "TVOD Product Info" + chr(10)
    text += "  SKU: " + tvodAA.sku + chr(10)
    text += "  Name: " + tvodAA.title + chr(10)
    text += "  Content Key: " + tvodAA.contentKey + chr(10)
    text += "  Price: " + tvodAA.price + chr(10)
    text += "  Original Price: " + tvodAA.originalPrice + chr(10)
    text += chr(10)  'blank line'

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
