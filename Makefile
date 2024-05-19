TARGET := iphone:clang:latest:12.0
INSTALL_TARGET_PROCESSES = WhatsApp
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = zxUpdateNotifier

$(TWEAK_NAME)_FILES = $(wildcard src/*.x src/*.m)
$(TWEAK_NAME)_CLAGS = -fobjc-arc
$(TWEAK_NAME)_LOGOS_DEFAULT_GENERATOR = internal

include $(THEOS_MAKE_PATH)/tweak.mk
