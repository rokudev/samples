'Library "v30/bslDefender.brs"
Function Main() as void
    screen = CreateObject("roListScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    
    m.localization = CreateObject("roLocalization")
    InitTheme()
    screen.SetHeader(tr("Welcome to The Channel Diner"))
    screen.SetBreadcrumbText(tr("Menu"), tr("Breakfast"))
    
    contentList = InitContentList()
    screen.SetContent(contentList)
    screen.show()
    
    while (true)
        msg = wait(0, port)
        if (type(msg) = "roListScreenEvent")
            if (msg.isListItemFocused())
                screen.SetBreadcrumbText(tr("Menu"), contentList[msg.GetIndex()].Title)            
            endif            
        endif
       
    end while
End Function

Function InitTheme() as void
    app = CreateObject("roAppManager")

    primaryText                 = "#FFFFFF"
    secondaryText               = "#707070"
    backgroundColor             = "#e0e0e0"
    
    logo = m.localization.GetLocalizedAsset("images", "channel_diner_logo.png")
    select_bkgnd = m.localization.GetLocalizedAsset("images", "select_bkgnd.png")
    slice = m.localization.GetLocalizedAsset("images", "Overhang_Slice_HD.png")
    theme = {
        BackgroundColor: backgroundColor
        OverhangSliceHD: slice
        OverhangSliceSD: slice
        OverhangLogoHD: logo
        OverhangLogoSD: logo
        OverhangOffsetSD_X: "25"
        OverhangOffsetSD_Y: "15"
        OverhangOffsetHD_X: "25"
        OverhangOffsetHD_Y: "15"
        BreadcrumbTextLeft: "#37491D"
        BreadcrumbTextRight: "#E1DFE0"
        BreadcrumbDelimiter: "#37491D"
        ListItemText: secondaryText
        ListItemHighlightText: primaryText
        ListScreenDescriptionText: secondaryText
        ListItemHighlightHD: select_bkgnd
        ListItemHighlightSD: select_bkgnd        
    }
    app.SetTheme( theme )
End Function

Function InitContentList() as object
    breakfast_small = m.localization.GetLocalizedAsset("images", "breakfast_small.png")
    breakfast_large = m.localization.GetLocalizedAsset("images", "breakfast_large.png")
    lunch_small = m.localization.GetLocalizedAsset("images", "lunch_small.png")
    lunch_large = m.localization.GetLocalizedAsset("images", "lunch_large.png")
    dinner_small = m.localization.GetLocalizedAsset("images", "dinner_small.png")
    dinner_large = m.localization.GetLocalizedAsset("images", "dinner_large.png")
    dessert_small = m.localization.GetLocalizedAsset("images", "dessert_small.png")
    dessert_large = m.localization.GetLocalizedAsset("images", "dessert_large.png")
    about_small = m.localization.GetLocalizedAsset("images", "about_small.png")
    about_large = m.localization.GetLocalizedAsset("images", "about_large.png")
      
    contentList = [
        {
            Title: tr("Breakfast")
            ID: "1"
            SDSmallIconUrl: breakfast_small
            HDSmallIconUrl: breakfast_small
            HDBackgroundImageUrl: breakfast_large
            SDBackgroundImageUrl: breakfast_large            
            ShortDescriptionLine1: tr("Breakfast Menu")
            ShortDescriptionLine2: tr("Select from our award winning offerings")
        },
        {
            Title: tr("Lunch")
            ID: "2"
            SDSmallIconUrl: lunch_small
            HDSmallIconUrl: lunch_small
            HDBackgroundImageUrl: lunch_large
            SDBackgroundImageUrl: lunch_large            
            ShortDescriptionLine1: tr("Lunch Menu")
            ShortDescriptionLine2: tr("Eating again already?")            
        },
        {
            Title: tr("Dinner")
            ID: "3"
            SDSmallIconUrl: dinner_small
            HDSmallIconUrl: dinner_small
            HDBackgroundImageUrl: dinner_large
            SDBackgroundImageUrl: dinner_large            
            ShortDescriptionLine1: tr("Dinner Menu")
            ShortDescriptionLine2: tr("Chicken or Fish?")            
        },
        {
            Title: tr("Dessert")
            ID: "4"
            SDSmallIconUrl: dessert_small
            HDSmallIconUrl: dessert_small
            HDBackgroundImageUrl: dessert_large
            SDBackgroundImageUrl: dessert_large            
            ShortDescriptionLine1: tr("Dessert Menu")
            ShortDescriptionLine2: tr("Something for your sweet tooth")            
        }
        {
            Title: tr("Contact")
            ID: "5"
            SDSmallIconUrl: about_small
            HDSmallIconUrl: about_small
            HDBackgroundImageUrl: about_large
            SDBackgroundImageUrl: about_large            
            ShortDescriptionLine1: tr("The Channel Diner")
            ShortDescriptionLine2: tr("Phone: 1-(111)-111-1111")            
        }
    ]
    return contentList
End Function