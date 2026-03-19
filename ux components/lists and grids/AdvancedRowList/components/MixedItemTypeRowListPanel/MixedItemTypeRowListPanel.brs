'
' RowList example - rowItemComponentNames
'
' The rowItemComponentNames field can be used to specify an array
' of component types, one per row, as an alternative to a single
' component type set via itemComponentName.
'
' The itemComponentName _must_ be set to a non-empty value if using
' rowItemComponentNames, which will be used as the fallback component
' type if there are more rows than specified in rowItemComponentNames.
' The type is not actually checked before use - if it is not a valid
' component type, row creation will fail when the row is reached.
'
' New rows can be added to rowItemComponentNames while the RowList
' is in use. This example shows this.
'
' In addition the rows can be re-ordered. In this case, first set
' the new row component types, and then replace the data model.
'
' Note: This example is for demonstrating the RowList rather than as an
' actual practical example of how to build a channel.
'
' Note: This feature is only supported from 15.3. In 15.2 there is sample
' support but this has some limitations, and should not be relied on.
'
function rowNames()
    return {
        "CONTINUE_WATCHING": 0,
        "FEATURED": 1,
        "TEST_BUTTONS": 9
    }
end function

' Create a template for the content nodes and component type names to
' be used.
'
' The template is expanded by creating the relevant datamodel (a tree of
' ContentNodes) and constructing the array of content types.
'
' This is purely for simplifying this demo channel and is not a pattern that
' would necessarily be used in a production channel.
'
' @param num_rows   the number of rows to create
'
sub createTemplate(num_rows)
    if m.num_rows = invalid then
        ? "Creating initial template for %d rows".format(num_rows)
        start_row = 0
        m.rows = []
        m.component_types = []
        m.heights = []
        m.row_item_sizes = []
    else
        ? "Extending template to %d rows".format(num_rows)
        start_row = m.num_rows
    end if
    m.num_rows = num_rows

    row_titles = ["Comedy", "Drama", "Documentary", "SceneGraph", "BrightScript", "Grids",
                    "Sport"]

    row_names = rowNames()

    for i = start_row to m.num_rows - 1
        content_node_type = invalid
        num_cols = 20
        title = row_titles[i mod row_titles.count()]

        if (i MOD 2 = 0 and i < 8)
            ' Alternate rows are portrait/landscape, for rows 2-8
            height = 250
            row_item_size = [142, 211]
            uri_leaf_template = "Portrait_%d.jpg"
        else
            ' Landscape
            height = 180
            row_item_size = [196, 148]
            uri_leaf_template = "Landscape_%d.jpg"
        end if

        if i = row_names.CONTINUE_WATCHING then
            ' Top row has "continue watching"
            title = "Continue Watching"
            component_type = "ContinueWatching"
            content_node_type = "ContinueWatchingContentNode"
            height = 210
            row_item_size = [196, 190]
            uri_leaf_template = "Landscape_%d.jpg"
            num_cols = 3
        else if i = row_names.FEATURED then
            ' Second row is "featured" (big buck bunny)
            title = "Featured"
            component_type = "Hero"
            height = 200
            row_item_size = [294, 180]
            num_cols = 1
        else if i < 10 then
            ' These rows alternate portrait/landscape
            component_type = "MixedBaseTile"
        else if i = 10 then
            ' Row 10 is "live TV"
            title = "Live"
            height = 250
            component_type = "LiveTVTile"
            content_node_type = "LiveTVContentNode"
            row_item_size = [250, 216]
            num_cols = 5
        else
            ' Back to plain landscape
            height = 180
            component_type = "MixedBaseTile"
        end if

        uri_template = "https://devtools.web.roku.com/samples/images/" + uri_leaf_template
        row = {
            row_index: i,
            title: title,
            content_node_type: content_node_type,
            uri_template: uri_template,
            num_cols: num_cols,
        }
        m.rows.push(row)
        m.component_types.push(component_type)
        m.heights.push(height)
        m.row_item_sizes.push(row_item_size)
    end for
end sub

' Given a template and a row, create one of the row's children
function buildModelItem(rowContent as Object, template as Object, col as integer)
    if template.content_node_type <> invalid then
        itemContent = CreateObject("roSGNode", template.content_node_type)
        itemContent.columnIndex = col
    else
        itemContent = CreateObject("roSGNode", "ContentNode")
        itemContent.TITLE = "ITEM"
    end if
    itemContent.HDPOSTERURL = template.uri_template.format((col mod 12) + 1)
    rowContent.appendChildren([itemContent])
    return itemContent
end function

' Given the AA from createTemplate() construct the tree of content nodes that the
' rowlist will expect. A real channel would not do it this way.
'
' Assume that existing children are already correctly created.
function buildModel()
    if m.model = invalid then
        m.model = createObject("RoSGNode", "ContentNode")
    end if

    num_rows = m.model.getChildCount()
    for i = num_rows to m.num_rows - 1
        rowContent = m.model.createChild("ContentNode")
        template = m.rows[i]
        rowContent.TITLE = template.title

        for j = 0 to template.num_cols - 1
            buildModelItem(rowContent, template, j)
        end for
    end for
