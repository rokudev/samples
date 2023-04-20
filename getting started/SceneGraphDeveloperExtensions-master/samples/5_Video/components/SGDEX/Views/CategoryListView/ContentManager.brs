' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub OnRootContentLoaded()
    canSetContent = true

    content = m.top.content
    content.isLoaded = true
    numItemsToLoad = GetVisibleItems()
    numSectionsToLoad = GetNumSectionsToLoad()

    alreadyVisibleItems = 0

    canSetContent = true
    sectionIndex = 0
    for each section in m.top.content.GetChildren( - 1, 0)
        PopulateLoadingFlags(section)
        populateSectionFields(section, sectionIndex)
        index = 0
        if section.GetChildCount() > 0 then
            alreadyVisibleItems += section.GetChildCount()
            section.isLoaded = true
            section.isLoading = false
            section.isFailed = false
            if CheckIfLazyRow(section) then
                ' TODO load items near this section
                LoadPaginationForSection(section, sectionIndex)
            end if
        else
            if section[m.Handler_ConfigField] <> invalid then
                ' row needs to be loaded
                LoadContentForSection(section, { IsInitialLoading: true })

                if alreadyVisibleItems < numItemsToLoad then
                    'we don' t have content to show yet
                    canSetContent = false
                end if
                if numSectionsToLoad <= 0 then
                    ' we are loading start amount of sections
                    exit for
                end if
                numSectionsToLoad--
            end if
        end if
        sectionIndex++
    end for

    if canSetContent then
        ' if we have spinner visible and enough rows to show we can hide the spinner
        if canSetContent then
            ShowBusySpinner(false)
            ResetAllmaps()
        end if
    end if
end sub

sub LoadContentForSection(section, params = {}, callback = invalid as Object)
    IsInitialLoading = false
    aditionalParams = {}
    shouldDeleteHandlerConfig = true
    itemIndex = - 2
    if GetInterface(params, "ifAssociativeArray") <> invalid then
        if params.IsInitialLoading <> invalid then
            IsInitialLoading = params.IsInitialLoading
        end if
        if params.shouldDeleteHandlerConfig <> invalid then
            shouldDeleteHandlerConfig = params.shouldDeleteHandlerConfig
        end if
        if params.aditionalParams <> invalid then
            aditionalParams = params.aditionalParams
        end if
        if params.itemIndex <> invalid then
            itemIndex = params.itemIndex
        end if
    end if

    simpleLoadFunction = sub(data, isSuccess)
        if GetGlobalAA().debug then ? "received section content="m.section.title
        m.section.isLoading = false
        m.section.isLoaded = isSuccess
        InitSectionMaps(GetGlobalAA().top.content)
        if m.callback <> invalid
            if isSuccess or m.callback.onError = invalid
                if m.callback.onReceive <> invalid then m.callback.OnReceive(data)
            else if m.callback.onError <> invalid then
                m.callback.OnError(data)
            end if
            ' if no extra callback was passed and we failed then we have to restore config
        else if not isSuccess then
            Handler_ConfigField = GetGlobalAA().Handler_ConfigField

            if m.section[Handler_ConfigField] = invalid then
                m.section[Handler_ConfigField] = m.config
            end if
        end if
    end sub

    if IsInitialLoading then
        functionToUse = sub(data, isSuccess)
            content = GetGlobalAA().top.content
            numItemsToLoad = GetVisibleItems()

            sections = content.GetChildren( - 1, 0)
            sectionsLeft = sections.Count()
            canShowContent = false
            for each section in sections
                if section.GetChildCount() > 0 then
                    numItemsToLoad -= section.GetChildCount()
                else if numItemsToLoad >= 0 then
                    if not IsRowAlreadyLoading(section) then
                        exit for
                    end if
                else
                    canShowContent = true
                end if
                sectionsLeft--
            end for

            if numItemsToLoad <= 0 or canShowContent or GetGlobalAA().runningQueue.IsEmpty()
                ShowBusySpinner(false)
                ResetAllmaps()
            end if
            m.SimpleLoadFunction(data, isSuccess)
        end sub
    else
        functionToUse = simpleLoadFunction
    end if

    rowIndex = invalid
    config = section[m.Handler_ConfigField]

    callback = {
        ' this will be used for sorting
        itemIndex: itemIndex
        ' extra callback if needed
        callback: callback
        ' current loading section
        section: section
        ' simple load function that executes basic functionality
        simpleLoadFunction: simpleLoadFunction
        ' config that is used to retrieve content
        config: config

        functionToUse: functionToUse
        onReceive: sub(data)
            m.FunctionToUse(data, true)
        end sub
        onError: sub(data)
            m.FunctionToUse(data, false)
        end sub
    }

    ' TODO handler is deleted, need to add way not to delete it
    if shouldDeleteHandlerConfig then section[m.Handler_ConfigField] = invalid
    QueueGetContentData(callback, config, section, aditionalParams, true)

    section.isLoaded = false
    section.isLoading = true
    section.isFailed = false
