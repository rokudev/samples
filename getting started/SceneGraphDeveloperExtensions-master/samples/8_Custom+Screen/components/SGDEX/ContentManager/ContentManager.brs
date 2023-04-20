' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    InitContentGetterValues()
end sub

' this function is called outside to set view to this content manager
'this is done so that view doesn' t even have to know about content manager
sub setView(view as Object)
    m.view = view
    if m.view <> invalid then
        view.ObserveField("focusedChild", "OnViewFocuseChanged")
        view.ObserveField("rowItemFocused", "OnRowItemFocused")

        'add control observers so we don' t start any background job when view is not visible
        view.ObserveField("wasShown", "ContinueLoadingContent")
        view.ObserveField("saveState", "SuspendLoadingContent")
        view.ObserveField("wasClosed", "StopLoadingContent")
        view.ObserveField("content", "OnContentLoaded")
    else
        ? "ERROR, Content Manager, received invalid view"
    end if
end sub

' Content manager field has changed
' This is to control content manager loading process
sub onControlChanged(event as Object)
    actions = {
        start: StartLoadingContent
        STOP: StopLoadingContent
        suspend: SuspendLoadingContent
    }
    data = event.GetData()

    if data <> invalid and actions[data] <> invalid then
        functionToRun = actions[data]
        FunctionToRun()
    end if
end sub

' Initializes content loading
sub StartLoadingContent()
    if m.view <> invalid and m.view.content <> invalid and m.view.content[m.Handler_ConfigField] <> invalid and m.view.content[m.Handler_ConfigField].name <> invalid and m.view.content[m.Handler_ConfigField].name.Len() > 0 then
        ' we shouldn' t check children count as developer might set new config to refresh View 
        ' OnMainContentLoaded will be called when config finishes
        ' use this function to load content, so we have all tasks in one place and can easily cancel them
        config = m.view.content[m.Handler_ConfigField]
        ' erase config so we will know if any additional work will be needed
        m.view.content[m.Handler_ConfigField] = invalid
        if m.view.showSpinner <> invalid then m.view.showSpinner = true
        m.task = GetContentData({
            view: m.view
            config: config
            onReceive:  OnMainContentLoaded
            onError:    OnNoMainContentReceived
        }, config, m.view.content)
    end if
end sub

sub ContinueLoadingContent()
    m.CanLoadContent = true
    RunNextTaskFromQueue()
end sub

sub StopLoadingContent()
    m.CanLoadContent = false
    m.content = invalid
end sub

sub SuspendLoadingContent()
    m.CanLoadContent = false
end sub

sub OnViewFocuseChanged(event as Object)
end sub

' Is triggered when row item is focused, this is only called on grids
' has logic for async loading of grids
' calculates how far data should be loaded
sub OnRowItemFocused(event as Object)
    currentRowIndex = event.GetData()[0]
    currentItemIndex = event.GetData()[1]
    ' stop any idle job
    m.IdleUpdateTimer.control = "stop"
    m.numRowsToLoad = GetNumRowsToLoad()

    ' Check if we are moving verticaly or horizontaly
    isLazyRow = false
    isVerticalMove = false
    isHorizontalPagination = false

    row = invalid
    if m.view.content <> invalid then
        row = m.view.content.GetChild(currentRowIndex)
        isLazyRow = CheckIfLazyRow(row)
        if not isLazyRow and IsPaginationRow(row) then
            isHorizontalPagination = true
        end if
    end if
    if row <> invalid
        ' even if we move vertically we should start horizontal lazy loading first      

        focusindexToSet = currentItemIndex
        if currentItemIndex < 0 then currentItemIndex = 0
        setFocusedItem(row, currentItemIndex)

        if m.previousFocusedRow <> currentRowIndex
            isVerticalMove = true
        end if
        ' we have to check if placeholders have to be loaded
        doLookAHead = true
        if isLazyRow then LazyLoadHorizontalRow(row, currentItemIndex, m.previousFocusedItemIndex, doLookAHead)
        ' load extra rows if needed
        if isVerticalMove then LazyLoadVerticalRows(currentRowIndex)
        ' check if we need to load pagination for horizontal row
        if isHorizontalPagination then TryToLoadHorizontalPagination(row, currentItemIndex, m.previousFocusedItemIndex)
    end if
    m.previousFocusedRow = currentRowIndex
    m.previousFocusedItemIndex = currentItemIndex
    ' restore idle job if needed
    if m.top.IDLE_ROW_LOAD_TIME > 0 then
        m.IdleUpdateTimer.control = "start"
    end if
