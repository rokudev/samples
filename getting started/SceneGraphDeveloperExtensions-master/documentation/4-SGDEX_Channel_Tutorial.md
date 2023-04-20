# Building a channel using SceneGraph Developer Extensions

This tutorial is for building a SceneGraph Developer Extensions (SGDEX)
based channel. Developers who want to build their first Roku channel, or
are interested in moving their existing channel to RSG, benefit from
this guide.

**SGDEX includes the following views:**

  - Grid

  - Details

  - Video with endcard view

  - Category list

  - Entitlement

Combining the views listed above, the developer can create their channel
without a deep knowledge of Roku SceneGraph components.

## Creating a project

Using an IDE, create a new project or use an existing project

Make sure the app manifest contains:

~~~~
ui_resolutions=hd
~~~~

All views are developed in HD resolution and autoscaled to FHD and SD.
Make sure to develop the views for the app in HD resolution as well.

## Required files

### File structure

~~~~
project/
    components/
        SGDEX/
        "your RSG components"
    source/
        SGDEX.brs
        main.brs
    manifest
~~~~

In the source folder, create a file main.brs and populate it with the
following:

**Contents of main.brs**

~~~~
sub GetSceneName()
    return "MainScene"
end sub
~~~~

The code above creates the scene and is the first step in building an
app.

Here, "MainScene" is the name of the scene.

## Developing a channel

To develop a SGDEX channel, create a Scene that extends from BaseScene.

### Scene

The XML file contains the following:

~~~~
<?xml version="1.0" encoding="UTF-8"?>
 
<component name="MainScene" extends="BaseScene" >
 
    <script type="text/brightscript" uri="pkg:/components/MainScene.brs" />
 
    <script type="text/brightscript" uri="pkg:/components/DetailsScreenLogic.brs" />
 
    <script type="text/brightscript" uri="pkg:/components/VideoPlayerLogic.brs" />
 
</component>
~~~~

In /components/MainScene.brs, add:

~~~~
sub Show(args as Object)
 
    'This function is called when the view is ready to show your content
 
end sub
~~~~

This function passes params from main.brs and decides what view is
displayed.

You can display a home screen(view), or create a deep linking
screen(view) here by passing the proper params.

The scene has a ComponentController interface field that is used to show
views and control flows.

## ComponentController

A componentController is the component that controls all
views.

### Interface

**Fields**

| **Field**                   | **Description**                                                                     |
| --------------------------- | ----------------------------------------------------------------------------------- |
| currentScreen               | The view that is currently shown                                                    |
| shouldCloseLastScreenOnBack | Indicates if the last screen in the stack should be closed before the channel exits |

Manipulate this screen if the channel needs to implement deep linking
or, a confirm exit dialog when the user presses back on the first
screen.

### Function interface

| **Function** | **Use**                             |
| ------------ | ----------------------------------- |
| show         | Used to add a new view to the stack |

## Showing the first view

To show the first view, the developer needs to create the view, add
content to it, and then display it.

#### Example

In /components/MainScene.brs, add the following to indicate the
show(args) function:

~~~~
sub Show(args as Object)
     
    m.grid = CreateObject("roSGNode", "GridView")   
    m.grid.ObserveField("rowItemSelected", "OnGridItemSelected")    
     
    'Setup the UI of the view    
     
    m.grid.SetFields({        
        style: "standard"        
        posterShape: "16x9"      
    })
 
    'This is the root content that describes how to populate rest of the rows
 
    content = CreateObject("roSGNode", "ContentNode")
 
    content.AddFields({
        HandlerConfigGrid: {
           name: "CGRoot"
           fields : { param : "123" }
        }
    })
    m.grid.content = content
 
    'Triggers a job to show the view
 
    m.top.ComponentController.CallFunc("show", {
        view: m.grid
    })
end sub
~~~~

The above code creates a simple grid view and displays it.

All views that extend Component have the following
interfaces:

## View UI setup

