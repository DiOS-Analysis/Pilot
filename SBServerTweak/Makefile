DEBUG=1
export DEBUG=1

TARGET = iphone:latest:8.0
#export ARCHS="armv7"

CLANG = xcrun -sdk iphoneos clang
TARGET_CC=$(CLANG)
TARGET_CXX=$(CLANG)
TARGET_LD=$(CLANG)

include theos/makefiles/common.mk

TWEAK_NAME = SBServerTweak

${TWEAK_NAME}_FILES += $(shell find ${TWEAK_NAME} -name '*.m' -print)
${TWEAK_NAME}_FILES += $(shell find ${TWEAK_NAME} -name '*.mm' -print)
${TWEAK_NAME}_FILES += $(shell find ../Common/CocoaLumberjack/Classes -depth 1 -name '*.m' -print)
${TWEAK_NAME}_FILES += $(shell find RoutingHTTPServer/Source -name '*.m' -print)
${TWEAK_NAME}_FILES += $(shell find RoutingHTTPServer/External/CocoaHTTPServer/Core -name '*.m' -print)
${TWEAK_NAME}_FILES += $(shell find RoutingHTTPServer/External/CocoaHTTPServer/Vendor/CocoaAsyncSocket -name '*.m' -print)

${TWEAK_NAME}_INCLUDES = $(addprefix -I,$(shell find ${TWEAK_NAME} -type d))
${TWEAK_NAME}_INCLUDES += $(addprefix -I,$(shell find ../Common/CocoaLumberjack/Classes -type d))
${TWEAK_NAME}_INCLUDES += $(addprefix -I,$(shell find RoutingHTTPServer/Source -type d))
${TWEAK_NAME}_INCLUDES += $(addprefix -I,$(shell find RoutingHTTPServer/External/CocoaHTTPServer/Core RoutingHTTPServer/External/CocoaHTTPServer/Vendor/CocoaAsyncSocket -type d))

${TWEAK_NAME}_CFLAGS = -fobjc-arc -I./Header -I./Header/SpringBoard -Wno-error
${TWEAK_NAME}_CFLAGS += ${${TWEAK_NAME}_INCLUDES}

${TWEAK_NAME}_LDFLAGS =  -lstdc++ -read_only_relocs suppress

${TWEAK_NAME}_FRAMEWORKS = CFNetwork Security CoreGraphics UIKit
# PrivateFrameworks
${TWEAK_NAME}_LDFLAGS = -F../Common/PrivateFrameworks
${TWEAK_NAME}_FRAMEWORKS = StoreServices SpringBoardUI

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