end function

sub configureRowTypes()
    m.rowList.rowHeights = m.heights
    ? "Setting rowItemComponentName"
    if m.component_types <> invalid then
        ? "  %s".format(m.component_types.join(","))
    end if
    m.rowList.rowItemComponentNames = m.component_types
    m.rowList.rowItemSize = m.row_item_sizes
end sub

function focusChanged()
    if m.top.isInFocusChain()
        if not m.rowList.hasFocus()
            m.rowList.setFocus(true)
        end if
    end if
end function

function itemFocused()
    ' Just for the demo channel - when we get to row 8, populate the remaining
    ' rows. This is not how it would be done in a production channel.
    if m.rowList.rowItemFocused[0] = 8 and m.have_updates = false then
        createTemplate(15)
        buildModel()
        configureRowTypes()
        m.have_updates = true
    end if

    ' And at this row, swap the component types around.
    if m.rowList.rowItemFocused[0] = 10 then
        startPoolTest()
    end if
end function

function itemSelected()
    row = m.rowList.rowItemSelected[0]
    col = m.rowList.rowItemSelected[1]
    ? "rowlist [%d, %d]: type: '%s'".format(col, row, m.rowlist.rowItemComponentNames[row])
    row_names = rowNames()
    if row = row_names.TEST_BUTTONS then
        handleTesterAction(col)
    end if
end function

sub handleTesterAction(col as integer)
    if col = 0 then
        if m.test_step <> 0 then
            ? "Pool test already in progress (step %d)".format(m.test_step)
        else
            startPoolTest()
        end if
    end if
end sub

sub startPoolTest()
    ? "Pool test: waiting 1s before content replacement"
    m.test_step = 1
    m.poolTestTimer.duration = 1.0
    m.poolTestTimer.control = "start"
end sub

sub onPoolTestTimer()
    if m.test_step = 1 then
        ? "Pool test: replacing content with CW and Hero rows swapped"
        m.test_step = 0
        swapAndReplaceContent()
    end if
end sub

' Example of swapping out the per-row component types and replacing the
' data.
sub swapAndReplaceContent()
    device_info = CreateObject("roDeviceInfo")
    ver = device_info.GetOSVersion()
    major = StrToI(ver.major)
    minor = StrToI(ver.minor)
    build = StrToI(ver.build)
    if (major = 15 and minor <= 2) or (major = 23 and build <= 3020) then
        ? "Swap/replace not supported"
        return
    end if

    ? "Swapping and replacing"
    rn = rowNames()
    cw = rn.CONTINUE_WATCHING
    ft = rn.FEATURED

    ' Swap the template, component type, and sizing for the CW and Hero rows.
    ' When the RowList replaces its content, the RowListItem that held CW tiles
    ' is reused for the Hero row (and vice versa), exercising the inner pool
    ' type-mismatch path in MarkupGrid::itemComponentChanged().
    tmp = m.rows[cw]
    m.rows[cw] = m.rows[ft]
    m.rows[ft] = tmp

    tmp = m.component_types[cw]
    m.component_types[cw] = m.component_types[ft]
    m.component_types[ft] = tmp

    tmp = m.heights[cw]
    m.heights[cw] = m.heights[ft]
    m.heights[ft] = tmp

    tmp = m.row_item_sizes[cw]
    m.row_item_sizes[cw] = m.row_item_sizes[ft]
    m.row_item_sizes[ft] = tmp

    ' Rebuild from scratch with the new row ordering, then replace the RowList
    ' content.
    m.model = invalid
    buildModel()
    ? "Setting rowlist content"
    m.rowList.content = m.model
    configureRowTypes()
    ? "Done setting rowlist content"
    ? "Pool test: content replaced"
end sub

function init()
    print "in MixedItemTypeRowListPanel init()"

    createTemplate(10)
    buildModel()

    m.have_updates = false
    m.test_step = 0
    m.poolTestTimer = m.top.findNode("poolTestTimer")
    m.poolTestTimer.observeField("fire", "onPoolTestTimer")

    m.rowList = m.top.findNode("theRowList")
    m.rowList.visible = false
    m.rowList.numRows = 3
    m.rowList.itemSize = [ 196*3 + 20*2, 180 ]
    m.rowList.itemSpacing = [ 20, 30]

    ' Default to this type if no row-specific type available
    m.rowList.itemComponentName = "MixedBaseTile"

    configureRowTypes()

    m.rowList.rowItemSpacing = [ [20, 20] ]

    m.rowList.focusXOffset = 0

    m.rowList.showRowLabel   = true
    m.rowList.showRowCounter = true

    m.rowList.rowLabelOffset = [ [0, 10] ]

    m.rowList.rowFocusAnimationStyle = "floatingfocus"

    m.rowList.content = m.model

    m.rowList.visible = true

    m.rowList.observeField("rowItemSelected", "itemSelected")
    m.rowList.observeField("rowItemFocused",  "itemFocused")

    m.top.observeField("focusedChild", "focusChanged")

    ? "init:rowlisttype: '%s'".format(m.rowlist.itemComponentName)
    m.top.visible = true
end function