| **Field**   | **Description**                                                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| style       | The style to be used, see the documentation for each view                                                                             |
| posterShape | The shape of the poster to be used in this view                                                                                       |
| content     | View's content                                                                                                                        |
| overhang    | Congifure the overhang node to customize each view of your channel. For example, some views can have options or another logo or title |

### View visibility handling

| **Field** | **Description**                                                                                                                                                                                              |
| ----------| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| wasClosed | Triggered when the current view is closed. Use this when reading any value from a closed view. For example, itemFocused to set proper focus on the previous screen                              |
| saveState | Triggered when a new view is opened after the current view. It is useful when data needs to be saved before another view is opened. For example, pause audio or video when a new view is opened |
| wasShown  | Triggered when the current view is opened for the first time or restored after the top view was closed                                                                                          |
| close     | Use this field to manually close view. For example, during a registration flow, all registration views are closed after successful login                                                        |

If the developer does not have content for the grid, use
HandlerConfigGrid that describes how to populate rows for grid view:

~~~~
content = CreateObject("roSGNode", "ContentNode")
 
    content.AddFields({
        HandlerConfigGrid: {
            name: "CGRoot"
        }
    })
    m.grid.content = content
  ~~~~

## Content Getters

A content getter is a component responsible for populating content for
views.

To load certain data for a view, use content getters.

To add root Content Getter, add it to the content of the created view:

~~~~
m.grid = CreateObject("roSGNode", "GridView")
 
content = CreateObject("roSGNode", "ContentNode")
 
    content.AddFields({
        HandlerConfigGrid: {
            name: "CGRoot"
            fields : { param: "123" }
        }
    })
 
    m.grid.content = content
~~~~

Each SGDEX view has an Associative Array (AA) Content Getter field and
contains the following:

name \[required\] - Project Content Getter component name

fields \[optional\] - Developer interface fields to be populated

### Default Content Getter

#### Interfaces

Content getter provides a predefined list of interfaces:

<table>
<thead>
<tr class="header">
<th><strong>Field</strong></th>
<th><strong>Description</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>content</td>
<td>Contentto be modified by the content getter. This content can be the view's content field or a child of it when the content for the child needs to be loaded (Example, a row in the grid or an item in the details or video view)</td>
</tr>
<tr class="even">
<td>handlerConfig</td>
<td><p>Config added by the developer. Use handlerConfig to read the value of the config or restore it to content if needed</p>
<p><strong>Note</strong>: Content getter removes processed Configs. If data needs to be reloaded each time content is shown, restore the config for the content in the proper Content Getter</p></td>
</tr>
<tr class="odd">
<td>offset</td>
<td>Indicates which offset is in use. Use offset for horizontal lazy loading of the grid row</td>
</tr>
<tr class="even">
<td>pageSize</td>
<td>Indicates the page size configured by the developer. Used for horizontal lazy loading of the grid row</td>
</tr>
</tbody>
</table>

### Implementing Content Getter

To implement a Content Getter, create a component and extend it from
ContentHandler.

**Example**

~~~~
<?xml version="1.0" encoding="UTF-8"?>
 
<component name="CGRoot" extends="ContentHandler" xsi:noNamespaceSchemaLocation="https://devtools.web.roku.com/schema/RokuSceneGraph.xsd">
 
    <script type="text/brightscript" uri="pkg:/components/content/CGRoot.brs" />
 
</component>
~~~~

Content Getter implements only one required function GetContent() that
does not return anything:

~~~~
sub GetContent()
 
    'This is only a sample. Usually the feed is retrieved from an url using roUrlTransfer
 
    feed = ReadAsciiFile("pkg:/components/content/feed.json")
 
    if feed.Len() > 0
        json = ParseJson(feed)
        if json <> invalid AND json.rows <> invalid AND json.rows.Count() > 0
            rootChildren = []
 
            for each row in json.rows
                if row.items <> invalid
                    children = []
 
                    for childIndex = 0 to 3
 
                        for each item in row.items
                            itemNode = CreateObject("roSGNode", "ContentNode")
                            itemNode.SetFields(item)
                            children.Push(itemNode)
                        end for
                    end for
 
                    rowNode = CreateObject("roSGNode", "ContentNode")
                    rowNode.SetFields({ title: row.title })
                    rowNode.AppendChildren(children)
 
                    rootChildren.Push(rowNode)
 
                end if
            end for
 
            m.top.content.AppendChildren(rootChildren)
 
        end if
    end if
