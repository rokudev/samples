' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    ' init content manager utils field
    m.itemToSection = []
    m.firstItemInSection = [0]
    m.ContentIsLoaded = false
    InitContentGetterValues()
    'Don' t set this value to big as background loading on low end devices will timeout
    m.MAX_RADIUS = 45

    m.Handler_ConfigField = "HandlerConfigCategoryList"
    m.ItemKeyField = "CM_CL_Item_Index"
    ' is used by utils to populate id of loading data
    m.SectionKeyField = "CM_row_ID_Index"

    ' setup nodes
    m.categoryList = m.top.FindNode("categoryList")
    m.itemsList = m.top.FindNode("itemsList")
    m.itemsList.focusBitmapUri = "pkg:/components/SGDEX/Images/focus.9.png"

    m.spinner = m.top.FindNode("spinner")
    m.spinner.uri = "pkg:/components/SGDEX/Images/loader.png"
    ' show loading indicator
    ShowBusySpinner(true)

    m.categoryListGainFocus = false
    m.debug = false

    m.itemsList.AddField("itemTitleColor", "color", true)
    m.itemsList.AddField("itemDescriptionColor", "color", true)

    m.top.ObserveField("wasShown", "OnWasShown")
    m.top.ObserveField("content", "OnContentChange")

    m.top.ObserveField("jumpToItem", "OnjumpToItem")
    m.top.ObserveField("animateToItem", "OnanimateToItem")
    m.top.ObserveField("jumpToCategory", "OnjumpToSection")
    m.top.ObserveField("animateToCategory", "OnanimateToSection")
    m.top.ObserveField("jumpToItemInCategory", "OnjumpToItemInSection")
    m.top.ObserveField("animateToItemInCategory", "OnanimateToItemInSection")

    m.categoryList.ObserveField("itemFocused", "OnCategoryListItemFocused")

    m.categoryList.ObserveField("translation", "OnCategoryListTranslationChange")
    m.itemsList.ObserveField("translation", "OnCategoryListTranslationChange")

    m.itemsList.ObserveField("itemFocused", "OnItemsListItemFocused")
    m.itemsList.ObserveField("currFocusSection", "OnCurrFocusSectionChange")
    m.itemsList.ObserveField("content", "OnItemsListContentSet")

    m.itemsList.ObserveField("itemSelected", "OnItemsListItemSelected")
    m.itemsList.ObserveField("isFFPressed", "OnItemsListItemFFRewPressed")
    m.itemsList.ObserveField("isRewPressed", "OnItemsListItemFFRewPressed")

    m.top.ObserveField("posterShape", "OnPosterShapeChanged")

    if m.LastThemeAttributes <> invalid then
        SGDEX_SetTheme(m.LastThemeAttributes)
    end if
end sub

sub OnWasShown()
    if m.itemsList.content <> invalid then m.itemsList.SetFocus(true)
end sub

sub OnContentChange()
    if m.top.content <> invalid
        if not m.top.content.IsSameNode(m.itemsList.content) and not m.top.content.IsSameNode(m.content) then
            m.content = m.top.content
            PopulateLoadingFlags(m.top.content)
            if m.top.content[m.Handler_ConfigField] <> invalid and m.top.content.GetChildCount() = 0
                config = m.top.content[m.Handler_ConfigField]
                callback = {
                    config: config
                    content: m.top.content
                    onReceive: sub(data)
                        OnRootContentLoaded()
                    end sub

                    onError: sub(data)
                        config = m.config
                        gthis = GetGlobalAA()
                        if m.content[gthis.Handler_ConfigField] <> invalid then
                            config = m.content[gthis.Handler_ConfigField]
                        end if

                        GetContentData(m, config, m.content)
                    end sub
                }
                GetContentData(callback, config, m.top.content)
            else if m.top.content.GetChildCount() > 0
                OnRootContentLoaded()
            end if
        end if
    end if
end sub

' number of items that have to be populated in order to show this View
function GetVisibleItems()
    return 7
end function

sub ShowBusySpinner(shouldShow)
    if shouldShow then
        if not m.spinner.visible then
            m.spinner.visible = true
            m.spinner.control = "start"
        end if
    else
        m.spinner.visible = false
        m.spinner.control = "stop"
    end if
end sub

function GetNumSectionsToLoad()
    return 3
end function