end sub

' Lazy loads vertical rows
' checks if focused row has content
' loads current and next row
' after that loads other neighbor rows 
sub LazyLoadVerticalRows(rowIndexToLoad as Integer)
    if m.debug then ? "LazyLoadVerticalRows, row Focused:"rowIndexToLoad " previousFocusedRow "m.previousFocusedRow
    extraRows = m.EXTRA_ROWS ' number of previous rows to load

    if rowIndexToLoad >= m.previousFocusedRow ' going down
        index = rowIndexToLoad - extraRows
        if index < 0 then index = 0
        endIndex = rowIndexToLoad + m.numRowsToLoad + extraRows
        loopStep = 1
    else
        index = rowIndexToLoad + m.numRowsToLoad
        if index > m.view.content.GetChildCount() then index = m.view.content.GetChildCount() - 1
        endIndex = rowIndexToLoad - extraRows
        if endIndex < 0 then endIndex = 0
        loopStep = - 1
    end if

    ' load focused row first
    alreadyLoadingRows = {}
    for rowIndex = (rowIndexToLoad + GetNumRowsToLoad()) to rowIndexToLoad step - 1
        visibleRow = m.view.content.GetChild(rowIndex)
        if ShouldLoadDataForRow(visibleRow) then
            if m.debug then ? "LazyLoadVerticalRows, try to load content for visible row: "rowIndex
            alreadyLoadingRows[rowIndex.Tostr()] = ""
            AsyngGrid_LoadContentForRow(visibleRow)
        else if CheckIfLazyRow(visibleRow)
            LazyLoadHorizontalRow(visibleRow, getFocusedItem(visibleRow, 0), - 1, true)
        end if
    end for

    ' load rows around this row
    for rowIndex = index to endIndex step loopStep
        row = m.view.content.GetChild(rowIndex)
        if row <> invalid and alreadyLoadingRows[rowIndex.Tostr()] = invalid and ShouldLoadDataForRow(row) and rowIndexToLoad <> rowIndex
            if m.debug then ? "try to load content for extra row: "rowIndex
            AsyngGrid_LoadContentForRow(row, false)
        else if CheckIfLazyRow(row)
            LazyLoadHorizontalRow(row, getFocusedItem(row, 0), - 1, false)
        end if
    end for

    ' check if we need to load extra pages for vertical pagination
    if m.view.content.GetChildCount() - (rowIndexToLoad + extraRows + m.numRowsToLoad) <= 0 then
        ' we need to check if we have pagination for root content
        if IsPaginationRow(m.view.content) and not IsRowAlreadyLoading(m.view.content)
            AsyngGrid_LoadContentForRow(m.view.content)
        end if
    end if
end sub

function LazyLoadHorizontalRowByIndex(rowIndexToLoad as Integer, itemIndexToLoad as Integer, previousItemIndex as Integer) as Boolean
    if m.view.content <> invalid and m.view.content.GetChildCount() > rowIndexToLoad then
        row = m.view.content.GetChild(rowIndexToLoad)
        return LazyLoadHorizontalRow(row, itemIndexToLoad, previousItemIndex)
    end if
end function

