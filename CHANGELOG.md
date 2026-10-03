# Changelog

## [Unreleased]

## [1.0.1] — 2026-10-03

Shapeshifted portraits are left alone.

* **Druid forms** (Cat, Bear, Dire Bear, Travel, Aquatic, Moonkin and the later forms) and
  the shaman's **Ghost Wolf** show the creature, not the race, so their portraits are now
  left as Blizzard draws them instead of getting the race's framing, which made them
  smaller. On you, on your target, focus, party and their targets.
* A dead **night elf's wisp** is left alone too.
* Stances, stealth and Shadowform keep your own model and are framed as before.
* Other players in combat: the game hides their buffs from addons there, so the last form
  seen for that player is used until combat ends, and every portrait is checked again then.
* The calibration window says so when you are in a form; `/cri status` shows what the form
  check sees on you and your target.

The work that led up to it, newest first:


### 2026-10-03 — Ghost Wolf found more ways; a night elf's wisp

* The user: "Ghost form påverkas fortfarande". Which test missed it can't be seen offline,
  so every way a form can slip through is closed, and `/cri status` now shows what the form
  test sees ("your form: form 16, display … (native …), form auras 2645, in a form", the
  same for a player target).
* You: the animal forms (Blizzard's `ANIMAL_FORMS` IDs, Ghost Wolf 16) count by their form
  ID alone, without the display check; another form still only when it changes your display
  (not when the display is 0). A druid's or shaman's form the client doesn't report as a
  form is found by its aura on you (only while aura data isn't restricted).
* Everyone: a form aura is also looked for by its name in the client's language
  (`C_Spell.GetSpellName`, `C_UnitAuras.GetAuraDataBySpellName(unit, name, "HELPFUL")`), for
  one under another spell ID; the names are only kept once the client has them.
* A dead night elf's ghost is a wisp (Wisp Spirit): `UnitIsGhost`, Blizzard's portrait,
  reason "wisp". Other races' ghosts are their race and stay cropped.
* Tests: 1322 checks; mutants all killed.

### 2026-10-03 — druid forms and Ghost Wolf keep Blizzard's portrait

* The user: "Druid former ska ignoreras av addonet. Nu när man har på addonet för tex Night
  elf, och dom är i Cat Form, Travel Form eller Bear form så blir bilden "mindre"", then
  "Samma sak gäller shaman ghost wolfs". A form's portrait shows the creature, and the
  race's crop made it smaller; such a portrait is now left as Blizzard draws it.
* You: Blizzard's own test (`ModelSceneUtil.SetUpCharacterSheetScene`) — a
  `GetShapeshiftFormID()` form whose `C_PlayerInfo.GetDisplayID()` is not
  `GetNativeDisplayID()`, so stances, stealth and Shadowform keep your own model and stay
  cropped. Without `C_PlayerInfo`, the form's ID decides (Blizzard's `ANIMAL_FORMS`, which
  Forever doesn't load).
* Other players, druids and shamans only (`UnitClass`): the form's aura,
  `C_UnitAuras.GetUnitAuraBySpellID` — Cat 768, Bear 5487, Dire Bear 9634, Travel 783,
  Aquatic 1066, Moonkin 24858, Tree of Life 33891, Flight 33943, Swift Flight 40120, Ghost
  Wolf 2645. While aura data is restricted (combat, encounters, challenge modes, PvP
  matches) a missing aura says nothing, unless every form the client has is flagged never
  secret (`C_Secrets.GetSpellAuraSecrecy`); then the last answer read for that player (by
  GUID) stands, and one never read keeps Blizzard's portrait. No blocked-action popup: the
  query just returns nothing.
* `PLAYER_REGEN_ENABLED` now always crops every frame again (forms can be read again);
  `UPDATE_SHAPESHIFT_FORM` checks your own once more.
* The tuner says "In a form: change back to calibrate."; `/cri status` gives "shapeshifted"
  or "form unknown" as the reason.
* Tests: 1268 checks (forms for you and others, restricted auras, never-secret flags, the
  tuner); mutants all killed.

## [1.0.0] — 2026-09-30

The first release.

* Every player's own portrait framed the way the Classic client framed it, on the player,
  target, target of target, focus, focus target and party frames — with the stock UI and
  with ClassicUI Forever.
* All eight classic races and Forever's Skyborne, male and female: all 18 tuned by default
  against the Classic client's own portraits.
* **Options window** (`/cri options`): the frames, each race and sex, and calibration.
* **Calibration window** (`/cri tune`): your portrait beside the Classic one — drag, zoom,
  overlay with a strength fader — saved per race and sex.
* **Past the edge** (`/cri shrink`, on): a portrait may be smaller than, or moved beyond,
  Forever's picture, with black around it as on a Classic portrait.
* Safe in combat: only texture calls on Blizzard's portraits, nothing of theirs moved,
  hidden or written.

The work that led up to it, newest first:

### 2026-09-30 — the version is 1.0.0

* The user: "Jag vill börja på 1.0 i version". The TOC's `## Version` goes from 0.1.0 to
  1.0.0; everything under [Unreleased] became this release.

### 2026-09-30 — /cri alone no longer lists every race's switch

* The user: "Kanske kan ta bort raden om alla racer som säger on och off. eftersom man ser
  detta i options". `/cri` lists the eight commands only; `/cri status` still shows the
  switches.
* Tests: 1107 checks (the help's lines).

### 2026-09-30 — the addon list says "Classic", not 3.3.5a

* The user: "info rutan ingame ska inte nämna 3.3.5a heller, utan säga Classic". The TOC's
  notes: "Frames players' own portraits the way the Classic client did: …".

### 2026-09-30 — /cri options: an options window (not yet tested in game)

* The user's layout ("Gör nu en passande Options ruta för addonet när man skriver /cri
  options"), titled "Classic Race Icons" (the user: "Classic Race Icons ska det stå istället
  för Classic portraits for forever"):
  * **General:** Enable addon; Player, Target, Focus and Party Frames Portrait. The target
    of target goes with the target, the focus's target with the focus; a frame of any other
    unit follows only Enable addon.
  * **Race Overrides:** every race, Male and Female on their own.
  * **Calibration:** "Current: <race> <sex> - <name>" (the one the tuner takes: your
    target of a known race, else you; "(custom)" when you have tuned it), Calibrate Current
    Character (opens the tuner), Reset Current Calibration (back to the default; greyed out
    when there is nothing to reset), Reset All Custom Calibrations (asks for a second click
    within 4 seconds).
  * Every switch works at once and is saved; the open window follows `/cri` commands and
    the tuner. It opens left of the tuner. `/cri options` (or `/cri config`) opens and closes
    it. No Escape-to-close: that needs an entry in a Blizzard table (`UISpecialFrames`).
* Settings: `ClassicRaceIconsDB.kinds` (each race and sex) replaces `races`; an old save
  keeps its races (both sexes) and loses `races`. `ClassicRaceIconsDB.frames` holds the four
  frame switches. `/cri <race>` turns both sexes off, or on if either was off; `/cri status`
  shows "male only" / "female only" and the frame switches.
* The tuner and the options share one window maker; the tuner's Reset and `/cri reset`
  share theirs with the options.
* Tests: 1102 checks; 46 mutants of the new code killed (one equivalent removed: a
  `vehicle` unit is never a player).

### 2026-09-30 — the tuner's old picture is labelled "Classic"

* The user: "gör så det står 'Classic' istället för 3.3.5 under högra bilden". The picture
  itself is unchanged (the 3.3.5a client's portrait).
* Tests: 866 checks.

### 2026-09-30 — the orc male re-tuned past the edge

* The user re-tuned the orc male with `/cri shrink` ("jag ska fixa Orc male igen nu med denna
  ändringen" … "orc male klar"): zoom 0.92, x −0.012, y −0.078 from their SavedVariables
  (was 0.98 / −0.044 / −0.042, the compromise the picture's edge forced). Zoomed out under
  the ring with the head moved down past the client's picture, black below it. With
  `/cri shrink` off it is pulled in to the picture's edge.
* Tests: 864 checks; the orc male's default is checked with `/cri shrink` on and off.

### 2026-09-30 — the Skyborne male is a default, past the edge: all 18 kinds cropped out of the box

* The user, after seeing the black laid over the portrait ("Ja mycket bättre. Skyborne male
  klar"): zoom 0.84, x −0.057, y −0.092, from their SavedVariables. The first default past
  the client's picture: smaller than the ring's opening, head right and down, black around
  it. With `/cri shrink` off it is shown at zoom 0.86 in the middle.
* A crop pulled all the way in (no room at all) is now x 0, y 0 rather than −0, which
  `/cri status` and the tuner printed as "−0.00".
* Tests: 850 checks. The Skyborne male joins the kinds the tests take out of the defaults
  (the past-the-edge tests start from the whole picture) and is checked at the end, with
  `/cri shrink` on and off.

### 2026-09-30 — past the edge: black laid over the portrait instead of a disc behind it (not yet tested in game)

* Seen in game by the user: "blir konstiga streck på ikonen och ikonen där spelarens bild
  visas är helt svart. Det svarta försvinner när man trycker en gång på karaktären".
* **Black player frame:** the disc behind the portrait was a frame of the addon's own one
  frame level below the portrait's. It came out over the whole player frame, ring and level
  badge too. Forever's PlayerFrame is `toplevel` (raised when clicked, which is what the
  click did) and has no set frame level. Frame levels are not used any more.
* **Streaks:** past its picture the client stretches the picture's edge pixels outwards
  (clamped texcoords); where the model touches the edge (hair on top, body below) that is a
  streak. Black behind cannot hide it.
* Now: `Media\Outside.tga`, black with a round hole the size of the client's picture
  (radius 0.49 of 0.5) and black edge pixels, is laid over the portrait with the portrait's
  own texcoords, so all beyond the picture is black and the streaks are covered. It is a
  texture in the frame the portrait is drawn in, one sublevel above the portrait, masked
  round to the frame's opening: the ring is open there, so it shows the same over or under
  the target's ring (the same sublevel). Being part of the unit frame it shows, hides and
  fades with it; no OnUpdate. The tuner's preview has the same over it.
* Made out of combat (one wanted in combat comes after it); in combat only its texcoords
  and alpha change. A portrait whose parent, draw layer or size is secret keeps its crop,
  without the black.
* `tools/make_outside.ps1` writes the texture.
* New file: a full client restart is needed.
* Tests: 831 checks; 47 mutants killed (the mock's Blizzard frames can now take the addon's
  own textures, counted against it if laid out or shown/hidden in combat).

### 2026-09-30 — past the edge: smaller or further than the client's picture, black around it (not yet tested in game)

* The user, tuning the Skyborne male at zoom 0.86: "jag kan inte zooma ut eller flytta
  skyborne male bilden". Forever's camera frames him so close that the picture's own edge
  left no room; of the two ways out the user chose the black fill ("2").
* `/cri shrink` (on by default, `ClassicRaceIconsDB.shrink`): a crop may show the picture
  down to zoom 0.5 and move it up to 0.3 from the middle. Where it goes past the client's
  picture, a black disc of the addon's own lies behind the portrait (masked round, one frame
  level below the frame the portrait is drawn in, parented to UIParent), fading and hiding
  with that frame. Such a crop keeps its size and place on every frame (target of target
  too). Off: every crop is kept within the picture again; the saved values stay.
* Only crops past the edge change: one tuned right on it (and rounded, or a hair under
  zoom 0.86 from adding up zoom steps) stays as before, with no disc.
* Taint-safe: the disc is made only out of combat (one wanted in combat comes on
  `PLAYER_REGEN_ENABLED`); in combat only its texture's alpha changes. Blizzard's frames
  are only read, through `canaccessvalue`: a secret alpha gives full strength, a secret
  visibility, level or strata no disc.
* The tuner's bottom line says when a crop is past the picture; `/cri status` marks it
  "past the edge", and the summary shows the switch.
* Tests: 790 checks; 35 mutants of the new code killed. The mock's unit frames now report
  strata, level, visibility and alpha, and a secret value traps arithmetic too.

### 2026-09-30 — the Skyborne female is a default

* The user ("Skyborne Female är klar"): zoom 0.96, x 0.024, y 0.03 (zoomed out under the
  ring, head up and left a little), from their SavedVariables.
* The Skyborne male is not tuned yet.

### 2026-09-30 — Forever's Skyborne (not yet tested in game)

* The user: "Vi ska även kalibrera den nya racen 'Skyborne' för Forever, dom är blood
  elfs". Skyborne is a ninth race: `/cri skyborne`, male and female, in `/cri status` and
  the tuner, on for an old save.
* Which file name Forever's `UnitRace` gives them is not known here (its UI source has both
  `SKYBORNE` and `BLOODELF` tags), so both `Skyborne` and `BloodElf` count as Skyborne.
* The tuner compares them with 3.3.5a's blood elves, cut out of the user's screenshots
  ("Belfmaletest", "Belffemalete").
* No default crop yet: they keep Blizzard's portrait until tuned.
* Tests: 671 checks.

### 2026-09-30 — the tuned females become defaults: all 16 kinds cropped out of the box

* The user tunes each female in game against their 3.3.5a screenshot; values from their
  SavedVariables:
  * orc female ("orc female klar"): zoom 1.12, x −0.051, y −0.104 (head down to the
    clamp's edge);
  * undead female ("Undead female klar"): zoom 0.90, x 0.006, y 0.021 (zoomed out under the
    ring, head up to the edge);
  * tauren female ("tauren female klar"): zoom 1.00, x −0.068, y 0.017 (head right to the
    edge);
  * troll female ("Troll female klar"): zoom 1.04, x −0.04, y 0.002;
  * dwarf female ("dwarf female klar"): zoom 0.94, x 0.026, y −0.034 (zoomed out under the
    ring, head down and left to the edge);
  * night elf female ("night elf female klar"): zoom 0.94, x −0.002, y −0.043 (zoomed out
    under the ring, head down to the edge);
  * gnome female ("gnome female klar"): zoom 1.02, x −0.032, y −0.059.
* With that every race and sex has the user's crop by default.
* Tests: 600 checks (one checks all 16 kinds have a default). Every kind may get a default now, so the tests take two kinds (orc
  and undead female) out of the addon's defaults to have uncropped ones, and put them back
  and check them at the end; the females run through one table (`FEMALES`).

### 2026-09-30 — every race and sex has its real 3.3.5a portrait in the tuner (not yet tested in game)

* The user sent 3.3.5a screenshots of the females ("Imorgon fortsätter vi med Female"; "Det
  ska vara alla raserna för både male och female"): orc, undead, tauren, troll, dwarf, night
  elf, gnome. Cut out like the males' (same fit: 1.397 px per unit on every shot) into
  `Media\Shot-Female-<Race>.tga`.
* The two still missing — undead male and human female, the first two tuned — come from
  the user's 3.3.5a screenshots of 2026-09-29 (their level 80 undead, resting: a faint glow
  at the rim; "Humantesttes").
* With all 16, the tuner always shows the screenshot cut-out; the stock TemporaryPortrait
  pictures are no longer used or shipped (`tools/extract_portraits.ps1` still writes them
  as PNG for reference). The addon's icon is the undead male's cut-out.
* `tools/cut_screenshots.ps1 -Only <pattern>` cuts just the kinds that match.
* No crop defaults changed: the females (but the human) stay uncropped until tuned.
* Tests: 542 checks — every kind's picture is checked in the tuner and as a file in `Media`.

### 2026-09-29 — moves stop at the edge instead of sliding; a little zoom-out under a ring (not yet tested in game)

* The user, tuning the orc male: "går inte att zooma ut mer, när man tar till höger går den
  snett uppåt också".
* **Sliding:** a move past the picture's edge was pulled back towards the middle, which slid
  the head along the edge — Right also moved it up. A move (buttons, drag) now goes only the
  way asked and stops where the picture ends. Only a zoom that leaves too little room still
  pulls the head inwards. Guarded against rounding right on the edge (no NaN).
* **Zoom-out:** the least zoom was fixed at 1. Where a ring hides the picture's edge it can go
  down to 2 × the opening — 0.86 on ClassicUI's frames — with less room to move the head the
  further out (none at 0.86). A frame that shows the whole circle (target of target, Blizzard's
  own frames) still stops at 1 and shows such a crop as the whole picture. The texture's
  corners then lie beyond the picture, under the ring.
* The tuner's bottom line says when the crop is at the edge ("zoom in for more room").
* Tests: 478 checks; 13 mutants killed.

### 2026-09-29 — the other seven males are defaults too (every male now cropped)

* The user tuned the males in game against their 3.3.5a screenshots; values from their
  SavedVariables:
  * human male ("Human male klar"): zoom 1.08, x −0.069, y −0.075 (head moved down). That
    is right on the clamp's edge for ClassicUI's ring: at this zoom the head cannot go
    lower. On a whole-circle frame (target of target) it is pulled in further, as for
    every crop;
  * night elf male ("night elf male klar"): zoom 1.08, x −0.087, y 0.01;
  * dwarf male ("dwarf male klar"): zoom 1.00, x −0.022, y −0.067 (head down, also on the
    clamp's edge — 0.07 of room at zoom 1);
  * gnome male ("gnome male klar"): zoom 1.02, x −0.02, y −0.07;
  * tauren male ("tauren male är fixad nu"): zoom 1.00, x −0.016, y 0.03;
  * troll male ("Troll male klar"): zoom 1.24, x −0.022, y 0.065;
  * orc male ("orc male klar"): zoom 0.98, x −0.044, y −0.042 — a compromise: Forever's
    camera frames the orc closer and more centred than 3.3.5a did, and a smaller head can't
    also be moved far (the picture ends); zoomed out a little under the ring, head moved
    right and down to the edge.
* Removed an unused `Round` helper.
* Tests: 478 checks at the last bake (the edge tests moved to the orc female, who has no
  crop to start from); the male table's expectations go through the addon's clamp, as the
  frame shows them. The other males run through one table (`MALES`), so each newly tuned
  one is a line there; undead female stands in for "a kind without a crop"; the undead
  male (no screenshot) is checked to get the stock picture. 9 mutants killed.

### 2026-09-29 — all eight classic races, the real 3.3.5a portraits, overlay fader (not yet tested in game)

* Dwarf, Night Elf, Gnome, Orc, Tauren and Troll join Human and Undead (the user sent
  3.3.5a screenshots of every male: "så ska night elf male se ut", "Tauren male", …).
  `/cri dwarf | nightelf | gnome | orc | tauren | troll` toggle them; an old save gets them on.
  None is cropped until tuned — their defaults come from the user's `/cri tune` values.
* The tuner compares males with the **real 3.3.5a portrait**: cut out of the user's
  screenshots of the old player frame by `tools/cut_screenshots.ps1`, which finds the frame
  by matching UI-TargetingFrame's opaque texels (all seven shots: 1.397 px per unit, the
  ring's inner edge exactly on the cut). Transparent where the ring covers it. The stock
  TemporaryPortrait pictures are another face (the tauren's even another angle), so they
  are only used for the females now.
* 3.3.5a's ring opening measured from its texture: radius 27.3 of 64 = 0.43, the same as
  ClassicUI's.
* Tuner: **Overlay strength** fader, 0–100 % in 5 % steps (mouse wheel on it too), saved as
  `ClassicRaceIconsDB.overlay` (default 50 %). Moving it shows the overlay, 0 % hides it;
  *Overlay* still toggles it and brings it back at 50 % from 0 %.
* Tests: 347 checks; 13 mutants — 12 killed, 1 equivalent (a clamp the slider already
  does; removed).

### 2026-09-29 — both tuned crops are the defaults

* The user tuned both kinds in game against the 3.3.5a client ("så om någon använder
  vårat addon så är det förinställt"); values read from their SavedVariables:
  * undead male: zoom 1.30, x −0.01, y 0 (the earlier 1.36 / 0.03 came from a
    screenshot taken before their last change);
  * human female: zoom 1.28, x −0.07, y 0.02.
* Human male and undead female stay uncropped.
* Tests: 199 checks; mutants all killed.

### 2026-09-29 — only undead male and human female are cropped

* The user: "Bara undead male + human female som behöver göras om". Human male and
  undead female keep Blizzard's portrait by default; `/cri tune` on one of them starts
  from the whole picture and crops it from then on, `Reset` gives Blizzard's back.
* Human female starts from the undead male's crop until the user has tuned it.
* The tuner and `/cri status` say "(not cropped)" for a kind without a crop.
* Tests: 198 checks; 18 mutants (all killed).

### 2026-09-29 — the user's undead male crop is the default

* Default crop for undead male: zoom 1.36, x 0.03, y 0 — set by the user in game with
  `/cri tune` ("så som jag har nu vill jag alltid ha för undead male"). Human male/female
  and undead female start from the same values until tuned. `Reset` / `/cri reset` go back
  to these.
* Tests: 171 checks; 22 mutants (all killed).

### 2026-09-29 — crop your own portrait instead of a picture (not yet tested in game)

* The unit frames keep the client's own portrait (your face, hair and gear) and crop it
  with `SetTexCoord` so the head sits where it sat in 3.3.5a (user: "det ska vara avataren
  från spelaren själv ... men med den positionen som jag nu har"). The 3.3.5a pictures no
  longer replace portraits.
* Crop per race and sex (zoom, x, y). Default for all four: zoom 1.10, head up 0.10 —
  measured for the undead male on a Forever screenshot, a first guess for the others.
* Every crop is kept inside the client's round picture. The shown part is ClassicUI's
  ring opening (0.43 of the portrait) when its unit frames are on, else the whole circle;
  the target-of-target frame always counts as the whole circle.
* `/cri tune`: live preview beside the 3.3.5a picture, drag / mouse wheel / buttons,
  overlay of the old picture, reset; saved in `ClassicRaceIconsDB.crops`. `/cri reset`.
* `/cri status` lists only frames with a unit, plus the crops and the ring opening.
* Tests: 163 checks; 21 mutants (all killed).

## [0.1.0] — 2026-09-29

### 2026-09-29 — first version (tested in game: loads, pictures show)

* The 3.3.5a client's portraits of the classic Human and Undead models (male and female)
  on the player, target, focus, target-of-target, focus-target and party frames, for
  players of those races.
* `/cri on|off|human|undead|others|status`, saved in `ClassicRaceIconsDB`.
* Forever's class-icon portraits are left alone; redraw on their `CVAR_UPDATE`.
* Tools to extract the pictures from a 3.3.5a client; offline tests.