end sub
~~~~

####   Contents of the JSON file

~~~~
{
    "rows": [{
        "title": "ROW 1",
 
        "items": [{
                "hdPosterUrl": "poster_url"
            },{
                "hdPosterUrl": "poster_url"
            },{
                "hdPosterUrl": "poster_url"
            },{
                "hdPosterUrl": "poster_url"
        }]
    },{
        "title": "ROW 2",
        "items": [{
            "hdPosterUrl": "poster_url"
        },{
            "hdPosterUrl": "poster_url"
        },{
            "hdPosterUrl": "poster_url"
        },{
            "hdPosterUrl": "poster_url"
        }]
    }]
}
~~~~

**Note:** According to SceneGraph best practices, it is suggested to use

~~~~
m.top.content.AppendChildren(rootChildren)
~~~~

As this removes multiple rendezvous between the render thread and the
task node.

## Opening next view

To open a new view for a certain action, use the same mechanism to
create and populate the view.

For example, to open details screen upon selection on a grid, use:

Assuming the following has been executed,

~~~~
m.grid.ObserveField("rowItemSelected", "OnGridItemSelected")
~~~~

Implement the function OnGridItemSelected:

~~~~
sub OnGridItemSelected(event as Object)
 
    grid = event.GetRoSGNode()
    selectedIndex = event.getdata()
    rowContent = grid.content.getChild(selectedIndex[0])
 
    detailsScreen = ShowDetailsScreen(rowContent, selectedIndex[1])
    detailsScreen.ObserveField("wasClosed", "OnDetailsWasClosed")
end sub
~~~~

## DetailsView

In /components/DetailsScreenLogic.brs

~~~~
function ShowDetailsScreen(content, index)
 
    details = CreateObject("roSGNode", "DetailsView")
 
    details.content = content
    details.jumpToItem = index
 
    details.ObserveField("currentItem", "OnDetailsContentSet")
 
    details.ObserveField("buttonSelected", "OnButtonSelected")
 
    'Triggers a job to show the view
 
    m.top.ComponentController.callFunc("show", {
 
        view: details
    })
    return details
end function
~~~~

The above code creates new details view and passes grid row as the
content for details. It also uses jumpToItem to set starting index.

If the developer does not want to pass a list of items but only one
item, they can use the snippet below:

~~~~
details.content = content.getChild(index)
 
'Tells details screen that only one item should be visible
 
details.isContentList = false
 
'isContentList – Informs details view that this is a proper item and can be rendered such that no extra items are loaded
~~~~


###   Details view interfaces

Details view provides several interfaces:

buttons type = "node"

### Buttons content node

Buttons support same content meta-data fields as Label list which sets
the title as well as a small icon for each button.

**Fields description**