' @param row - row that has lazy items that should be loaded
' @param itemIndexToLoad [Integer] item index that should be checked and loaded if needed
' @param  doLookAhead [Boolean] tells if lookahead should be performed, be careful with this field as you can trigger a lot of page loadings, so use only for focused or visible row 
function LazyLoadHorizontalRow(row as Object, itemIndexToLoad as Integer, previousItemIndex as Integer, doLookAhead = false as Boolean) as Boolean
    result = false
    if row <> invalid and CheckIfLazyRow(row) then
        if m.debug then ? "LazyLoadHorizontalRow, item "itemIndexToLoad " prev "previousItemIndex
        HandlerConfigGrid = row[m.Handler_ConfigField]
        child = row.GetChild(itemIndexToLoad)
        if child <> invalid then
            itemsCount = m.view.content.GetChildCount()
            currentPage = child.CM_pageNum
            alreadyLoadingPages = {}
            if currentPage <> invalid and currentPage >= 0 and not isPageAlreadyInQueue(row.CM_row_ID_Index, currentPage) then
                callback = getHorizontalpaginationCallback(row, HandlerConfigGrid, itemIndexToLoad, currentPage)
                if m.debug_loadingItems then child.hdposterUrl = m.hdposterUrl
                alreadyLoadingPages[currentPage.Tostr()] = ""
                QueueGetContentData(callback, HandlerConfigGrid, row, { offset: currentPage, pageSize: HandlerConfigGrid.pageSize })
                result = true
            end if
            if doLookAhead then
                lookAheadNumberMap = {
                    "1": m.top.FORWARD_ROW_LOOKAHEAD_NUMBER_OF_ITEMS
                    "-1": m.top.REWIND_ROW_LOOKAHEAD_NUMBER_OF_ITEMS
                }
                totalCount = row.GetChildCount()
                ' check both left and right sides 
                for each multiplier in [1, - 1]
                    lookAheadNumber = lookAheadNumberMap[multiplier.Tostr()]
                    ' starting from one as multiply by 0 will load for current item
                    for index = 1 to lookAheadNumber
                        itemIndexToCheck = itemIndexToLoad + (index * multiplier)
                        ' check last items too
                        if itemIndexToCheck < 0 then
                            itemIndexToCheck = totalCount - Abs(itemIndexToCheck)
                        end if

                        child = row.GetChild(itemIndexToCheck)
                        'if child is not valid that we are doing something wrong or row size is smaller so don' t continue on this side
                        if child <> invalid then
                            pageNumber = GetPageNum(child)

                            if pageNumber >= 0 and not isPageAlreadyInQueue(row.CM_row_ID_Index, pageNumber) and not IsToManyPageFails(row, pageNumber) then
                                if m.debug_loadingItems then child.hdposterUrl = m.hdposterUrl
                                callback = getHorizontalpaginationCallback(row, HandlerConfigGrid, itemIndexToCheck, pageNumber)
                                alreadyLoadingPages[pageNumber.Tostr()] = ""

                                QueueGetContentData(callback, HandlerConfigGrid, row, { offset: pageNumber, pageSize: HandlerConfigGrid.pageSize }, false)
                                result = true
                            end if
                        else
                            exit for
                        end if
                    end for
                end for
            end if
        end if
    end if
    return result
end function

' callback for loading non-serial model
' this function should be called before getting cotnent as it adds itself to pending queue so pages are not called twice 
function getHorizontalpaginationCallback(row, HandlerConfigGrid, itemIndexToCheck, page)
    ' add this row and page to loading map
    map = m.ContentManager_Page_IDs
    rowindex = row.CM_row_ID_Index.Tostr()
    pageIndex = page.Tostr()

    if map[rowindex] = invalid then
        map[rowindex] = {}
    end if
    ' add this item to row map
    if map[rowindex][pageIndex] = invalid
        map[rowindex][pageIndex] = ""
    end if

    ' return callback that handles cleaning current map
    return {
        view: m.view
        ' current row
        row: row
        ' item index that triggered page load
        ' this can be any item within proper pagesize
        itemIndex: itemIndexToCheck
        ' current config
        HandlerConfigGrid: HandlerConfigGrid
        ' page number
        page: page

        onreceive: sub(data)
            ' mark this page as loaded
            m.ClearPageFails()
            ' delete the page numbers if replace function wasn' t used
            m.UpdatePageNumber(false)
            ' delete this page from queue
            m.ClearFromQueue()
        end sub

        ' we assume that nothing was changed
        ' there is no way to restore page number if developer called replace
        onError: sub(data)
            ' add page to failed map            
            m.AddPageFail()
            ' if we exceed to many fails we don' t do anything here
            ' loading functions check if this page didn' t exceed number of fails
            ' when developer moves focus number of fails is cleared for all rows
            ' clear this page from queue
            m.ClearFromQueue()
        end sub

        ' function for updating page number
        ' for now we only delete page_num in case everything is loaded
        ' @param restoreDefault [Boolean] tells if we need to restore default value
        updatePageNumber: sub(restoreDefault as Boolean)
            pageSize = m.handlerConfigGrid.pageSize
            ' default page size will be 1
            ' so just check items near item that triggered loading
            if pageSize = invalid then pageSize = 1
            ' check 2x items in case developer modifies more items that he stated in config
            itemIndex = m.itemIndex - pageSize
            ' This should be > 0 so we get content properly
            if itemIndex < 0 then itemIndex = 0
            pageToCompare = m.page

            children = m.row.GetChildren(pageSize * 2, itemIndex)
            for each child in children
                if child <> invalid and child.HasField("CM_pageNum") and child.CM_pageNum <> invalid and pageToCompare = child.CM_pageNum
                    ' reseting values
                    if not restoreDefault then
                        child.CM_pageNum = - 1
                    end if
                end if
            end for
        end sub

        clearFromQueue: sub()
            tmp = GetGlobalAA().ContentManager_Page_IDs[m.row.CM_row_ID_Index.Tostr()].Delete(m.page.Tostr())
        end sub

        ' clear any page fails
        ' This should be called in OnReceive even if page failed previously
        ClearPageFails: sub()
            ClearPageFails(m.row, m.page)
        end sub

        ' increment current page fails counter 
        AddPageFail: sub()
            AddPageFail(m.row, m.page)
        end sub

        ' retrieve page fails count
        GetPageFails: function() as Integer
            return GetPageFails(m.row, m.page)
        end function

        IsToManyPageFails: function() as Boolean
            return IsToManyPageFails(m.row, m.page)
        end function

        OnStart: sub()
        end sub
    }
