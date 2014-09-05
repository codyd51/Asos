ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:7.0
THEOS_BUILD_DIR = Packages

BUNDLE_NAME = Asos
Asos_CFLAGS = -fobjc-arc
Asos_FILES = Asos.m
Asos_INSTALL_PATH = /Library/PreferenceBundles
Asos_FRAMEWORKS = UIKit
Asos_PRIVATE_FRAMEWORKS = Preferences CoreGraphics AudioToolBox
Asos_LIBRARIES = applist

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk


#after-stage::
#	find $(FW_STAGING_DIR) -iname '*.plist' -or -iname '*.strings' -exec plutil -convert binary1 {} \;
#	find $(FW_STAGING_DIR) -iname '*.png' -exec pincrush-osx -i {} \;

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Asos.plist$(ECHO_END)
