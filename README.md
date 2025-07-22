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

### 3.  Consume the **installer image** (Talos ≥ v1.5)

The CI workflow in this repo produces a ready-made installer OCI image at

```
ghcr.io/<owner>/talos-installer:v<talos-series>
```

This image already contains **all** required extensions (your EDID overlay
plus the official Nvidia/Intel/uinput ones).  Use it in the machine
configuration:

```yaml
machine:
  install:
    image: ghcr.io/<owner>/talos-installer:v1.10.5  # ← exact tag pushed by CI
    # Pass the kernel argument so the GPU driver picks up the EDID
    extraKernelArgs:
      # change connector if needed (find via `dmesg | grep -i connect`)
      - drm.edid_firmware=HDMI-A-1:edid/custom.edid
```

Talos pulls this custom installer during the install or upgrade step, so
the EDID (and other extensions) are active right after the first reboot.

If you install via PXE/USB you can alternatively download the **metal disk
image** artefact from the workflow (file name
`talos-v<version>-metal-thinktank-<run>.raw.gz`) and flash/serve it – it
already has the same extensions baked in.

---
## FAQ

### Where do I get an EDID *.bin file?

*   Extract from a working monitor using `get-edid | parse-edid` (Linux) or `edid-decode`.
*   Use tools such as `