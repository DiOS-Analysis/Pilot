DEBUG=1
export DEBUG=1

#ARCHS="armv7"
TARGET = iphone:latest:7.0

CLANG = xcrun -sdk iphoneos clang
TARGET_CC=$(CLANG)
TARGET_CXX=$(CLANG)
TARGET_LD=$(CLANG)

# add entitlements
TARGET_CODESIGN_FLAGS ?= -Sentitlements.xml


include theos/makefiles/common.mk

TOOL_NAME = aaexecutord

${TOOL_NAME}_FILES += $(shell find AAExecutorDaemon -name '*.m' -print)
${TOOL_NAME}_FILES += $(shell find AAExecutorDaemon -name '*.mm' -print)
${TOOL_NAME}_FILES += $(shell find ../Common/CocoaLumberjack/Lumberjack -depth 1 -name '*.m' -print)
${TOOL_NAME}_FILES += $(shell find ../Common/NSData+Base64 -depth 1 -name '*.m' -print)

${TOOL_NAME}_CFLAGS += -fobjc-arc
${TOOL_NAME}_CFLAGS += -I./Header
${TOOL_NAME}_CFLAGS += -I./Header/UIAutomation
${TOOL_NAME}_CFLAGS += -I../Common/CocoaLumberjack/Lumberjack
${TOOL_NAME}_CFLAGS += -I../Common/NSData+Base64

#${TOOL_NAME}_CFLAGS += -Qunused-arguments

${TOOL_NAME}_LDFLAGS = -lstdc++ -F./Frameworks -lAAClientLib -lCCGraphT -LAAExecutorDaemon

${TOOL_NAME}_FRAMEWORKS = UIKit CoreGraphics
${TOOL_NAME}_PRIVATE_FRAMEWORKS = UIAutomation

include $(THEOS_MAKE_PATH)/tool.mk
