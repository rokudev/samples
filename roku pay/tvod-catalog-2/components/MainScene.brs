'********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

function init()
    #if includePPV
        menus = ["Base/Bundle", "Add-ons", "PPV"]
    #else
        menus = ["Base/Bundle", "Add-ons"]
    #endif

    configStr = ReadAsciiFile("pkg:/config-tvod.json")
    tvodAA = parseJson(configStr)
    menus.push("TVOD")

    ' create billing component node'
    billing = createObject("roSGNode", "Billing")

    ' Set product screen as the initial screen'
    m.productScreen = m.top.FindNode("productScreen")
    m.productScreen.billing = billing
    m.productScreen.tvodAA = tvodAA
    m.productScreen.menus = menus


end function

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        ? "Scene - Key pressed: " + key
    end if
    return handled
end function
