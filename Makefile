ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0
THEOS_BUILD_DIR = Packages

TWEAK_NAME = Asos
Asos_CFLAGS = -fobjc-arc
Asos_FILES = Tweak.xm
Asos_FRAMEWORKS = UIKit CoreGraphics QuartzCore
Asos_PRIVATE_FRAMEWORKS = SpringBoardServices AppSupport
Asos_LIBRARIES = applist

ADDITIONAL_CFLAGS = -I../common

SUBPROJECTS += Preferences

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk


after-stage::
	find $(FW_STAGING_DIR) -iname '*.plist' -or -iname '*.strings' -exec plutil -convert binary1 {} \;
	find $(FW_STAGING_DIR) -iname '*.png' -exec pincrush-osx -i {} \;


after-install::
	install.exec "killall -9 SpringBoard"

