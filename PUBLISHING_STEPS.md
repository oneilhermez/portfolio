# Publishing the Portfolio Site

## Fast automated method

1. Install Git: https://git-scm.com/downloads
2. Install GitHub CLI: https://cli.github.com/
3. Extract this portfolio ZIP.
4. Open the extracted folder.
5. Right-click inside the folder and choose **Open in Terminal**.
6. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\publish-to-github.ps1
```

The script will sign you into GitHub, create a public repo named `<your-username>.github.io`, upload the website, and try to enable GitHub Pages.

Your final site will usually be:

```text
https://<your-username>.github.io
```

## Manual fallback

If the script fails, create a public repository named `<your-username>.github.io`, upload all files in this folder, then go to **Settings > Pages** and set the source to **main / root**.
