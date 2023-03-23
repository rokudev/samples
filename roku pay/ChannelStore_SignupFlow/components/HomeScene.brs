' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' Component initialization, setting default properties, configuring observers (handlers).
sub init()
    print ">>> HomeScene :: init()"
    
    m.rokuSignUp = m.top.findNode("rokuSignUp")
    deviceinfo = createObject("roDeviceInfo")

    if deviceinfo.getDisplaySize().w = 1920
        m.rokuSignUp.posterSplash.uri = "pkg:/images/splash_fhd.jpg"
    else
        m.rokuSignUp.posterSplash.uri = "pkg:/images/splash_hd.jpg"
    end if
    
    m.rokuSignUp.buttonLoginFlow.SetFields({
        focusBitmapUri  : "pkg:/images/button_on.9.png"
        focusedIconUri  : "pkg:/images/login.png"
        iconUri         : "pkg:/images/login.png"
    })
    m.rokuSignUp.buttonSignupFlow.SetFields({
        focusBitmapUri  : "pkg:/images/button_on.9.png"
        focusedIconUri  : "pkg:/images/signup.png"
        iconUri         : "pkg:/images/signup.png"
    })
    m.rokuSignUp.dialogsButtonConfig = {
        focusBitmapUri : "pkg:/images/button_on.9.png"
    }
    
    m.rokuSignUp.ObserveField("isSubscribed", "On_rokuSignUp_isSubscribed")
    m.rokuSignUp.ObserveField("isLoginAPISuccess", "On_rokuSignUp_isAuthN")
    
    m.rokuSignUp.isAuthNeeded = true
    m.rokuSignUp.show = true
    
    print "<<< HomeScene :: init()"
end sub


' Handler for processing RokuSignUp flow result.
sub On_rokuSignUp_isSubscribed()
    msgDialog = CreateObject("roSGNode", "BackDialog")
    msgDialog.buttons = ["Continue"]
    msgDialog.buttonGroup.focusBitmapUri = "pkg:/images/button_on.9.png"
    msgDialog.ObserveField("buttonSelected", "On_msgDialog_buttonSelected")
    msgDialog.ObserveField("isBackPressed", "On_msgDialog_buttonSelected")

    if m.rokuSignUp.isSubscribed then
        if m.rokuSignUp.isAfterLoginAuthFlow then
            On_msgDialog_buttonSelected()
        else
            msgDialog.title = "Subscribed successfully"
            m.top.dialog = msgDialog
        end if
    else
        if m.top.dialog <> invalid then m.top.dialog.close = true
        msgDialog.title = "Not subscribed"
        m.top.dialog = msgDialog
    end if
end sub


' Handler for processing RokuSignUp AuthN flow result.
sub On_rokuSignUp_isAuthN()
    msgDialog = CreateObject("roSGNode", "BackDialog")
    msgDialog.buttons = ["Continue"]
    msgDialog.buttonGroup.focusBitmapUri = "pkg:/images/button_on.9.png"
    msgDialog.ObserveField("buttonSelected", "On_msgDialog_buttonSelected")
    msgDialog.ObserveField("isBackPressed", "On_msgDialog_buttonSelected")
  

    if m.rokuSignUp.isLoginAPISuccess AND m.rokuSignUp.isAfterLoginAuthFlow then
        msgDialog.title = "Authenticated successfully"
        m.top.dialog = msgDialog
    else
        msgDialog.title = "Authentication failed"
        m.top.dialog = msgDialog
    end if

end sub


' Handler for processing subscription result dialog button selection.
sub On_msgDialog_buttonSelected()
    if m.rokuSignUp.isSubscribed then
        m.top.backgroundURI = "pkg:/images/bg_colored.jpg"
    else
        m.top.backgroundUri = "pkg:/images/bg_dark.jpg"
    end if
    if m.top.dialog <> invalid then m.top.dialog.close = true
    m.rokuSignUp.show = false
    m.top.SetFocus(true)
end sub