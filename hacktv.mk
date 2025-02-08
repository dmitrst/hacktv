################################################################################
#
# hacktv
#
################################################################################

HACKTV_VERSION = 1.0
HACKTV_SITE = git@github.com:dmitrst/hacktv.git
HACKTV_SITE_METHOD = git
HACKTV_SUBDIR = src
HACKTV_LICENSE = GPL-3.0+
HACKTV_DEPENDENCIES = ffmpeg hackrf 
HACKTV_INSTALL_STAGING = YES
HACKTV_LICENSE_FILES = COPYING

OBJS    := hacktv.o common.o fir.o vbidata.o teletext.o wss.o video.o fifo.o mac.o dance.o eurocrypt.o videocrypt.o videocrypts.o syster.o acp.o vits.o vitc.o nicam728.o sis.o av.o av_test.o av_ffmpeg.o rf.o rf_file.o spdif.o

HACKTV_MAKE_OPTS = \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="-lm $(shell $(HOST_DIR)/bin/pkg-config --cflags libavcodec libavformat libavdevice libswscale libswresample libavutil) -DVERSION=\"$(HACKTV_VERSION)\"" \
	AV_LDFLAGS="$(shell $(HOST_DIR)/bin/pkg-config --libs libavcodec libavformat libavdevice libswscale libswresample libavutil)" 


define HACKTV_BUILD_CMDS
	$(MAKE) $(HACKTV_MAKE_OPTS) -C $(@D)/src $(OBJS) hacktv
endef

define HACKTV_INSTALL_STAGING_CMDS
	$(INSTALL) -d $(STAGING_DIR)/usr/bin
	$(INSTALL) -D -m 0755 $(@D)/hacktv $(STAGING_DIR)/usr/bin/hacktv
endef

define HACKTV_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 0755 $(@D)/src/hacktv $(TARGET_DIR)/usr/bin/hacktv
endef

$(eval $(generic-package))