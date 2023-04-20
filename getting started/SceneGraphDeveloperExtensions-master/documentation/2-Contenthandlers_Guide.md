# Using the Content Manager

# Content Management

The SceneGraph Developer Extension's (SGDEX) Content Manager simplifies
task management for developers by using a Content Handler to manage and
view as well as the Task Nodes, and streamline the multi-threaded nature
of Roku SceneGraph Nodes.

In order to populate a view, the developer needs to provide the Content
Manager with config data to drive that view's Content Getter(s).

# Content Handlers

Content Handlers (CH) are responsible for all content loading tasks in
SGDEX. Channels typically extend ContentHandler to implement specific
content or data loading tasks. ContentHandlers should implement a
function called GetContent(). This function is called by SGDEX, allowing
the handler to make application specific API calls or perform other
operations to load the content associated with the handler.

CHs modify the Content Node referenced by m.top.content to get the
content.

A Content Handler is made up of two components; Markup, and
BrightScript. A very simple CH might look like the following:

**Markup** (SimpleContentGetter.xml)

~~~~
<?xml version="1.0" encoding="UTF-8"?>
<component name="SimpleContentGetter" extends="ContentHandler" >
  <script type="text/brightscript" uri="pkg:/components/content/SimpleContentGetter.brs" />
</component>
~~~~

**BrightScript** (SimpleContentGetter.brs)

~~~~
sub GetContent()
  m.top.content.SetFields({
    title: "Hello World"
  })
end sub
~~~~

## Content Getter Handler Config

Each CH is driven by a Content Handler Config (CHConfig). The CHConfig
is set as the value of a field on the content node that needs to be
modified. The simplest CHConfig consists of the name of the component
that implements it. The example below defines a DetailView CHConfig that
invokes the simple CH defined above:

~~~~
myContentNode.AddFields({
  HandlerConfigDetails: {
    name: "SimpleContentGetter"
  }
}
~~~~

## Grid View Supported Data Models

### Single Task

In a single task model, all the data for the grid is populated by a
single CH. The CHConfig for this CH should be placed
in the GridView's root Content node.

### One Task Per Row

In this model, the rows of a grid are defined by a root CH similar to
the single task model, but the content for each row is populated by a
separate CH. To accomplish this, each row that requires loading content
has its own CHConfig. It can be set either in the root CH or in other
CH.

### Multiple Tasks Per Row

This model is useful when the developer is working with an API that
returns the content of a row in pages and each page requires a separate
API call. There are two variations of this model.

#### Serial

> In the serial variation, the pages of content of a row must be
> requested in order.
> 
> To implement this, the root CH places a CHConfig on each of its child
> nodes (that represent a row), as in the "One Task Per Row" model.
> Moreover, the CHConfig rows have a field hasMore that tells SGDEX that
> the row has more items to load. This CH is invoked by SGDEX multiple
> times without deleting the CHConfig. When a developer loads portion
> serial content andÂ is aware of more content that exists, they can set
> a new CH to m.top.content inside of the getContent function.

#### Non-Serial

> In the non-serial variation, the pages of content of a row can be
> requested out of order. The developer must know from the beginning how
> many items are there in each row altogether. 
> 
> The implementation of this model is complex. To implement this model,
> the root CH places a CHConfig on each of its child nodes (that
> represent a row), as in the "One Task Per Row" model.
> 
> When SGDEX invokes a row's initial CH, it deletes the CHConfig. The
> initial CH does two things:
> 
> Populate the row with "n" placeholder content items where n is the
> final number of items the row contains
> 
> Place a new CHConfig on the row's node with a pageSize field, similar
> to that in the serial model
> 
> SGDEX then calls this secondary row CH multiple times, without
> deleting the CHConfig. Each time it is called, the CH updates the
> appropriate placeholder items on the row with the final content. Note
> that the CH uses the values
> found in m.top.offset and m.top.pageSize to determine which items
> it needs to update.

## CHConfig Management

In some cases, when SGDEX invokes a CH, it deletes the associated
CHConfig. But the developer may need to re-run a CH.

One such instance is when an API request fails. In this case, the
recommended approach is for the CH to detect the error and
then set m.top.failed = true in the getContent() function.

If the developer needs to invoke another handler, they can specify a new
CHConfig on the same Content node passed by SGDEX to m.top.content and
filed in the Content handler; Otherwise, the old CHConfig will be used.
This causes SGDEX to invoke the CH defined by the new CHConfig so the
request can be re-tried.

## DetailsView supported Data Models

If the channel does not have content to show on the details view and
needs to load it via an API call, set the HandlerConfigDetails to a
content node in the details view. This CH has a basic structure (See:
Content Handler Config).

Details view supports two variants for using content; List model and
Single model. List model is used to show the list of items on details
view and the user can navigate right/left to switch them. A single model
is a details view that displays only one item.

### List Model

> This is the default data model for DetailsView.
> 
> To load the list of items to be displayed in a details view,
> set a HandlerConfigDetails on the view's root Content node. Then, in
> the CH's GetContent() function, append the
> children to m.top.content for each of the items to be displayed.

### Single Item Model

> To display a single item in a DetailsView, set a single Content node
> to the view's content field:
> 
> Set view.isContentList = false

###### Copyright (c) 2018 Roku, Inc. All rights reserved.