sub setContentObservers()
    ' when number of children changes add extra observers
    fieldsToObserve = [
        "HDGRIDPOSTERURL"
        "SDGRIDPOSTERURL"
        "HDLISTITEMICONURL"
        "title"
    ]

    for each category in m.top.content.GetChildren(- 1, 0)
        for each field in fieldsToObserve
            category.UnObserveFieldScoped(field)
            ' this requires only updating of visual elements
            category.ObserveFieldScoped(field, "UpdateCategoriesVisualFields")
        end for
    end for
end sub

' updates category (left panel) visual field
sub UpdateCategoriesVisualFields(event as Object)
    category = event.GetRoSGNode()
    value = event.GetData()
    field = event.GetField()

    ' we have to find coresponding item in category list
    index = 0
    found = false
    for each child in m.itemsList.content.GetChildren(- 1, 0)
        if child.IsSameNode(category) then
            found = true
            exit for
        end if
        index++
    end for
    if found then
        child = m.categoryList.content.GetChild(index)
        if child <> invalid then
            child.Setfield(field, value)
        end if
    end if
end sub

function IsValidContent(content as Object) as Boolean
    if content <> invalid
        if content.GetChildCount() > 0
            if content.GetChild(0).GetChildCount() > 0
                return true
            else
                if m.debug then ? "SGDEX: Category List view received content with empty category"
                return false
            end if
        else
            if m.debug then ? "SGDEX: Category List view received empty content"
            return false
        end if
    else
        if m.debug then ? "SGDEX: Category List view received invalid content"
        return false
    end if
end function

sub ResetAllmaps()
    m.ContentIsLoaded = true
    InitSectionMaps(m.top.content)
    SetupLists(m.top.content)
    m.IdleUpdateTimer.control = "start"
end sub

sub SetupLists(content as Object)
    categoryContent = content.Clone(true)

    for each item in categoryContent.GetChildren( - 1, 0)
        item.contentType = "movie" ' remove section category, so list is rendered as simple list
    end for

    focusedIndex = 0
    isCategoryFocused = m.categoryList.HasFocus()
    if iscategoryFocused
        focusedIndex = m.categoryList.itemfocused
    else
        focusedIndex = m.itemsList.itemfocused
    end if

    m.categoryList.content = categoryContent
    m.itemsList.content = content

    'TODO this doesn' t fix focus when user holds down button on item list
    ' pagination is triggered by focused section field but there is no exact item to restore focus
    if isCategoryFocused then
        m.categoryList.jumpToItem = focusedIndex
    else
        m.itemsList.jumpToItem = focusedIndex
    end if

    ' check whether developer pass correct initial category index
    if m.top.initialPosition[0] < m.firstItemInSection.Count() - 1 and m.top.initialPosition[0] >= 0
        ' set focus on proper category and item
        m.categoryList.jumpToItem = m.top.initialPosition[0]
        m.itemsList.jumpToItem = m.firstItemInSection[m.top.initialPosition[0]] + m.top.initialPosition[1]
        m.top.initialPosition = [- 1, - 1]
    end if
    setContentObservers()
end sub

sub InitSectionMaps(content as Object)
    m.itemToSection = [] ' absoluteItemIndex -> sectionIndex
    m.firstItemInSection = [0] ' index of 1st item in the section
    sectionCount = 0
    totalIndex = 0
    for each section in content.GetChildren(- 1, 0)
        itemsPerSection = section.GetChildCount()
        if itemsPerSection > 0
            for each child in section.GetChildren(- 1, 0)
                m.itemToSection.Push(sectionCount)
                populateItemIndex(child, totalIndex)
                totalIndex++
            end for
        else
            m.itemToSection.Push(sectionCount)
        end if
        m.firstItemInSection.Push(m.firstItemInSection.Peek() + itemsPerSection)
        sectionCount++
    end for

    m.firstItemInSection.Pop() ' remove last redundant item
end sub

sub OnCategoryListItemFocused(event as Object)
    m.IdleUpdateTimer.control = "stop"
    if m.categoryListGainFocus
        m.categoryListGainFocus = false
    else
        focusedCategory = event.GetData()
        focusedItem = m.firstItemInSection[focusedCategory]
        m.itemsList.jumpToItem = focusedItem
        ' we have to check if category is loaded
        LoadCategoryIfNeeded(focusedCategory)
        checkCategoryPagination(focusedCategory)

        LoadNonSerialPaginationForItem(focusedItem)
        LoadSerialPaginationForItem(focusedItem)
        ' jump to item doesn' t generate proper event
        fireItemFocusedEvent(m.firstItemInSection[focusedCategory])
    end if
    m.IdleUpdateTimer.control = "start"
