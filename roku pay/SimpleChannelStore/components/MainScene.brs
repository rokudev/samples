'********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

function init()
    m.top.backgroundUri=""
    m.top.backgroundColor="0x000000ff"
    m.store = m.top.FindNode("store")
    m.store.ObserveField("catalog", "onGetCatalog")
    m.store.ObserveField("purchases", "onGetPurchases")
    m.store.observeField("orderStatus", "onOrderStatus")
    m.store.ObserveField("userData", "onGetUserData")
    m.productGrid = m.top.FindNode("productGrid")
    m.productGrid.ObserveField("itemSelected", "onProductSelected")
    m.productGrid.SetFocus(true)
end function

function onGetCatalog() as void
    data = CreateObject("roSGNode", "ContentNode")
    if (m.store.catalog <> invalid)
        count = m.store.catalog.GetChildCount()
        for i = 0 to count - 1
	    productData = data.CreateChild("ChannelStoreProductData")
            item = m.store.catalog.getChild(i)
	    productData.productCode = item.code
	    productData.productName = item.name
	    productData.productPrice= item.cost
        end for
        m.productGrid.content = data
    endif
end function

function onGetUserData() as void
    if (m.store.userData <> invalid)
        MakePurchase()
    end if
end function

function onGetPurchases() as void
    data = CreateObject("roSGNode", "ContentNode")
    if (m.store.purchases <> invalid)
        count = m.store.purchases.GetChildCount()
        for i = 0 to count - 1
            item = m.store.purchases.GetChild(i)
        end for
        m.productGrid.content = data
    endif
end function

'This field observer function checks the userData field value to determine if the user consented.  If so,
'the purchase is initiated.
function MakePurchase() as void
    myOrder = CreateObject("roSGNode", "ContentNode")
    product = myOrder.CreateChild("ContentNode")
    product.addFields({"code" : m.item_to_purchase.productCode, "name" : m.item_to_purchase.productName, "qty" : 1})
    m.store.order = myOrder
    m.store.command = "doOrder"
end function

function onProductSelected() as void
    index = m.productGrid.itemSelected
    m.item_to_purchase = m.productGrid.content.GetChild(index)
    'Get user permission to share account information and proceed with the purchase if consent is given.
    'Setting the ChannelStore command field to getUserData will invoke the share screen.  The observer for
    'userData, onGetUserData, then takes over.
    m.store.command = "getUserData"
end function

function onOrderStatus() as void
    orderStatus = m.store.orderStatus
	if (orderStatus <> invalid ) and (orderStatus.status = 1)
	    dialog = CreateObject("roSGNode", "StatusDialog")
	    item = orderStatus.getChild(0)
	    dialog.message = "Your Purchase of " + item.code + " Completed Successfully"		
	    m.top.dialog = dialog
	end if
end function
