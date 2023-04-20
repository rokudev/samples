# SGDEX Components:  
* [ComponentController](#componentcontroller) 
* [BaseScene](#basescene)  
* [ContentHandler](#contenthandler)
* [EntitlementHandler](#entitlementhandler) 
* [RAFHandler](#rafhandler)  
* [SGDEXComponent](#sgdexcomponent)  
* [CategoryListView](#categorylistview)
* [VideoView](#videoview) 
* [DetailsView](#detailsview) 
* [GridView](#gridview) 
* [EntitlementView](#entitlementview)  

____


## ComponentController

**Extends: [Group](https://sdkdocs.roku.com/display/sdkdoc/Group)**

### Description

The ComponentController component implements the basic default view
management. It essentially implements the view stack. Further, the
component also handles view to view navigation, back button handling,
and showing and closing views. The developer can use ComponentController
to call the show() function to add views to the view stack and make them
visible. Developers do not need to create ComponentController instances
in their channels. This is created on the channel's scene by SGDEX if
the scene is extended from
BaseScene.

### Interface

#### Fields

| **Field**                   | **Type** | **Default** | **Use**                                                                                                                |
| --------------------------- | -------- | ----------- | ---------------------------------------------------------------------------------------------------------------------- |
| currentView                 | Node     |  -          | Holds the reference to the view that is currently shown                                                                |
| allowCloseChannelOnLastView | Boolean  | True        | If true, the channel closes when the back button is pressed or if the previous view set the view's close field to true |
| allowCloseLastViewOnBack    | Boolean  | True        | If true, the current view is closed, and the user can open another view through the new view's wasClosedÂ callback      |

####   
Functions

| **Function** | **Description**                                            |
| ------------ | ---------------------------------------------------------- |
| show         | Called to add a view to the view stack and make it visible |

**Example**

**Using ComponentController**  
~~~~
m.top.ComponentController.callFunc("show", {

view: screen

})
~~~~
## BaseScene

**Extends: [Scene](https://sdkdocs.roku.com/display/sdkdoc/Scene)**

### Description

As with any other Roku SceneGraph based channel, SGDEX channels
implement a main scene that host all other channel views and components;
this scene is derived from BaseScene. BaseScene provides a variety of
default functionality. The function show() should be overridden in the
channel to implement any view specific initialization.

### Interface

#### Fields

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
<td>ComponentController</td>
<td>Node</td>
<td>-</td>
<td><p>This field holds the ComponentController instance created by SGDEX for use in the channel</p>
<p><strong>Read Only</strong></p></td>
</tr>
<tr class="even">
<td>exitChannel</td>
<td>Boolean</td>
<td>False</td>
<td><p>Exits channel if set to true</p>
<p><strong>Write Only</strong></p></td>
</tr>
<tr class="odd">
<td>theme</td>
<td>Associative array</td>
<td>{ }</td>
<td><p>Theme is used to customize the appearance of all SGDEX views</p>
<p>For common fields, see SGDEXComponent</p>
<p>For view-specific views, refer to:</p>
<ul>
<li><p><a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-GridViewthemeattributes">GridView</a></p></li>
</ul>
<ul>
<li><p><a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-DetailsViewthemeattributes">DetailsView</a></p></li>
</ul>
<ul>
<li><p><a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-VideoViewthemeattributes">VideoView</a></p></li>
</ul>
<ul>
<li><p><a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-CategoryListViewthemeattributes">CategoryListView</a></p></li>
</ul>
<p>Theme attributes can be global so that they apply to any view that supports the specific theme attribute. They can also be set at the view level in which case, they apply to that view component type only:</p>
<p><strong>Make All Views Have Red Text</strong> </p>

<p>'All views will have red text</p>

<p><code>scene.theme = {
 global: {
 textColor: &quot;FF0000FF&quot;
  }
}</code></p>

<p><strong>Make All Grid View Text Red</strong></p>

<p><code>scene.theme = {
gridView: {
textColor: &quot;FF0000FF&quot;
}
}</code></p>

<p>Theme attributes can also be set on specific view instances. For example, this specific grid is set to have red text:</p>
<p><strong>Use view's theme field to set its theme</strong></p>

<p><code>view = CreateObject(&quot;roSGNode&quot;, &quot;GridView&quot;)
view.theme = {
 textColor: &quot;FF0000FF&quot;
}</code></p>

<p>The model can also be used to create a hierarchy of themes. For example, the code below makes the text of all views red, globally, expect for all grid view instances (this is green.) The text color theme attribute is further modified for the specific view2 instance, which the code sets to white.</p>
<p>Because textColor is globally set to red, the detailsView instance will have red text as none of the theme overrides in the hierarchy impact details views.</p>

<p><code>scene.theme = {
  global: {
  textColor: &quot;FF0000FF&quot;
  }
 gridView: {
    textColor: &quot;00FF00FF&quot;
   }
}
view1 = CreateObject(&quot;roSGNode&quot;, &quot;GridView&quot;)
view2 = CreateObject(&quot;roSGNode&quot;, &quot;GridView&quot;)
view2.theme = {
  textColor: &quot;FFFFFFFF&quot;
}
detailsView= CreateObject(&quot;roSGNode&quot;, &quot;DetailsView&quot;)</code></p>
</td>
</tr>
<tr class="even">
<td>updateTheme</td>
<td>Associative array</td>
<td>{ }</td>
<td><p>Used to update theme attributes. This field can be set to a theme config similar to the original theme field. Only the attributes that need to be changed have to be set</p>
<p><strong>Note:</strong> When changing many theme fields, do this with as few updates as possible to prevent frequent redraws</p></td>
</tr>
</tbody>
</table>

**Example**

**Using BaseScene**  

~~~~
// MainScene.xml
<?xml version="1.0" encoding="UTF-8"?>
<component name="MainScene" extends="BaseScene" >
<script type="text/brightscript" uri="pkg:/components/MainScene.brs" />
</component>
 
// MainScene.brs
sub Show(args)
homeGrid = CreateObject("roSGNode", "GridView")
    homeGrid.content = GetContentNodeForHome() 'implemented by user
    homeGrid.ObserveField("rowItemSelected","OnGridItemSelected")
'this will trigger job to show the view
m.top.ComponentController.callFunc("show", {
    view: homeGrid
    })
end sub
~~~~

## ContentHandler

**Extends: [Task](https://sdkdocs.roku.com/display/sdkdoc/Task)**

### Description

Content Handlers are responsible for all content loading tasks in SGDEX.
Channels typically extend ContentHandler to implement specific content
or data loading tasks. ContentHandlers should implement a
function called GetContent(). This function is called by SGDEX,
allowing the handler to make application specific API calls or perform
other operations to load the content associated with the handler.

### Interface

#### Fields

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
<td>content</td>
<td>Node</td>
<td>-</td>
<td>Modified in the GetContent() function by adding/updating the Content Nodes being rendered by the associated view</td>
</tr>
<tr class="even">
<td>offset</td>
<td>Integer</td>
<td>0</td>
<td>When working with paged data, offset reflects which page of content SGDEX is expecting to populate using ContentHandler</td>
</tr>
<tr class="odd">
<td>pageSize</td>
<td>Integer</td>
<td>0</td>
<td>When working with paged data, pageSize reflects the number of items SGDEX is expecting to populate using ContentHandler</td>
</tr>
<tr class="even">
<td>failed</td>
<td>Boolean</td>
<td>False</td>
<td><p>Indicates if the ContentHandler failed to load the requested content</p>
<p>If GetContent() sets this field to true, SGDEX will try to load the content again using the ContentHandler instance.<br />
Alternatively, the channel can set a new HandlerConfig to the content field. This causes SGDEX to use the new config when it re-tries using the ContentHandler</p>
<p>If the HandlerConfig is not updated, SGDEX will re-use the original one for subsequent tries</p></td>
</tr>
<tr class="odd">
<td>HandlerConfig</td>
<td>Associative array</td>
<td>{ }</td>
<td>Contains a reference to the ContentHandler config</td>
</tr>
</tbody>
</table>

**Example**

**Using ContentHandler** 

~~~~
// SimpleContentHandler.xml
 
<?xml version="1.0" encoding="UTF-8"?>
<component name="SimpleContentHandler" extends="ContentHandler" >
<script type="text/brightscript" uri="pkg:/components/content/SimpleContentHandler.brs" />
</component>
 
// SimpleContentHandler.brs
 
sub GetContent()
m.top.content.SetFields({
    title: "Hello World"
         })
end sub
~~~~

## EntitlementHandler

**Extends:** [**Task**](https://sdkdocs.roku.com/display/sdkdoc/Task)

### Description

Entitlement Handlers are used together with the EntitlementView
component to let developers leverage Roku Billing for buildinng a basic
SVOD for their channels. The Entitlement Handler is used to let SGDEX
know about the subscription products associated with the channel.

The developer can implement a Handler in the channel that extends
EntitlementHandler. In this handler, they can override two functions:

  - ConfigureEntitlements(config) \[Required\]

  - OnPurchaseSuccess(transactionData) \[Optional\]

For ConfigureEntitlements, the channel can update the config with its
own params.

The config should contain the following fields:

config.products \[Array\] of AAs having fields

  - config.products.code \[String\]: Product code in ChannelStore

  - config.products.hasTrial \[Boolean\]: True if theÂ product's trial
    period has expired

OnPurchaseSuccess is a callback that allows the developer to inject some
custom logic on purchase success by overriding this subroutine. The
default implementation for this callback is set to taking no
action.

### Interface

#### Fields

| **Field** | **Type** | **Default** | **Description**                                                                               |
| --------- | -------- | ----------- | --------------------------------------------------------------------------------------------- |
| content   | Node     | \-          | The content node from EntitlementView is passed here; the developer can use it inÂ the handler|
| view      | Node     | \-          | It refers to the EntitlementView where the specific handler was created                       |

**Example**

**Using EntitlementHandler** 

~~~~
// [In <component name="HandlerEntitlement" extends="EntitlementHandler"> in channel]
sub ConfigureEntitlements(config as Object)
config.products = [
'{code: "PROD1", hasTrial: false}
{code: "PROD2", hasTrial: false}
    ]
end sub
~~~~

## RAFHandler

**Extends: [Task](https://sdkdocs.roku.com/display/sdkdoc/Task)**

### Description

The RAFHandler component is the SGDEX wrapper for the Roku Ad Framwork
(RAF). The developer extends this component in the channel and
implements ConfigureRAF(adIface as Object).

They can further implement any desired configuration supported by RAF in
ConfigRAF().

**Example**

**Using RAFHandler** 

~~~~
sub ConfigureRAF(adIface)
// Detailed RAF docs: https://sdkdocs.roku.com/display/sdkdoc/Integrating+the+Roku+Advertising+Framework
adIface.SetAdUrl("http://www.some.ad.url.com")
adIface.SetContentGenre("General Variety")
adIface.SetContentLength(1200) ' in seconds
// Nielsen specific data
adIface.EnableNielsenDAR(true)
adIface.SetNielsenProgramId("CBAA")
adIface.SetNielsenGenre("GV")
adIface.SetNielsenAppId("P123QWE-1A2B-1234-5678-C7D654348321")
end sub
~~~~

## SGDEXComponent

**Extends: [Group](https://sdkdocs.roku.com/display/sdkdoc/Group)**

### Description

This is the base component for all SGDEX views.

### Interface

#### Fields

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
<td>theme</td>
<td>Associative array</td>
<td>{ }</td>
<td><p>Theme is used to set view specific theme fields</p>
<p>To update a value, use updateTheme</p>
<p>For a list of the common attributes for all view, refer to Common theme attributes<br />
<br />
<strong>Usage</strong></p>
<p>See the theme attribute description in the BaseScene component section above</p></td>
</tr>
<tr class="even">
<td>updateTheme</td>
<td>Associative array</td>
<td>{ }</td>
<td><p>Used to update view specific theme fields</p>
<p>Usage is same as theme field but here, only the field that needs to be updated is set</p>
<p>For global updates, set the updateTheme field on the channel's scene. This assumes the scene is extended from BaseScene</p></td>
</tr>
<tr class="odd">
<td>style</td>
<td>String</td>
<td>&quot;Standard&quot;</td>
<td><p>Indicates what style to use for a view</p>
<p>The style is view specific</p>
<p>For example, GridView supports standard and hero styles</p></td>
</tr>
<tr class="even">
<td>posterShape</td>
<td>String</td>
<td>&quot;16X9&quot;</td>
<td>Indicates what poster shape to use for the posters rendered on the view</td>
</tr>
<tr class="odd">
<td>content</td>
<td>Node</td>
<td>-</td>
<td>Holds the view content. The content structure is defined by the specific view</td>
</tr>
<tr class="even">
<td>close</td>
<td>Boolean</td>
<td>False</td>
<td>A control field that tells the view manager to close a view</td>
</tr>
<tr class="odd">
<td>wasClosed</td>
<td>Boolean</td>
<td>False</td>
<td>Indicates when a view is closed and removed from the view manager</td>
</tr>
<tr class="even">
<td>saveState</td>
<td>Boolean</td>
<td>False</td>
<td>Indicates when a view is hidden, and a new top view is opened</td>
</tr>
<tr class="odd">
<td>wasShown</td>
<td>Boolean</td>
<td>False</td>
<td>Indicates when a view was shown for the first time or restored after the top view was closed</td>
</tr>
</tbody>
</table>

## CategoryListView

**Extends: SGDEXComponent**

### Description

CategoryListView represents the SGDEX category list view that has two
lists; one for categories and another for the items in the category.

### Interface

#### Fields

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
<td>initialPosition</td>
<td>Vector2D</td>
<td>[0, 0]</td>
<td>Indicates where initial focus is set on the itemsList: 1st coordinate = category, 2st coordinate = item in this category</td>
</tr>
<tr class="even">
<td>selectedItem</td>
<td>Vector2D</td>
<td>[0, 0]</td>
<td><p>Array with 2 integers; returns the section and item in the current section that was selected</p>
<p><strong>Read Only</strong></p></td>
</tr>
<tr class="odd">
<td>focusedItem</td>
<td>Integer</td>
<td>0</td>
<td><p>Returns the currently focused item index (within all categories)</p>
<p><strong>Read Only</strong></p></td>
</tr>
<tr class="even">
<td>focusedItemInCategory</td>
<td>Integer</td>
<td>0</td>
<td>Returns the currently inÂ focusÂ item index from the current focusedCategory</td>
</tr>
<tr class="odd">
<td>focusedCategory</td>
<td>Integer</td>
<td>0</td>
<td>Returns the currently in focus category index</td>
</tr>
<tr class="even">
<td>jumpToItem</td>
<td>Integer</td>
<td>0</td>
<td><p>Jumps toÂ an itemÂ in the items list (within all categories)</p>
<p>This field must be set after setting the content field only</p>
<p><strong>Write Only</strong></p></td>
</tr>
<tr class="odd">
<td>animateToItem</td>
<td>Integer</td>
<td>0</td>
<td><p>Animates to an item in the items list (within all categories)</p>
<p><strong>Write Only</strong></p></td>
</tr>
<tr class="even">
<td>jumpToCategory</td>
<td>Integer</td>
<td>0</td>
<td><p>Jumps to a category</p>
<p><strong>Write Only</strong></p></td>
</tr>
<tr class="odd">
<td>animateToCategory</td>
<td>Integer</td>
<td>0</td>
<td><p>Animates to a category</p>
<p><strong>Write Only</strong></p></td>
</tr>
<tr class="even">
<td>jumpToItemInCategory</td>
<td>Integer</td>
<td>0</td>
<td><p>Jumps to an item in the current category</p>
<p><strong>Write Only</strong></p></td>
</tr>
<tr class="odd">
<td>animateToItemInCategory</td>
<td>Integer</td>
<td>0</td>
<td><p>Animates to an item in the current category</p>
<p><strong>Write Only</strong></p></td>
</tr>
<tr class="even">
<td>theme</td>
<td>Associative array</td>
<td>{ }</td>
<td><p>Used to change the colorÂ of the grid view elements</p>
<p><strong>Note:</strong> Set TextColor and focusRingColor to have a generic theme and only change attributes that would not use it</p>
<p>For all the Possible values of the field, refer to <a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-CategoryListViewthemeattributes">CategoryListView theme attributes</a></p></td>
</tr>
<tr class="odd">
<td>content</td>
<td>Node</td>
<td>-</td>
<td><p>Follows the model below to build a proper content node</p>
<p><strong>Possible fields</strong></p>
<p>Category fields:</p>
<table>
<thead>
<tr class="header">
<th><strong>Field</strong></th>
<th><strong>Description</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>TITLE</td>
<td>Title displayed for the category name</td>
</tr>
<tr class="even">
<td>CONTENTTYPE</td>
<td>Must be set to SECTION</td>
</tr>
<tr class="odd">
<td>HDLISTITEMICONURL</td>
<td>The image file for the icon to be displayed to the left of the list item label when the list item is <strong>not</strong> in focus</td>
</tr>
<tr class="even">
<td>HDLISTITEMICONSELECTEDURL</td>
<td>The image file for the icon to be displayed to the left of the list item label when the list item is in focus</td>
</tr>
<tr class="odd">
<td>HDGRIDPOSTERURL</td>
<td>The image file for the icon to be displayed to the left of the section label when the screen resolution is set to HD</td>
</tr>
</tbody>
</table>
<p>Item List fields:</p>
<table>
<thead>
<tr class="header">
<th><strong>Field</strong></th>
<th><strong>Description</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>title</td>
<td>The title shown</td>
</tr>
<tr class="even">
<td>description</td>
<td>Descriptionfor an item, maximum 4 lines</td>
</tr>
<tr class="odd">
<td>hdPosterUrl</td>
<td>The imageÂ URL for an item</td>
</tr>
</tbody>
</table></td>
</tr>
</tbody>
</table>

**Example**

**Using CategoryListView** 

~~~~
CategoryList = CreateObject("roSGNode", "CategoryListView")
    CategoryList.posterShape = "square"
 
content = CreateObject("roSGNode", "ContentNode")
    content.Addfields({
HandlerCategoryList: {
    name: "CGSeasons"
     }
})
 
CategoryList.content = content
    CategoryList.ObserveField("selectedItem", "OnEpisodeSelected")
 
'Triggers a job to show the view
m.top.ComponentController.CallFunc("show", {
    view: CategoryList
})
 
// Advanced loading logic
 
root = {
HandlerConfigCategoryList: {
_description: "Content handler that will be called to populate categories if they are not created"
    name: "Component name that extends [ContentHandler](#ContentHandler)"
    fields: {
        field: "any field that you want to set in this component when it's created"
       }
   }
 
_comment: "categories"
children: [{
    title: "Category that is prepopulated"
    contentType: "section"
children: [{
    title: "Title to be shown"
    description: "Description for item, max 4 lines"
    hdPosterUrl: "image url for item"
   }]
  
_optionalFields: "Fields that can be used for category"
 
HDLISTITEMICONURL: "icon that will be shown left to category when not focused"
HDLISTITEMICONSELECTEDURL: "icon that will be shown left to category title when focused"
HDGRIDPOSTERURL: "icon that will be shown left to title in item list"
  },
  
{
title: "Category that requires content to be loaded"
    contentType: "section"
 
HandlerConfigCategoryList: {
_description: "Content handler that will be called if there are no children in category"
    name: "Component name that extends [ContentHandler](#ContentHandler)"
    fields: {
        field: "any field that you want to set in this component when it's created"
        }
     }
 },
  
{
title: "Category that has children but they need metadata (non serial model)"
    contentType: "section"
 
HandlerConfigCategoryList: {
_description: "Content handler that will be called if "
    name: "Component name that extends [ContentHandler](#ContentHandler)"
_note: "use bigger value for page size to improve performance"
_mandatatory: "This field is required in order to work"
 
pageSize: 2
    fields: {
        field: "any field that you want to set in this component when it's created"
        }
    }
children: [{title: "Title to be shown"}
{title: "Title to be shown"}
{title: "Title to be shown"}
{title: "Title to be shown"}]
  },
  
{
title: "Category has children but there are more items that can be loaded"
    contentType: "section"
 
HandlerConfigCategoryList: {
_description: "Content handler will be called when focused near end of category"
    name: "Component name that extends [ContentHandler](#ContentHandler)"
_mandatatory: "This field is required in order to work"
    hasMore: true
    fields: {
        field: "any field that you want to set in this component when it's created"
        }
   }
 
children: [{
    title: "Title to be shown"
    description: "Description for item, max 4 lines"
    hdPosterUrl: "image url for item"
          }]
    }]
}
 
CategoryList = CreateObject("roSGNode", "CategoryListView")
    CategoryList.posterShape = "square"
 
content = CreateObject("roSGNode", "ContentNode")
    content.update(root)
 
CategoryList.content = content
 
'Triggers a job to show the view
m.top.ComponentController.CallFunc("show", {
    view: CategoryList
 })
~~~~

## VideoView

**Extends: SGDEXComponent**

### Description

VideoView is the SGDEX component is used by channels to play content. It
includes a number of different features, including:

  - Playback of a single video or a video playlist;

  - Loading of content via HandlerConfigVideo before playback;

  - Showing endcards view after a video playback ends;

  - Loading of endcard content via HandlerConfigEndcard before the video
    ends for performance benefit;

  - Handling of RAF - handlerConfigRAF is set in the content node;

  - Video.state field is aliased to make tracking of states easier;

  - Theme support

### Interface

#### Fields

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
<td>endcardCountdownTime</td>
<td>Integer</td>
<td>10</td>
<td><p>Returns the endcard countdown time</p>
<p>Indicates how long the endcard is shown for before the next video starts playing</p></td>
</tr>
<tr class="even">
<td>endcardLoadTime</td>
<td>Integer</td>
<td>10</td>
<td>Returns the time at which the video ends so that the endcard content can start loading</td>
</tr>
<tr class="odd">
<td>alwaysShowEndcards</td>
<td>Boolean</td>
<td>False</td>
<td>Config that indicates when the VideoView shows the endcard with the default next item and the repeat button even if the content getter is not specified by the user</td>
</tr>
<tr class="even">
<td>isContentList</td>
<td>Boolean</td>
<td>True</td>
<td>Indicates if the content is a playlist or an individual item</td>
</tr>
<tr class="odd">
<td>jumpToItem</td>
<td>Integer</td>
<td>0</td>
<td><p>Jumps to an item in the playlist</p>
<p>This field must be set after setting the content field </p></td>
</tr>
<tr class="even">
<td>control</td>
<td>String</td>
<td>&quot;none&quot;</td>
<td><p>Controls &quot;play&quot; and &quot;prebuffer&quot; and starts loading content from Content Getter</p>
<p>If any other control is defined, it issetdirectly to the video node</p></td>
</tr>
<tr class="odd">
<td>endcardTrigger</td>
<td>Boolean</td>
<td>False</td>
<td>Trigger to notify channel that endcard loading has started</td>
</tr>
<tr class="even">
<td>currentIndex</td>
<td>Integer</td>
<td>-1</td>
<td>Indicates what is theÂ indexÂ of the current item - index of a child in the content</td>
</tr>
<tr class="odd">
<td>state</td>
<td>String</td>
<td>&quot;none&quot;</td>
<td>State of the Video Node</td>
</tr>
<tr class="even">
<td>position</td>
<td>Integer</td>
<td>0</td>
<td>Playback position in seconds</td>
</tr>
<tr class="odd">
<td>duration</td>
<td>Integer</td>
<td>0</td>
<td>Playback duration in seconds</td>
</tr>
<tr class="even">
<td>currentItem</td>
<td>Node</td>
<td>-</td>
<td><p>Indicates the current item in the content node</p>
<p>If changing this field manually, unexpected behavior can occur</p>
<p><strong>Read Only</strong></p></td>
</tr>
<tr class="odd">
<td>endcardItemSelected</td>
<td>Node</td>
<td>-</td>
<td>The content node of the selected endcard item</td>
</tr>
<tr class="even">
<td>disableScreenSaver</td>
<td>Boolean</td>
<td>False</td>
<td><p>This is an alias of the video node's field of the same name</p>
<p>Refer to <a href="https://sdkdocs.roku.com/display/sdkdoc/Video#Video-MiscellaneousFields">Video nodes</a> for the description of the field</p></td>
</tr>
<tr class="odd">
<td>theme</td>
<td>Associative array</td>
<td>{ }</td>
<td><p>Theme is used to change the color of the grid view elements</p>
<p><strong>Note:</strong> Set TextColor and focusRingColor to have a generic theme and only change the attributes not using the generic theme</p>
<p>For the possible <a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-VideoViewthemeattributes">VideoView</a> values, refer to:</p>
<ul>
<li><p><a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-Generalfields">General attributes</a></p></li>
<li><p><a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-Videoplayerfields">Video player attributes </a></p></li>
<li><p><a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-BufferingBarcustomization">Buffering bar attributes</a></p></li>
<li><p><a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-RetrievingBarcustomization">Retrieving bar attributes </a></p></li>
</ul>
<p>For the possible <a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-Endcardthemeattributes">EncardView</a> values, refer to :</p>
<ul>
<li><p><a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-Viewattributes">View attributes</a></p></li>
<li><p><a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-Gridattributes">Grid attributes</a></p></li>
</ul></td>
</tr>
</tbody>
</table>

**Example**

**Using VideoView** 

~~~~
video = CreateObject("roSGNode", "VideoView")
 
    video.content = content
    video.jumpToItem = index
    video.control = "play"
 
m.top.ComponentController.callFunc("show", {
    view: video
    })
 
'User can observe video.endcardItemSelected to handle endcard selection
'video.currentIndex or video.currentItem fields can be used to track what was the last video after a video is closed.
~~~~

## 

## DetailsView

**Extends: SGDEXComponent**

### Description

DetailsView is the SGDEX equivalent of the springboard screen that was
used in the legacy Roku SDK. It can be used to show poster art for
content, text descriptions, and a set of action buttons defined by the
buttons field. These buttons support the content meta data fields listed
below for customizing the text and images displayed in the
button.

**Fields **

| **Field**                 | **Type** | **Description**                                                                                                       |
| ------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------- |
| TITLE                     | String   | The label for the list item                                                                                           |
| HDLISTITEMICONURL         | Uri      | The image file for the icon to be displayed to the left of the list item label when the list item is **not** in focus |
| HDLISTITEMICONSELECTEDURL | Uri      | The image file for the icon to be displayed to the left of the list item label when the list item is in focus         |

### Interface

#### Fields

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
<td>buttons</td>
<td>Node</td>
<td>-</td>
<td><p>The content node for a button's node</p>
<p>Has children with an ID and a title that is shown on the view</p></td>
</tr>
<tr class="even">
<td>isContentList</td>
<td>Boolean</td>
<td>True</td>
<td><p>Tells details view how your content is structured<br />
If set to true it will take children of content to display on the view<br />
If set to false it will take content and display it on the view</p>
<p><strong>Write Only</strong></p></td>
</tr>
<tr class="odd">
<td>allowWrapContent</td>
<td>Boolean</td>
<td>True</td>
<td><p>Defines the logic of showing content when pressing left on the first item or pressing right on the last item</p>
<p>If set to true, start playback from the first item (when pressing right) or starts it from the last item (when pressing left)</p>
<p><strong>Write Only</strong></p></td>
</tr>
<tr class="even">
<td>currentItem</td>
<td>Node</td>
<td>-</td>
<td><p>Returns the currently displayed item</p>
<p>This field is set when the Content Getter finishes loading extra meta-data</p>
<p><strong>Read Only</strong></p></td>
</tr>
<tr class="odd">
<td>itemFocused</td>
<td>Integer</td>
<td>0</td>
<td>Indicates which item is currently focused</td>
</tr>
<tr class="even">
<td>jumpToItem</td>
<td>Integer</td>
<td>0</td>
<td><p>Manually focuses on the desired item</p>
<p>Must be set after setting the content field</p>
<p><strong>Write Only</strong></p></td>
</tr>
<tr class="odd">
<td>buttonFocused</td>
<td>Integer</td>
<td>0</td>
<td><p>Indicates which button is focused</p>
<p><strong>Read Only</strong></p></td>
</tr>
<tr class="even">
<td>buttonSelected</td>
<td>Integer</td>
<td>0</td>
<td><p>Is set when a button is selected by the user</p>
<p>Observed in the channel</p>
<p>Can be used to show the next screen or start a playback</p>
<p><strong>Read Only</strong></p></td>
</tr>
<tr class="odd">
<td>jumpToButton</td>
<td>Integer</td>
<td>0</td>
<td><p>Interface for setting focused button</p>
<p><strong>Write Only</strong></p></td>
</tr>
<tr class="even">
<td>theme</td>
<td>Associative array</td>
<td>{ }</td>
<td><p>Controls the color of visual elements</p>
<p>For a list of all the possible values, refer to <a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-DetailsViewthemeattributes">DetailsView theme attributes</a></p></td>
</tr>
</tbody>
</table>

## GridView

**Extends: SGDEXComponent**

### Description

The GridView component defines a standard content grid. In conjunction
with ContentHandlers, SGDEX grids can be implemented to support:

  - Content loading;

  - Lazy loading of the rows and an item in the row;

  - Lazy loading of the rows when a user is not browsing the grid

### Interface

#### Fields

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
<td>rowItemFocused</td>
<td>Vector2D</td>
<td>[0, 0]</td>
<td>Updated when focused item changes<br />
Value is an array containing the index of the row and the items that were focused</td>
</tr>
<tr class="even">
<td>rowItemSelected</td>
<td>Vector2D</td>
<td>[0, 0]</td>
<td>Updated when an item is selected<br />
Value is an array containing the index of the row and the items that were selected</td>
</tr>
<tr class="odd">
<td>jumpToRowItem</td>
<td>Vector2D</td>
<td>[0, 0]</td>
<td><p>Sets grid focus toÂ a specified item<br />
Value is an array containing the index of the row and the items that should be focused</p>
<p>This field must be set after setting the content field only</p></td>
</tr>
<tr class="even">
<td>theme</td>
<td>Associative array</td>
<td>{ }</td>
<td><p>Controls the color of the visual elements</p>
<p>For the possible values of Grid view theme, refer to <a href="https://confluence.portal.roku.com:8443/display/DR/Theme+attributes+for+views#Themeattributesforviews-GridViewthemeattributes">Gridview theme attributes</a></p></td>
</tr>
<tr class="odd">
<td>style</td>
<td>String</td>
<td>&quot;standard&quot;</td>
<td><p>Indicates what grid UI is used</p>
<p><strong>Possible values</strong></p>
<ul>
<li><p>standard - Default grid style</p></li>
<li><p>hero - Default grid style</p></li>
</ul></td>
</tr>
<tr class="even">
<td>posterShape</td>
<td>String</td>
<td>&quot;16X9&quot;</td>
<td><p>Controls the aspect ratio of the posters on the grid</p>
<p><strong>Possible values</strong></p>
<ul>
<li><p>16x9</p></li>
<li><p>portrait</p></li>
<li><p>4x3</p></li>
<li><p>square</p></li>
</ul></td>
</tr>
<tr class="odd">
<td>content</td>
<td>Node</td>
<td>-</td>
<td><p>Controls how SGDEX loads the content for the view</p>
<p>Content metadata field that can be used:</p>

<p><code>root = {
children:[{
    title: "Row title"
children: [{
    title: "title that will be shown on upper details section"
    description: "Description that will be shown on upper details section"
    hdPosterUrl: "Poster URL that should be shown on grid item"
    releaseDate: "Release date string"
    StarRating: "star rating integer between 0 and 100"
  
_gridItemMetaData: "fields that are used on grid"
    shortDescriptionLine1: "first row that will be displayed on grid"
    shortDescriptionLine2: "second row that will be displayed on grid"
 
_forShowing_bookmarks_on_grid: "Add these fields to show bookmarks on grid item"
    length: "length of video"
    bookmarkposition: "actual bookmark position"
_note: "tels if this bar should be hidden, default = true"
    hideItemDurationBar: false
            }]
        }]
    }
 
// Making API calls to get the list of rows
content = CreateObject("roSGNode", "ContentNode")
    content.addfields({
    HandlerConfigGrid: {
    name: "CHRoot"
        }
    })
grid.content = content
 
'Where CHRoot is a ContentHandler responsible for getting rows for grid
 
'If you know the structure of your grid but need to load content to the rows, implement:
 
content = CreateObject("roSGNode", "ContentNode")
row = CreateObject("roSGNode", "ContentNode")
    row.title = "first row"
    row.addfields({
    HandlerConfigGrid: {
    name: "ContentHandlerForRows"
    fields : {
        myField1 : "value I need to pass to content handler"
            }
        }
    })
grid.content = content</code></p>

<p>Here,</p>
<ol type="1">
<li><p>&quot;ContentHandlerForRows&quot; is the content handler that is called to get the content for the provided row</p></li>
<li><p>Fields is an Associative Array of values that are set to the ContentHandler to pass additional data to it</p></li>
</ol>
<p><strong>Note:</strong> Passing the row itself or grid via fields might cause memory leaks</p>
<p>Set the row ContentHandler when parsing content in &quot;CHRoot,&quot; so that it is called when data for that row is needed</p></td>
</tr>
</tbody>
</table>

**Example**

**Using GridView** 

~~~~
grid = CreateObject("roSGNode", "GridView")
    grid.setFields({
    style: "standard"
    posterShape: "16x9"
})
content = CreateObject("roSGNode", "ContentNode")
    content.addfields({
    HandlerConfigGrid: {
    name: "CHRoot"
    }
})
grid.content = content
 
'Triggers a job to show the view
m.top.ComponentController.callFunc("show", {
    view: grid
    })
~~~~

## EntitlementView

**Extends: SGDEXComponent**

### Description

The EntitlementView gives developers a way to build a basic SVOD
experience in their channel. It can be used to walk a user through the
purchase of a Roku Billing subscription and also beÂ  used after a
purchase to enforce entitlement rules by checking whether a user owns a
valid subscription.

There are two implementations of this view:

1.  A silent check of the available subscriptions;

2.  A check to show Entitlement view/flow

To pass configs to view, a user implements a handler that extends
EntitlementHandler.

### Interface

#### Fields

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
<td>isSubscribed</td>
<td>Boolean</td>
<td>False</td>
<td><p>[ObserveOnly] Sets to true/false and shows ifÂ a userÂ is subscribed after:</p>
<ol type="1">
<li><p>Checking via silentCheckEntitlement=true (see below)</p></li>
<li><p>Exiting from the subscription flow initiated by addingÂ a viewÂ to the view stack</p></li>
</ol></td>
</tr>
<tr class="even">
<td>silentCheckEntitlement</td>
<td>Boolean</td>
<td>False</td>
<td><p>Initiates silent entitlement checking (headless mode)</p>
<p><strong>Write Only</strong></p></td>
</tr>
</tbody>
</table>

**Example**

**Using EntitlementView**  

~~~~
// [In channel]
// contentItem - content node with handlerConfigEntitlement: {name : "HandlerEntitlement"}
 
// To make just silent check if user subscribed
ent = CreateObject("roSGNode", "EntitlementView")
    ent.ObserveField("isSubscribed", "OnSubscriptionChecked")
    ent.content = contentItem
    ent.silentCheckEntitlement = true
 
// To show billing flow
ent = CreateObject("roSGNode","EntitlementView")
    ent.ObserveField("isSubscribed", "OnIsSubscribedToPlay")
    ent.content = contentItem
m.top.ComponentController.callFunc("show", {view: ent})
~~~~