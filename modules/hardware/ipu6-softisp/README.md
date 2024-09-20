# ipu6-softisp

This code adds support for the ipu6 webcams via libcamera, based on the work in
https://copr.fedorainfracloud.org/coprs/jwrdegoede/ipu6-softisp/.

It's supposed to be included in your NixOS configuration imports, and will:

 - Add some patches to your kernel, which should apply on 6.7.x
 - Add the `ipu6-camera-bins` firmware (still needed)
 - Enable some kernel config options
 - Add an udev rule so libcamera can do DMABUF things
 - Override `services.pipewire.package` and
   `services.pipewire.wireplumber.package` to use a pipewire built with a libcamera
   with support for this webcam.

Please make sure you don't have any of the `hardware.ipu6` options still
enabled, as they use the closed-source userspace stack and will conflict.

The testing instructions from
https://copr.fedorainfracloud.org/coprs/jwrdegoede/ipu6-softisp/ still apply.

`qcam` can be found in `libcamera-qcam` (pending on
https://github.com/NixOS/nixpkgs/pull/284964 to trickle into master).

Thanks to Hans de Goede for helping me bringing this up, as well as to
puckipedia for sorting out some pipewire-related confusion.
