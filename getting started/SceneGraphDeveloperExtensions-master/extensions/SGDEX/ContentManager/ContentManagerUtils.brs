' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub InitContentGetterValues()
    m.Handler_ConfigField = "HandlerConfigGrid"
    'print debug info
    m.debug = false
    'change poster url for items that are added to queue
    m.debug_loadingItems = false
    ' Tells how many extra rows should be loaded, so we have more that visible rows loaded 
    ' to prefetch data when developer will need it
    m.EXTRA_ROWS = 2
    m.VISIBLE_ITEMS = 5
    'reset all idle values
    resetIdleValues()
    'maximum radius for loading content
    m.MAX_RADIUS = 30
    ' internal fields    
    m.ContentManager_id = - 1
    'callbacks map for each task that is executed
    m.ContentManager_callbacks = {}
    'map of current pending tasks so we don't add task to queue again
    m.ContentManager_TaskIds = {}
    'map for holding current loading page per row so we don't load it again
    m.ContentManager_Page_IDs = {}
    'map for holding number of fails per row and page,  {"0" (row_index):{"1"(page_index):0 (count)}}
    m.ContentManager_Page_Fails = {}

    ' Fields for queue 
    m.waitingQueue = []
    'tasks that are running now
    m.runningQueue = []

    m.previousFocusedRow = - 1
    m.previousFocusedItemIndex = - 1
    'background update timer
    m.IdleUpdateTimer = CreateObject("roSGNode", "Timer")
    if m.top.IDLE_ROW_LOAD_TIME <> invalid then
        m.IdleUpdateTimer.duration = m.top.IDLE_ROW_LOAD_TIME
    else
        m.IdleUpdateTimer.duration = 5
    end if
    m.IdleUpdateTimer.ObserveField("fire", "OnIdleLoadExtraContent")
    m.IdleUpdateTimer.ObserveField("control", "OnIdleStateChanged")
    m.IdleUpdateTimer.repeat = true
    m.CanLoadContent = true
    'image url that should be replaced for items that are added to queue
    m.hdposterUrl = "https://dummyimage.com/25x25/ff0000/2b3299/locked.png&text=locked"

    m.CM_row_ID_Index = 0
end sub

'This function creates task and starts it
'no max number of tasks check is performed use @see QueueGetContentData
function GetContentData(callback, HandlerConfig, content = invalid, additionalFields = invalid as Object)
    task = CreateTask(callback, HandlerConfig, content, additionalFields)
    if task <> invalid then
        task.control = "RUN"
    end if
    return task
end function

'Creates new tasks and populates all fields
'@param callback - [AA] callback that will be called
'@param HandlerConfig - [AA] - config that will be used to load content
'@param content - [AA] - content that will be passed to developer
'@param additionalFields - [AA] - any additional fields map that will be set to task interface
function CreateTask(callback as Object, HandlerConfig as Object, content as Object, additionalFields as Object) as Object
    task = invalid
    if HandlerConfig <> invalid and HandlerConfig.name <> invalid then
        task = GetNodeFromChannel(HandlerConfig.name)
        if task <> invalid then
            if HandlerConfig.fields <> invalid then task.SetFields(HandlerConfig.fields)
            if additionalFields <> invalid then task.SetFields(additionalFields)
            RegisterTaskCallback(callback, task)
            if m.debug then ? "GetContentData: " HandlerConfig.name' ":" task.functionName
            if not task.hasField("content") then task.AddField("content", "node", true)
            task.content = content
            task.HandlerConfig = HandlerConfig
        end if
    end if
    return task
end function

'Registers tasks callback to provided tasks
'callback will be called when task is finished, @see OnTaskContentReceived
sub RegisterTaskCallback(callback as Object, task as Object)
    if m.ContentManager_id = invalid then m.ContentManager_id = 0
    if not task.HasField("ContentManager_id") then
        m.ContentManager_id++
        task.AddFields({ ContentManager_id: m.ContentManager_id })
    end if
    key = m.ContentManager_id.ToStr()
    if m.ContentManager_callbacks = invalid then m.ContentManager_callbacks = {}
    if m.ContentManager_callbacks[key] = invalid then m.ContentManager_callbacks[key] = { task: task, callbacks: [] }
    m.ContentManager_callbacks[key].callbacks.Push(callback)

    task.ObserveField("result", "OnTaskContentReceived")
    task.ObserveField("state", "OnTaskContentReceived")
    task.ObserveField("finished", "OnTaskContentReceived")
end sub

