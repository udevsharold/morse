ARCHS = arm64 arm64e
DEBUG=0
FINALPACKAGE=1

TARGET = iphone:latest:13.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = morse

morse_FILES = main.m ../MorseCodeManager.xm
morse_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tool.mk
