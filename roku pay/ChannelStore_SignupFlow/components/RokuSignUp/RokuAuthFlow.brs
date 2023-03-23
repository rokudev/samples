' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' Component initialization, setting default properties, configuring observers (handlers)
sub init()
    print ">>> RokuAuthFlow :: init()"

    m.indexButtonGo = 0
    m.indexButtonBack = 1
    m.indexButtonPasswordShowHide = 0
    m.indexButtonPasswordGo = 1
    m.indexButtonPasswordBack = 2

    m.top.kbdialogEmail = CreateObject("roSGNode", "BackKeyboardDialog")
    m.top.kbdialogEmail.title = "Enter the email address"
    m.top.kbdialogEmail.text = ""
    m.top.kbdialogEmail.buttons = ["Continue", "Back"]
    m.top.kbdialogEmail.ObserveField("buttonSelected", "On_kbdialogEmail_buttonSelected")

    m.top.kbdialogPassword = CreateObject("roSGNode", "BackKeyboardDialog")
    m.top.kbdialogPassword.title = "Enter the password"
    m.top.kbdialogPassword.text = ""
    m.top.kbdialogPassword.buttons = ["Show/hide password", "Continue", "Back"]
    m.top.kbdialogPassword.keyboard.textEditBox.secureMode = true
    m.top.kbdialogPassword.ObserveField("buttonSelected", "On_kbdialogPassword_buttonSelected")

    m.top.dialogErrEmail = CreateObject("roSGNode", "BackDialog")
    m.top.dialogErrEmail.title = "Email input error"
    m.top.dialogErrEmail.message = "Please enter a valid email address"
    m.top.dialogErrEmail.buttons = ["OK"]
    m.top.dialogErrEmail.ObserveField("buttonSelected", "On_dialogErrEmail_buttonSelected")

    m.top.dialogErrPassword = CreateObject("roSGNode", "BackDialog")
    m.top.dialogErrPassword.title = "Password input error"
    m.top.dialogErrPassword.message = "Please enter non-empty password"
    m.top.dialogErrPassword.buttons = ["OK"]
    m.top.dialogErrPassword.ObserveField("buttonSelected", "On_dialogErrPassword_buttonSelected")

    m.top.dialogTermsOfUse = CreateObject("roSGNode", "BackDialog")
    m.top.dialogTermsOfUse.title = "Terms Of Use"
    m.top.dialogTermsOfUse.message = ""  'if empty string then not shown to the user, set from your app if needed
    m.top.dialogTermsOfUse.buttons = ["Accept", "Decline"]
    m.top.dialogTermsOfUse.ObserveField("buttonSelected", "On_dialogTermsOfUse_buttonSelected")

    m.top.pdialogAuth = CreateObject("roSGNode", "ProgressDialog")
    m.top.pdialogAuth.title = "Please wait..."

    m.top.dialogAuthFailed = CreateObject("roSGNode", "BackDialog")
    m.top.dialogAuthFailed.title = "Authentication failed"
    m.top.dialogAuthFailed.buttons = ["Try again", "Cancel"]
    m.top.dialogAuthFailed.ObserveField("buttonSelected", "On_dialogAuthFailed_buttonSelected")

    m.top.ObserveField("userData", "On_userData")

    print "<<< RokuAuthFlow :: init()"
end sub


' Email address validation. Returns True if given email address matches regexEmail, false otherwise.
function IsValidEmail(email as String) as Boolean
    return CreateObject("roRegex", m.top.regexEmail, "i").IsMatch(email)
end function


' Password validation. Returns True if given password matches regexPassword, false otherwise.
function IsValidPassword(password as String) as Boolean
    return CreateObject("roRegex", m.top.regexPassword, "i").IsMatch(password)
end function


' Populates user data (email address and password) from related keyboard dialogs
sub Set_userData()
    userData = {
        email       : m.top.kbdialogEmail.text
        password    : m.top.kbdialogPassword.text
    }
    m.parentScene.dialog.close = true
    m.top.userData = userData
end sub


