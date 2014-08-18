ARCHS = armv7 arm64
include theos/makefiles/common.mk

BUNDLE_NAME = Asos
Asos_FILES = Asos.mm
Asos_INSTALL_PATH = /Library/PreferenceBundles
Asos_FRAMEWORKS = UIKit
Asos_PRIVATE_FRAMEWORKS = Preferences
Asos_LIBRARIES=applist

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Asos.plist$(ECHO_END)
