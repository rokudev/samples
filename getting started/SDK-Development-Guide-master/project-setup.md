# Setting up a project

All Roku channels developed using SceneGraph must contain the following directories and a `manifest` file:

* `source` directory
* `components` directory
* `images` directory
* `manifest`

In a new project, create a folder for `source`, `components`, and `images`. You can also choose to create a blank file for `manifest` now or when you get to the manifest section below.

## Source Directory

The source directory contains BrightScript code for the main application’s execution thread with the extension `.brs`. Most applications will have separate files for SceneGraph scenes and background logic in the `components` folder. The `main.brs` file only needs to create and display `roSGScreen`, used to display the contents of a SceneGraph node tree.

The `main.brs` file will be covered in a later section.

## Components Directory

The components directory contains all the XML component and associated BrightScript code needed for the SceneGraph scenes. The XML files must have the extension `.xml`, and BrightScript code files must have the extension `.brs`.

Each XML component file contains a single `<component>` element that contains a specific SceneGraph node/element tree defining that component. When the channel is launched, all the files with extension `.xml` in the `components` directory are loaded and added to the available types of nodes that can be created.

The next part of this guide will cover the contents of this folder so we'll leave it empty for now.

## Images Directory

Any graphic image files to be included in the application package are stored in the `images` directory. At a minimum, the `images` directory must contain the `mm_icon_focus_hd` image and a `splash_screen_fhd` graphic described in the following section.

For this example, you can save the following images and add them to your `images` folder:
* [channel-poster.png](/images/channel-poster.png)
* [channel-splash.png](/images/channel-splash.png)

## Manifest File

At the root level there must be a file named `manifest` which contains attributes for the application. The attributes specified in the `manifest` include the name and version number of the application, the artwork image to be used on the home screen, and many more.

> :information_source: See [Roku Channel Manifest](https://sdkdocs.roku.com/display/sdkdoc/Roku+Channel+Manifest) for more details.

The following fields are required:
* title
* major_version
* minor_version
* build_version
* mm_icon_focus_hd
* splash_screen_fhd

If you haven't created a manifest file yet, create a blank file named `manifest` (no extension) at the root level of the project and fill out the required fields. It should look similar to this:

```brightscript
title=VideoExample
major_version=1
minor_version=0
build_version=1

mm_icon_focus_hd=pkg:/images/channel-poster.png
splash_screen_fhd=pkg:/images/channel-splash.png
```

## Parsing an XML Feed

Proceed to the next section which covers [Parsing an XML Content Feed](/parsing-feed.md).
