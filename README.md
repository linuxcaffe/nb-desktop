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

### Add New Item — image(s) + item note (nb-website workflow)

Right-click one or more images → **Scripts → Add New Item** (Caja). Caja's
own icon view gives you real thumbnails and real multi-select — the reason
this goes through Caja rather than a browser file-open dialog.

1. **Choose a notebook** — all your nb notebooks listed
2. **Code + Title** — Code defaults to the first image's filename stem (e.g.
   `ABC001`) and is used as the filename/accounting reference; Title is the
   separate descriptive text, always required

The script then calls nb-web's `/api/item/new` (same endpoint the item
specialty header's own "+ New" button uses, so both paths create identical
items):
- The first selected image becomes the primary image (`images/ABC001.jpg`);
  any further selected images are supplemental, auto-suffixed
  (`images/ABC001-1.jpg`, `images/ABC001-2.jpg`, ...)
- Creates `items/ABC001.md` from the item template (`.templates/item.md`),
  with `image:`, `title:`, and `date:` pre-filled (`image:` becomes a YAML
  list when there's more than one image)
- If the selected image(s) carry embedded IPTC/XMP Keywords (Pix writes
  tags there when its "store metadata in files" setting is on), those
  become the item's `tags:` list too — read via GExiv2, the same library
  Pix itself uses, so no extra install. Best-effort: if there are no tags,
  or GExiv2 isn't available, `tags:` is just left empty as before.
- Updates both `.index` files and makes a single git commit

Designed for [nb-website](https://github.com/linuxcaffe/nb-website) workflows.
Open nb-web after to fill in the remaining item fields — the item specialty
header's Fields modal auto-opens for exactly this if you use the in-app
"+ New" button instead; from Caja you'll want to open the item manually.

#### Also available from Pix

Pix's own "Personalize" scripts (Tools ▸ Personalize) can run the same
`nb-new-item` — no Pix extension development needed, no new script. The
installer wires up an entry called **Add New Item (nb)** automatically:
crop/tag/rename your images in Pix first, select the finished ones, then
Tools ▸ Personalize ▸ **Add New Item (nb)** runs the exact same flow as the
Caja version above, on whatever's selected in Pix.

Pix stores Personalize scripts in one file it owns and rewrites on its own
schedule, `~/.config/pix/scripts.xml` — there's no drop-in folder like Caja's
Scripts menu. `install.sh` merges the `nb-add-new-item` entry into that file
by `id` (via `pix/install-script.py`), leaving any scripts you've defined
yourself through Pix's UI untouched. **Quit Pix before running the
installer** — if Pix is open, it holds its own in-memory copy of
`scripts.xml` and will overwrite the file (silently dropping this entry)
the next time it saves or exits.

**Requires nb-web running** (default `http://127.0.0.1:5001` — override with
`NB_WEB_URL` for a remote install, e.g. a second real user's own machine:
`export NB_WEB_URL=http://10.0.0.19:5001`, or a Tailscale address). Auth is a
real per-user login (username/password, prompted once via zenity) — the same
flow a browser uses, not the shared `.api_token` (that's bound to one fixed
account, so every invocation would be attributed to it regardless of who's
actually at the keyboard). The session cookie is cached at
`~/.local/share/nb-new-item/session.cookies` (override the directory with
`NB_NEW_ITEM_STATE_DIR`) and reused until it stops working, then re-prompted.
The notebook picker is populated from `/api/notebooks`, not a local `nb` CLI
call — this script has no dependency on notebooks existing on the machine
it runs on, and a restricted account's `notebooks:` scope is respected
automatically. Unlike Import to nb, this script is *not* standalone — it's a
thin client over nb-web's own item-creation logic rather than a second
parallel implementation.

All activity is logged to `/tmp/nb-new-item.log`.

---

## Requirements

- [nb](https://xwmx.github.io/nb/) installed and on `$PATH`
- `zenity` (standard on MATE/Cinnamon desktops)
- Caja (Linux Mint MATE, Ubuntu MATE) and/or Nemo (Linux Mint Cinnamon)
- `curl` and `jq` — Add New Item only, to call nb-web's API
- [nb-web](https://github.com/linuxcaffe/nb-web) running — Add New Item only
- [Pix](https://github.com/linuxmint/pix) (optional) — for the Pix Personalize entry; `python3` also needed for the `scripts.xml` merge

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
2. Symlinks the Caja Scripts entries (`~/.config/caja/scripts/Import to nb`, `Add New Item`)
3. Generates the Nemo action (`~/.local/share/nemo/actions/nb-import.nemo_action`) — templated with `$HOME`, so this one file is generated rather than symlinked
4. Symlinks `nb-new-item` into `~/.local/bin/`

Caja and Nemo are detected automatically — whichever is present gets wired up.
Everything except the generated Nemo action is a symlink back into this repo
— there is exactly one copy of the code, editing it here takes effect
immediately, and nothing can silently drift out of sync with what's actually
installed.

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

### From Pix
Select image(s) → **Tools ▸ Personalize ▸ Add New Item (nb)**

### From the terminal
```bash
nb send ~/Pictures/photo.jpg
nb send ~/Documents/report.pdf
nb-new-item ~/Pictures/ABC001.jpg                    # single image
nb-new-item ~/Pictures/ABC001.jpg ~/Pictures/ABC001-b.jpg   # primary + supplemental
```

---

## File managers

| File manager | Desktop | How it's wired |
|---|---|---|
| Caja | Linux Mint MATE, Ubuntu MATE | Scripts menu — `~/.config/caja/scripts/Import to nb` |
| Nemo | Linux Mint Cinnamon | Action file — `~/.local/share/nemo/actions/nb-import.nemo_action` |
| Pix | any (image manager, not a file manager) | Personalize script — `~/.config/pix/scripts.xml`, Add New Item only |

---

## Repo layout

```
bin/
  nb-new-item           # Add New Item main script (symlinked to ~/.local/bin/)
caja/
  Import to nb          # Caja shim — exec nb send
  Add New Item          # Caja shim — exec nb-new-item
nemo/
  nb-import.nemo_action # Nemo action template — generated (not symlinked) at install time
pix/
  nb-add-new-item.script.xml # Pix Personalize <script> entry — Add New Item (nb)
  install-script.py     # Merges the entry into ~/.config/pix/scripts.xml by id
install.sh              # Installs plugin + file manager hooks + nb-new-item (symlinks throughout, except the templated Nemo action)
```

---

## Related

- [nb-plugins](https://github.com/linuxcaffe/nb-plugins) — send.nb-plugin lives here, along with grep, cal, and others
- [nb](https://xwmx.github.io/nb/) — the note-taking tool this integrates with

---

## License

MIT
