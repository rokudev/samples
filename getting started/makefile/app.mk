#########################################################################
# common include file for application Makefiles
#
# Makefile common usage:
# > make
# > make run
# > make install
# > make remove
#
# Makefile less common usage:
# > make art-opt
# > make pkg
# > make install_native
# > make remove_native
# > make tr
#
# By default, ZIP_EXCLUDE will exclude -x \*.pkg -x storeassets\* -x keys\* -x .\*
# If you define ZIP_EXCLUDE in your Makefile, it will override the default setting.
#
# To exclude different files from being added to the zipfile during packaging
# include a line like this:ZIP_EXCLUDE= -x keys\*
# that will exclude any file who's name begins with 'keys'
# to exclude using more than one pattern use additional '-x <pattern>' arguments
# ZIP_EXCLUDE= -x \*.pkg -x storeassets\*
#
# If you want to add additional files to the default ZIP_EXCLUDE use
# ZIP_EXCLUDE_LOCAL
#
# Important Notes:
# To use the "run", "install" and "remove" targets to install your
# application directly from the shell, you must do the following:
#
# 1) Make sure that you have the curl command line executable in your path
# 2) Set the variable ROKU_DEV_TARGET in your environment to the IP
#    address of your Roku box. (e.g. export ROKU_DEV_TARGET=192.168.1.1.
##########################################################################

# improve performance and simplify Makefile debugging by omitting
# default language rules that don't apply to this environment.
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

HOST_OS := unknown
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	HOST_OS := macos
else ifeq ($(UNAME_S),Linux)
	HOST_OS := linux
else ifneq (,$(findstring CYGWIN,$(UNAME_S)))
	HOST_OS := cygwin
endif

IS_TEAMCITY_BUILD ?=
ifneq ($(TEAMCITY_BUILDCONF_NAME),)
IS_TEAMCITY_BUILD := true
endif

# get the root directory in absolute form, so that current directory
# can be changed during the make if needed.
APPS_ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# the current directory is the app root directory
SOURCEDIR := .

DISTREL := $(APPS_ROOT_DIR)/dist
COMMONREL := $(APPS_ROOT_DIR)/common

ZIPREL := $(DISTREL)/apps
PKGREL := $(DISTREL)/packages
CHECK_TMP_DIR := $(DISTREL)/tmp-check

DATE_TIME := $(shell date +%F-%T)

APP_ZIP_FILE := $(ZIPREL)/$(APPNAME).zip
APP_PKG_FILE := $(PKGREL)/$(APPNAME)_$(DATE_TIME).pkg

# these variables are only used for the .pkg file version tagging.
APP_NAME := $(APPNAME)
APP_VERSION := $(VERSION)
ifeq ($(IS_TEAMCITY_BUILD),true)
APP_NAME    := $(subst /,-,$(TEAMCITY_BUILDCONF_NAME))
APP_VERSION := $(BUILD_NUMBER)
endif

APPSOURCEDIR := $(SOURCEDIR)/source
IMPORTFILES := $(foreach f,$(IMPORTS),$(COMMONREL)/$f.brs)
IMPORTCLEANUP := $(foreach f,$(IMPORTS),$(APPSOURCEDIR)/$f.brs)

# ROKU_NATIVE_DEV must be set in the calling environment to
# the firmware native-build src directory
NATIVE_DIST_DIR := $(ROKU_NATIVE_DEV)/dist
#
NATIVE_DEV_REL  := $(NATIVE_DIST_DIR)/rootfs/Linux86_dev.OBJ/root/nvram/incoming
NATIVE_DEV_PKG  := $(NATIVE_DEV_REL)/dev.zip
NATIVE_PLETHORA := $(NATIVE_DIST_DIR)/application/Linux86_dev.OBJ/root/bin/plethora
NATIVE_TICKLER  := $(NATIVE_PLETHORA) tickle-plugin-installer

# only Linux host is supported for these tools currently
APPS_TOOLS_DIR    := $(APPS_ROOT_DIR)/tools/$(HOST_OS)/bin

