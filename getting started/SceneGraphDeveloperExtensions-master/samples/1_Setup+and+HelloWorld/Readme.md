# SGDEX Guide: Setup and HelloWorld

## SGDEX Introduction

This sample will be using Scene Graph Developer Extensions, or SGDEX for short.
SGDEX is a framework built for Roku SceneGraph development to streamline the process and make it quicker to build channels that conform to the Roku UX guidelines.  You can build a basic channel using the built-in tools like the one we do in this sample but you also have the power of Roku SceneGraph at your disposal.

SGDEX is composed of a few different components.
They have the few basic views: a grid view, a details view, a category list view, and a video view.
These handle all the logistics for displaying your content, and they each use a ContentHandler.  A ContentHandler is used to get and parse out the data you get from your own content feed.  To use these Components you extend them and then override the functions in them to fit your channel.


## Step 1: Setting up the environment

If you’re new to Roku Development and you don’t have your environment set up, use the guide here https://www.youtube.com/watch?v=-gq_5NRuHQ8 to set up your Roku and you can use Eclipse with the Brightscript plugin using this guide here https://sdkdocs.roku.com/display/sdkdoc/Roku+Plugin+for+Eclipse+IDE .  If you are new to Brightscript an or Roku Scenegraph development please read through our documentation on it here https://sdkdocs.roku.com/display/sdkdoc/BrightScript+Language+Reference to learn the basics on the language.

## Step 2: Setting up SGDEX

First, you need to set up your file structure.  It should look like this:

```
components/
    SGDEX/
    your RSG components
source/
    main.brs
    SGDEX.brs
manifest
```

After you have that all set up you should set up your manifest file.  You can find out how here https://sdkdocs.roku.com/display/sdkdoc/Roku+Channel+Manifest.

Feel free to change the title and images to the fit your channel. You need to make sure you the lines below.

```
ui_resolutions=hd
bs_libs_required=roku_ads_lib
```

The first line is there because all of the views are developed for HD and autoscaled by the firmware to FHD and SD. The second - because framework uses RAF.

Now it is time to start coding your channel!
We begin with the Main.brs file.
You should add the line override the function “GetSceneName()” to provide SGDEX the name of your entry scene.  It should look like this:

```
function GetSceneName() as String
    return "MainScene"
end function
```

## Step 3: Setting up the Scene

Now it is time to create the entry Scene.
Create two files in the components directory, MainScene.brs and MainScene.xml.
First, we should write xml file.  It should look like this.

```
<?xml version="1.0" encoding="UTF-8"?>
    <component name="MainScene" extends="BaseScene" />
    <!-- importing main handler -->
    <script type="text/brightscript" uri="pkg:/components/MainScene.brs" />
</component>
```

We extend BaseScene and import the MainScene.brs.  Now, in our MainScene.brs file we must override the show() function, the file should look like this.

```
sub show(args as Object)
    print "Hello World!"
end sub
```

If you run the channel, the text "Hello World!" will be printed to the BRS console on port 8085.  You can see this by using the telnet command like this

```
telnet xx.xx.xxx.xxx 8085
```

There you go, now we are all set to start adding content to our channel!

###### Copyright (c) 2018 Roku, Inc. All rights reserved.
