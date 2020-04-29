# websockets

WEBSOCKETS_GITURL := https://github.com/warmcat/libwebsockets

$(TARBALLS)/libwebsockets-git.tar.xz:
	$(call download_git,$(WEBSOCKETS_GITURL),master,554b2cd5b8480a62f5d126b5af2c02fe86073125)

.sum-websockets: libwebsockets-git.tar.xz
	$(warning $@ not implemented)
	touch $@

websockets: libwebsockets-git.tar.xz 
	$(UNPACK)
	$(APPLY) $(SRC)/websockets/fix-route.patch
	$(MOVE)

ifdef HAVE_TIZEN
EX_ECFLAGS = -fPIC
endif


DEPS_websockets = zlib $(DEPS_zlib)
DEPS_websockets = openssl $(DEPS_openssl)
DEPS_websockets = uv $(DEPS_uv)

ifdef HAVE_TVOS
	make_option=-DLWS_WITHOUT_DAEMONIZE=1
endif

.websockets: websockets .zlib .openssl .uv toolchain.cmake
	cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)" $(CMAKE) -DLWS_WITH_LIBUV=ON -DLWS_WITH_SSL=OFF -DLWS_WITH_SHARED=OFF -DLWS_WITHOUT_TEST_SERVER=ON -DLWS_WITHOUT_TEST_SERVER_EXTPOLL=ON -DLWS_WITHOUT_TEST_PING=ON -DLWS_WITHOUT_TEST_ECHO=ON -DLWS_WITHOUT_TEST_CLIENT=ON -DLWS_WITHOUT_TEST_FRAGGLE=ON -DLWS_IPV6=ON $(make_option)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
