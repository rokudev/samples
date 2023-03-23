Copyright 2016 Roku Corp.  All Rights Reserved.



Sample for RokuSignUp component usage.





1. Description



This is a sample channel demonstrating usage of RokuSignUp component that encapsulates 

standard Roku Billing Sign Up Flow. 



Channel uses mock API to simulate interaction with real channel-specific API on user login/signup.

It doesn't use any real APIs and doesn't store any data in Roku device persistent memory.



Channel itself starts from auth selection screen which allows to select either login or signup flow.

If user subscribes successfully via Roku Billing or has previously purchased products (this option need 

publishing the channel under Roku dev account and creating any consumable subscription products for it),

a colored poster is shown. If user not subscribed then dark poster is shown.





2. Project files hierarchy



components/

    RokuSignUp/

        BackDialog.xml ]

        BackDialog.brs ]- overridden Dialog component node which handles "back"

            remote key press as fake dialog button selection.

        

        BackKeyboardDialog.xml ]

        BackKeyboardDialog.brs ]- overridden KeyboardDialog component node

            which handles "back" remote key press as fake dialog button selection.

        

        RokuAuthFlow.xml ]

        RokuAuthFlow.brs ]- node which implements the standard flow for authorization (login/signup)

            using channel-specific API.

        

        RokuAuthScreen.xml ]

        RokuAuthScreen.brs ]- node which implements typical authorization selection screen having

            background poster and 2 buttons for selecting login or signup flow when channel uses

            specific API for user login/signup.

        

        RokuSignUp.xml ]

        RokuSignUp.brs ]- main top-level component that encapsulates standard Roku Billing Sign Up Flow.

        

        utils.brs - additional utility function module.

    

    HomeScene.xml ]

    HomeScene.brs ]- main scene containing RokuSignUp component.



/docs - this folder contains components documentation and current readme.txt file.

/images - image assets

/source

    API.brs - module implementing channel-specific API (for this sample this is only a mockup).

    main.brs - main launching module.





3. RokuSignUp component usage inside channel app



To use RokuSignUp component in the channel app you need to copy /RokuSignUp folder under your project's

/components folder as in current sample, add RokuSignUp component to your channel markup scene and pre-setup

the component (please see the sample in RokuSignUp component's documentation). Let the component is stored 

in some m.rokuSignUp variable:



    m.rokuSignUp = myScene.CreateChild("RokuSignUp")



The entry point for RokuSignUp flow is RokuSignUp "show" interface, the exit point is "isSubscribed" interface

(please see RokuSignUp node documentation for details). Before using these interface you need to set the handler

for "isSubscribed" field:

    

    m.rokuSignUp.ObserveField("isSubscribed", "On_rokuSignUp_isSubscribed")



Here in the sample above "On_rokuSignUp_isSubscribed" is a handler (trigger) function which should handle

the result of Roku Sign Up Flow (see below).



At the point you need Roku Sign Up Flow (e.g. selecting restricted contents etc.) you need to perform



    m.rokuSignUp.show = true

    

which starts the flow. When the Roku Sign Up Flow is finished, the control passes to isSubscribed field's handler

(On_rokuSignUp_isSubscribed function in our case). "isSubscribed" field has Boolean type. True value means

Sign Up Flow was successful (i.e. user subscribed) while False means that some issues occured with signing up

the user (i.e. user remained unsubscribed). Based on this, handler function may e.g. allow or disallow watching 

restricted content etc.





    



