# EDID binaries go here

Place one or more `*.edid` / `*.bin` files in this directory.
Each file should contain a **128-byte** or **256-byte** raw EDID block as
produced by tools such as `edid-decode`, `read-edid`, CRU, etc.

Example (1080p60 forged EDID):

```
custom.edid
```

Remember to update the kernel parameter in your Talos machine-config to
match the file name you choose. 