# Classic Race Icons — WoW Forever

**Your own portrait, framed the Classic way.** In WoW Forever the unit frame portraits
come from the new models, and their camera puts the head low and small in the circle.
Classic Race Icons re-frames every player's *own* portrait — face, hair and gear stay
exactly as they are — so the head sits where it sat in the Classic client.

**Works with both the stock UI and the
[ClassicUI Forever](https://github.com/wowaddonmaker/classicuiforever) addon** by
[justawower](https://github.com/wowaddonmaker) — Blizzard's own unit frames as well as
ClassicUI Forever's 1.x frames. Nothing to set up: the addon sees which one you use.

| Stock UI, addon off | Stock UI, addon on |
| :---: | :---: |
| ![Forever's own portraits, addon off](Pictures/Original%20UI%20-%20CRI%20Disabled.png) | ![The same frames with Classic Race Icons](Pictures/Original%20UI%20-%20CRI%20Enabled.png) |

**Every classic race and Forever's Skyborne, male and female — all 18 are tuned out of
the box:**

![The 18 races and sexes as Classic Race Icons frames them](Pictures/Classic%20Icons.png)

Made by **Jedborg** (<https://github.com/JedborgWoW>).

## Features

* **All the classic races**: Human, Dwarf, Night Elf, Gnome, Orc, Undead, Tauren and
  Troll, plus Forever's **Skyborne** (blood elves) — each male and female tuned on its own
  against the Classic client's real portraits.
* **Orc male is limited**: Forever's orc male sits in a different position in its portrait
  than the Classic one, so it can't be framed exactly like Classic — it is tuned as close
  as the picture allows.
* **Your real portrait**: nothing is swapped for a picture. Every player's live portrait is
  shown, only framed differently, so gear, hair and faces are their own.
* **Every portrait frame**: player, target, target of target, focus, focus target and
  party frames.
* **Options window** (`/cri options`) to switch frames, races and sexes on or off.
* **Calibration window** (`/cri tune`) to re-frame any race and sex yourself, side by side
  with the Classic portrait, with an overlay to line the heads up.
* **Classic black around the portrait** when a head has to be smaller than Forever's
  picture allows — like the black behind a Classic portrait.
* **Works with the stock UI and with
  [ClassicUI Forever](https://github.com/wowaddonmaker/classicuiforever)** (by
  [justawower](https://github.com/wowaddonmaker)): Blizzard's own
  unit frames and ClassicUI Forever's 1.x frames alike, found by itself at login.
* **Safe in combat**: no "blocked from an action" popups, no taint — the addon never moves,
  hides or changes Blizzard's frames, it only picks which part of the portrait is shown.

## Installation

1. Download the addon (*Code → Download ZIP*, or a release).
2. Copy the **`ClassicRaceIcons`** folder (the one with `ClassicRaceIcons.toc` inside) to
   your WoW Forever `Interface\AddOns\` folder, e.g.
   `World of Warcraft\_classic_beta_\Interface\AddOns\ClassicRaceIcons`.
   The folder must be called exactly `ClassicRaceIcons` — not `…-main`.
3. Start the game and make sure *Classic Race Icons* is enabled in the AddOns list on the
   character screen.

That's it: every portrait is framed the Classic way from the first login.

## Options

Type **`/cri options`** to open the options window.

<img src="Pictures/options%20panel.png" alt="The options window" width="300" align="right">

**General**

* *Enable addon* — everything on or off.
* *Player / Target / Focus / Party Frames Portrait* — which frames are re-framed. The
  target of target goes with *Target*, the focus's target with *Focus*.

**Race Overrides**

* Every race, *Male* and *Female* on their own. A race and sex that is off keeps Forever's
  own portrait.

**Calibration**

* *Current* shows who the buttons act on: your target (if it is a player of one of the
  races), otherwise you — and whether that race and sex uses the default or your own
  calibration (*custom*).
* *Calibrate Current Character* opens the calibration window.
* *Reset Current Calibration* puts that race and sex back to the default.
* *Reset All Custom Calibrations* puts every race and sex back to the defaults (click it
  twice to confirm).

Every change shows at once and is saved for the whole account.

<br clear="right">

## Calibrating a portrait yourself

The defaults already frame every race and sex. If you want one framed differently:

1. **Target a player** of that race and sex — or target nobody to calibrate your own
   character.
2. Type **`/cri tune`** (or click *Calibrate Current Character* in the options).
3. **Left**: the portrait as your frames show it. **Right**: the *Classic* client's
   portrait of that race and sex, as a reference.
4. **Move and zoom** the left one until the head sits like the right one:
   * drag it with the mouse, and use the mouse wheel to zoom, or
   * use the *Zoom − / Zoom + / Up / Down / Left / Right* buttons (hold **Shift** for
     bigger steps).
5. **Overlay** lays the Classic portrait over yours; the *Overlay strength* fader (or the
   mouse wheel on it) sets how much of it shows. Line up eyes, nose and chin.
6. It is **saved per race and sex** and used straight away for every player of that race
   and sex, on every frame. *Reset* goes back to the default.

| Your portrait beside the Classic one | With the overlay at 60 % |
| :---: | :---: |
| ![Calibrating a gnome female](Pictures/Gnome%20Female%20calibration%20panel%20-%20no%20overlay.png) | ![The Classic portrait laid over it](Pictures/Gnome%20Female%20calibration%20panel%20-%20with%20overlay.png) |
| ![Calibrating a tauren female](Pictures/Tauren%20Female%20calibration%20panel.png) | ![The tauren with the overlay](Pictures/Tauren%20Female%20calibration%20panel2.png) |

![Calibrating a Skyborne female — the target frame follows at once](Pictures/Skyborne%20Female%20Calibration%20Panel.png)

The line at the bottom of the window helps:

* *Edge of the client's picture: zoom in for more room* — Forever's picture ends there;
  zoom in a little to move the head further.
* *Past the client's picture: black around it* — the portrait is now smaller than, or moved
  beyond, Forever's picture, and the rest of the circle is black, the way Classic portraits
  had a black background. (Turn this off with `/cri shrink` if you'd rather keep every
  portrait within Forever's picture.)

## Slash commands

| Command | What it does |
| --- | --- |
| `/cri options` | Open or close the options window |
| `/cri tune` | Open the calibration window (your target, or you) |
| `/cri on` / `/cri off` | Turn the addon on or off |
| `/cri human`, `dwarf`, `nightelf`, `gnome`, `orc`, `undead`, `tauren`, `troll`, `skyborne` | Turn one race on or off (both sexes) |
| `/cri others` | Re-frame everyone, or only your own portrait |
| `/cri shrink` | Allow portraits smaller than or beyond Forever's picture, with black around them (on by default) |
| `/cri reset` | Every race and sex back to the defaults |
| `/cri status` | What each frame shows, and every race and sex's framing |

`/classicraceicons` works as well as `/cri`.

## Good to know

* **Forever's class icon portraits** (the Settings option, or RougeUI's *Class Portrait*)
  win over this addon while they are on.
* **Stock UI or ClassicUI Forever**: both work. The stock frames show the whole round
  portrait, so on a few races you may see a little black at the rim, where Forever's picture
  ends; ClassicUI Forever's ring covers that part.
* NPCs are never touched — only players of the races above.
* When the game hides a player's race or sex from addons, that portrait stays Forever's own.
* Settings are stored in `ClassicRaceIconsDB` (SavedVariables), for the whole account.

## Why the portraits look different — and what the addon does

A unit frame portrait is a picture the game client renders of the unit's model. Classic
Era renders it exactly the same way; the Classic look comes from the original models and
their portrait camera. Forever's character models are newer models with classic-style
textures, and their camera frames the head lower and smaller.

No addon can move that camera. What an addon *can* do is choose which part of the
rendered picture is shown — so Classic Race Icons zooms and moves that window, right after
the game draws the portrait, until the head sits where the Classic client put it. Where
Forever's picture is too tight to zoom out further, the area beyond it is covered with
black, like the black behind a Classic portrait. The head's angle can't be changed, only
its size and place.

For the curious:

* One `hooksecurefunc` on `UnitFramePortrait_Update`, the function every Blizzard unit frame
  redraws its portrait through. After it, the portrait gets `SetTexCoord` — a texture call,
  not protected, fine in combat.
* Nothing of Blizzard's is moved, resized, shown or hidden; no field is written on a
  Blizzard object and no Blizzard Lua function is called.
* The black (`Media/Outside.tga`) is the addon's own texture, laid over the portrait with
  the same texcoords and masked to the ring's opening. It is only made and placed out of
  combat; in combat only its texcoords and alpha change.
* `UnitRace` / `UnitSex` can be secret in Forever; they are checked with `canaccessvalue`
  first, and a secret one leaves Blizzard's portrait.

## Files

* `ClassicRaceIcons/` — the addon: `ClassicRaceIcons.toc`, `ClassicRaceIcons.lua` and
  `Media/`.
  * `Media/Shot-<Sex>-<Race>.tga` — the Classic (3.3.5a) client's portraits of each race
    and sex (Blizzard Entertainment's art), cut out of screenshots of its player frame: the
    calibration window's *Classic* picture.
  * `Media/Outside.tga` — the black laid around a portrait that goes past Forever's
    picture.
* `Pictures/` — the screenshots on this page.
* `CHANGELOG.md` — every change, dated.
* `LICENSE` — the licence.

## License

All rights reserved; see [LICENSE](LICENSE). You may download, install and use the addon
for your own play. Forks are welcome for proposing changes back as pull requests, but
copies may not be published or distributed anywhere, addon sites included. Blizzard
Entertainment's art (the Classic portraits and the game in the screenshots) is theirs and
not covered by the licence.