end function

' This will tell if page is already in queue
'So we don' t start new loading
function isPageAlreadyInQueue(rowIndex as Object, itemIndex as Object) as Boolean
    return m.ContentManager_Page_IDs[rowIndex.Tostr()] <> invalid and m.ContentManager_Page_IDs[rowIndex.Tostr()][itemIndex.Tostr()] <> invalid
end function

sub TryToLoadHorizontalPagination(row, currentItemIndex as Integer, previousItemIndex as Integer)
    if IsPaginationRow(row) and currentItemIndex >= 0 then
        childCount = row.GetChildCount()
        if (childCount - currentItemIndex) - m.VISIBLE_ITEMS <= 0
            AsyngGrid_LoadContentForRow(row)
        end if
    end if
end sub

' Callback for root content loaded
'This is part of callback so it's m is callback AA' s m
sub OnMainContentLoaded(content as Object)
    if GetGlobalAA().debug then ? "OnMainContentLoaded"
    if m.view <> invalid then
        canSetContent = true

        ' TODO check if this is true for refresh  
        content = GetGlobalAA().view.content
        numRows = GetNumRowsToLoad()
        if numRows <> invalid then
            ' assume that this is grid
            rowsToLoad = []
            firstNotLoadeRow = - 1
            index = 0
            for index = 0 to numRows
                row = content.GetChild(index)
                if row <> invalid then
                    ' row might be loading already
                    ' we have noticed that itemFocused is called before this function so vertical rows are already loading
                    if IsRowAlreadyLoading(row) then canSetContent = false
                    if row[GetGlobalAA().Handler_ConfigField] <> invalid and row.GetChildCount() <= 1 then
                        ' row needs to be loaded
                        AsyngGrid_LoadContentForRow(row)
                        if IsRowAlreadyLoading(row) then canSetContent = false
                    end if
                end if
            end for
        end if
        ' if we have spinner visible and enough rows to show we can hide the spinner
        if m.view.showSpinner <> invalid and canSetContent then
            m.view.showSpinner = false
        end if
    end if
end sub

sub OnNoMainContentReceived(content as Object)
    if m.task.failed
        if m.Handler_ConfigField <> invalid
            m.config = m.view.content[m.Handler_ConfigField]
            m.view.content[m.Handler_ConfigField] = invalid
        end if
                
        if m.view.showSpinner <> invalid then m.view.showSpinner = true
        
        m.task = GetContentData(m, m.config, m.view.content)
    else if m.view <> invalid 
        m.view.content = content
    end if
end sub