APP_PACKAGE_TOOL  := $(APPS_TOOLS_DIR)/app-package
MAKE_TR_TOOL      := $(APPS_TOOLS_DIR)/maketr
BRIGHTSCRIPT_TOOL := $(APPS_TOOLS_DIR)/brightscript

# if building from a firmware tree, use the BrightScript libraries from there
ifneq (,$(wildcard $(APPS_ROOT_DIR)/../3rdParty/brightscript/Scripts/LibCore/.))
BRIGHTSCRIPT_LIBS_DIR ?= $(APPS_ROOT_DIR)/../3rdParty/brightscript/Scripts/LibCore
endif
# else use the reference libraries from the tools directory.
BRIGHTSCRIPT_LIBS_DIR ?= $(APPS_ROOT_DIR)/tools/brightscript/Scripts/LibCore

APP_KEY_PASS_TMP := /tmp/app_key_pass
DEV_SERVER_TMP_FILE := /tmp/dev_server_out

# The developer password that was set on the player is required for
# plugin_install operations on modern versions of firmware.
# It may be pre-specified in the DEVPASSWORD environment variable on entry,
# otherwise the make will stop and prompt the user to enter it when needed.
ifdef DEVPASSWORD
	USERPASS := rokudev:$(DEVPASSWORD)
else
	USERPASS := rokudev
endif

ifeq ($(HOST_OS),macos)
	# Mac doesn't support these args
	CP_ARGS =
else
	CP_ARGS = --preserve=ownership,timestamps --no-preserve=mode
endif

# For a quick ping, we want the command to return success as soon as possible,
# and a timeout failure in no more than a second or two.
ifeq ($(HOST_OS),cygwin)
	# This assumes that the Windows ping command is used, not cygwin's.
	QUICK_PING_ARGS = -n 1 -w 1000
else # Linux
	QUICK_PING_ARGS = -c 1 -w 1
endif

ifndef ZIP_EXCLUDE
	ZIP_EXCLUDE= -x \*.pkg -x storeassets\* -x keys\* -x \*/.\* $(ZIP_EXCLUDE_LOCAL)
endif

# -------------------------------------------------------------------------
# $(APPNAME): the default target is to create the zip file for the app.
# This contains the set of files that are to be deployed on a Roku.
# -------------------------------------------------------------------------
.PHONY: $(APPNAME)
$(APPNAME): manifest
	@echo "*** Creating $(APPNAME).zip ***"

	@echo "  >> removing old application zip $(APP_ZIP_FILE)"
	@if [ -e "$(APP_ZIP_FILE)" ]; then \
		rm -f $(APP_ZIP_FILE); \
	fi

	@echo "  >> creating destination directory $(ZIPREL)"
	@if [ ! -d $(ZIPREL) ]; then \
		mkdir -p $(ZIPREL); \
	fi

	@echo "  >> setting directory permissions for $(ZIPREL)"
	@if [ ! -w $(ZIPREL) ]; then \
		chmod 755 $(ZIPREL); \
	fi

	@echo "  >> copying imports"
	@if [ "$(IMPORTFILES)" ]; then \
		mkdir $(APPSOURCEDIR)/common; \
		cp -f $(CP_ARGS) -v $(IMPORTFILES) $(APPSOURCEDIR)/common/; \
	fi \

# zip .png files without compression
# do not zip up Makefiles, or any files ending with '~'
	@echo "  >> creating application zip $(APP_ZIP_FILE)"
	@if [ -d $(SOURCEDIR) ]; then \
		(zip -0 -r "$(APP_ZIP_FILE)" . -i \*.png $(ZIP_EXCLUDE)); \
		(zip -9 -r "$(APP_ZIP_FILE)" . -x \*~ -x \*.png -x Makefile $(ZIP_EXCLUDE)); \
	else \
		echo "Source for $(APPNAME) not found at $(SOURCEDIR)"; \
	fi

	@if [ "$(IMPORTCLEANUP)" ]; then \
		echo "  >> deleting imports";\
		rm -r -f $(APPSOURCEDIR)/common; \
	fi \

	@echo "*** packaging $(APPNAME) complete ***"

