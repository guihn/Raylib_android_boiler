# Generic Android Makefile

# Define your C source files
SRC_DIR := src
SRCS := $(wildcard $(SRC_DIR)/*.c)

# Define project information
APPNAME := Eye
PACKAGENAME := org.yourorg.$(APPNAME)
ANDROID_VERSION := 30
ANDROID_TARGET := $(ANDROID_VERSION)

KEYSTOREFILE := last_key
ALIASNAME := standkey
STOREPASS := password
DNAME := "CN=example.com, OU=ID, O=Example, L=Doe, S=John, C=GB"

# Define paths to Android SDK and NDK
ANDROID_SDK_ROOT := /home/gui/android_sdk/build-tools/30.0.2
ANDROID_NDK_ROOT := $(ANDROID_SDK_ROOT)/../../ndk/21.3.6528147

PROJECT_ROOT := $(shell pwd)

# Define build tools and compilers
CC := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/$(shell uname -s | tr '[:upper:]' '[:lower:]')-x86_64/bin/aarch64-linux-android30-clang

# Compiler flags
CFLAGS := -Os -DANDROID -DAPPNAME=\"$(APPNAME)\" -DANDROIDVERSION=$(ANDROID_VERSION) -I$(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux_x86_64/sysroot/usr/include -I$(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux_x86_64/sysroot/usr/include/android -I$(ANDROID_NDK_ROOT)/sysroot/usr/include -I$(ANDROID_NDK_ROOT)/sysroot/usr/include/android -I$(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/$(shell uname -s | tr '[:upper:]' '[:lower:]')-x86_64/sysroot/usr/include -fPIC
LDFLAGS := -shared -Wl,--gc-sections -Wl,--no-undefined libraylib.a -lm -lGLESv3 -lEGL -landroid -llog -lOpenSLES

# Output directory and APK file
OUT_DIR := makecapk
APKFILE := $(OUT_DIR)/$(APPNAME).apk

# Define the targets for different architectures
TARGETS := $(addprefix $(OUT_DIR)/lib/,$(addsuffix /lib$(APPNAME).so,arm64-v8a))

# Create a new fake key
$(KEYSTOREFILE) :
	keytool -genkey -v -keystore $(KEYSTOREFILE).keystore -alias $(ALIASNAME) -keyalg RSA -keysize 2048 -validity 10000 -storepass $(STOREPASS) -keypass $(STOREPASS) -dname $(DNAME)

# Rule for compiling for different architectures
$(OUT_DIR)/lib/%/lib$(APPNAME).so: $(SRCS)
	mkdir -p $(OUT_DIR)/lib/$*
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)


# Rule for creating the APK
$(APKFILE): $(TARGETS) AndroidManifest.xml
	mkdir -p $(OUT_DIR)/assets
#	cp libraylib.5.0.0.so $(OUT_DIR)/lib/arm64-v8a/
	# You might add asset copying here if needed
	$(ANDROID_SDK_ROOT)/aapt package -f -F temp.apk -I $(ANDROID_SDK_ROOT)/../../platforms/android-$(ANDROID_VERSION)/android.jar -M AndroidManifest.xml -S Sources/res -A $(OUT_DIR)/assets -v --target-sdk-version $(ANDROID_TARGET)
	unzip -o temp.apk -d $(OUT_DIR)
	cd $(OUT_DIR) && zip -D4r ../$(APKFILE)_t . && zip -D0r ../$(APKFILE)_t ./resources.arsc ./AndroidManifest.xml
	$(ANDROID_SDK_ROOT)/zipalign -v 4 $(APKFILE)_t $(APKFILE)
	$(ANDROID_SDK_ROOT)/apksigner sign --key-pass pass:$(STOREPASS) --ks-pass pass:$(STOREPASS) --ks $(PROJECT_ROOT)/$(KEYSTOREFILE).keystore $(APKFILE)
	cp $(APKFILE) $(PROJECT_ROOT)
	cd $(PROJECT_ROOT)
#	rm -rf temp.apk
#	rm -rf $(OUT_DIR)
	@ls -l $(APPNAME).apk

push:
	adb install $(APPNAME).apk

run:
	adb shell am start -n $(PACKAGENAME)/android.app.NativeActivity

# Rule to compile all architectures
all: $(APKFILE)

# Rule for cleaning generated files
clean:
	rm -rf $(OUT_DIR)/*.apk $(OUT_DIR)/lib
