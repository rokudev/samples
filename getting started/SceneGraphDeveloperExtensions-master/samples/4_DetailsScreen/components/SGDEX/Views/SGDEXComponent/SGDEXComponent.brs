' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    ?"SGDEX: create new view: "m.top.subtype()
    m.themeDebug = false
    m.top.overhang = m.top.FindNode("overhang")
    m.top.getScene().ObserveField("theme", "SGDEX_GlobalThemeObserver")
    m.top.getScene().ObserveField("updateTheme", "SGDEX_GlobalUpdateThemeObserver")
    
    m.backgroundRectangle = m.top.FindNode("backgroundRectangle")
    m.backgroundImage = m.top.FindNode("backgroundImage")
    
    
    SGDEX_InternalBuildAndSetTheme(m.top.theme, m.top.getScene().actualThemeParameters)
end sub

'this function will return view key to retrieve it from global theme map
function SGDEX_GetViewType() as String
    return "global"
end function

sub SGDEX_SetTheme(theme as Object)
    ? "INFO: implement SGDEX_SetTheme(theme as AA) to set theme to your view"
end sub

sub SGDEX_ViewUpdateThemeObserver(event as Object)
    if m.themeDebug then ? "SGDEX_ViewUpdateThemeObserver"
    theme = {}
    
    data = event.GetData()
    if m.themeDebug then ? "data="event.GetData()
    theme.Append(data)
    SGDEX_InternalSetTheme(theme, true)
end sub

sub SGDEX_GlobalUpdateThemeObserver(event as Object)
    if m.themeDebug then ? "SGDEX_GlobalUpdateThemeObserver"
    newTheme = event.GetData()
    newSceneTheme = {}
    globalTheme = m.top.getScene().actualThemeParameters
    if globalTheme <> invalid then
        newSceneTheme.append(globalTheme)
        for each key in newSceneTheme
            themeSet = newSceneTheme[key]
            newThemeSet = newTheme[key]
            if GetInterface(themeSet, "ifAssociativeArray") <> invalid and GetInterface(newThemeSet, "ifAssociativeArray") <> invalid then
                themeSet.append(newThemeSet)
            end if
        end for

    end if
    for each key in newTheme
        if newSceneTheme[key] = invalid then newSceneTheme[key] = newTheme[key]
    end for

    m.top.getScene().actualThemeParameters = newSceneTheme
    SGDEX_InternalBuildAndSetTheme(invalid, newTheme)
end sub

'Functions for setting initial theme
sub SGDEX_GlobalThemeObserver(event as Object)
    if m.themeDebug then ? "SGDEX_GlobalThemeObserver"
    newTheme = event.GetData()
    m.top.getScene().actualThemeParameters = newTheme
    SGDEX_InternalBuildAndSetTheme(m.top.theme, newTheme)
end sub

sub SGDEX_ViewThemeObserver(event as Object)
    theme = {}
    if m.top.getScene().theme <> invalid then theme.Append(m.top.getScene().theme)
    theme.Append(event.GetData())
    SGDEX_InternalBuildAndSetTheme(m.top.theme, theme)
end sub


'Function for building theme params for view from global and view specific field
sub SGDEX_InternalBuildAndSetTheme(viewTheme as Object, newTheme as Object, isUpdate = false as Boolean)
    if GetInterface(newTheme, "ifAssociativeArray") <> invalid then
        viewKey = SGDEX_GetViewType()
        
        theme = {}
        if GetInterface(newTheme["global"], "ifAssociativeArray") <> invalid then theme.Append(newTheme["global"])
        if GetInterface(newTheme[viewKey], "ifAssociativeArray") <> invalid then theme.Append(newTheme[viewKey])
        if GetInterface(viewTheme, "ifAssociativeArray") <> invalid then theme.Append(viewTheme)
        SGDEX_InternalSetTheme(theme, isUpdate)
    end if
end sub

'function for setting all required theme attributes to all nodes
sub SGDEX_InternalSetTheme(theme as Object, isUpdate = false as Boolean)
    if m.LastThemeAttributes <> invalid and isUpdate then
        m.LastThemeAttributes.Append(theme)
    else
        m.LastThemeAttributes = theme
    end if
    SGDEX_SetOverhangTheme(theme)
    SGDEX_SetBackgroundTheme(theme)
    
    SGDEX_SetTheme(theme)
end sub

