DEBUG=1
export DEBUG=1

ARCHS=armv7 arm64
TARGET = iphone:latest:8.0

ifeq ($(OS),Windows_NT) 
    detected_OS := Windows
else
    detected_OS := $(shell sh -c 'uname 2>/dev/null || echo Unknown')
endif

ifeq ($(detected_OS), Darwin)
	CLANG = xcrun -sdk iphoneos clang
	TARGET_CC=$(CLANG)
	TARGET_CXX=$(CLANG)
	TARGET_LD=$(CLANG)
endif

# add entitlements
TARGET_CODESIGN_FLAGS ?= -Sentitlements.xml


include theos/makefiles/common.mk

TOOL_NAME = aaexecutord

${TOOL_NAME}_FILES += $(shell find AAExecutorDaemon -name '*.m' -print)
${TOOL_NAME}_FILES += $(shell find AAExecutorDaemon -name '*.mm' -print)
ifeq ($(detected_OS), Linux)
	${TOOL_NAME}_FILES += $(shell find ../Common/CocoaLumberjack/Classes -maxdepth 1 -name '*.m' -print)
	${TOOL_NAME}_FILES += $(shell find ../Common/NSData+Base64 -maxdepth 1 -name '*.m' -print)
else
	${TOOL_NAME}_FILES += $(shell find ../Common/CocoaLumberjack/Classes -depth 1 -name '*.m' -print)
	${TOOL_NAME}_FILES += $(shell find ../Common/NSData+Base64 -depth 1 -name '*.m' -print)
endif

${TOOL_NAME}_CFLAGS += -fobjc-arc
${TOOL_NAME}_CFLAGS += -I./Header
${TOOL_NAME}_CFLAGS += -I./Header/UIAutomation
${TOOL_NAME}_CFLAGS += $(addprefix -I,$(shell find ../Common/CocoaLumberjack/Classes -type d))
${TOOL_NAME}_CFLAGS += -I../Common/NSData+Base64

#${TOOL_NAME}_CFLAGS += -Qunused-arguments

${TOOL_NAME}_LDFLAGS = -lstdc++ -F./Frameworks -lAAClientLib -lCCGraphT -LAAExecutorDaemon

${TOOL_NAME}_FRAMEWORKS = UIKit CoreGraphics
# PrivateFrameworks
${TOOL_NAME}_PRIVATE_FRAMEWORKS = UIAutomation

include $(THEOS_MAKE_PATH)/tool.mk
