# nb-desktop

Desktop file manager integration for [nb](https://xwmx.github.io/nb/) — right-click any file in Caja or Nemo and send it directly to an nb notebook.

Powered by [send.nb-plugin](https://github.com/linuxcaffe/nb-plugins/blob/main/send.nb-plugin) from [nb-plugins](https://github.com/linuxcaffe/nb-plugins).

---

## What it does

### Import to nb — general file import

Right-click a file → **Scripts → Import to nb** (Caja) or **Import to nb** (Nemo):

1. **Choose a notebook** — all your nb notebooks listed
2. **Choose a folder and filename** — subfolders listed; rename the file stem if you like (original extension always preserved)

Files with unrecognised MIME types (executables, unknown binaries) trigger a warning before import. The actual file copy, `.index` entry, and git commit are handled by nb's own `import copy` — nothing is reinvented.

All activity is logged to `/tmp/nb-send.log`.

---

### Add New Item — image + item note (nb-website workflow)

Right-click an image → **Scripts → Add New Item** (Caja):

1. **Choose a notebook** — all your nb notebooks listed
2. **Confirm the base name** — defaults to the image filename stem (e.g. `ABC001`)

The script then:
- Copies the image to `images/ABC001.jpg` in the notebook
- Creates `items/ABC001.md` from the item template (`.templates/item.md`), with `image:`, `title:`, and `date:` pre-filled
- Updates both `.index` files and makes a single git commit

Designed for [nb-website](https://github.com/linuxcaffe/nb-website) workflows where image and item note share the same base filename. Open nb-web after to fill in the remaining item fields.

All activity is logged to `/tmp/nb-new-item.log`.

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
Right-click an image → **Scripts → Add New Item**

### From Nemo
Right-click any file → **Import to nb**

### From the terminal
```bash
nb send ~/Pictures/photo.jpg
nb send ~/Documents/report.pdf
nb-new-item ~/Pictures/ABC001.jpg
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
bin/
  nb-new-item           # Add New Item main script (installed to ~/.local/bin/)
caja/
  Import to nb          # Caja shim — exec nb send
  Add New Item          # Caja shim — exec nb-new-item
nemo/
  nb-import.nemo_action # Nemo action definition
install.sh              # Installs plugin + file manager hooks + nb-new-item
```

---

## Related

- [nb-plugins](https://github.com/linuxcaffe/nb-plugins) — send.nb-plugin lives here, along with grep, cal, and others
- [nb](https://xwmx.github.io/nb/) — the note-taking tool this integrates with

---

## License

MIT
