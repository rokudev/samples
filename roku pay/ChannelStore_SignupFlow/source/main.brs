' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' Home scene initialization, interaction between RokuSignUp component and API mockup in the Main thread
sub RunUserInterface()
    screen = CreateObject("roSGScreen")
    scene = screen.CreateScene("HomeScene")

    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.Show()
    
    rokuSignUp = scene.findNode("rokuSignUp")
    rokuSignUp.textTermsOfUse = API().GetTermsOfUse()
    rokuSignUp.ObserveField("loginUserData", port)
    rokuSignUp.ObserveField("signupUserData", port)


    while true
        msg = wait(500, port)
        msgType = type(msg)
        
        if msgType = "roSGNodeEvent" then
            nodeID = msg.GetNode()
            field = msg.GetField()
            
            if nodeID = rokuSignUp.id then
                fieldValue = rokuSignUp.getField(field)
                
                if field = "loginUserData" then
                    ' got user data for login, call login API and pass result to RokuSignUp component
                    rokuSignUp.isLoginAPISuccess = API().Login(fieldValue)
                    
                else if field = "signupUserData" then
                    ' got user data for signup, call signup API and pass result to RokuSignUp component
                    rokuSignUp.isSignupAPISuccess = API().SignupAndLogin(fieldValue)
                    
                end if
            end if
        end if
    end while
    
    screen.Close()
end sub
