function init()
    m.contentRowList = m.top.FindNode("contentRowList")
    m.contentRowList.observeField("selectedContent", "onContentSelected")
    m.contentRowList.SetFocus(true)
end function

'Create the appropriate dialog (pin/no pin) when a content item is selected
function onContentSelected() as void
    m.top.selectedContent = m.contentRowList.selectedContent
    m.top.action="tvodpurchase"
end function

'Displays a status dialog after completing a transaction (successful/failed).
function showPurchaseStatus(response as Object) as void
    msg = "Your purchase of " + response.title
    if (response.status = "Success")
        msg = msg + " was successful."
    else
        if (response.errorMessage = invalid)
            response.errorMessage = response.errorCode
        end if
        msg = msg + " failed." + chr(10) + chr(10) + "Error: " + response.errorMessage
    end if
    m.dialog = createObject("roSGNode", "Dialog")
    m.dialog.title = "Purchase"
    m.dialog.message = msg
    m.buttons = ["OK"]
    m.dialog.buttons = m.buttons

    m.dialog.observeField("buttonSelected", "statusDialogButtonSelected")

    m.top.dialog = m.dialog
end function

'Close the status dialog
function statusDialogButtonSelected() as void
    m.dialog.close = true
    m.top.action = ""
end function