sub SGDEX_SetOverhangTheme(theme)
'    overhang = m.top.overhang
    overhang = m.top.overhang
    if overhang <> invalid then
        SGDEX_setThemeFieldstoNode(m.top, {
            TextColor: {
                overhang: [
                    "titleColor"
                    "clockColor"
                    "optionsColor"
                    "optionsDimColor"
                    "optionsIconColor"
                    "optionsIconDimColor"
                ]
            }
        }, theme)
        
        overhangThemeAttributes = {
            'Main attribute
            Overhangtitle:                   "title"
            OverhangshowClock:               "showClock"
            OverhangshowOptions:             "showOptions"
            OverhangoptionsAvailable:        "optionsAvailable"
            Overhangvisible:                 "visible"
            OverhangtitleColor:              "titleColor"
            OverhangLogoUri:                 "logoUri"
            OverhangbackgroundUri:           "backgroundUri"
            OverhangoptionsText:             "optionsText"
            Overhangheight:                  "height"
            OverhangBackgroundColor:         "color"
                                                                                         
            'Additional attributes, no need to document these
            OverhangclockColor:              "clockColor"
            OverhangclockText:               "clockText"
            OverhangleftDividerUri:          "leftDividerUri"
            OverhangleftDividerVertOffset:   "leftDividerVertOffset"
            OverhanglogoBaselineOffset:      "logoBaselineOffset"
            OverhangOptionsColor:            "optionsColor"
            OverhangOptionsDimColor:         "optionsDimColor"
            OverhangOptionsIconColor:        "optionsIconColor"
            OverhangOptionsIconDimColor:     "optionsIconDimColor"
            OverhangOptionsMaxWidth:         "optionsMaxWidth"
            OverhangrightDividerUri:         "rightDividerUri"
            OverhangrightDividerVertOffset:  "rightDividerVertOffset"
            OverhangrightLogoBaselineOffset: "rightLogoBaselineOffset"
            OverhangrightLogoUri:            "rightLogoUri"
            OverhangshowRightLogo:           "showRightLogo"
            Overhangtranslation:             "translation"
        }
        
        for each key in theme
            if overhangThemeAttributes[key] <> invalid then
                field = overhangThemeAttributes[key]
                value = theme[key]
                SGDEX_SetThemeAttribute(overhang, field, value, "")
            end if
        end for
    end if
end sub

sub SGDEX_SetBackgroundTheme(theme as Object)
    isUriBackground = GetInterface(theme.backgroundImageURI, "ifString") <> invalid

    if isUriBackground then
        ' don't use backgroundColor for blending color as it's used for other Views 
        ' so developers don't want it to be applied to this View
        colorTheme = { backgroundImageURI: { backgroundImage: "uri" } }
    else
        colorTheme = { backgroundColor: { backgroundRectangle: "color" } }
    end if
    
    m.backgroundRectangle.visible = not isUriBackground
    m.backgroundImage.visible = isUriBackground
    
   
    SGDEX_setThemeFieldstoNode(m, colorTheme, theme)
end sub

'This function is used to set theme attributes to nodes
'It support advanced setup of theming config 
'Example


'map = {
'    >>> 'Theme attribute name
'    genericColor: {
'        'for each attribute in video node set "genericColor" value   
'        video: [
'            "bufferingTextColor",
'            "retrievingTextColor"

'           >>> for internal fields of video also set this value
'            {
'                trickPlayBar: [
'                    "textColor"
'                    "thumbBlendColor"
'                ]
'            }
'        ]
'    
'    }
'
'
'    bufferingTextColor:             { video: "bufferingTextColor" }
'
'    textColor:                      { video: { trickPlayBar: "textColor" } }
'    currentTimeMarkerBlendColor:    "currentTimeMarkerBlendColor"
'    
'}


'@param node - root AA or node for searching sub nodes
'@param map - developer defined config for theme
'@param theme - theme that should be set

sub SGDEX_setThemeFieldstoNode(node, map, theme)
    for each field in map
        attribute = map[field]
        if theme.DoesExist(field) then
            value = theme[field]
            if GetInterface(attribute, "ifAssociativeArray") <> invalid then
                SGDEX_SetValueToAllNodes(node, attribute, value)
            else
                SGDEX_SetThemeAttribute(node, field, value, "")
            end if
        end if
    end for
end sub

sub SGDEX_SetValueToAllNodes(node, attributes, value)
    if node <> invalid then
        for each key in attributes
            properField = attributes[key]
            if GetInterface(properField, "ifAssociativeArray") <> invalid then
                SGDEX_SetValueToAllNodes(node[key], properField, value)
            else if GetInterface(properField, "ifArray") <> invalid
                for each arrayField in properField
                    if GetInterface(arrayField, "ifAssociativeArray") <> invalid then
                        SGDEX_SetValueToAllNodes(node[key], arrayField, value)
                    else if node[key] <> invalid
                        SGDEX_SetThemeAttribute(node[key], arrayField, value, "")
                    end if
                end for
            else if node[key] <> invalid
                SGDEX_SetThemeAttribute(node[key], properField, value, "")
            end if
        end for
    end if
end sub

sub SGDEX_SetThemeAttribute(node, field as String, value as Object, defaultValue = invalid)
    properValue = defaultValue
    if value <> invalid then
        properValue = value
    end if
    
    if m.themeDebug then ? "SGDEX_SetThemeAttribute, field="field" , value=["properValue"]"
    node[field] = properValue
end sub