# If DISTDIR is not empty then copy the zip package to the DISTDIR.
# Note that this is used by the firmware build, to build applications that are
# embedded in the firmware software image, such as the built-in screensaver.
# For those cases, the Netflix/Makefile calls this makefile for each app
# with DISTDIR and DISTZIP set to the target directory and base filename
# respectively.
	@if [ $(DISTDIR) ]; then \
		rm -f $(DISTDIR)/$(DISTZIP).zip; \
		mkdir -p $(DISTDIR); \
		cp -f --preserve=ownership,timestamps --no-preserve=mode \
			$(APP_ZIP_FILE) $(DISTDIR)/$(DISTZIP).zip; \
	fi

# -------------------------------------------------------------------------
# clean: remove any build output for the app.
# -------------------------------------------------------------------------
.PHONY: clean
clean:
	rm -f $(APP_ZIP_FILE)
# FIXME: we should use a canonical output file name, rather than having
# the date-time stamp in the output file name.
#	rm -f $(APP_PKG_FILE)
	rm -f $(PKGREL)/$(APPNAME)_*.pkg

# -------------------------------------------------------------------------
# clobber: remove any build output for the app.
# -------------------------------------------------------------------------
.PHONY: clobber
clobber: clean

# -------------------------------------------------------------------------
# dist-clean: remove the dist directory for the sandbox.
# -------------------------------------------------------------------------
.PHONY: dist-clean
dist-clean:
	rm -rf $(DISTREL)/*

# -------------------------------------------------------------------------
# CHECK_OPTIONS: this is used to specify configurable options, such
# as which version of the BrightScript library sources should be used
# to compile the app.
# -------------------------------------------------------------------------
CHECK_OPTIONS =
ifneq (,$(wildcard $(BRIGHTSCRIPT_LIBS_DIR)/.))
CHECK_OPTIONS += -lib $(BRIGHTSCRIPT_LIBS_DIR)
endif

# -------------------------------------------------------------------------
# check: run the desktop BrightScript compiler/check tool on the
# application.
# You can bypass checking on the application by setting
# APP_CHECK_DISABLED=true in the app's Makefile or in the environment.
# -------------------------------------------------------------------------
.PHONY: check
check: $(APPNAME)
ifeq ($(APP_CHECK_DISABLED),true)
ifeq ($(IS_TEAMCITY_BUILD),true)
	@echo "*** Warning: application check skipped ***"
endif
else
ifeq ($(wildcard $(BRIGHTSCRIPT_TOOL)),)
	@echo "*** Note: application check not available ***"
else
	@echo "*** Checking application ***"
	rm -rf $(CHECK_TMP_DIR)
	mkdir -p $(CHECK_TMP_DIR)
	unzip -q $(APP_ZIP_FILE) -d $(CHECK_TMP_DIR)
	$(BRIGHTSCRIPT_TOOL) check \
		$(CHECK_OPTIONS) \
		$(CHECK_TMP_DIR)
	rm -rf $(CHECK_TMP_DIR)
endif
endif

# -------------------------------------------------------------------------
# check-strict: run the desktop BrightScript compiler/check tool on the
# application using strict mode.
# -------------------------------------------------------------------------
.PHONY: check-strict
check-strict: $(APPNAME)
	@echo "*** Checking application (strict) ***"
	rm -rf $(CHECK_TMP_DIR)
	mkdir -p $(CHECK_TMP_DIR)
	unzip -q $(APP_ZIP_FILE) -d $(CHECK_TMP_DIR)
	$(BRIGHTSCRIPT_TOOL) check -strict \
		$(CHECK_OPTIONS) \
		$(CHECK_TMP_DIR)
	rm -rf $(CHECK_TMP_DIR)

# -------------------------------------------------------------------------
# GET_FRIENDLY_NAME_FROM_DD is used to extract the Roku device ID
# from the ECP device description XML response.
# -------------------------------------------------------------------------
define GET_FRIENDLY_NAME_FROM_DD
	cat $(DEV_SERVER_TMP_FILE) | \
		grep -o "<friendlyName>.*</friendlyName>" | \
		sed "s|<friendlyName>||" | \
		sed "s|</friendlyName>||"
endef

# -------------------------------------------------------------------------
# CHECK_ROKU_DEV_TARGET is used to check if ROKU_DEV_TARGET refers a
# Roku device on the network that has an enabled developer web server.
# If the target doesn't exist or doesn't have an enabled web server
# the connection should fail.
# -------------------------------------------------------------------------
define CHECK_ROKU_DEV_TARGET
	if [ -z "$(ROKU_DEV_TARGET)" ]; then \
		echo "ERROR: ROKU_DEV_TARGET is not set."; \
		exit 1; \
	fi
	echo "Checking dev server at $(ROKU_DEV_TARGET)..."

	# first check if the device is on the network via a quick ping
	ping $(QUICK_PING_ARGS) $(ROKU_DEV_TARGET) &> $(DEV_SERVER_TMP_FILE) || \
		( \
			echo "ERROR: Device is not responding to ping."; \
			exit 1 \
		)

	# second check ECP, to verify we are talking to a Roku
	rm -f $(DEV_SERVER_TMP_FILE)
	curl --connect-timeout 2 --silent --output $(DEV_SERVER_TMP_FILE) \
		http://$(ROKU_DEV_TARGET):8060 || \
		( \
			echo "ERROR: Device is not responding to ECP...is it a Roku?"; \
			exit 1 \
		)

	# echo the device friendly name to let us know what we are talking to
	ROKU_DEV_NAME=`$(GET_FRIENDLY_NAME_FROM_DD)`; \
	echo "Device reports as \"$$ROKU_DEV_NAME\"."

	# third check dev web server.
	# Note, it should return 401 Unauthorized since we aren't passing the password.
	rm -f $(DEV_SERVER_TMP_FILE)
	HTTP_STATUS=`curl --connect-timeout 2 --silent --output $(DEV_SERVER_TMP_FILE) \
		http://$(ROKU_DEV_TARGET)` || \
		( \
			echo "ERROR: Device server is not responding...is the developer installer enabled?"; \
			exit 1 \
		)

	echo "Dev server is ready."
endef

# -------------------------------------------------------------------------
# CHECK_DEVICE_HTTP_STATUS is used to that the last curl command
# to the dev web server returned HTTP 200 OK.
# -------------------------------------------------------------------------
define CHECK_DEVICE_HTTP_STATUS
	if [ "$$HTTP_STATUS" != "200" ]; then \
		echo "ERROR: Device returned HTTP $$HTTP_STATUS"; \
		exit 1; \
	fi
endef

# -------------------------------------------------------------------------
# GET_PLUGIN_PAGE_RESULT_STATUS is used to extract the status message
# (e.g. Success/Failed) from the dev server plugin_* web page response.
# (Note that the plugin_install web page has two fields, whereas the
# plugin_package web page just has one).
# -------------------------------------------------------------------------
define GET_PLUGIN_PAGE_RESULT_STATUS
	cat $(DEV_SERVER_TMP_FILE) | \
		grep -o "<font color=\"red\">.*" | \
		sed "s|<font color=\"red\">||" | \
		sed "s|</font>||"
endef

# -------------------------------------------------------------------------
# GET_PLUGIN_PAGE_PACKAGE_LINK is used to extract the installed package
# URL from the dev server plugin_package web page response.
# -------------------------------------------------------------------------
define GET_PLUGIN_PAGE_PACKAGE_LINK =
	cat $(DEV_SERVER_TMP_FILE) | \
		grep -o "<a href=\"pkgs//[^\"]*\"" | \
		sed "s|<a href=\"pkgs//||" | \
		sed "s|\"||"
endef

# -------------------------------------------------------------------------
# install: install the app as the dev channel on the Roku target device.
# -------------------------------------------------------------------------
.PHONY: install
install: $(APPNAME) check
	@$(CHECK_ROKU_DEV_TARGET)

	@echo "Installing $(APPNAME)..."
	@rm -f $(DEV_SERVER_TMP_FILE)
	@HTTP_STATUS=`curl --user $(USERPASS) --digest --silent --show-error \
		-F "mysubmit=Install" -F "archive=@$(APP_ZIP_FILE)" \
		--output $(DEV_SERVER_TMP_FILE) \
		--write-out "%{http_code}" \
		http://$(ROKU_DEV_TARGET)/plugin_install`; \
	$(CHECK_DEVICE_HTTP_STATUS)

	@MSG=`$(GET_PLUGIN_PAGE_RESULT_STATUS)`; \
	echo "Result: $$MSG"

# -------------------------------------------------------------------------
# remove: uninstall the dev channel from the Roku target device.
# -------------------------------------------------------------------------
.PHONY: remove
remove:
	@$(CHECK_ROKU_DEV_TARGET)

	@echo "Removing dev app..."
	@rm -f $(DEV_SERVER_TMP_FILE)
	@HTTP_STATUS=`curl --user $(USERPASS) --digest --silent --show-error \
		-F "mysubmit=Delete" -F "archive=" \
		--output $(DEV_SERVER_TMP_FILE) \
		--write-out "%{http_code}" \
		http://$(ROKU_DEV_TARGET)/plugin_install`; \
	$(CHECK_DEVICE_HTTP_STATUS)

	@MSG=`$(GET_PLUGIN_PAGE_RESULT_STATUS)`; \
	echo "Result: $$MSG"

# -------------------------------------------------------------------------
# check-roku-dev-target: check the status of the Roku target device.
# -------------------------------------------------------------------------
.PHONY: check-roku-dev-target
check-roku-dev-target:
	@$(CHECK_ROKU_DEV_TARGET)

# -------------------------------------------------------------------------
# run: the install target is 'smart' and doesn't do anything if the package
# didn't change.
# But usually I want to run it even if it didn't change, so force a fresh
# install by doing a remove first.
# Some day we should look at doing the force run via a plugin_install flag,
# but for now just brute force it.
# -------------------------------------------------------------------------
.PHONY: run
run: remove install

# -------------------------------------------------------------------------
# pkg: use to create a pkg file from the application sources.
#
# Usage:
# The application name should be specified via $APPNAME.
# The application version should be specified via $VERSION.
# The developer's signing password (from genkey) should be passed via
# $APP_KEY_PASS, or via stdin, otherwise the script will prompt for it.
# -------------------------------------------------------------------------
.PHONY: pkg
pkg: install
	@echo "*** Creating Package ***"

	@echo "  >> creating destination directory $(PKGREL)"
	@if [ ! -d $(PKGREL) ]; then \
		mkdir -p $(PKGREL); \
	fi

	@echo "  >> setting directory permissions for $(PKGREL)"
	@if [ ! -w $(PKGREL) ]; then \
		chmod 755 $(PKGREL); \
	fi

	@$(CHECK_ROKU_DEV_TARGET)

	@echo "Packaging $(APP_NAME)/$(APP_VERSION) to $(APP_PKG_FILE)"

	@if [ -z "$(APP_KEY_PASS)" ]; then \
		read -r -p "Password: " REPLY; \
		echo "$$REPLY" > $(APP_KEY_PASS_TMP); \
	else \
		echo "$(APP_KEY_PASS)" > $(APP_KEY_PASS_TMP); \
	fi

	@rm -f $(DEV_SERVER_TMP_FILE)
	@PASSWD=`cat $(APP_KEY_PASS_TMP)`; \
	PKG_TIME=`expr \`date +%s\` \* 1000`; \
	HTTP_STATUS=`curl --user $(USERPASS) --digest --silent --show-error \
		-F "mysubmit=Package" -F "app_name=$(APP_NAME)/$(APP_VERSION)" \
		-F "passwd=$$PASSWD" -F "pkg_time=$$PKG_TIME" \
		--output $(DEV_SERVER_TMP_FILE) \
		--write-out "%{http_code}" \
		http://$(ROKU_DEV_TARGET)/plugin_package`; \
	$(CHECK_DEVICE_HTTP_STATUS)

	@MSG=`$(GET_PLUGIN_PAGE_RESULT_STATUS)`; \
	case "$$MSG" in \
		*Success*) \
			;; \
		*)	echo "Result: $$MSG"; \
			exit 1 \
			;; \
	esac

	@PKG_LINK=`$(GET_PLUGIN_PAGE_PACKAGE_LINK)`; \
	HTTP_STATUS=`curl --user $(USERPASS) --digest --silent --show-error \
		--output $(APP_PKG_FILE) \
		--write-out "%{http_code}" \
		http://$(ROKU_DEV_TARGET)/pkgs/$$PKG_LINK`; \
	$(CHECK_DEVICE_HTTP_STATUS)

	@echo "*** Package $(APPNAME) complete ***"

# -------------------------------------------------------------------------
# app-pkg: use to create a pkg file from the application sources.
# Similar to the pkg target, but does not require a player to do the signing.
# Instead it requires the developer key file and signing password to be
# specified, which are then passed to the app-package desktop tool to create
# the package file.
#
# Usage:
# The application name should be specified via $APPNAME.
# The application version should be specified via $VERSION.
# The developer's key file (.pkg file) should be specified via $APP_KEY_FILE.
# The developer's signing password (from genkey) should be passed via
# $APP_KEY_PASS, or via stdin, otherwise the script will prompt for it.
# -------------------------------------------------------------------------
.PHONY: app-pkg
app-pkg: $(APPNAME) check
	@echo "*** Creating package ***"

	@echo "  >> creating destination directory $(PKGREL)"
	@mkdir -p $(PKGREL) && chmod 755 $(PKGREL)

	@if [ -z "$(APP_KEY_FILE)" ]; then \
		echo "ERROR: APP_KEY_FILE not defined"; \
		exit 1; \
	fi
	@if [ ! -f "$(APP_KEY_FILE)" ]; then \
		echo "ERROR: key file not found: $(APP_KEY_FILE)"; \
		exit 1; \
	fi

	@if [ -z "$(APP_KEY_PASS)" ]; then \
		read -r -p "Password: " REPLY; \
		echo "$$REPLY" > $(APP_KEY_PASS_TMP); \
	else \
		echo "$(APP_KEY_PASS)" > $(APP_KEY_PASS_TMP); \
	fi

	@echo "Packaging $(APP_NAME)/$(APP_VERSION) to $(APP_PKG_FILE)"

	@if [ -z "$(APP_VERSION)" ]; then \
		echo "WARNING: VERSION is not set."; \
	fi

	@PASSWD=`cat $(APP_KEY_PASS_TMP)`; \
	$(APP_PACKAGE_TOOL) package $(APP_ZIP_FILE) \
		-n $(APP_NAME)/$(APP_VERSION) \
		-k $(APP_KEY_FILE) \
		-p "$$PASSWD" \
		-o $(APP_PKG_FILE)

	@rm $(APP_KEY_PASS_TMP)

	@echo "*** Package $(APPNAME) complete ***"

# -------------------------------------------------------------------------
# teamcity: used to build .zip and .pkg file on TeamCity.
# See app-pkg target for info on options for specifying the signing password.
# -------------------------------------------------------------------------
.PHONY: teamcity
teamcity: app-pkg
ifeq ($(IS_TEAMCITY_BUILD),true)
	@echo "Adding TeamCity artifacts..."

	sudo rm -f /tmp/artifacts
	sudo mkdir -p /tmp/artifacts

	cp $(APP_ZIP_FILE) /tmp/artifacts/$(APP_NAME)-$(APP_VERSION).zip
	@echo "##teamcity[publishArtifacts '/tmp/artifacts/$(APP_NAME)-$(APP_VERSION).zip']"

	cp $(APP_PKG_FILE) /tmp/artifacts/$(APP_NAME)-$(APP_VERSION).pkg
	@echo "##teamcity[publishArtifacts '/tmp/artifacts/$(APP_NAME)-$(APP_VERSION).pkg']"

	@echo "TeamCity artifacts complete."
else
	@echo "Not running on TeamCity, skipping artifacts."
endif

##########################################################################

# -------------------------------------------------------------------------
# CHECK_NATIVE_TARGET is used to check if the Roku simulator is
# configured.
# -------------------------------------------------------------------------
define CHECK_NATIVE_TARGET
	if [ -z "$(ROKU_NATIVE_DEV)" ]; then \
		echo "ERROR: ROKU_NATIVE_DEV not defined"; \
		exit 1; \
	i
	if [ ! -d "$(ROKU_NATIVE_DEV)" ]; then \
		echo "ERROR: native dev dir not found: $(ROKU_NATIVE_DEV)"; \
		exit 1; \
	fi
	if [ ! -d "$(NATIVE_DIST_DIR)" ]; then \
		echo "ERROR: native build dir not found: $(NATIVE_DIST_DIR)"; \
		exit 1; \
	fi
endef

# -------------------------------------------------------------------------
# install-native: install the app as the dev channel on the Roku simulator.
# -------------------------------------------------------------------------
.PHONY: install-native
install-native: $(APPNAME) check
	@$(CHECK_NATIVE_TARGET)
	@echo "Installing $(APPNAME) to native."
	@if [ ! -d "$(NATIVE_DEV_REL)" ]; then \
		mkdir "$(NATIVE_DEV_REL)"; \
	fi
	@echo "Source is $(APP_ZIP_FILE)"
	@echo "Target is $(NATIVE_DEV_PKG)"
	@cp $(APP_ZIP_FILE) $(NATIVE_DEV_PKG)
	@$(NATIVE_TICKLER)

# -------------------------------------------------------------------------
# remove-native: uninstall the dev channel from the Roku simulator.
# -------------------------------------------------------------------------
.PHONY: remove-native
remove-native:
	@$(CHECK_NATIVE_TARGET)
	@echo "Removing $(APPNAME) from native."
	@rm $(NATIVE_DEV_PKG)
	@$(NATIVE_TICKLER)

##########################################################################

# -------------------------------------------------------------------------
# art-jpg-opt: compress any jpg files in the source tree.
# Used by the art-opt target.
# -------------------------------------------------------------------------
APPS_JPG_ART=`\find . -name "*.jpg"`

.PHONY: art-jpg-opt
art-jpg-opt:
	p4 edit $(APPS_JPG_ART)
	for i in $(APPS_JPG_ART); \
	do \
		TMPJ=`mktemp` || return 1; \
		echo "optimizing $$i"; \
		(jpegtran -copy none -optimize -outfile $$TMPJ $$i && mv -f $$TMPJ $$i &); \
	done
	wait
	p4 revert -a $(APPS_JPG_ART)

# -------------------------------------------------------------------------
# art-png-opt: compress any png files in the source tree.
# Used by the art-opt target.
# -------------------------------------------------------------------------
APPS_PNG_ART=`\find . -name "*.png"`

.PHONY: art-png-opt
art-png-opt:
	p4 edit $(APPS_PNG_ART)
	for i in $(APPS_PNG_ART); \
	do \
		(optipng -o7 $$i &); \
	done
	wait
	p4 revert -a $(APPS_PNG_ART)

# -------------------------------------------------------------------------
# art-opt: compress any png and jpg files in the source tree using
# lossless compression options.
# This assumes a Perforce client/workspace is configured.
# Modified files are opened for edit in the default changelist.
# -------------------------------------------------------------------------
.PHONY: art-opt
art-opt: art-png-opt art-jpg-opt

##########################################################################

# -------------------------------------------------------------------------
# tr: this target is used to update translation files for an application
# MAKE_TR_OPTIONS may be set to [-t] [-d] etc. in the external environment,
# if needed.
# -------------------------------------------------------------------------
.PHONY: tr
tr:
	p4 opened -c default
	p4 edit locale/.../translations.xml
	$(MAKE_TR_TOOL) $(MAKE_TR_OPTIONS)
	rm locale/en_US/translations.xml
	p4 revert -a locale/.../translations.xml
	p4 opened -c default

##########################################################################
