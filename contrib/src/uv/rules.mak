# libuv

LIBUV_GITURL := https://github.com/libuv/libuv
#version 1.35.0 (stable)
$(TARBALLS)/libuv-git.tar.xz:
	$(call download_git,$(LIBUV_GITURL),v1.x,e45f1ec38db882f8dc17b51f51a6684027034609)


uv: libuv-git.tar.xz 
	$(UNPACK)
ifdef HAVE_ANDROID
	$(APPLY) $(SRC)/uv/android-config.patch
endif
	$(MOVE)

ifdef HAVE_ANDROID
cmake_android_def = -DANDROID=1
endif

.uv: uv toolchain.cmake
	cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)" $(CMAKE) -DBUILD_TESTING=OFF $(cmake_android_def) $(make_option) 
	cd $< && $(MAKE) install
	touch $@