' onChange handler for "show" field
sub On_show()
    print "RokuAuthFlow :: On_show()"
    if GetParentScene() = invalid then
        return
    end if

    m.top.kbdialogEmail.focusButton = m.indexButtonGo
    m.top.kbdialogPassword.text = ""
    m.top.kbdialogPassword.focusButton = m.indexButtonPasswordShowHide
    m.parentScene.dialog = m.top.kbdialogEmail
end sub


' Handler for processing email address KeyboardDialog button selection
sub On_kbdialogEmail_buttonSelected()
    if GetParentScene() = invalid then
        return
    end if

    if m.top.kbdialogEmail.buttonSelected = m.indexButtonGo then
        if IsValidEmail(m.top.kbdialogEmail.text) then
            m.parentScene.dialog = m.top.kbdialogPassword
        else
            m.parentScene.dialog = m.top.dialogErrEmail
        end if

    else if m.top.kbdialogEmail.buttonSelected = m.indexButtonBack OR m.top.kbdialogEmail.buttonSelected < 0 then
        m.parentScene.dialog.close = true
        m.parentScene.dialog = invalid
        m.top.isAuthorized = false

    end if
end sub


' Handler for processing email address error Dialog button selection
sub On_dialogErrEmail_buttonSelected()
    if GetParentScene() = invalid then
        return
    end if
    m.parentScene.dialog = m.top.kbdialogEmail
end sub


' Handler for processing password KeyboardDialog button selection
sub On_kbdialogPassword_buttonSelected()
    if GetParentScene() = invalid then
        return
    end if

    if m.top.kbdialogPassword.buttonSelected = m.indexButtonPasswordGo then
        if IsValidPassword(m.top.kbdialogPassword.text) then
            if m.top.dialogTermsOfUse.message.Len() = 0 then
                Set_userData()
            else
                m.top.dialogTermsOfUse.focusButton = m.indexButtonGo
                m.parentScene.dialog = m.top.dialogTermsOfUse
            end if
        else
            m.parentScene.dialog = m.top.dialogErrPassword
        end if

    else if m.top.kbdialogPassword.buttonSelected = m.indexButtonPasswordBack OR m.top.kbdialogPassword.buttonSelected < 0 then
        m.parentScene.dialog = m.top.kbdialogEmail

    else if m.top.kbdialogPassword.buttonSelected = m.indexButtonPasswordShowHide then
        m.parentScene.dialog.keyboard.textEditBox.secureMode = not m.parentScene.dialog.keyboard.textEditBox.secureMode

    end if
end sub


' Handler for processing password error Dialog button selection
sub On_dialogErrPassword_buttonSelected()
    if GetParentScene() = invalid then
        return
    end if
    m.parentScene.dialog = m.top.kbdialogPassword
end sub


' Handler for processing Terms-Of-Use Dialog button selection
sub On_dialogTermsOfUse_buttonSelected()
    if GetParentScene() = invalid then
        return
    end if

    if m.top.dialogTermsOfUse.buttonSelected = m.indexButtonGo then
        Set_userData()
    else if m.top.dialogTermsOfUse.buttonSelected < 0
        m.parentScene.dialog = m.top.kbdialogPassword
    else
        m.parentScene.dialog = m.top.kbdialogEmail
    end if
end sub


' Handler for processing user data (email address, password) collected from related dialogs
sub On_userData()
    m.parentScene.dialog = m.top.pdialogAuth
end sub


' onChange handler for "isAPISuccess" field
sub On_isAPISuccess()
    if GetParentScene() = invalid then
        return
    end if
    if m.top.isAPISuccess then
        m.top.isAuthorized = true
    else
        m.parentScene.dialog = m.top.dialogAuthFailed
    end if
end sub


' Handler for processing auth failure Dialog button selection
sub On_dialogAuthFailed_buttonSelected()
    if GetParentScene() = invalid then
        return
    end if
    if m.top.dialogAuthFailed.buttonSelected = m.indexButtonGo then
        m.parentScene.dialog = m.top.kbdialogEmail
    else
        m.parentScene.dialog.close = true
        m.top.isAuthorized = false
    end if
end sub