'Observer function that is executed when task is finished
'@see RegisterTaskCallback for fields that can trigger this function
sub OnTaskContentReceived(event as Object)
    field = event.GetField()
    task = event.GetRoSGNode()
    'fields that say that task has finished
    FinishedFieldsMap = {
        result: ""
        state: "stop"
        finished: ""
    }

    if FinishedFieldsMap[field] <> invalid then
        if FinishedFieldsMap[field].Len() > 0 then
            data = event.GetData()
            ' check if we received proper event
            if GetInterface(data, "ifString") <> invalid and FinishedFieldsMap[field] <> data then return
        end if
        if task <> invalid then
            if task.ContentManager_id <> invalid and m.ContentManager_callbacks[task.ContentManager_id.ToStr()] <> invalid then
                content = task.content
                key = task.ContentManager_id.ToStr()

                ' clear task registration before processing so callback can add new loading if task failed
                for each observedFields in FinishedFieldsMap
                    task.UnobserveFieldScoped(observedFields)
                end for
                callbacks = m.ContentManager_callbacks[key].callbacks
                m.ContentManager_callbacks.Delete(key)

                for each callback in callbacks
                    callback.task = task
                    childcount = content.GetChildCount()

                    isFailed = task.failed <> invalid and task.failed

                    if not isFailed and (childcount > 0 or (callback.mAllowEmptyResponse <> invalid and callback.mAllowEmptyResponse)) then
                        if callback.OnReceive <> invalid then callback.OnReceive(content)
                    else
                        if callback.OnError <> invalid then callback.OnError(content)
                    end if
                    if callback.OnComplete <> invalid then callback.OnComplete()
                end for
            end if
        else
            ? "ERROR: Content Manager, task was destroyed before data was set"
        end if
    end if
end sub

'This function is called by RunNextTaskFromQueue, it creates tasks and adds it to queue
'@see RunNextTaskFromQueue
function ExecuteGetContentData(callback as Object, HandlerConfig as Object, content = invalid as Object, additionalFields = invalid as Object)
    newCallback = {
        callback: callback

        onReceive: sub(data)
            m.RemoveItemFromQueue()
            if m.callback.onReceive <> invalid then m.callback.OnReceive(data)
        end sub

        onError: sub(data)
            m.RemoveItemFromQueue()
            if m.callback.onError <> invalid then m.callback.OnError(data)
        end sub

        ' removes this task from queue
        ' call this before callback so callback can retry same content
        removeItemFromQueue: sub()
            gThis = GetGlobalAA()
            for index = 0 to gThis.runningQueue.Count() - 1
                task = gThis.runningQueue[index]
                if task <> invalid and task.Callback.ContentManager_id = m.ContentManager_id
                    gThis.runningQueue.Delete(index)

                    key = task.id[0].Tostr() + "_" + task.id[1].Tostr()
                    tmp = gThis.ContentManager_TaskIds.Delete(key)
                end if
            end for
        end sub

        OnComplete: sub()
            if m.callback.OnComplete <> invalid then m.callback.OnComplete()
            RunNextTaskFromQueue()
        end sub

        OnStart: sub()
            if m.callback.OnStart <> invalid then m.callback.OnStart()
        end sub
    }
    task = CreateTask(newCallback, HandlerConfig, content, additionalFields)
    if task <> invalid then
        newCallback.ContentManager_id = task.ContentManager_id
        task.control = "run"
    end if

    return {
        task: task
        callback: newCallback
    }
end function

'This function should be used for loading a lot of data and keep track of number parallel tasks
'@see RunNextTaskFromQueue
sub QueueGetContentData(callback as Object, HandlerConfig as Object, content = invalid as Object, additionalFields = invalid as Object, isHighPriority = true as Boolean)
    taskObject = {
        callback: callback
        HandlerConfig: HandlerConfig
        content: content
        additionalFields: additionalFields
    }
    ' adding id fields that can be used for sorting tasks
    ' content can have  CM_row_ID_Index
    ' or if not present it will use "rowIndex" from callback
    if content <> invalid and content.CM_row_ID_Index <> invalid then
        taskObject.id = [content.CM_row_ID_Index, - 1]
    else if taskObject.callback.rowIndex <> invalid then
        taskObject.id = [taskObject.callback.rowIndex, - 1]
    else
        taskObject.id = [- 1, - 1]
    end if
    ' we should always use item id not page id here
    ' This item is used for sorting tasks according to focused item position
    if taskObject.callback.itemIndex <> invalid then
        taskObject.id[1] = taskObject.callback.itemIndex
    end if
    isShouldAdd = true
    if taskObject.id[0] >= 0 then
        key = taskObject.id[0].Tostr() + "_" + taskObject.id[1].Tostr()
        ' this will add rows task to map so we can know which row tasks are alredy there
        isShouldAdd = not m.ContentManager_TaskIds[key] <> invalid
        m.ContentManager_TaskIds[key] = ""
    end if
    if isShouldAdd then
        if isHighPriority then
            m.waitingQueue.Push(taskObject)
        else
            m.waitingQueue.Unshift(taskObject)
        end if
    else if false ' this is blocked as we are calculating priority
        index = 0
        taskToDelete = invalid
        for each task in m.waitingQueue
            if task.id <> invalid and task.id[0] = taskObject.id[0] and task.id[1] = taskObject.id[1] then
                taskToDelete = task
                exit for
            end if
            index++
        end for
        if taskToDelete <> invalid then
            m.waitingQueue.Delete(index)
            m.waitingQueue.Push(taskToDelete)
        end if
        ? ""
        ? ""
        ? "TASK already in QUEUE!!!!, size is " m.waitingQueue.Count()
        ? ""
        ? ""
    end if
    RunNextTaskFromQueue()
