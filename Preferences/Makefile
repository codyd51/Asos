ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:7.0
THEOS_BUILD_DIR = Packages

BUNDLE_NAME = Asos
Asos_CFLAGS = -fobjc-arc
Asos_FILES = Asos.m ../BTTouchIDController.mm
Asos_INSTALL_PATH = /Library/PreferenceBundles
Asos_FRAMEWORKS = UIKit LocalAuthentication
Asos_PRIVATE_FRAMEWORKS = Preferences CoreGraphics ManagedConfiguration AudioToolBox
Asos_LIBRARIES = applist

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Asos.plist$(ECHO_END)
