# protobuf

PROTOBUF_VERSION := 3.11.4
PROTOBUF_URL := https://github.com/google/protobuf/archive/v${PROTOBUF_VERSION}.tar.gz
#PROTOBUF_GITURL := https://github.com/protocolbuffers/protobuf


#	$(call download_git,$(WEBSOCKETS_GITURL),master,d0bfd5221182da1a7cc280f3337b5e41a89539cf)

$(TARBALLS)/protobuf-$(PROTOBUF_VERSION).tar.gz:
	$(call download,$(PROTOBUF_URL))

.sum-protobuf: protobuf-$(PROTOBUF_VERSION).tar.gz
	$(warning $@ not implemented)
	touch $@

protobuf: protobuf-$(PROTOBUF_VERSION).tar.gz
	$(UNPACK)
	#$(APPLY) $(SRC)/websockets/fix-route.patch
	$(MOVE)


ifdef HAVE_ANDROID
LIBS="-llog -lz -lc++_static"
endif


.protobuf: protobuf toolchain.cmake
	cd $< && ./autogen.sh
	cd $< && $(HOSTVARS_PIC) ./configure $(HOSTCONF) LIBS=$(LIBS)
	cd $< && $(MAKE) install
	touch $@







