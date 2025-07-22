# talos-edid-extension

This repository provides a minimal **Talos Linux system extension** that ships a custom EDID (Extended Display Identification Data) binary.  
When installed the extension places the EDID file under `/usr/lib/firmware/edid/` inside the Talos root-filesystem so that the Linux kernel can expose it via the `drm.edid_firmware` kernel parameter.

Typical use-cases:
* Head-less GPU / VDI nodes that need a “fake” monitor to unlock high resolutions or enable the NVIDIA driver.
* KVM/Hyper-V virtual machines that should expose a fixed resolution to the guest.

---
## Repository layout

```
├── edid/                 # Put your EDID *.bin files here (one is committed as an example)
│   └── custom.edid
├── manifest.yaml         # Metadata describing the extension (required by Talos)
├── Dockerfile            # Builds the OCI image that Talos will consume
├── Makefile              # Convenience targets (build, push, tag, etc.)
└── README.md             # You are here
```

> **Replace** `edid/custom.edid` with a real EDID binary generated for your environment (see the FAQ below).

---
## Quick start

### 1.  Build the extension

```
# Build a multi-arch image (amd64 + arm64) ready for Talos ≥1.7
$ make build
```

### 2.  Push to a registry

Login and push to GitHub Container Registry (`ghcr.io`) – or any registry of your choice:

```
# GitHub login (or docker login <registry>)
$ echo $GITHUB_TOKEN | docker login ghcr.io -u <username> --password-stdin

$ make push
```

The *Makefile* automatically tags `$IMAGE_REPO/$IMAGE_NAME:latest` (defaults to `ghcr.io/<gituser>/talos-edid-extension`).

### 3.  Reference the extension in Talos machine-config

```yaml
machine:
  install:
    # 1) Tell the installer to pull the system-extension image
    extensions:
      - image: ghcr.io/<username>/talos-edid-extension@sha256:<digest>
    # 2) Pass the kernel argument so the GPU driver picks up the EDID
    extraKernelArgs:
      # Change "HDMI-A-1" to the connector you need (see `drm_info` output)
      - drm.edid_firmware=HDMI-A-1:edid/custom.edid
```

Reboot (or reinstall) the node – Talos will bake the extension into `initramfs` and mount the EDID at boot time.

---
## FAQ

### Where do I get an EDID *.bin file?

*   Extract from a working monitor using `get-edid | parse-edid` (Linux) or `edid-decode`.
*   Use tools such as `wxEDID` or *Custom Resolution Utility* (CRU) on Windows.
*   Online generators exist for common resolutions, e.g. 1920×1080 / 4K.

### How do I know the connector name to use in `drm.edid_firmware`?

Boot a Talos live ISO (or any Linux) on the target machine and run:

```bash
dmesg | grep -i connect
```

Look for lines like `HDMI-A-1`, `DP-0`, `DVI-D-0` etc. – use the exact string before the colon.

### Can I host the image privately?

Yes – any OCI compliant registry works.  
Set `IMAGE_REPO=<registry_host>/<namespace>` when running *make* or build/push manually:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t registry.local/edid-ext:1.0 .
docker push registry.local/edid-ext:1.0
```

Make sure your Talos nodes (installer) can reach the registry and configure auth if required (`machine.install.registryAuth`).

---
## Advanced – GitHub Actions CI

A ready-to-use workflow is included under `.github/workflows/image.yml` (not committed by default).  
It builds multi-arch images on every push and attaches a signed provenance to satisfy Talos’ image-signature verification.

---
## License

MIT – do as you wish, no warranties.