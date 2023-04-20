Copyright 2016 Roku Corp.  All Rights Reserved.

Sample for style 3 channel base on Khan Academy API

1. Description:

This is a sample of fully working channel based on grid screen with description section for focused item.

Channel has independent screen nodes that can be used separately it any order, containing:
1) Grid screen with ability to handle content loading, rendering and handling selection of an item.
Content populating prior to loading grid panel by setting "gridContent" property of scene. Content loading performed by function "GetApiArray".
2) Video player that can handle fullscreen animation.
3) Fading poster node for smooth changing background image according to focused item.

2. Base Hierarchy of files in project
     components
        - screens - all screens
        - images - all images used in this channel
        - source - containce main.brs file