end sub

'This function gets last tasks that was added to queue and runs it
'It can start up to m.top.MAX_SIMULTANEOUS_LOADINGS tasks at a time
' if implemented doPrioritySort() function is responsible for sorting tasks 
'@See doPrioritySort
sub RunNextTaskFromQueue()
    if not m.waitingQueue.IsEmpty() and m.CanLoadContent then
        timer = CreateObject("roTimespan")
        if doPrioritySort <> invalid then doPrioritySort()
        if m.debug then ? "sorted in "timer.TotalMilliseconds() " size = "m.waitingQueue.Count()
        for index = 1 to m.top.MAX_SIMULTANEOUS_LOADINGS - m.runningQueue.Count()
            taskToRun = m.waitingQueue.Pop()
            if taskToRun <> invalid then
                callback = taskToRun.callback
                HandlerConfig = taskToRun.HandlerConfig
                content = taskToRun.content
                additionalFields = taskToRun.additionalFields

                newTaskToRun = ExecuteGetContentData(callback, HandlerConfig, content, additionalFields)
                newTaskToRun.id = TaskToRun.id
                if taskToRun.callback.OnStart <> invalid then taskToRun.callback.OnStart()
                m.runningQueue.Push(newTaskToRun)
            end if
        end for
        if m.debug then ? "# of running tasks "m.runningQueue.Count() " of "m.top.MAX_SIMULTANEOUS_LOADINGS" # of waiting tasks "m.waitingQueue.Count()
    end if
end sub

'This is utility function to create components defined in developer channel
'If you call createObject in library it will try to find it in library
function GetNodeFromChannel(name as String) as Object
    result = invalid
    if m.top.GetScene() <> invalid then
        result = m.top.GetScene().CallFunc("createObjectOnDemand", name)
    else
        ' try to create it in local scope
        result = m.top.CreateChild(name)
    end if
    return result
end function

'returns if this row is serial pagination
function IsPaginationRow(row as Object) as Boolean
    return row <> invalid and row[m.Handler_ConfigField] <> invalid and row[m.Handler_ConfigField].hasMore <> invalid and row[m.Handler_ConfigField].hasMore
end function

' checks is this row has placeholdre items
' if yes, it check if all items are marked
'marking is done once so we don' t do it very often when user navigates 
function CheckIfLazyRow(row as Object) as Boolean
    result = row <> invalid and row[m.Handler_ConfigField] <> invalid and row[m.Handler_ConfigField].pageSize <> invalid and row[m.Handler_ConfigField].pageSize > 0
    if result and (row.CM_Lazy_IsMarked = invalid or not row.CM_Lazy_IsMarked) and row.GetchildCount() > 0 then
        pageSize = row[m.Handler_ConfigField].pageSize
        pageNum = 0
        pageIndex = 0
        ' mark children as not loaded, not loaded child is when CM_pageNum >=0
        children = row.GetChildren(- 1, 0)
        for each child in children
            if not child.HasField("CM_pageNum") then      child.AddField("CM_pageNum", "int", false)
            if not child.HasField("CM_orig_pageNum") then child.AddField("CM_orig_pageNum", "int", false)
            child.CM_pageNum = pageNum
            child.CM_orig_pageNum = pageNum

            pageIndex++
            if pageIndex >= pageSize
                pageIndex = 0
                pageNum++
            end if
        end for
        if not row.HasField("CM_Lazy_IsMarked") then row.AddField("CM_Lazy_IsMarked", "bool", false)
        row.CM_Lazy_IsMarked = true
    end if

    return result
