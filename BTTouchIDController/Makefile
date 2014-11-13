ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0
include theos/makefiles/common.mk

TWEAK_NAME = BTTouchIDController
TWEAK_CODESIGN_FLAGS = -SEntitlements.plist
BTTouchIDController_FILES = BTTouchIDController.mm
BTTouchIDController_FRAMEWORKS = UIKit AudioToolbox LocalAuthentication
BTTouchIDController_PRIVATE_FRAMEWORKS = BiometricKit SpringBoardServices SpringBoardUIServices AppSupport
BTTouchIDController_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

ADDITIONAL_CFLAGS = -I../common
ADDITIONAL_CFLAGS = -I../../common

after-install::
	install.exec "killall -9 Preferences; killall -9 SpringBoard"