' Initializes loading of content for row on grid
' has proper logic for adding missing fields and populating new content
sub AsyngGrid_LoadContentForRow(row, isHighPriority = true as Boolean)
    initialIsLoading = row.HasField("isLoading") and row.isLoading
    PopulateLoadingFlags(row)
    isLazyRow = CheckIfLazyRow(row)
    if row[m.Handler_ConfigField] <> invalid and not initialIsLoading and ( not row.isLoaded or IsPaginationRow(row)) and not isLazyRow then
        if not IsToManyPageFails(row, -1)
            row.isLoading = true
            HandlerConfigGrid = row[m.Handler_ConfigField]
            callback = {
                view: m.view
                row: row
                HandlerConfigGrid: HandlerConfigGrid
    
                onreceive: function(data)
                    'we shouldn' t do anything here as developer should populate all content here
                    m.row.isLoaded = true
                    m.row.isFailed = false
                    m.row.isLoading = false
                    ' check if row that was loaded has lazy items to be loaded
                    ClearPageFails(m.row, -1)
                    if CheckIfLazyRow(m.row) then
                        LazyLoadHorizontalRow(m.row, getFocusedItem(m.row, 0), - 1, true)
                    end if
                    'RDE-819  GridView does not accurately reflect initial focus
                    if m.view.hasField("updateFocusedItem") then m.view.updateFocusedItem = true 

                    ' if spinner is running we have to check if this row is enough to close spinner
                    if m.view.showSpinner <> invalid and m.view.showSpinner then m.CheckInitRows()
                end function
    
                onError: function(data)
                    ' set these flags so we can load row again
                    m.row.isFailed = true
                    m.row.isLoaded = false
                    m.row.isLoading = false
    
                    ' restore previous CG config if developer didn' t set new one so we can retry later
                    Handler_ConfigField = GetGlobalAA().Handler_ConfigField
                    if m.row[Handler_ConfigField] = invalid then
                        m.row[Handler_ConfigField] = m[Handler_ConfigField]
                    end if
                    ' put this row to queue again
                    AddPageFail(m.row, -1)
                    AsyngGrid_LoadContentForRow(m.row)
                    
                    ' if spinner is running we have to check if this row is enough to close spinner
                    if m.view.showSpinner <> invalid and m.view.showSpinner then m.CheckInitRows()
                end function
    
    '            Checks for minimum rows to be loaded and when they are loaded sets content to actual view
                checkInitRows: sub()
                    content = m.view.content
                    if content <> invalid then
                        numRows = GetNumRowsToLoad()
                        isAllMandatoryRowsLoaded = true
                        for i = 0 to numRows - 1
                            row = content.GetChild(i)
                            if row <> invalid then
                                ' there could be less rows then numrows
                                isAllMandatoryRowsLoaded = isAllMandatoryRowsLoaded and ((row.isLoaded <> invalid and row.isLoaded) or (row.isFailed <> invalid and row.isFailed) or row.GetChildCount() > 0)
                            end if
                        end for
                        if not isAllMandatoryRowsLoaded then return
                        ' set content from storage 
                        m.view.showSpinner = false
                    end if
                end sub
            }
            row[m.Handler_ConfigField] = invalid
            QueueGetContentData(callback, HandlerConfigGrid, row, {}, isHighPriority)
        
        else
            ?"SGDEX: failed too many times "row.cm_row_id_index
        end if
    else if isLazyRow
        LazyLoadHorizontalRow(row, 0, - 1, true)
        row.isLoaded = true
    else if row[m.Handler_ConfigField] = invalid and row.isLoading = false and row.isLoaded = false and row.isFailed = false
        row.isLoaded = true
    end if
end sub

' sets new time to timer
sub onIdleTimerChanged()
    m.IdleUpdateTimer.duration = m.top.IDLE_ROW_LOAD_TIME
end sub

