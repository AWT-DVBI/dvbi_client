{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        }; };

      myflutter = pkgs.writeScriptBin "flutter" ''
            TMP=/tmp/${appname}
            mkdir -p $TMP
            export HOME=$TMP
            export PUB_CACHE="$TMP/.pub-cache";
            export LD_LIBRARY_PATH="${pkgs.libepoxy}/lib";
            ${pkgs.flutter}/bin/flutter "$@"
      '';

      # Getting information
      # $ cd nixpkgs/pkgs/development/mobile/androidenv
      # $ ./querypackages.sh packages
      androidComposition = pkgs.androidenv.composeAndroidPackages {
        toolsVersion = "26.1.1";
        platformToolsVersion = "33.0.2";
        buildToolsVersions = [ "30.0.3" ];
        includeEmulator = true;
        emulatorVersion = "31.3.9";
        platformVersions = [ "31" ];
        includeSources = true;
        includeSystemImages = true;
        #systemImageTypes = [ "google_apis_playstore" ];
        #abiVersions = [ "x86_64" ];
        cmakeVersions = [ "3.22.1" ];
        includeNDK = true;
        ndkVersions = ["22.1.7171670"];
        useGoogleAPIs = false;
        useGoogleTVAddOns = false;
        extraLicenses = [
          "android-googletv-license"
          "android-sdk-arm-dbt-license"
          "android-sdk-license"
          "android-sdk-preview-license"
          "google-gdk-license"
          "intel-android-extra-license"
          "intel-android-sysimage-license"
          "mips-android-sysimage-license"
          ];
        includeExtras = [
          "extras;google;gcm"
        ];
      };

        # Getting information
        # $ cd nixpkgs/pkgs/development/mobile/androidenv
        # $ ./querypackages.sh images
        myemulator =  pkgs.androidenv.emulateApp {
          name = "emulate-MyAndroidApp";
          platformVersion = "33";
          abiVersion = "x86_64"; # armeabi-v7a, mips, x86_64
          systemImageType = "google_apis_playstore";
          sdkExtraArgs = {
             emulatorVersion = "31.3.9";
          };
        };
        appname = "dvbi_flutter";
        nativeDeps = with pkgs; [
            autoPatchelfHook
            pkg-config
            cmake
            clang
            myflutter
            ninja
        ];
        buildDeps = with pkgs; [
          at-spi2-core
          dbus
          libxkbcommon
          xorg.libXdmcp
          libdatrie
          libthai
          libsepol
          libselinux
          util-linux
          wxGTK31
          gtk3
          pcre
          libepoxy
          lzlib
          clang
        ];
      in
      rec {
        defaultPackage = pkgs.flutter.mkFlutterApp {
          pname = "dvbi";
          version = "0.0.1";
          vendorHash = "sha256-ikZbvShphzyUzJKyHInbWSfVuMujXzQM78YD8atwLCY=";
          src = ./dvbi_flutter_client;
        };

        defaultApp = utils.lib.mkApp {
          drv = self.defaultPackage."${system}";
        };

        devShell = with pkgs; mkShell {
          nativeBuildInputs = nativeDeps ++ [ chromium ];
          buildInputs = buildDeps ++ nativeDeps;
          shellHook = ''
            # Flutter configuration
            export CHROME_EXECUTABLE="chromium";

            # Android jail
            export JAVA_HOME=${pkgs.jdk.home}
            export ANDROID_SDK_HOME=$TMP/Android;
            mkdir -p $ANDROID_SDK_HOME
            export ANDROID_SDK_ROOT="${androidComposition.androidsdk}/libexec/android-sdk";
            export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk-bundle;
          '';

        };
      });
}
