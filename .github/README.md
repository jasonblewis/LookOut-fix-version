# Self-hosted fork of LookOut (fix version)

For what LookOut does and how to use it, see upstream's
[README](https://github.com/jasonblewis/LookOut-fix-version/blob/ot/README.MD).
This page covers only what is different about this fork.

This fork is installed from file and updates itself from this repository. The
add-on is upstream's [LookOut (fix version)](https://github.com/TB-throwback/LookOut-fix-version)
with the same add-on ID, so it replaces an installed copy and keeps its
settings.

It differs from upstream in three ways:

- **No `strict_max_version`.** Upstream caps the add-on at the Thunderbird
  version it has tested and only follows ESR releases, so each monthly release
  disables it. Without the cap it only stops working if Thunderbird really
  breaks it.
- **Auto-update.** `update_url` in `src/manifest.json` points at
  `updates.json` on this branch, which points at the xpi attached to the
  matching GitHub release.
- **Bug fixes** that are not yet upstream, each on its own `fix/*` branch off
  `master` so it can be offered upstream as a separate pull request:
  - `fix/rtf-decompress-bound`: a 52-byte winmail.dat could hang the parser
    (RTF size trusted from the message).
  - `fix/mapi-count-bounds`: 21-45 byte files could hang the parser (MAPI
    property, name and value counts, string lengths).
  - `fix/remove-attachments-splice`: removing winmail.dat also hid every
    attachment listed after it.
  - `fix/attachment-read-error`: a failed attachment read left LookOut
    waiting forever.
  - `fix/stream-bounds-check`: the input reader's bounds check never fired.
  - `fix/stale-message-race`: moving to another message while one was being
    decoded put the first message's attachments, body or invitation on the
    second.

## Branches

- `master`: tracks upstream `master`, unchanged.
- `fix/*`: one fix each, based on `master`.
- `ot` (default): `master` + all `fix/*` branches + the fork changes above.
  Releases are built from here.

## Releasing

1. Merge upstream or new fixes into `ot`.
2. Raise `version` in `src/manifest.json` (keep it above every version
   released so far, including upstream's).
3. Run `./ot-release.sh`. It builds the xpi into `dist/` and rewrites
   `updates.json`.
4. Commit and push, then create the GitHub release with the xpi, using the
   commands the script prints.

To install by hand (first install, or after the add-on has vanished from the
profile), download the xpi from the releases page with right-click, **Save
Link As**: a plain click in Firefox tries to install it as a Firefox add-on.
Then in Thunderbird go to **Add-ons**, click the gear icon, then **Install
Add-on From File**.

Thunderbird checks for add-on updates about once a day. To check at once, go
to **Add-ons**, click the gear icon, then **Check for Updates**.