' Function for handling idle loading of rows
'This is called after m.top.IDLE_ROW_LOAD_TIME when developer doesn' t navigate on View 
' m.top.MAX_SIMULTANEOUS_LOADINGS is used to limit number of task for loading rows
sub OnIdleLoadExtraContent()
    timer = CreateObject("roTimespan")

    maxLoadingsCount = m.top.MAX_SIMULTANEOUS_LOADINGS
    currentloadings = m.runningQueue.Count()
    currentloadings = 0
    isAnyRowLoading = false
    if m.CanLoadContent and m.view <> invalid and m.view.content <> invalid and currentloadings < maxLoadingsCount and m.currentIdleRadius < m.MAX_RADIUS
        currentRowIndex = m.view.rowItemFocused[0]
        currentItemIndex = m.view.rowItemFocused[1]
        if currentItemIndex < 0 then currentItemIndex = 0
        content = m.view.content
        rowsCount = m.view.content.GetChildCount()
        hasNotLoadedData = false

        for index = 0 to m.currentIdleRadius
            nextRowIndex =      currentRowIndex + index
            previousRowIndex =  currentRowIndex - index

            nextRow =           content.GetChild(nextRowIndex)
            previousRow =       content.GetChild(previousRowIndex)

            ' nothing to do
            if nextRow = invalid and previousRow = invalid then exit for
            rowsToProcess = []
            if nextRow <> invalid then rowsToProcess.Push(nextRow)
            if previousRow <> invalid and (nextRow = invalid or not previousRow.IsSameNode(nextRow)) then rowsToProcess.Push(previousRow)
            ' processing rows one by one
            for each row in rowsToProcess
                ' check if this row needs to be loaded
                if ShouldLoadDataForRow(row)
                    AsyngGrid_LoadContentForRow(row)
                    hasNotLoadedData = true
                    isAnyRowLoading = true
                else if CheckIfLazyRow(row) then ' check if we need pages to be loaded
                    'map for storing existing indexes so we don't check them again
                    existingIndexes = {}
                    ' go left and right
                    for each multiplier in [1, - 1]
                        pageIndex = (m.currentIdleRadius - index) * multiplier

                        ' get rows focused item. This is good as rows have different items focused
                        rowItemIndex = getFocusedItem(row)
                        focusedChild = row.GetChild(rowItemIndex)

                        ' now we have to find proper page based on focused item page
                        if focusedChild <> invalid then
                            currentPageindex = getPageNum(focusedChild)
                            ' check if focused child page is loaded
                            if currentPageindex >= 0 then
                                LazyLoadHorizontalRow(row, rowItemIndex, - 1)
                            end if
                            
                            children = row.GetChildren(- 1, 0)

                            'don' t allow to many checks as we are checking each row that is slow
                            allowedCount = m.MAX_RADIUS
                            indexesToCheck = []
                            'build array of indexes to check like 0,1,2,3 or 0,20,19,18
                            ' TODO we can optimize this by knowing page size so we can jump some items < pagesize 
                            children_count = children.count() 
                            for numChildrenIndex = 0 to allowedCount
                                tempIndex = rowItemIndex + (numChildrenIndex * multiplier)
                                
                                if tempIndex < 0 then
                                    tempIndex = children_count + tempIndex
                                else if tempIndex >= children_count
                                    tempIndex = children_count - tempIndex
                                end if
                                
                                if existingIndexes[tempIndex.ToStr()] = invalid then
                                    existingIndexes[tempIndex.ToStr()] = ""
                                    indexesToCheck.Push(tempIndex)
                                end if
                            end for
                            ' go through items and check if page has to be loaded
                            for each childIndex  in indexesToCheck
                                child = children[childIndex]
                                if child <> invalid then
                                    pageindex = getPageNum(child)
                                    ' ? "row.CM_row_ID_Index="row.CM_row_ID_Index "x"pageindex  " child["childIndex"]"
                                    if pageindex >= 0 and not isPageAlreadyInQueue(row.CM_row_ID_Index, pageindex) and not IsToManyPageFails(row, pageindex) then
                                        LazyLoadHorizontalRow(row, childIndex, - 1)
                                        hasNotLoadedData = true
                                        if m.debug_loadingItems then child.hdposterUrl = m.hdposterUrl
                                        'we found one page to load in this range
                                        exit for
                                    end if
                                end if
                                if allowedCount < 0 then exit for
                                allowedCount--
                            end for
                        end if
                    end for
                else if IsRowAlreadyLoading(row)
                    isAnyRowLoading = true
                end if
            end for
        end for
        if not hasNotLoadedData
            'This doesn' t mean that no data has to be loaded
            ' This might occur due to all data being already loaded on this radius 
        end if
        if m.debug then ? "radius ="m.currentIdleRadius", idle finished in "timer.TotalMilliseconds()
        m.currentIdleRadius++
        ' in case we have pending async row loadings we shouldn' t stop idle
        ' in most cases row loading takes longer then we reach MAX_RADIUS
        if isAnyRowLoading and m.currentIdleRadius >= m.MAX_RADIUS then
            ' keep trying to load background data till we reach all rows within radius beeing loaded
            m.currentIdleRadius = m.MAX_RADIUS - 1
        end if
    else if not m.CanLoadContent or m.currentIdleRadius >= m.MAX_RADIUS
        if m.debug then ? "stop idle loading"
        m.IdleUpdateTimer.control = "stop"
    end if
