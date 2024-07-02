TARGET := iphone:clang:latest:9.0
INSTALL_TARGET_PROCESSES = WhatsApp  # used as testing app
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = zxUpdateNotifier

$(TWEAK_NAME)_FILES = $(wildcard src/*.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
