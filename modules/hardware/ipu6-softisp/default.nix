{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.hardware.ipu6-softisp;

  libcamera = pkgs.libcamera.overrideAttrs (old: {
    # This is a mix of #281755 (bump pipewire to 0.2.0),
    # and the additional ipu6-softisp patches.
    version = "0.2.0";
    src = pkgs.fetchgit {
      url = "https://git.libcamera.org/libcamera/libcamera.git";
      rev = "v0.2.0";
      hash = "sha256-x0Im9m9MoACJhQKorMI34YQ+/bd62NdAPc2nWwaJAvM=";
    };

    mesonFlags = old.mesonFlags or [ ] ++ [
      "-Dpipelines=simple/simple,ipu3,uvcvideo"
      "-Dipas=simple/simple,ipu3"
    ];

    # Explicitly clear list of patches, as #281755 did.
    # This is
    # https://copr-dist-git.fedorainfracloud.org/cgit/jwrdegoede/ipu6-softisp/libcamera.git/plain/libcamera-0.2.0-softisp.patch?h=f39&id=60e6b3d5e366a360a75942073dc0d642e4900982,
    # but manually piped to git and back, as some renames were not processed properly.
    patches = [
      ./libcamera/0001-libcamera-pipeline-simple-fix-size-adjustment-in-val.patch
      ./libcamera/0002-libcamera-internal-Move-dma_heaps.-h-cpp-to-common-d.patch
      ./libcamera/0003-libcamera-dma_heaps-extend-DmaHeap-class-to-support-.patch
      ./libcamera/0004-libcamera-internal-Move-SharedMemObject-class-to-a-c.patch
      ./libcamera/0005-libcamera-internal-Document-the-SharedMemObject-clas.patch
      ./libcamera/0006-libcamera-introduce-SoftwareIsp-class.patch
      ./libcamera/0007-libcamera-software_isp-Add-SwStats-base-class.patch
      ./libcamera/0008-libcamera-software_isp-Add-SwStatsCpu-class.patch
      ./libcamera/0009-libcamera-software_isp-Add-Debayer-base-class.patch
      ./libcamera/0010-libcamera-software_isp-Add-DebayerCpu-class.patch
      ./libcamera/0011-libcamera-ipa-add-Soft-IPA-common-files.patch
      ./libcamera/0012-libcamera-ipa-Soft-IPA-add-a-Simple-Soft-IPA-impleme.patch
      ./libcamera/0013-libcamera-software_isp-add-Simple-SoftwareIsp-implem.patch
      ./libcamera/0014-libcamera-pipeline-simple-rename-converterBuffers_-a.patch
      ./libcamera/0015-libcamera-pipeline-simple-enable-use-of-Soft-ISP-and.patch
      ./libcamera/0016-libcamera-swstats_cpu-Add-support-for-8-10-and-12-bp.patch
      ./libcamera/0017-libcamera-debayer_cpu-Add-support-for-8-10-and-12-bp.patch
      ./libcamera/0018-libcamera-debayer_cpu-Add-BGR888-output-support.patch
      ./libcamera/0019-libcamera-pipeline-simple-Enable-simplepipeline-for-.patch
      ./libcamera/0020-libcamera-Add-support-for-IGIG_GBGR_IGIG_GRGB-bayer-.patch
      ./libcamera/0021-libcamera-swstats_cpu-Add-support-for-10bpp-IGIG_GBG.patch
      ./libcamera/0022-libcamera-debayer_cpu-Add-support-for-10bpp-IGIG_GBG.patch
      ./libcamera/0023-libcamera-Add-Software-ISP-benchmarking-documentatio.patch
      ./libcamera/0024-ov01a1s-HACK.patch
      ./libcamera/0025-libcamera-debayer_cpu-Make-the-minimum-size-1280x720.patch
    ];
  });

  # compat with libcamera 0.2
  pipewire' = (pkgs.pipewire.overrideAttrs (old: {
    patches = old.patches or [ ] ++ [
      (pkgs.fetchpatch {
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/merge_requests/1750
        name = "pipewire-spa-libcamera-use-cameraconfiguration-orientation-pr1750.patch";
        url = "https://gitlab.freedesktop.org/pipewire/pipewire/-/merge_requests/1750.patch ";
        hash = "sha256-Ugg913KZDKELnYLwpDEgYh92YPxccw61l6kAJulBbIA=";
      })
    ];
  })).override {
    inherit libcamera;
  };

  wireplumber' = (pkgs.wireplumber.override {
    pipewire = pipewire';
  });

in
{
  options.modules.hardware.ipu6-softisp = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    hardware.firmware = [ pkgs.ipu6-camera-bins ];

    boot.kernelPatches = [{
      name = "linux-kernel-test.patch";
      patch = pkgs.fetchurl {
        url = "https://copr-dist-git.fedorainfracloud.org/cgit/jwrdegoede/ipu6-softisp/kernel.git/plain/linux-kernel-test.patch?h=f39&id=0ed76891b2fc08579d08bedb9294a41840007299";
        hash = "sha256-8hKP4nltGlkzr8iOgsIUT9Tt5i+x4kdLmw/+lFeNoGQ=";
      };
      extraStructuredConfig = {
        # needed for /dev/dma_heap
        DMABUF_HEAPS_CMA = lib.kernel.yes;
        DMABUF_HEAPS_SYSTEM = lib.kernel.yes;
        DMABUF_HEAPS = lib.kernel.yes;
      };
    }];

    services.udev.extraRules = ''
      KERNEL=="system", SUBSYSTEM=="dma_heap", TAG+="uaccess"
    '';

    services.pipewire.package = lib.mkForce pipewire';
    services.pipewire.wireplumber.package = lib.mkForce wireplumber';
  };
}
