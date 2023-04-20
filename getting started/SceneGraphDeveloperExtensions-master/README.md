# Scene Graph Developer Extensions

## Overview

This is a collection of developer sample code that we call Scene Graph Developer Extensions (SGDEX). This sample code demonstrates how a developer can use pre-built, reusable Roku Scene Graph (RSG) components to enable rapid development of channels that follow a consistent UX paradigm.

### Views

SGDEX views are full screen components. If you've built channels using the legacy Roku SDK this will be familiar to you. Using an SGDEX view saves you the effort of building a screen from scratch using lower level RSG components.

### Content Manager

SGDEX includes a robust content manager that makes it easy to connect a view to a content source like a feed or API. Using the content manager saves you the effort of having to manage RSG Task Nodes and helps ensure that your channel will perform well on all Roku devices.

### Component Controller

SGDEX includes a component controller that helps manage the views in your channel. Using the component controller saves you the effort of managing the screen stack on your own.

### Other components

SGDEX also includes components that make it easier to:

* Use Roku Ad Framework (RAF) to monetize your content
* Use Roku Billing to manage subscriptions and entitlement

## Installation

Follow these steps to prepare your channel to use SGDEX components:

* Copy the `extentions/SGDEX` folder into your channel so that the path to the folder is `pkg:/components/SGDEX`. _This path is required for certain graphic elements to work correctly._
* Copy `library/SGDEX.brs` into your channel so that the path to the file is `pkg:/source/SGDEX.brs`
* Add this line to your manifest: `bs_libs_required=roku_ads_lib`

You are now ready to use SGDEX components in your channel!

###### Copyright (c) 2018 Roku, Inc. All rights reserved.
