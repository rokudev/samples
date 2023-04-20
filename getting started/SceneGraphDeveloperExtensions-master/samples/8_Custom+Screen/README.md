# SGDEX Guide: Custom View

## Creating the Custom View

We are going to create a custom view that displays the thumbnail full View.

Create in the components folder another folder called "CustomView". Inside that folder create a "custom.xml" file. In the XML you should extend Group so it will be renderable. We need to create an interface with a field where we can pass in where the picture is stored. Notice that the alias is "thumbnail.uri." What this does is sets the poster.uri that we define below named thumbnail automatically.

The xml should be as below:

```
<?xml version="1.0" encoding="utf-8" ?>
<component name="custom" extends="Group" >
    <interface>
       <field id="picPath" type="string" alias="thumbnail.uri" />
    </interface>
    <children>
        <Poster id="thumbnail" translation="[0,0]" width="1280" height="720" />
    </children>
</component>
```

You can add a custom.brs file if you would like to add in additional functionality, but we don't need that for this demo.

## Invoking the Custom View

Create the file "CustomViewLogic.brs" file in the components folder.  Add in the line to the Mainscene.xml file to include the new file

```
    <script type="text/brightscript" uri="pkg:/components/CustomViewLogic.brs" /\>
```

Now in this script we need to create the view, find the path, specify the path, and show the view. This is done in the following code:

```
function ShowCustomView(hdPosterUrl)
    m.CustomView = CreateObject("roSGNode", "custom")
    m.CustomView.picPath = hdPosterUrl
    m.top.ComponentController.callFunc("show", {
        view: m.CustomView
    })
end function
```

And there you go.

###### Copyright (c) 2018 Roku, Inc. All rights reserved.
