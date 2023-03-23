' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' Returns singleton object for handling channel-specific API calls.
' For this sample, this is just a mockup simulating actual API calls.
function API() as Object
    gThis = GetGlobalAA()
    if gThis.apiObj = invalid then
        gThis.apiObj = API__GetInstance()
    end if
    return gThis.apiObj
end function


' API object instance constructor
function API__GetInstance() as Object
    this = {}
    
    this.Login          = API__Login
    this.SignupAndLogin = API__SignupAndLogin
    this.GetTermsOfUse  = API__GetTermsOfUse
    
    return this
end function


' Login API mockup. Actual API call for user logging in should be implemented here.
' @param userData [Object] associative array: {email, password}
' @return [Boolean] login API result: True means user is successfully logged in. 
function API__Login(userData as Object) as Boolean
    result = true
    
    print "Logging in user:"
    print userData
    sleep(2000)
    
    return result
end function


' Signup API mockup. Actual API call for creating user account and logging in with it should be implemented here.
' @param userData associative array: {email, password}
' @return [Boolean] signup API result: True means user account is created and user is successfully logged in via channel API using this account
function API__SignupAndLogin(userData as Object) as Boolean
    result = true
    
    print "Signing up user and logging in:"
    print userData
    sleep(2000)
    
    return result
end function


' Mockup for API returning Terms Of Use text. Actual API call for getting Terms Of Use should be implemented here.
' Note: Terms Of Use should be returned as plain text without any HTML tags.
function API__GetTermsOfUse() as String
    result = ""
    result = result + "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt"
    result = result + " ut labore et dolore  magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"
    result = result + " ullamco  laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in"
    result = result + " reprehenderit in voluptate velit esse cillum dolore  eu fugiat nulla pariatur. Excepteur sint"
    result = result + " occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est"
    result = result + " laborum."
    result = result + Chr(10) + Chr(10) + result
    
    return result
end function