end function

' tells if this row has needed info to load metadata
function ShouldLoadDataForRow(row) as Boolean
    result = false
    if row <> invalid then
        isLoaded = row.isLoaded <> invalid and row.isLoaded
        isLoading = IsRowAlreadyLoading(row)
        isFailed = row.isFailed <> invalid and row.isFailed
        hasHandlerConfig = row[m.Handler_ConfigField] <> invalid
        if not isLoading and not isLoaded then
            if isFailed
                result = hasHandlerConfig
            else
                'wasn' t loaded yet
                result = true
            end if
        end if
    end if
    return result
end function

'tells if already loading flag is populated use isAlreadyInQueue to know if row and item are already in queue
'@See isAlreadyInQueue
function IsRowAlreadyLoading(row) as Boolean
    return (row.isLoading <> invalid and row.isLoading)
end function

'Is used to know if item of the row is already in waiting queue
function isAlreadyInQueue(rowIndex as Object, itemIndex as Object) as Boolean
    key = rowIndex.Tostr() + "_" + itemIndex.Tostr()
    return m.ContentManager_TaskIds[key] <> invalid
end function

'populate row loading flags to provided row
sub PopulateLoadingFlags(row)
    if not row.HasField("isLoading") then   row.AddField("isLoading", "bool", true):    row.isLoading = false
    if not row.HasField("isLoaded") then    row.AddField("isLoaded", "bool", true):     row.isLoaded = false
    if not row.HasField("isFailed") then    row.AddField("isFailed", "bool", true):     row.isFailed = false
end sub

'reset all idle values
'is called in init and when developer navigate so we start new background loading based on focused position
sub resetIdleValues()
    m.currentIdleRadius = 1
    m.ContentManager_Page_Fails = {}
end sub

' get page number from this item
' this is populated by CheckIfLazyRow
'when page is loaded it' s reseted to < 0 value
function getPageNum(item) as Integer
    if item <> invalid and item.HasField("CM_pageNum") then return item.CM_pageNum
    return - 1
end function

'tells if this item contains page that has to be loaded, is used for non-serial pagination
function ShouldLoadPlaceHolder(item) as Boolean
    return getPageNum(item) >= 0
end function

sub OnIdleStateChanged(event as Object)
    data = event.GetData()
    if data = "stop" then
        resetIdleValues()
    end if
end sub

function IsToManyPageFails(row as Object, page as Object) as Boolean
    max_fails = 5
    if GetGlobalAA().top.MAX_NUMBER_OF_FAILS <> invalid then
        max_fails = GetGlobalAA().top.MAX_NUMBER_OF_FAILS
    end if

    return GetPageFails(row, page) > max_fails
end function

function GetPageFails(row as Object, page as Object) as Integer
    gThis = GetGlobalAA()
    map = gThis.ContentManager_Page_Fails
    rowKey = getPageKey(row)

    if map[rowKey] <> invalid then
        rowFails = map[rowKey]
        pageFailsNumber = rowFails[page.Tostr()]
        if pageFailsNumber <> invalid then
            return pageFailsNumber
        end if
    end if
    return 0
end function

' increment current page fails counter 
sub AddPageFail(row as Object, page as Object)
    gThis = GetGlobalAA()
    rowKey = getPageKey(row)
    map = gThis.ContentManager_Page_Fails
    if map[rowKey] = invalid then map[rowKey] = {}
    rowFails = map[rowKey]
    pageFailsNumber = rowFails[page.Tostr()]

    if pageFailsNumber = invalid then
        rowFails[page.Tostr()] = 0
    else
        rowFails[page.Tostr()] = pageFailsNumber + 1
    end if
end sub

' clear any page fails
' This should be called in OnReceive even if page failed previously
sub ClearPageFails(row as Object, page as Object)
    gThis = GetGlobalAA()
    map = gThis.ContentManager_Page_Fails

    rowKey = getPageKey(row)

    if map[rowKey] <> invalid then
        rowFails = map[rowKey]
        rowFails.Delete(page.Tostr())
    end if
end sub

function getPageKey(value as Object) as String
    result = "-1"
    if value <> invalid
        if Type(value) = "Integer" or Type(value) = "roInteger" or Type(value) = "roInt"
            result = value.ToStr()
        else if type(value) = "String" or type(value) = "roString"
            result = value
        else if value <> invalid and value.CM_row_ID_Index <> invalid then
            result = value.CM_row_ID_Index.ToStr()
        end if
    end if

    return result
end function