end sub

function GetNumRowsToLoad()
    return 2
end function

function GetPageSize(row)
    return row[m.Handler_ConfigField].pageSize
end function

function GetCurrentPage(item)
    if item.CM_orig_pageNum <> invalid then
        return item.CM_orig_pageNum
    else
        return - 1
    end if
end function

function getFocusedItem(row, defaultIndex = 0 as Integer) as Integer
    if row.CM_focusedItem <> invalid then
        if row.getChildCount() > 0 and row.CM_row_ID_Index = 2 then return 13
        return row.CM_focusedItem
    else
        setFocusedItem(row, defaultIndex)
        return defaultIndex
    end if
end function

sub setFocusedItem(row, newIndex)
    if not row.Hasfield("CM_focusedItem") then row.AddField("CM_focusedItem", "int", false)
    row.CM_focusedItem = newIndex
end sub

sub OnContentLoaded()
    hasConfig = m.view.content <> invalid and m.view.content[m.Handler_ConfigField] <> invalid and m.view.content[m.Handler_ConfigField].name <> invalid and m.view.content[m.Handler_ConfigField].name.Len() > 0 
    canLoad = hasConfig AND not IsPaginationRow(m.view.content)
    
    if m.content = invalid or not m.content.IsSameNode(m.view.content) or canLoad then
        needToStartNewLoading = false
        if m.content <> invalid then
            needToStartNewLoading = true
        end if
        
        m.content = m.view.content
        m.view.content.ObserveFieldScoped("change", "MarkRows")
        MarkRows()
        if needToStartNewLoading then StartLoadingContent()
    end if
end sub

sub MarkRows()
    index = 0
    children = m.view.content.Getchildren( - 1, 0)
    ' TODO if rows were added/deleted/inserted we have to change map references too
    'TODO add another references field to hold in map so we don' t use row index

    for each row in children
        if not row.HasField("CM_row_ID_Index") then
            row.AddFields({ CM_row_ID_Index: index })
        else
            row.SetFields({ CM_row_ID_Index: index })
        end if
        index++
    end for
end sub

sub doPrioritySort()
    focusedRow = m.view.rowItemFocused[0]

    ' TODO we have to take this from focused item not the one received
    focusedItem = m.view.rowItemFocused[1]
    if focusedItem = invalid or focusedItem < 0 then focusedItem = 0
    if focusedRow = invalid or focusedRow < 0 then focusedRow = 0
    if m.debug then ? "new priority for rows near "focusedRow
    rowPriority = 10
    itemPriority = 10
    rows = m.view.content.GetChildren( - 1, 0)
    for each taskObject in m.waitingQueue
        ' set new priority
        rowId = taskObject.id[0]
        itemId = taskObject.id[1]
        row = rows[rowId]
        if row <> invalid then
            focusedItem = getFocusedItem(row,0)
            
            diffRow = Abs(focusedRow - rowId)
            diffItem = Abs(focusedItem - itemId)
            ' calculate distance from end of row
            secondItemDiff = diffItem

            secondItemDiff = row.GetChildCount() - itemId + focusedItem
            ' take smallest distance
            if diffItem > secondItemDiff then diffItem = secondItemDiff
            diff = diffItem
            if diff < diffRow then diff = diffRow
            taskObject.priority = diff + rowPriority * diffRow + diffItem * itemPriority
        end if
    end for
    ' sort the queue
    m.waitingQueue.SortBy("priority", "r")
end sub
