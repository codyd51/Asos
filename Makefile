#ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = Asos
Asos_FILES = Tweak.xm
Asos_FRAMEWORKS = UIKit CoreGraphics
Asos_PRIVATE_FRAMEWORKS = SpringBoardServices AppSupport
Asos_CFLAGS = -fobjc-arc
Asos_LIBRARIES=applist
ADDITIONAL_CFLAGS = -I../common

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
