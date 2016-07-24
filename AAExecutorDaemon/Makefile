DEBUG=1
export DEBUG=1

ARCHS=armv7 arm64
TARGET = iphone:latest:9.0

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
${TOOL_NAME}_FILES += $(shell find ../Common/CocoaLumberjack/Classes -depth 1 -name '*.m' -print)
${TOOL_NAME}_FILES += $(shell find ../Common/NSData+Base64 -depth 1 -name '*.m' -print)

${TOOL_NAME}_CFLAGS += -fobjc-arc
${TOOL_NAME}_CFLAGS += -I./Header
${TOOL_NAME}_CFLAGS += -I./Header/UIAutomation
${TOOL_NAME}_CFLAGS += $(addprefix -I,$(shell find ../Common/CocoaLumberjack/Classes -type d))
${TOOL_NAME}_CFLAGS += -I../Common/NSData+Base64

#${TOOL_NAME}_CFLAGS += -Qunused-arguments

${TOOL_NAME}_LDFLAGS = -lstdc++ -F./Frameworks -lAAClientLib -lCCGraphT -LAAExecutorDaemon

${TOOL_NAME}_FRAMEWORKS = UIKit CoreGraphics
# PrivateFrameworks
${TOOL_NAME}_FRAMEWORKS = UIAutomation

include $(THEOS_MAKE_PATH)/tool.mk
