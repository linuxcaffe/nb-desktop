# nb-desktop

Desktop file manager integration for [nb](https://xwmx.github.io/nb/) — right-click any file in Caja or Nemo and send it directly to an nb notebook.

Powered by [send.nb-plugin](https://github.com/linuxcaffe/nb-plugins/blob/main/send.nb-plugin) from [nb-plugins](https://github.com/linuxcaffe/nb-plugins).

---

## What it does

Right-click a file → **Scripts → Import to nb** (Caja) or **Import to nb** (Nemo):

1. **Choose a notebook** — all your nb notebooks listed
2. **Choose a folder and filename** — subfolders listed; rename the file stem if you like (original extension always preserved)

Files with unrecognised MIME types (executables, unknown binaries) trigger a warning before import. The actual file copy, `.index` entry, and git commit are handled by nb's own `import copy` — nothing is reinvented.

All activity is logged to `/tmp/nb-send.log`.

---

## Requirements

- [nb](https://xwmx.github.io/nb/) installed and on `$PATH`
- `zenity` (standard on MATE/Cinnamon desktops)
- Caja (Linux Mint MATE, Ubuntu MATE) and/or Nemo (Linux Mint Cinnamon)

---

## Install

Clone both repos alongside each other, then run the installer:

```bash
git clone https://github.com/linuxcaffe/nb-plugins.git
git clone https://github.com/linuxcaffe/nb-desktop.git
cd nb-desktop
./install.sh
```

The installer:
1. Runs `nb plugin install send.nb-plugin` (from the sibling nb-plugins directory)
2. Installs the Caja Scripts entry (`~/.config/caja/scripts/Import to nb`)
3. Installs the Nemo action (`~/.local/share/nemo/actions/nb-import.nemo_action`)

Caja and Nemo are detected automatically — whichever is present gets wired up.

### Install send.nb-plugin standalone

If you only want `nb send` in the terminal without file manager integration:

```bash
nb plugin install https://raw.githubusercontent.com/linuxcaffe/nb-plugins/main/send.nb-plugin
```

---

## Usage

### From Caja
Right-click any file → **Scripts → Import to nb**

### From Nemo
Right-click any file → **Import to nb**

### From the terminal
```bash
nb send ~/Pictures/photo.jpg
nb send ~/Documents/report.pdf
nb send file:///home/djp/archive/note.md   # URI form (as passed by Nemo)
```

---

## File managers

| File manager | Desktop | How it's wired |
|---|---|---|
| Caja | Linux Mint MATE, Ubuntu MATE | Scripts menu — `~/.config/caja/scripts/Import to nb` |
| Nemo | Linux Mint Cinnamon | Action file — `~/.local/share/nemo/actions/nb-import.nemo_action` |

---

## Repo layout

```
caja/
  Import to nb          # Caja script shim — exec nb send
nemo/
  nb-import.nemo_action # Nemo action definition
install.sh              # Installs plugin + file manager hooks
```

The `bin/` directory (standalone `nb-import` script) was retired when the logic moved into `send.nb-plugin`.

---

## Related

- [nb-plugins](https://github.com/linuxcaffe/nb-plugins) — send.nb-plugin lives here, along with grep, cal, and others
- [nb](https://xwmx.github.io/nb/) — the note-taking tool this integrates with

---

## License

MIT