end sub

sub OnItemsListItemFocused(event as Object)
    m.IdleUpdateTimer.control = "stop"
    focusedItem = event.GetData()
    categoryIndex = m.itemToSection[focusedItem]
    if categoryIndex = invalid then return
    if (categoryIndex - 1) = m.categoryList.jumpToItem
        m.categoryList.animateToItem = categoryIndex
    else if not m.categoryList.IsInFocusChain()
        m.categoryList.jumpToItem = categoryIndex
    end if

    for index = 0 to GetVisibleItems()
        newCategoryIndex = m.itemToSection[focusedItem + index]
        if newCategoryIndex <> invalid and categoryIndex <> newCategoryIndex
            LoadCategoryIfNeeded(newCategoryIndex)
            exit for
        end if
    end for
    ' check if pagination should be loaded
    checkCategoryPagination(categoryIndex)

    LoadNonSerialPaginationForItem(focusedItem)
    LoadSerialPaginationForItem(focusedItem)
    ' fire event that item was focused
    fireItemFocusedEvent(focusedItem)
    m.IdleUpdateTimer.control = "start"
end sub

' check if we need to load extra categories
sub checkCategoryPagination(categoryIndex)
    ' number of categories that should be checked before loading pagination
    LOAD_PAGINATION_BEFORE_CATEGORY_INDEX = 3
    if categoryIndex <> invalid and IsPaginationRow(m.top.content) and not IsRowAlreadyLoading(m.top.content) and m.top.content.GetChildCount() - categoryIndex <= LOAD_PAGINATION_BEFORE_CATEGORY_INDEX
        if not IsToManyPageFails( - 1, - 1)
            callback = {
                config: m.top.content[m.Handler_ConfigField]
                content: m.top.content

                onReceive: sub(data)
                    SetupLists(GetGlobalAA().top.content)
                    ClearPageFails( - 1, - 1)
                end sub

                onError: sub(data)
                    AddPageFail( - 1, - 1)
                    ' restore previous config
                    config = m.config
                    gthis = GetGlobalAA()
                    if m.content[gthis.Handler_ConfigField] <> invalid then
                        config = m.content[gthis.Handler_ConfigField]
                    end if

                    m.content[gthis.Handler_ConfigField] = config
                end sub
            }
            LoadContentForSection(m.top.content, {}, callback)
        else
            ?"too many fails"
        end if
    end if
end sub

sub OnCurrFocusSectionChange(event as Object)
    data = event.Getdata()
    categoryIndex = data \ 1

    if m.ContentIsLoaded and (m.prev_categoryIndex = invalid or m.prev_categoryIndex <> categoryIndex) then
        m.prev_categoryIndex = categoryIndex
        if (categoryIndex - 1) = m.categoryList.jumpToItem
            m.categoryList.animateToItem = categoryIndex
        else if m.itemsList.scrollingStatus
            m.categoryList.jumpToItem = categoryIndex
        end if

        if not m.categoryList.IsInFocusChain() then
            LoadCategoryIfNeeded(categoryIndex)
        end if

        ' TODO we need to check if this is needed
        ' calling pagination here causes issues with restoring content
        checkCategoryPagination(categoryIndex)
    end if
end sub

sub fireItemFocusedEvent(focusedItem)
    categoryIndex = m.itemToSection[focusedItem]

    m.top.focusedItem = focusedItem
    m.top.focusedCategory = categoryIndex
    m.top.focusedItemInCategory = focusedItem - m.firstItemInSection[categoryIndex]
end sub

sub OnItemsListContentSet(event as Object)
    if m.itemsList.content = invalid or not m.itemsList.content.IsSameNode(m.top.content) or ( not m.categoryList.HasFocus() and not m.itemsList.HasFocus()) then
        itemsContent = event.GetData()
        if itemsContent <> invalid then m.itemsList.SetFocus(true)
    end if
end sub

sub OnItemsListItemSelected(event as Object)
    itemSelected = event.GetData()
    sectionIndex = m.itemToSection[itemSelected]
    m.top.selectedItem = [sectionIndex, itemSelected - m.firstItemInSection[sectionIndex]]
end sub