end sub

sub LoadCategoryIfNeeded(categoryIndex as Integer)
    lookAhead = 3
    content = m.top.content
    for index = 0 to lookAhead
        for each multiplier in [1, - 1]
            newIndex = categoryIndex + (index * multiplier)
            if newIndex < 0 then newIndex = content.GetChildCount() - 1 - Abs(newIndex)
            if newIndex >= content.GetChildCount() then newIndex = Abs(content.GetChildCount() - newIndex)
            category = content.GetChild(newIndex)
            if category <> invalid then
                ' check if is already loading
                if not IsRowAlreadyLoading(category) then
                    if category.GetChildCount() > 0 then
                        ' check if pagination is needed here
                    else if category[m.Handler_ConfigField] <> invalid
                        LoadContentForSection(category)
                    end if
                end if
            end if
        end for
    end for
end sub

' Sort items in queue, so they are loaded properly related to focused item
sub doPrioritySort()
    if m.itemsList.HasFocus() then
        focusedIndex = m.itemsList.itemFocused
        focusedSection = m.itemToSection[focusedIndex]
    else
        focusedSection = m.categoryList.itemFocused
        focusedIndex = m.firstItemInSection[focusedSection]
    end if
    itemPriority = 10
    rowPriority = 9
    if focusedIndex <> invalid and focusedSection <> invalid
        for each taskObject in m.waitingQueue
            ' set new priority
            rowId = taskObject.id[0]
            itemId = taskObject.id[1]
'            ?"rowId = "rowId", itemId = "itemId
            if itemId >= 0 then
                ' we are loading for item
                diff = Abs(focusedIndex - itemId)
                taskObject.priority = diff + diff * itemPriority
            else if rowId >= 0 then
                diff = Abs(focusedSection - rowId)
                taskObject.priority = diff + diff * rowPriority
            else
                taskObject.priority = 1
            end if
        end for
        m.waitingQueue.SortBy("priority", "r")
    end if
end sub

sub LoadPaginationForSection(section, sectionIndex as Integer, itemIndex = 0 as Integer)
'    LoadContentForSection(section)

    child = section.GetChild(itemIndex)
    pageNum = getPageNum(child)
    config = section[m.Handler_ConfigField]

    if pageNum >= 0 and config <> invalid and not IsToManyPageFails(sectionIndex, pageNum) then
        AddPaginationForSectionToQueue(section, child, pageNum, config)
    end if
end sub

sub LoadNonSerialPaginationForItem(itemIndex)
    TESTING_VISIBLE_ITEMS = 0

    ' get this item section and load content for it
    newCategoryIndex = m.itemToSection[itemIndex]
    section = m.itemsList.content.GetChild(newCategoryIndex)

    index = itemIndex - m.firstItemInSection[newCategoryIndex]
    LoadPaginationForSection(section, newCategoryIndex, index)

    lookAheadNumberMap = {
        "1": GetVisibleItems() + TESTING_VISIBLE_ITEMS
        "-1": GetVisibleItems() + TESTING_VISIBLE_ITEMS
    }
    totalCount = section.GetChildCount()
    content = m.itemsList.content

    sections = content.GetChildren( - 1, 0)
    ' check both left and right sides
    for each multiplier in [1, - 1]
        lookAheadNumber = lookAheadNumberMap[multiplier.Tostr()]
        ' starting from one as multiply by 0 will load for current item
        for index = 1 to lookAheadNumber
            itemIndexToCheck = itemIndex + (index * multiplier)
            ' check last items too
            if itemIndexToCheck < 0 then
