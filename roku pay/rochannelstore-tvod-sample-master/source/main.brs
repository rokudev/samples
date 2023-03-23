'********** Copyright 2017 Roku Inc.  All Rights Reserved. **********
function main() as void
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("MainScene")
    screen.show()

    m.channelStore = CreateObject("roChannelStore")

    scene.observeField("action", m.port)
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return 'exit channel
        else if msgType = "roSGNodeEvent"
            if (scene.action = "tvodpurchase")
                makePurchase(scene) 'proceed with purchase
            end if
        end if
    end while
end function

'This function checks to see if the user has a valid billing status
'If billing status is valid, setup the order details and proceed with the transaction
function makePurchase(scene as Object) as void
    metadata = scene.selectedContent

    order = CreateObject("roAssociativeArray")
    order.priceDisplay = metadata.price
    order.price = metadata.price
    ? "-----------------------------------------------------"
    ? "Order Request: "; order

    orderRequest = m.channelStore.requestPartnerOrder(order, metadata.product_id) 'check the user's billing status
    ? "-----------------------------------------------------"
    ? "Order Response: "; orderRequest

    confirmOrder = CreateObject("roAssociativeArray")
    confirmOrder.title = metadata.title 'set to title of content - this value will be shown on user's invoice
    confirmOrder.price = Mid(orderRequest.total, 2) 'strip out currency symbol
    confirmOrder.priceDisplay = metadata.price 'the price of the transaction - this value will be shown on user's invoice
    confirmOrder.orderID = orderRequest.id 'the ID returned from requestPartnerOrder confirming a valid billing status
    ? "-----------------------------------------------------"
    ? "Confirm Order Request"; confirmOrder

    response = m.channelStore.confirmPartnerOrder(confirmOrder, metadata.product_id) 'do the transaction
    ? "-----------------------------------------------------"
    ? "Confirm Order Response: "; response
    ? "-----------------------END---------------------------"

    response.title = metadata.title 'set the content title in response to display in the status dialog
    response.priceDisplay = "$" + confirmOrder.price 'set the price in response to display in the status dialog

    scene.callFunc("ShowPurchaseStatus", response) 'display a status dialog to show the user whether the purchase was successful or not
end function
