# SGDEX Development Guide

The guide covers some key concepts of Roku Scene Graph development using library which streamlines the process and makes it quicker that conform to the Roku UX guidelines.

This guide is composed of the following sections:

1. [**SGDEX Guide: Setup and HelloWorld**](1_Setup+and+HelloWorld)

    The section describes how to:
    -  set up the working environment (IDE, ROKU plugin)
    -  set up the file structure for a channel
    -  set up a manifest file
    -  import the library into the channel
    -  create an entry scene
    -  observe the result

2. [**SGDEX Sample: Basic Channel**](2_Basic+Channel)

    The section describes how to:
    - set up the working environment (IDE, ROKU plugin)
    - import the library into the channel
    - create, initialize and setup grid view component
    - parse a content feed
    - create, initialize and setup details view component
    - create video component and implement its logic
    - create, initialize and setup episode picker component

3. [**SGDEX Guide: Grid**](3_Grid)

    The section describes how to:
    - create and initialize grid view component
    - set up content handler
    - fetch content for grid view

4. [**SGDEX Guide: DetailsView**](4_DetailsScreen)

    The section describes how to:
    - create and initialize details view component
    - set up content handler
    - fetch content for details view
    - implement function that updates the information contextually   based on the type of content
    - attach handler in order to open details view from the grid view

5. [**SGDEX Guide: Video**](5_Video)
    The section describes how to:
    - create video view component
    - implement logic for video content
    - open video player

6. [**SGDEX Guide: Endcards**](6_Endcards)

    The section describes how to:
    - create endcard component
    - set up endcard content handler
    - triggering the endcard

7. [**SGDEX Guide: EpisodePickerView**](7_EpisodePickerScreen)

    The section describes how to:
    - create and configure episode picker view component
    - override function for getting content
    - implement functionality to display selected episode

8. [**SGDEX Guide: Custom View**](8_Custom+Screen)

     The section describes how to create and invoke custom view that displays thumbnail full screen

9. [**SGDEX Guide: Bookmarks**](9_Bookmarks)

    The section describes how to:
    -  modify details view logic in order to add and correctly refresh bookmarks
    - save bookmarks in run-time on user navigation, using timed interval and between sessions

10. [**Roku Recommends**](Roku_Recommends)
    Sample channel using Roku Recommends feed to populate content. Feed is in XML format so custom parser is used in ContentHandler.