'                itemIndexToCheck = totalCount - Abs(itemIndexToCheck)
                ' we need to look for previous section
                ' TODO add proper logic
                itemIndexToCheck = - 1
            end if
            newCategoryIndex = m.itemToSection[itemIndexToCheck]

            if newCategoryIndex <> invalid then
                section = sections[newCategoryIndex]
                if CheckIfLazyRow(section)
                    config = section[m.Handler_ConfigField]

                    childIndex = itemIndexToCheck - m.firstItemInSection[newCategoryIndex]
                    child = section.GetChild(childIndex)
                    pageNum = getPageNum(child)

                    if pageNum >= 0 and config <> invalid and not IsToManyPageFails(newCategoryIndex, pageNum) then
                        AddPaginationForSectionToQueue(section, child, pageNum, config)
                    end if
                end if
            end if
        end for
    end for
end sub

function AddPaginationForSectionToQueue(section as Object, child as Object, pageNum as Integer, config as Object, shouldDeleteHandlerConfig = false as Boolean)
    map = m.ContentManager_Page_IDs
    rowindex = section[m.SectionKeyField].Tostr()
    pageIndex = pageNum.Tostr()

    if map[rowindex] = invalid then
        map[rowindex] = {}
    end if
    ' add this item to row map
    if map[rowindex][pageIndex] = invalid and not IsToManyPageFails(rowindex, pageNum)
        map[rowindex][pageIndex] = ""
        if m.debug_loadingItems then child.HDPosterUrl = m.hdposterUrl
        params = {
            aditionalParams: {
                offset: pageNum
                pageSize: config.pageSize
            }
            shouldDeleteHandlerConfig:  shouldDeleteHandlerConfig
            itemIndex: child[m.ItemKeyField]
        }
        ' return callback that handles cleaning current map
        callback = {
            section: section
            pageNum: pageNum
            pageSize: config.pageSize

            onReceive: sub(data)
                ' we need to workaround a bug when section is not populated properly
                m.section.ELLIPSISTEXT = Rnd(2048).Tostr()
                ' remove this page from queue, and clear fails
                m.DeletePageFromAlreadyLoading(true)
                m.UpdatePageNumber(false)
            end sub

            onError: sub(data)
                ' we need to workaround a bug when section is not populated properly
                m.section.ELLIPSISTEXT = Rnd(2048).Tostr()
                ' remove this page from queue and add fails
                m.DeletePageFromAlreadyLoading(false)
            end sub

            deletePageFromAlreadyLoading: sub(isSuccess as Boolean)
                gThis = GetGlobalAA()
                map = gThis.ContentManager_Page_IDs
                rowindex = m.section[gThis.SectionKeyField].Tostr()
                pageIndex = m.pageNum.Tostr()
                if map[rowindex] <> invalid then
                    map[rowindex].Delete(pageIndex)
                end if

                if isSuccess then
                    ClearPageFails(rowindex, m.pageNum)
                else
                    AddPageFail(rowindex, m.pageNum)
                end if
            end sub

            ' function for updating page number
            ' for now we only delete page_num in case everything is loaded
            ' @param restoreDefault [Boolean] tells if we need to restore default value
            updatePageNumber: sub(restoreDefault as Boolean)
                pageToCompare = m.pageNum

                children = m.section.GetChildren(- 1, 0)
                for each child in children
                    if child <> invalid and child.HasField("CM_pageNum") and child.CM_pageNum <> invalid and pageToCompare = child.CM_pageNum
                        ' reseting values
                        if not restoreDefault then
                            child.CM_pageNum = - 1
                        end if
                    end if
                end for
            end sub
        }
        LoadContentForSection(section, params, callback)
    end if
