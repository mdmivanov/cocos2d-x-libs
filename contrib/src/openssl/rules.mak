# OPENSSL
OPENSSL_EXTRA_CONFIG_1=no-shared no-unit-test
OPENSSL_EXTRA_CONFIG_2=

ifdef HAVE_MACOSX
ifeq ($(MY_TARGET_ARCH),x86_64)
OPENSSL_CONFIG_VARS=darwin64-x86_64-cc
OPENSSL_ARCH=-m64
endif

ifeq ($(MY_TARGET_ARCH),i386)
OPENSSL_CONFIG_VARS=BSD-generic32
OPENSSL_ARCH=-m32
endif
endif


ifdef HAVE_ANDROID
export ANDROID_TOOLCHAIN=$(ANDROID_TOOLCHAIN_PATH)

ifeq ($(MY_TARGET_ARCH),arm64-v8a)
OPENSSL_CONFIG_VARS=android-arm64
endif

ifeq ($(MY_TARGET_ARCH),armeabi-v7a)
OPENSSL_CONFIG_VARS=android-arm
OPENSSL_EXTRA_CONFIG_2=-no-integrated-as
endif

ifeq ($(MY_TARGET_ARCH),armeabi)
OPENSSL_CONFIG_VARS=android-armeabi
endif

ifeq ($(MY_TARGET_ARCH),x86)
OPENSSL_CONFIG_VARS=android-x86
endif
endif

ifdef HAVE_IOS



ifeq ($(MY_TARGET_ARCH),armv7)
IOS_PLATFORM=OS
OPENSSL_CONFIG_VARS=ios-cross
OPENSSL_EXTRA_CONFIG_2=no-async
endif

ifeq ($(MY_TARGET_ARCH),arm64)
IOS_PLATFORM=OS
OPENSSL_CONFIG_VARS=ios64-cross
OPENSSL_EXTRA_CONFIG_2=no-async
endif

ifeq ($(MY_TARGET_ARCH),armv7s)
IOS_PLATFORM=OS
OPENSSL_CONFIG_VARS=ios-cross
OPENSSL_EXTRA_CONFIG_2=no-async
endif

ifeq ($(MY_TARGET_ARCH),i386)
IOS_PLATFORM=Simulator
OPENSSL_CONFIG_VARS=ios-sim-cross-i386
OPENSSL_EXTRA_CONFIG_2=no-async
endif

ifeq ($(MY_TARGET_ARCH),x86_64)
IOS_PLATFORM=Simulator
OPENSSL_CONFIG_VARS=ios-sim-cross-x86_64
OPENSSL_EXTRA_CONFIG_2=no-async
endif

CUR_MAKEFILE_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

export CROSS_TOP=$(shell xcode-select -print-path)/Platforms/iPhone${IOS_PLATFORM}.platform/Developer
export CROSS_SDK=iPhone${IOS_PLATFORM}.sdk
export IOS_MIN_SDK_VERSION=8.0

endif

LIBOPENSSL_GITURL := https://github.com/openssl/openssl

$(TARBALLS)/openssl-git.tar.xz:
	$(call download_git,$(LIBOPENSSL_GITURL), OpenSSL_1_1_1-stable, 36eadf1f84daa965041cce410b4ff32cbda4ef08)

.sum-openssl: openssl-git.tar.xz

openssl: openssl-git.tar.xz
	$(UNPACK)
ifdef HAVE_ANDROID
	$(APPLY) $(SRC)/openssl/android-config.patch
endif
ifdef HAVE_IOS
	$(APPLY) $(SRC)/openssl/ios-config.patch
endif
	$(MOVE)

.openssl: openssl
	cd $< && $(HOSTVARS_PIC) ./Configure $(OPENSSL_CONFIG_VARS) --prefix=$(PREFIX) ${OPENSSL_ARCH} $(OPENSSL_EXTRA_CONFIG_1) $(OPENSSL_EXTRA_CONFIG_2)
ifdef HAVE_IOS
	cd $< && perl -i -pe "s|^CFLAGS=(.*) -DNDEBUG (.*)-O3|CFLAGS=\\1 \\2 ${OPTIM} ${ENABLE_BITCODE}|g" Makefile
	cd $< && perl -i -pe "s|^CFLAGS_Q=(.*) -DNDEBUG (.*)|CFLAGS_Q=\\1 \\2 ${OPTIM} ${ENABLE_BITCODE}|g" Makefile
endif
ifdef HAVE_MACOSX
	cd $< && perl -i -pe "s|^CFLAGS=(.*) -DNDEBUG (.*)-O3|CFLAGS=\\1 \\2 ${OPTIM}|g" Makefile
	cd $< && perl -i -pe "s|^CFLAGS_Q=(.*) -DNDEBUG (.*)|CFLAGS_Q=\\1 \\2 ${OPTIM}|g" Makefile
endif
	cd $< && $(MAKE) install_sw
	touch $@
