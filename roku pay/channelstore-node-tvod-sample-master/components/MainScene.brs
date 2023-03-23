'********** Copyright 2017 Roku Inc.  All Rights Reserved. **********
function init()
    m.contentRowList = m.top.FindNode("contentRowList")
    m.contentRowList.observeField("selectedContent", "onContentSelected")
    m.contentRowList.SetFocus(true)

    m.store = createObject("RoSGNode", "ChannelStore")

    m.store.observeField("requestPartnerOrderStatus", "requestPartnerOrderStatusChanged")
    m.store.observeField("confirmPartnerOrderStatus", "confirmPartnerOrderStatusChanged")
 end function

function onContentSelected() as void
    m.selectedContent = m.contentRowList.selectedContent
    print "Calling makePurchase()"
    makePurchase()
end function

function statusDialogButtonSelected() as void
    m.dialog.close = true
end function

function ShowPurchaseStatus(params as Object) as void
    msg = "Your purchase of " + params.title + " for " + params.priceDisplay
    if (params.status = 1)
        msg = msg + " succeeded!"
    else
        msg = msg + " failed"
    end if
    m.dialog = createObject("RoSGNode", "Dialog")
    m.dialog.title = "TVOD Purchase Status"
    m.dialog.message = msg
    m.buttons = ["OK"]
    m.dialog.buttons = m.buttons

    m.dialog.observeField("buttonSelected", "statusDialogButtonSelected")

    m.top.dialog = m.dialog

end function

sub makePurchase()
    m.orderRequest = CreateObject("roSGNode", "ContentNode")
    m.orderRequest.title = m.selectedContent.title
    m.orderRequest.priceDisplay = m.selectedContent.price
    m.orderRequest.price = m.selectedContent.price

    m.orderRequest.addField("code", "string", false)
    m.orderRequest.code = m.selectedContent.product_id

    m.store.requestPartnerOrder = m.orderRequest

    ? "Issuing RequestPartnerOrder Command"
    ? "-- code: ", m.store.requestPartnerOrder.code
    ? "-- priceDisplay: ", m.store.requestPartnerOrder.priceDisplay
    ? "-- price: ", m.store.requestPartnerOrder.price
    m.store.command = "requestPartnerOrder"
end sub

sub requestPartnerOrderStatusChanged()
    ? "RequestPartnerOrderStatusChanged "; m.store.requestPartnerOrderStatus

    if m.store.requestPartnerOrderStatus.status = "Success"
        confirmPurchase()
    else
        displayOrderStatusDialog(m.store.requestPartnerOrderStatus)
    end if
end sub

sub confirmPurchase()
    m.confirmRequest = CreateObject("roSGNode", "ContentNode")
    m.confirmRequest.title = m.orderRequest.title
    m.confirmRequest.priceDisplay = m.orderRequest.priceDisplay
    m.confirmRequest.price = Mid(m.store.requestPartnerOrderStatus.total, 2)
    m.confirmRequest.orderID = m.store.requestPartnerOrderStatus.orderID

    m.confirmRequest.addField("code", "string", false)
    m.confirmRequest.code = m.orderRequest.code

    m.store.confirmPartnerOrder = m.confirmRequest

    ? "Issuing ConfirmPartnerOrder Command"
    ? "-- code: ", m.store.confirmPartnerOrder.code
    ? "-- title: ", m.store.confirmPartnerOrder.title
    ? "-- priceDisplay: ", m.store.confirmPartnerOrder.priceDisplay
    ? "-- price: ", m.store.confirmPartnerOrder.price
    ? "-- orderID: ", m.store.confirmPartnerOrder.orderID
    m.store.command = "confirmPartnerOrder"
end sub

sub confirmPartnerOrderStatusChanged()
    ? "ConfirmPartnerOrderStatusChanged "; m.store.confirmPartnerOrderStatus

    displayOrderStatusDialog(m.store.confirmPartnerOrderStatus)
end sub

Function orderStatusDialogButtonSelected()
    if m.top.dialog.buttonSelected = 0
        m.top.dialog.close = true
    end if
end Function

Function displayOrderStatusDialog(response as object) as void
    dialog = CreateObject("roSGNode", "Dialog")
    dialog.title = "Order Status"

    dialog.buttons = [ "OK" ]

    message = "Your purchase of " + m.orderRequest.title
    if response <> invalid and response.status = "Success"
        message = message + " for " + m.store.requestPartnerOrderStatus.total
        message = message + " succeeded"
    else
        message = message + " failed"
    end if

    dialog.message = message

    dialog.observeField("buttonSelected", "orderStatusDialogButtonSelected")

    ? "SHOWING ORDER STATUS DIALOG WITH MESSAGE: "; message
    m.top.dialog = dialog
End Function