end function

function isPageAlreadyInQueue(rowIndex as Object, itemIndex as Object) as Boolean
    return m.ContentManager_Page_IDs[rowIndex.Tostr()] <> invalid and m.ContentManager_Page_IDs[rowIndex.Tostr()][itemIndex.Tostr()] <> invalid
end function

sub LoadSerialPaginationForItem(focusedItem)
    ITEMS_TO_CHECK = GetVisibleItems()
    ' get this item section and load content for it
    categoryindex = m.itemToSection[focusedItem]

    if categoryindex <> invalid then
        content = m.itemsList.content
        section = content.GetChild(categoryindex)
        firstItemIndex = m.firstItemInSection[categoryindex]
        if firstItemIndex <> invalid and section <> invalid and IsPaginationRow(section) then
            currentIndex = focusedItem - firstItemIndex

            sectionChildCount = section.GetChildCount()
            if sectionChildCount - currentIndex <= ITEMS_TO_CHECK then
                ' value to be stored in loading map
                pageNum = - 3
                if not IsToManyPageFails(categoryindex, pageNum)
                    ' need to load data
                    config = section[m.Handler_ConfigField]
                    lastChild = section.GetChild(sectionChildCount - 1)
                    shouldDeleteConfig = true
                    AddPaginationForSectionToQueue(section, lastChild, pageNum, config, shouldDeleteConfig)
                end if
            end if
        end if
    end if
end sub

' Function for handling idle loading of rows
'This is called after m.top.IDLE_ROW_LOAD_TIME when user doesn' t navigate on View 
' m.top.MAX_SIMULTANEOUS_LOADINGS is used to limit number of task for loading rows
sub OnIdleLoadExtraContent()
    timer = CreateObject("roTimespan")

    maxLoadingsCount = m.top.MAX_SIMULTANEOUS_LOADINGS
    currentloadings = m.runningQueue.Count()
    currentloadings = 0
    if m.itemsList <> invalid and m.itemsList.content <> invalid and currentloadings < maxLoadingsCount and m.currentIdleRadius < m.MAX_RADIUS
        focusedItem = 0
        categoryIndex = 0
        isFocusedOnCategory = m.categoryList.HasFocus()
        if isFocusedOnCategory
            ' user is focused on category, so we assume that 1 item in it is focused
            focusedItem = m.firstItemInSection[m.categoryList.itemFocused]
        else
            focusedItem = m.itemsList.itemFocused
        end if

        for index = 0 to m.currentIdleRadius
            ' going up and down from focused item
            for each multiplier in [1, - 1]
                itemIndexToCheck = focusedItem + (index * multiplier)
                if itemIndexToCheck < 0 then itemIndexToCheck = 0
'                ? "focusedItem="focusedItem", index="index", itemIndexToCheck="itemIndexToCheck

                categoryIndex = m.itemToSection[itemIndexToCheck]
                if categoryIndex <> invalid
                    category = m.categoryList.content.GetChild(categoryIndex)
                    if category <> invalid
                        if ShouldLoadDataForRow(category) then
                            ' we have not populated category
                            LoadCategoryIfNeeded(categoryIndex)
                        else if IsPaginationRow(category)
                            ' This is serial loading
                            LoadSerialPaginationForItem(itemIndexToCheck)
                        else
                            LoadNonSerialPaginationForItem(itemIndexToCheck)
                            ' need to check pagination
                            checkCategoryPagination(categoryIndex)                        
                        end if
                    else
                        if m.debug then ? "invalid category"
                    end if
                else
                    if m.debug then ? "invalid category index"
                end if
            end for
        end for
        m.currentIdleRadius++
        if m.debug then ? "idle finished in "timer.TotalMilliseconds()
    else if m.currentIdleRadius >= m.MAX_RADIUS
        m.IdleUpdateTimer.control = "stop"
    end if
end sub