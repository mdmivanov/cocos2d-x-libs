# libuv

LIBUV_GITURL := https://github.com/libuv/libuv
#version 1.35.0 (stable)
$(TARBALLS)/libuv-git.tar.xz:
	$(call download_git,$(LIBUV_GITURL),v1.x,dc7c874660526e4ed70c7c7579b974283c9ad6e0)


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