<table>
<thead>
<tr class="header">
<th><strong>Field</strong></th>
<th><strong>Type</strong></th>
<th><strong>Default</strong></th>
<th><strong>Description</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>TITLEÂ </td>
<td></td>
<td></td>
<td>The label for the list item</td>
</tr>
<tr class="even">
<td>HDLISTITEMICONURL</td>
<td></td>
<td></td>
<td>The image file for the icon displayed to the left of the list item label when the list item is not focused</td>
</tr>
<tr class="odd">
<td>HDLISTITEMICONSELECTEDURL</td>
<td></td>
<td></td>
<td>The image file for the icon to be displayed to the left of the list item label when the list item is focused</td>
</tr>
<tr class="even">
<td>isContentList</td>
<td>Boolean</td>
<td>True</td>
<td><p>Tells details view how your content is structured</p>
<ul>
<li><p>If set to true it will take children of content to display on the screen</p></li>
<li><p>If set to false it will take content and display it on the screen</p></li>
</ul></td>
</tr>
<tr class="odd">
<td>allowWrapContent</td>
<td>Boolean</td>
<td>True</td>
<td><p>Defines the logic of showing content when pressing left on the first item or pressing right on the last item</p>
<p>If set to true, it starts playback from first item (when pressing right) or the last item (when pressing left) </p></td>
</tr>
<tr class="even">
<td>itemFocused</td>
<td>Integer</td>
<td></td>
<td>Indicates the item currently in focus</td>
</tr>
<tr class="odd">
<td>jumpToItem</td>
<td>Integer</td>
<td></td>
<td>Manually focus on the desired item</td>
</tr>
<tr class="even">
<td>buttonFocused </td>
<td>Integer</td>
<td></td>
<td>Tells what button is focused</td>
</tr>
<tr class="odd">
<td>buttonSelected</td>
<td>Integer</td>
<td></td>
<td>Is set when the button is selected by a user</td>
</tr>
<tr class="even">
<td>jumpToButton</td>
<td>Integer</td>
<td></td>
<td>Interface for setting the focused button</td>
</tr>
<tr class="odd">
<td>currentItem</td>
<td>Node</td>
<td></td>
<td><p>Currently displayed item</p>
<p>This item is set when the Content Getter finishes loading extra meta-data</p></td>
</tr>
</tbody>
</table>

### Getting extra metadata for details view

Sometimes when setting content to details view you are still pending
some info to be loaded to properly show this item.

To resolve this issue you should use content getter for details screen.

~~~~
function ShowDetailsScreen(content)
 
    details = CreateObject("roSGNode", "DetailsView")
 
    for each child in content.getChildren(-1, 0)
 
        'Tells details view which content getter is responsible for getting the content
 
        child.HandlerConfigDetails = {
            name: "GetDetailsContentConfig"
        }
 
    end for
 
    details.content = content
 
    'this will trigger job to show this screen
 
    m.top.ComponentController.callFunc("show", {
        view: details
    })
    return details
end function
~~~~

## Opening non-SGDEX view

SGDEX is not limited to use only SGDEX views; the channel can show its
own view and observe its fields.

To open a non-SGDEX view, create, and populate interface fields, set
observers and call:

~~~~
 m.top.ComponentController.callFunc("show", {
        view: yourViewNode
    })
~~~~

This hides the current view (if any) and displays theÂ non-SGDEX view.

**Note:** Component controller set's focus on your view, so your view
should implement proper focus handling.

**Example**

~~~~
<?xml version="1.0" encoding="UTF-8"?>
 
<component name="CustomView" extends="Group" xsi:noNamespaceSchemaLocation="https://devtools.web.roku.com/schema/RokuSceneGraph.xsd">
    <script type = "text/brightscript" uri="pkg:/components/customView.brs"/ >
    <children>
        <Group id="container">
            <Button id="btn" text="Push Me"/>
        </Group>
    </children>
</component>
~~~~

In /components/customView.brs, add:

~~~~
function init() as void
 
        m.btn = m.top.findNode("btn")
        m.top.observeField("focusedChild", "OnChildFocused")
 
    end function
 
    sub OnChildFocused()
 
        if m.top.isInFocusChain() and not m.btn.hasFocus() then
            m.btn.setFocus(true)
        end if
    end sub
  ~~~~

Whenever the view receives focus, it should be checked if it's in the
focus chain and the node unfocused.

Focus handling is important as component controller sets focus to
a non-SGDEX view in two cases:

  - The view is just shown

  - The view is restored after top view was closed

Component Controller is responsible for closing this view when the back
button is pressed.

If the view needs to be closed manually, a new field called "close"
should be added to the view.

By setting yourView.close = true, the developer can close the current
view and the previous view is opened.


###### Copyright (c) 2018 Roku, Inc. All rights reserved.
