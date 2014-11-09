ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0
THEOS_BUILD_DIR = Packages

TWEAK_NAME = Asos
TWEAK_CODESIGN_FLAGS = -SEntitlements.plist
Asos_CFLAGS = -fobjc-arc
Asos_FILES = Tweak.xm BTTouchIDController.mm
Asos_FRAMEWORKS = UIKit CoreGraphics QuartzCore LocalAuthentication
Asos_PRIVATE_FRAMEWORKS = SpringBoardServices SpringBoardUIServices AudioToolBox AppSupport BiometricKit

Asos_LIBRARIES = applist

ADDITIONAL_CFLAGS = -I../common

SUBPROJECTS += Preferences

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"