sub OnItemsListItemFFRewPressed(event as Object)
    field = event.GetField()
    value = event.GetData()
    addToCategoryListIndex = {
        "isFFPressed": 1
        "isRewPressed": - 1
    }
    addIndex = addToCategoryListIndex[field]
    if addIndex <> invalid
        currentSection = m.itemToSection[m.itemsList.itemFocused]
        ' if we are moving back from not first item in section, we have to move to start of section first
        if m.firstItemInSection[currentSection] <> m.itemsList.itemFocused and addIndex < 0 then
            addIndex = 0
        end if
        categoryIndex = currentSection + addIndex
        if categoryIndex > m.categoryList.content.GetChildCount() - 1 then categoryIndex = 0
        if categoryIndex < 0 then categoryIndex = m.categoryList.content.GetChildCount() - 1
        m.categoryList.jumpToItem = categoryIndex
        m.itemsList.jumpToItem = m.firstItemInSection[categoryIndex]
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false

    if press
        if key = "left" and m.itemsList.HasFocus()
            m.categoryListGainFocus = true
            m.categoryList.SetFocus(true)
            handled = true
        else if key = "right" and m.categoryList.HasFocus()
            m.itemsList.SetFocus(true)
            handled = true
        end if
    end if

    return handled
end function

sub OnCategoryListTranslationChange(event as Object)
    data = event.GetData()
    node = event.GetRosgNode()

    ' We must to use this custom list panel to fix labelList position bug when we use custom focus ring
    subtype = node.Subtype()

    key = subtype + "DefaultTranslation"
    value = m[key]
    ' translation should be > 0 as when new panel is added it has - max int and after it has 0 translation
    if value = invalid and node.translation[0] > 0
        m[key] = node.translation
    else if value <> invalid and node.translation[1] <> value[1]
        node.translation = value
    end if
end sub

sub OnPosterShapeChanged()
    m.itemsList.Addfield("posterShape", "string", false)
    m.itemsList.posterShape = m.top.posterShape
end sub

sub OnJumpToItem(event as Object)
    value = event.GetData()
    m.itemsList.jumpToItem = value
end sub

sub OnAnimateToItem(event as Object)
    value = event.GetData()
    m.itemsList.animateToItem = value
end sub

sub OnJumpToSection(event as Object)
    value = event.GetData()
    m.itemsList.jumpToItem = m.firstItemInSection[value]
end sub

sub OnAnimateToSection(event as Object)
    value = event.GetData()
    m.itemsList.animateToItem = m.firstItemInSection[value]
end sub

sub OnJumpToItemInSection(event as Object)
    value = event.GetData()
    section = m.itemToSection[m.itemsList.itemFocused]
    m.itemsList.jumpToItem = m.firstItemInSection[section] + value
end sub

sub OnAnimateToItemInSection(event as Object)
    value = event.GetData()
    section = m.itemToSection[m.itemsList.itemFocused]
    m.itemsList.animateToItem = m.firstItemInSection[section] + value
end sub

sub populateItemIndex(child, index)
    if not child.HasField(m.ItemKeyField) then child.AddField(m.ItemKeyField, "int", false)
    child.CM_CL_Item_Index = index
end sub

sub populateSectionFields(section, index)
    if not section.HasField(m.SectionKeyField) then section.AddField(m.SectionKeyField, "int", false)
    section[m.SectionKeyField] = index
end sub

sub SGDEX_SetTheme(theme as Object)
    SGDEX_setThemeFieldstoNode(m, {
        TextColor: {
            categoryList: [
                "focusedColor"
                "color"
                "sectionDividerTextColor"
            ]

            itemsList: [
                "itemTitleColor"
                "itemDescriptionColor"
            ]
        }
        focusRingColor: {
            categoryList: [
                "focusBitmapBlendColor"
            ]
            itemsList: ["focusBitmapBlendColor"]
        }
    }, theme)

    themeAttributes = {
        categoryFocusedColor:    { categoryList: "focusedColor" }
        categoryUnFocusedColor:  { categoryList: "color" }
        itemTitleColor:          { itemsList: "itemTitleColor" }
        itemDescriptionColor:    { itemsList: "itemDescriptionColor" }

        categoryfocusRingColor:  { categoryList: "focusBitmapBlendColor" }
        itemsListfocusRingColor: { itemsList:    "focusBitmapBlendColor" }
    }
    SGDEX_setThemeFieldstoNode(m, themeAttributes, theme)
end sub

function SGDEX_GetViewType() as String
    return "categoryListView"
end function
