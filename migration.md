# Ubuntu 26.04 and Omakub migration guide

This guide separates two different operations:

1. **Upgrade Ubuntu** from 24.04 LTS to 26.04 LTS using Ubuntu's release upgrader.
2. **Migrate the Omakub customization** to this repository's Omabuntu continuation using `migrate.sh`.

`migrate.sh` changes the customization installed under `~/.local/share/omakub`; it does not perform a major Ubuntu release upgrade.

## Support scope

This repository currently supports Ubuntu 24.04 LTS and Ubuntu 26.04 LTS. Its installer also restricts the supported CPU architectures to `x86_64` and `i686`. The desktop configuration assumes Ubuntu GNOME and GDM; other Ubuntu flavors, Server installations, WSL, and other architectures are not covered by this guide.

Ubuntu 26.04 LTS is Resolute Raccoon. Ubuntu 26.04.1 was released on 27 August 2026. Ubuntu's normal LTS upgrade offer becomes available after the first point release, so the supported direct upgrade from 24.04 LTS should now be available when the release upgrader considers the installation eligible. See the [Ubuntu 26.04 release notes](https://documentation.ubuntu.com/release-notes/26.04/), the [release schedule](https://documentation.ubuntu.com/release-notes/26.04/schedule/), and the [Ubuntu Desktop upgrade guide](https://ubuntu.com/desktop/docs/en/latest/how-to/upgrade-ubuntu-desktop/).

## Before upgrading Ubuntu

1. Back up your personal data and any important system configuration to a separate device or location. Keep a copy of project-specific configuration that you cannot easily recreate.
2. Connect laptops to power and make sure there is enough free disk space for the release upgrade. Ubuntu's [26.04 notes](https://documentation.ubuntu.com/release-notes/26.04/) describe the Desktop hardware and storage guidance.
3. Fully update Ubuntu 24.04 and reboot if prompted:

   ```bash
   sudo apt update
   sudo apt upgrade
   ```

4. Review third-party APT repositories and PPAs. Ubuntu disables third-party sources during a release upgrade; do not re-enable one until its publisher provides a repository for `resolute`.
5. Check the [Ubuntu 26.04 release notes](https://documentation.ubuntu.com/release-notes/26.04/) for blockers and known issues. In particular, Ubuntu 26.04 does not support cgroup v1, and the release upgrader blocks upgrades from systems running it. Do not attempt to bypass that check.

## Upgrade Ubuntu

Use Ubuntu's graphical Software Updater or run the supported command-line release upgrader:

```bash
sudo do-release-upgrade
```

Follow the interactive prompts, review the package and configuration-file changes, and reboot when the upgrade finishes. Do not use a development-release option for this LTS upgrade. Ubuntu does not support skipping releases: if the machine is older than 24.04, follow the sequential upgrade path in the [26.04 release notes](https://documentation.ubuntu.com/release-notes/26.04/) before proceeding to 26.04.

After the reboot, confirm that `/etc/os-release` reports `VERSION_ID="26.04"`. Review `/etc/apt/sources.list.d/` and re-enable only third-party repositories that explicitly support `resolute`.

## Migrate upstream Omakub to Omabuntu

Use the current `migrate.sh` from this repository after Ubuntu has completed its release upgrade. The script defaults to the `omakasui/omabuntu` repository and the `main` ref:

```bash
bash ./migrate.sh
```

You can select a different Omabuntu repository or ref with `OMAKUB_REPO` and `OMAKUB_REF`, for example:

```bash
OMAKUB_REPO=omakasui/omabuntu OMAKUB_REF=main bash ./migrate.sh
```

The script asks for confirmation, stages the target checkout before replacing the existing Omakub checkout, and saves a timestamped backup under `~/.local/share/omakub-backup-*`. It also backs up `~/.bashrc` when present. If the migration script exits before completion, it restores the original checkout and `.bashrc` from that backup. This does not roll back system-level changes already made by package installation or configuration scripts, so keep the separate backup from the pre-upgrade steps.

The migration script runs package updates as part of its work, but those are not a substitute for `do-release-upgrade`.

## Update an existing Omabuntu installation

If Omabuntu is already installed, do not use the Omakub-to-Omabuntu migration script solely to change Ubuntu releases. After completing the Ubuntu release upgrade and rebooting, update Omabuntu's APT sources and packages:

```bash
omakub-refresh-apt stable
omakub update
```

`omakub-refresh-apt` refreshes the release-specific Omakasui keyrings and sets the Omabuntu repository suite to the current Ubuntu codename. If keyring packages for `resolute` cannot be downloaded, stop and contact the repository maintainer rather than re-enabling old-release package sources.

## Post-upgrade checks

After the Omabuntu migration or update:

- Log in to the Ubuntu GNOME session and check the dock, app grid, GNOME extensions, shortcuts, and system settings.
- Confirm terminals, browsers, PDF associations, clipboard and screenshot tools, and file-manager actions work.
- Check display scaling and input on the target hardware. The Framework scaling helper now checks DRM panel modes under Wayland and uses `xrandr` only as an X11 fallback.
- Reboot once more and check the Plymouth theme and normal boot. Plymouth updates select Dracut by default on 26.04; if you have deliberately switched to `initramfs-tools`, run the helper with that backend selected:

  ```bash
  OMAKUB_INITRAMFS_BACKEND=initramfs-tools omakub-plymouth-update-initramfs
  ```

- Confirm Omabuntu APT sources use `resolute`, then run `omakub update` again if package updates were deferred during migration.

Ubuntu 26.04 upgrades GNOME to version 50 and the Ubuntu desktop session is Wayland-only. It also replaces several default applications; review the [Ubuntu 26.04 LTS summary](https://documentation.ubuntu.com/release-notes/26.04/summary-for-lts-users/) if a desktop application, extension, or workflow behaves differently.

## Official Ubuntu references

- [Ubuntu 26.04 LTS release notes](https://documentation.ubuntu.com/release-notes/26.04/)
- [Ubuntu 26.04 LTS summary for users upgrading from an LTS](https://documentation.ubuntu.com/release-notes/26.04/summary-for-lts-users/)
- [Ubuntu 26.04 release schedule](https://documentation.ubuntu.com/release-notes/26.04/schedule/)
- [Upgrade Ubuntu Desktop](https://ubuntu.com/desktop/docs/en/latest/how-to/upgrade-ubuntu-desktop/)
- [How to upgrade your Ubuntu Server release](https://documentation.ubuntu.com/server/how-to/software/upgrade-your-release/)
