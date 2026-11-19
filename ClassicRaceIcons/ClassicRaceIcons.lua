-- Classic Race Icons: frames the classic races' (and Forever's Skyborne) players' own portraits the way the 3.3.5a
-- client did, on Blizzard's unit frames (player, target, focus, their targets, party).
--
-- The portrait is rendered by the client from the unit's own model (SetPortraitTexture);
-- Classic Era calls exactly the same function and only differs in its (original) models
-- and their portrait camera. Forever's "SD" models are retail models with classic-style
-- textures, and their camera puts the head lower in the circle. An addon cannot move the
-- camera, but it can choose which part of the client's picture is shown: right after
-- Blizzard draws the portrait, SetTexCoord crops it so the head sits where it sat in 3.3.5a
-- (per race and sex; /cri tune adjusts it live against the old client's real portraits in
-- Media\, cut out of screenshots by tools\cut_screenshots.ps1). The shown circle is kept inside the
-- client's round picture, which has nothing beyond its edge: zooming out is possible only as
-- far as a ring hides that edge (ClassicUI's frames), never on a frame showing the whole circle.
--
-- Rules kept: only SetTexCoord on the portrait texture (not protected, fine in combat), and
-- SetTexture for the Aquatic Form picture (and SetPortraitTexture to give the client's back);
-- nothing is moved or resized; no field is written on a Blizzard object; no Blizzard Lua
-- function is called; race and sex are checked with canaccessvalue before they are used,
-- and a secret one leaves Blizzard's portrait as it is.

local ADDON, ns = ...

local SEXES = { [2] = "Male", [3] = "Female" }        -- UnitSex: 2 male, 3 female
-- UnitRace's file name -> name shown to the user, in /cri's order.
local RACE_ORDER = { "Human", "Dwarf", "NightElf", "Gnome", "Orc", "Scourge", "Tauren", "Troll", "Skyborne" }
local RACES = { Human = "Human", Dwarf = "Dwarf", NightElf = "Night Elf", Gnome = "Gnome",
    Orc = "Orc", Scourge = "Undead", Tauren = "Tauren", Troll = "Troll", Skyborne = "Skyborne" }
local COMMANDS = { human = "Human", dwarf = "Dwarf", nightelf = "NightElf", gnome = "Gnome",
    orc = "Orc", undead = "Scourge", tauren = "Tauren", troll = "Troll", skyborne = "Skyborne" }
-- Forever's Skyborne are blood elves (the user, 2026-09-30); which file name UnitRace gives
-- them is not known here, so both count as Skyborne.
local SAME_RACE = { BloodElf = "Skyborne" }

-- A crop: zoom (1 = the client's whole picture) and where the shown window's centre sits, in
-- picture widths from the picture's centre. +y moves the window down, so the head goes up.
local MAX_ZOOM = 2.5   -- the least zoom depends on the frame's opening (Clamp)
-- Every race and sex, tuned by the user (2026-09-29/30). A kind missing here would keep
-- Blizzard's portrait until someone tunes it.
local DEFAULT_CROPS = {
    -- Tuned by the user in game with /cri tune against the 3.3.5a client (ClassicUI frames;
    -- values from their SavedVariables).
    Scourge2 = { zoom = 1.30, x = -0.01, y = 0 },
    Human3 = { zoom = 1.28, x = -0.07, y = 0.02 },
    -- Males against their 3.3.5a screenshots. Human: head moved down as far as zoom 1.08
    -- lets it (the clamp's edge on ClassicUI's ring, less room on a whole-circle frame).
    Human2 = { zoom = 1.08, x = -0.069, y = -0.075 },
    NightElf2 = { zoom = 1.08, x = -0.087, y = 0.01 },
    Dwarf2 = { zoom = 1, x = -0.022, y = -0.067 },   -- head down to the clamp's edge
    Gnome2 = { zoom = 1.02, x = -0.02, y = -0.07 },
    Tauren2 = { zoom = 1, x = -0.016, y = 0.03 },
    Troll2 = { zoom = 1.24, x = -0.022, y = 0.065 },
    -- Past the edge (/cri shrink), with black around them; with it off they are pulled in.
    Orc2 = { zoom = 0.92, x = -0.012, y = -0.078 },   -- zoomed out under the ring, head down past the picture
    Skyborne2 = { zoom = 0.84, x = -0.057, y = -0.092 },   -- smaller than the opening, head right and down
    -- Females against their 3.3.5a screenshots (2026-09-30); the Skyborne against 3.3.5a's
    -- blood elf.
    Orc3 = { zoom = 1.12, x = -0.051, y = -0.104 },   -- head down to the edge
    Scourge3 = { zoom = 0.9, x = 0.006, y = 0.021 },   -- zoomed out under the ring, head up to the edge
    Tauren3 = { zoom = 1, x = -0.068, y = 0.017 },   -- head right to the edge
    Troll3 = { zoom = 1.04, x = -0.04, y = 0.002 },
    Dwarf3 = { zoom = 0.94, x = 0.026, y = -0.034 },   -- zoomed out under the ring, head down and left to the edge
    NightElf3 = { zoom = 0.94, x = -0.002, y = -0.043 },   -- zoomed out under the ring, head down to the edge
    Gnome3 = { zoom = 1.02, x = -0.032, y = -0.059 },
    Skyborne3 = { zoom = 0.96, x = 0.024, y = 0.03 },   -- zoomed out under the ring, head up and left a little
}
local NO_CROP = { zoom = 1, x = 0, y = 0 }   -- the tuner's start for a kind without one

-- The tuner's 3.3.5a picture: every kind's real portrait, ring opening and all, cut out of
-- the user's own screenshots of the 3.3.5a player frame (2026-09-29/30) by
-- tools\cut_screenshots.ps1 (Skyborne: 3.3.5a's blood elves).
local SHOT = "Interface\\AddOns\\" .. ADDON .. "\\Media\\Shot-"

local KINDS = {}   -- "Scourge2" -> { race, sex, label, picture }
for race, raceName in pairs(RACES) do
    for sex, sexName in pairs(SEXES) do
        KINDS[race .. sex] = {
            race = race,
            sex = sex,
            label = raceName .. " " .. sexName,
            picture = SHOT .. sexName .. "-" .. race .. ".tga",
        }
    end
end

-- Settings. kinds: each race and sex on or off; frames: the unit frames cropped, by kind of
-- frame (FrameGroup); overlay: the tuner's fader.
local DEFAULTS = { enabled = true, others = true, npcs = true, aquatic = true, overlay = 0.5, shrink = true,
    frames = { player = true, target = true, focus = true, party = true } }
local ALL_KINDS_ON = {}
for kind in pairs(KINDS) do ALL_KINDS_ON[kind] = true end
local db = { enabled = true, others = true, npcs = true, aquatic = true, overlay = DEFAULTS.overlay, shrink = DEFAULTS.shrink,
    kinds = ALL_KINDS_ON, frames = DEFAULTS.frames,
    crops = {}, models = {} }   -- until ADDON_LOADED

-- How much of the portrait the frame shows, as a radius in picture widths. ClassicUI's ring
-- opening is 27.4 of its 64 px portrait; Blizzard's own frames may show the whole circle.
local CLASSICUI_OPENING = 0.43
local visible = 0.5

local CanAccess = type(canaccessvalue) == "function" and canaccessvalue or function() return true end

-- A boolean from the client. Secret or failed: false, plus true as "unknown".
local function Flag(fn, ...)
    local ok, value = pcall(fn, ...)
    if ok and CanAccess(value) then
        return value and true or false, false
    end
    return false, true
end

local function CVarOn(name)
    if GetCVarBool then return GetCVarBool(name) end
    return C_CVar and C_CVar.GetCVarBool and C_CVar.GetCVarBool(name) or false
end

local function IsMe(unit)
    return unit == "player" or (Flag(UnitIsUnit, unit, "player"))
end

-- Forever's own class icon portraits (UnitFrame_ShouldReplacePortrait) are left alone.
local CLASS_ICON = "class icon"
local function ClassIconShown(unit, me)
    if not CVarOn(me and "ReplaceMyPlayerPortrait" or "ReplaceOtherPlayerPortraits") then
        return false
    end
    local human, unknown = Flag(UnitIsHumanPlayer, unit)
    return human or unknown
end

-- Druid forms and the shaman's Ghost Wolf show a creature, not the race: such a portrait is
-- left as Blizzard draws it (the user, 2026-10-03). Your own: the animal forms by their
-- GetShapeshiftFormID, another form only when it changes your display (Blizzard's test in
-- ModelSceneUtil.SetUpCharacterSheetScene), so stances, stealth and Shadowform still count
-- as you; a form the client doesn't report as one, by its aura. Another player's: the form's
-- aura, by spell ID or else by the form's name. While aura data is restricted (combat,
-- encounters, challenge modes, PvP matches) a missing aura says nothing unless the forms are
-- flagged never secret; then the last answer read for that player stands, and one never
-- read stays Blizzard's.
local MODEL_FORMS = { [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [16] = true,
    [27] = true, [31] = true, [35] = true }   -- Blizzard's ANIMAL_FORMS, which Forever doesn't load
local FORM_CLASSES = { DRUID = true, SHAMAN = true }
local FORM_AURAS = {
    768,     -- Cat Form
    5487,    -- Bear Form
    9634,    -- Dire Bear Form
    783,     -- Travel Form
    1066,    -- Aquatic Form
    24858,   -- Moonkin Form
    33891,   -- Tree of Life
    33943,   -- Flight Form
    40120,   -- Swift Flight Form
    2645,    -- Ghost Wolf
}
local NEVER_SECRET = Enum and Enum.SecrecyLevel and Enum.SecrecyLevel.NeverSecret or 0

-- Whether a missing form aura means no form: aura data isn't restricted now, or every form
-- the client has is flagged never secret.
local function FormAurasReadable()
    local secrets = C_Secrets
    if not (secrets and secrets.ShouldAurasBeSecret) then return true end
    local ok, restricted = pcall(secrets.ShouldAurasBeSecret)
    if ok and CanAccess(restricted) and not restricted then return true end
    if not secrets.GetSpellAuraSecrecy then return false end
    local exists = C_Spell and C_Spell.DoesSpellExist
    local any = false
    for _, id in ipairs(FORM_AURAS) do
        local okExists, has = true, true
        if exists then okExists, has = pcall(exists, id) end
        if okExists and CanAccess(has) and has then
            local okLevel, level = pcall(secrets.GetSpellAuraSecrecy, id)
            if not (okLevel and CanAccess(level) and level == NEVER_SECRET) then return false end
            any = true
        end
    end
    return any
end

-- The forms' names in the client's language, for a form aura under another spell ID.
local formNames
local function FormNames()
    if formNames then return formNames end
    local get = C_Spell and C_Spell.GetSpellName
    if type(get) ~= "function" then return {} end
    local names, seen = {}, {}
    for _, id in ipairs(FORM_AURAS) do
        local ok, name = pcall(get, id)
        if ok and CanAccess(name) and type(name) == "string" and name ~= "" and not seen[name] then
            seen[name] = true
            names[#names + 1] = name
        end
    end
    if #names > 0 then formNames = names end
    return names
end

-- The form auras on the unit: their spell IDs, or else the names found.
local function FormAuras(unit)
    local found = {}
    local auras = C_UnitAuras
    if not auras then return found end
    if type(auras.GetUnitAuraBySpellID) == "function" then
        for _, id in ipairs(FORM_AURAS) do
            local ok, aura = pcall(auras.GetUnitAuraBySpellID, unit, id)
            if ok and (not CanAccess(aura) or aura) then found[#found + 1] = id end   -- there, even if secret
        end
    end
    if #found == 0 and type(auras.GetAuraDataBySpellName) == "function" then
        for _, name in ipairs(FormNames()) do
            local ok, aura = pcall(auras.GetAuraDataBySpellName, unit, name, "HELPFUL")
            if ok and (not CanAccess(aura) or aura) then found[#found + 1] = name end
        end
    end
    return found
end

-- A unit's form from its aura: true, false, or nil when it can't be read.
local function AuraForm(unit)
    local auras = C_UnitAuras
    if not (auras and (auras.GetUnitAuraBySpellID or auras.GetAuraDataBySpellName)) then return nil end
    if #FormAuras(unit) > 0 then return true end
    if FormAurasReadable() then return false end
    return nil
end

-- Whether your display is not your native one; nil when that can't be read.
local function DisplayChanged()
    local info = C_PlayerInfo
    if not (info and info.GetDisplayID and info.GetNativeDisplayID) then return nil end
    local okShown, shown = pcall(info.GetDisplayID)
    local okNative, native = pcall(info.GetNativeDisplayID)
    if okShown and okNative and CanAccess(shown) and CanAccess(native) and shown ~= 0 then
        return shown ~= native
    end
    return nil
end

-- Your own form: true, false, or nil when it can't be read.
local function MyForm()
    if type(GetShapeshiftFormID) == "function" then
        local ok, form = pcall(GetShapeshiftFormID)
        if not ok or not CanAccess(form) then return nil end
        if form and (MODEL_FORMS[form] or DisplayChanged()) then return true end
    end
    -- A form the client doesn't report as one: its aura.
    local okClass, _, class = pcall(UnitClass, "player")
    if not (okClass and CanAccess(class) and FORM_CLASSES[class]) then return false end
    return AuraForm("player") == true
end

local formSeen = {}   -- another player's GUID -> their form when it was last read
local function InForm(unit)
    if IsMe(unit) then return MyForm() end
    local ok, _, class = pcall(UnitClass, unit)
    if not ok or not CanAccess(class) or not FORM_CLASSES[class] then return false end
    local okGuid, guid = pcall(UnitGUID, unit)
    if not okGuid or not CanAccess(guid) then guid = nil end
    local form = AuraForm(unit)
    if form ~= nil then
        if guid then formSeen[guid] = form end
        return form
    end
    if guid then return formSeen[guid] end
    return nil
end

-- NPCs have no race (UnitRace gives nil), but one shaped like a race uses that race's model
-- file, the same as its players (the user, 2026-11-17: a human male NPC and player both
-- 119940, female 119563). A model frame of our own, never drawn, is set to the unit and its
-- model file read. Each player seen counts a vote for their race and sex's file, so an NPC
-- with that file is framed as that race and sex; a creature, a form or a mount has another
-- file and keeps Blizzard's portrait. The model is read at once, or a frame or two later:
-- until then, and for a unit whose GUID can't be read, Blizzard's portrait.
-- Every race's model files, from the community listfile (wowdev/wow-listfile, 2026-11-17):
-- character/<race>/<sex>/<race><sex>.m2 (the SD models; human male 119940 and female 119563
-- seen in game), _hd and _hd_sdr (HD models), and the orc male's upright ones. Blood elves
-- are Forever's Skyborne, who also have models of their own (7478487 male, 7478494 female:
-- not in the listfile, seen on the players by the user's /cri models, 2026-11-19).
local DEFAULT_MODELS = {}
for kind, files in pairs({
    Human2 = { 119940, 1011653, 1838385 },            Human3 = { 119563, 1000764, 1838572, 1842700 },
    Dwarf2 = { 118355, 878772, 1838560 },             Dwarf3 = { 118135, 950080, 1838562 },
    NightElf2 = { 120791, 974343, 1838576 },          NightElf3 = { 120590, 921844, 1838574 },
    Gnome2 = { 119159, 900914, 1838566 },             Gnome3 = { 119063, 940356, 1838564 },
    Orc2 = { 121287, 917116, 1838578, 1968587, 1968838 }, Orc3 = { 121087, 949470, 1838580 },
    Scourge2 = { 121768, 959310, 1838584 },           Scourge3 = { 121608, 997378, 1838582 },
    Tauren2 = { 122055, 968705, 1838586 },            Tauren3 = { 121961, 986648, 1839008 },
    Troll2 = { 122560, 1022938, 1838590 },            Troll3 = { 122414, 1018060, 1838588 },
    Skyborne2 = { 117170, 1100087, 1853408, 7478487 }, Skyborne3 = { 116921, 1100258, 1839709, 7478494 },
}) do
    for _, file in ipairs(files) do DEFAULT_MODELS[file] = kind end
end
local DEFAULT_WEIGHT = 3   -- votes a default counts as, against a player in a costume
local MAX_VOTES = 50
local PROBE_TRIES, MAX_QUEUE = 120, 20   -- tries a frame apart: about two seconds
-- Two model frames of our own (no parent, no size: never drawn), each looking at one unit at
-- a time: the NPCs on show never wait behind the players being learned from (the user,
-- 2026-11-17: the NPC's portrait moved into place a moment after targeting).
local function Prober()
    return { frame = CreateFrame("PlayerModel"), queue = {}, pending = {} }
end
local voteProber, npcProber = Prober(), Prober()
local npcModels, npcCount = {}, 0   -- an NPC's GUID -> its model file (false: none)
local voted = {}                    -- a player's GUID -> counted this session
local ModelsChanged = function() end   -- crops again; set once Refresh exists

local function GuidOf(unit)
    local ok, guid = pcall(UnitGUID, unit)
    if ok and CanAccess(guid) and type(guid) == "string" then return guid end
end

-- The race and sex a model file belongs to: the players' votes, a default counting extra.
local function ModelKind(file)
    local votes = type(db.models[file]) == "table" and db.models[file] or {}
    local best, most = nil, 0
    for kind in pairs(KINDS) do
        local n = (votes[kind] or 0) + (DEFAULT_MODELS[file] == kind and DEFAULT_WEIGHT or 0)
        if n > most then best, most = kind, n end
    end
    return best
end

-- Set the frame to the unit and read its model file: at once (a unit on show has its model
-- loaded), else each frame until it has loaded. done(file, late) gets the file, false when
-- none came, or nil when the token moved to another unit meanwhile; late when it came later.
local function NextProbe(p)
    local job = table.remove(p.queue, 1)
    p.job = job
    if not job then return end
    pcall(p.frame.ClearModel, p.frame)   -- not the last unit's file while this one loads
    local set = pcall(p.frame.SetUnit, p.frame, job.unit)
    local tries = 0
    local function Check(late)
        if p.job ~= job then return end
        local file
        if GuidOf(job.unit) ~= job.guid then
            file = nil
        elseif not set then
            file = false
        else
            local ok, id = pcall(p.frame.GetModelFileID, p.frame)
            if ok and CanAccess(id) and type(id) == "number" and id > 0 then
                file = id
            else
                tries = tries + 1
                if tries < PROBE_TRIES then
                    C_Timer.After(0, function() Check(true) end)
                    return
                end
                file = false
            end
        end
        p.pending[job.guid] = nil
        job.done(file, late)
        NextProbe(p)
    end
    Check(false)
end

local function Probe(p, unit, guid, done)
    if p.pending[guid] or #p.queue >= MAX_QUEUE then return end
    p.pending[guid] = true
    p.queue[#p.queue + 1] = { unit = unit, guid = guid, done = done }
    if not p.job then NextProbe(p) end
end

-- A player of a known race and sex, in their own form: a vote for their model file.
local function Learn(unit, kind)
    local guid = GuidOf(unit)
    if not guid or voted[guid] then return end
    voted[guid] = true
    Probe(voteProber, unit, guid, function(file)
        if file == nil then voted[guid] = nil return end   -- another unit by then: later
        if not file then return end
        local votes = db.models[file] or {}
        db.models[file] = votes
        local before = ModelKind(file)
        votes[kind] = math.min(MAX_VOTES, (votes[kind] or 0) + 1)
        if ModelKind(file) ~= before then ModelsChanged() end
    end)
end

-- An NPC's kind from its model file; nil and why when there is none (yet).
local function NpcKind(unit)
    local guid = GuidOf(unit)
    if not guid then return nil, "secret" end
    local file = npcModels[guid]
    if file == nil then
        Probe(npcProber, unit, guid, function(found, late)
            if found == nil then return end
            if npcCount >= 500 then npcModels, npcCount = {}, 0 end
            npcModels[guid] = found
            npcCount = npcCount + 1
            if late and found and ModelKind(found) then ModelsChanged() end
        end)
        file = npcModels[guid]   -- read at once: framed on this very drawing
        if file == nil then return nil, "model not read yet" end
    end
    local kind = file and ModelKind(file)
    if not kind then return nil, "not a race's model" end
    return kind
end

-- Aquatic Form: Forever's portrait shows the whole sea lion, small (the user, 2026-11-19),
-- and zooming in on its head is far too coarse. The old client's portrait is shown instead:
-- Media\Aquatic.tga, Classic Era's own portrait of the form (display 2428, the same for night
-- elves and tauren, drawn through the model's portrait camera), sharpened by the user and cut
-- round by tools\cut_aquatic.ps1 (tools\render_aquatic.ps1 renders it from the 3.3.5a files).
-- Yours: form 4 or the form's aura; another druid's: the aura, else the last answer read.
local AQUATIC_PICTURE = "Interface\\AddOns\\" .. ADDON .. "\\Media\\Aquatic.tga"
local AQUATIC_FORM, AQUATIC_AURA = 4, 1066
local aquaticName

-- Aquatic Form's aura on the unit: true, false, or nil when it can't be read.
local function AquaticAura(unit)
    local get = C_Spell and C_Spell.GetSpellName
    if not aquaticName and type(get) == "function" then
        local ok, name = pcall(get, AQUATIC_AURA)
        if ok and CanAccess(name) and type(name) == "string" and name ~= "" then aquaticName = name end
    end
    local found = FormAuras(unit)
    for _, v in ipairs(found) do
        if v == AQUATIC_AURA or (aquaticName and v == aquaticName) then return true end
    end
    if #found > 0 or FormAurasReadable() then return false end
    return nil
end

local aquaticSeen = {}   -- another druid's GUID -> in Aquatic Form when last read
local function InAquatic(unit)
    if IsMe(unit) then
        if type(GetShapeshiftFormID) == "function" then
            local ok, form = pcall(GetShapeshiftFormID)
            if ok and CanAccess(form) and form == AQUATIC_FORM then return true end
        end
        return AquaticAura("player") == true
    end
    local ok, _, class = pcall(UnitClass, unit)
    if not ok or not CanAccess(class) or class ~= "DRUID" then return false end
    local guid = GuidOf(unit)
    local aquatic = AquaticAura(unit)
    if aquatic ~= nil then
        if guid then aquaticSeen[guid] = aquatic end
        return aquatic
    end
    return guid ~= nil and aquaticSeen[guid] == true
end

-- The unit's kind ("Scourge2"), whatever the settings; nil and why when there is none.
local NOT_A_PLAYER = "not a player"
local function KindOf(unit)
    if type(unit) ~= "string" then return nil, "no unit" end
    local isPlayer, unknown = Flag(UnitIsPlayer, unit)
    if unknown then return nil, "secret" end
    if not isPlayer then return nil, NOT_A_PLAYER end
    local ok, _, race = pcall(UnitRace, unit)
    if not ok or not CanAccess(race) then return nil, "secret" end
    local okSex, sex = pcall(UnitSex, unit)
    if not okSex or not CanAccess(sex) then return nil, "secret" end
    race = SAME_RACE[race] or race
    if not (race and RACES[race] and SEXES[sex]) then return nil, tostring(race) end
    return race .. sex
end

-- The kind to crop the unit's portrait for under the settings, or nil and why not.
local function KindFor(unit)
    if not db.enabled then return nil, "off" end
    local kind, why = KindOf(unit)
    if why == NOT_A_PLAYER then
        if not db.npcs then return nil, "NPCs off" end
        if not db.others then return nil, "others off" end
        kind, why = NpcKind(unit)
        if not kind then return nil, why end
        if not db.kinds[kind] then return nil, KINDS[kind].label .. " off" end
        if not (db.crops[kind] or DEFAULT_CROPS[kind]) then return nil, KINDS[kind].label .. " not cropped" end
        return kind, KINDS[kind].label .. " NPC"
    end
    if not kind then return nil, why end
    if not db.kinds[kind] then return nil, KINDS[kind].label .. " off" end
    local me = IsMe(unit)
    if not me and not db.others then return nil, "others off" end
    if ClassIconShown(unit, me) then return nil, CLASS_ICON end
    local form = InForm(unit)
    if form ~= false then return nil, form and "shapeshifted" or "form unknown" end
    -- A dead night elf's ghost is a wisp (Wisp Spirit).
    if KINDS[kind].race == "NightElf" and Flag(UnitIsGhost, unit) then return nil, "wisp" end
    if db.npcs then Learn(unit, kind) end
    if not (db.crops[kind] or DEFAULT_CROPS[kind]) then return nil, KINDS[kind].label .. " not cropped" end
    return kind, KINDS[kind].label
end

-- Which switch a unit frame goes by (the options' Player / Target / Focus / Party Frames
-- Portrait), from its unit: the target of target goes with the target, the focus's target
-- with the focus. A frame of another unit follows only "Enable addon".
local FRAME_GROUPS = { player = "player", target = "target", targettarget = "target",
    focus = "focus", focustarget = "focus" }
local function FrameGroup(frame)
    local unit = frame.unit
    if type(unit) ~= "string" then return nil end
    return FRAME_GROUPS[unit] or (unit:find("^party%d$") and "party") or nil
end

-- The kind to crop this unit frame's portrait for, or nil and why not.
local function KindForFrame(frame)
    local kind, why = KindFor(frame.unit)
    if not kind then return nil, why end
    local group = FrameGroup(frame)
    if group and not db.frames[group] then return nil, group .. " portraits off" end
    return kind, why
end

-- Whether the frame shows the Classic Aquatic Form picture: a player in the form, under
-- the same switches as a crop (but the race's).
local function AquaticForFrame(frame)
    if not (db.enabled and db.aquatic) then return false end
    local unit = frame.unit
    if type(unit) ~= "string" then return false end
    local isPlayer, unknown = Flag(UnitIsPlayer, unit)
    if unknown or not isPlayer then return false end
    local me = IsMe(unit)
    if not me and not db.others then return false end
    local group = FrameGroup(frame)
    if group and not db.frames[group] then return false end
    if ClassIconShown(unit, me) then return false end
    return InAquatic(unit)
end

-- The frame's opening; ClassicUI's target-of-target ring shows more (17 of 35 px).
local function OpeningOf(frame)
    if frame and frame.frameType == "TargetofTarget" then return 0.5 end
    return visible
end

-- Zoom within limits, and the shown circle (the opening's radius) inside the client's round
-- picture (radius 0.5). Where a ring hides the picture's edge (ClassicUI: opening 0.43) the
-- picture can also be shown a little smaller, down to zoom 2 x opening, with no room left to
-- move it there; a frame that shows the whole circle cannot go below zoom 1.
--
-- "Past the edge" (/cri shrink, the user's choice for the Skyborne, 2026-09-30): a crop may
-- also show the picture smaller than the opening or move it past its edge. What lies beyond
-- the client's picture is then covered with black (Cover), like
-- the black around a 3.3.5a portrait. Such a crop keeps its size and place on every frame.
local SHRINK_MIN_ZOOM, SHRINK_ROOM = 0.5, 0.3
local function Clamp(zoom, x, y, opening, past)
    opening = opening or visible
    zoom = math.max(past and SHRINK_MIN_ZOOM or 2 * opening, math.min(MAX_ZOOM, tonumber(zoom) or 1))
    x, y = tonumber(x) or 0, tonumber(y) or 0
    local room = math.max(0, 0.5 - opening / zoom)
    if past then room = math.max(room, SHRINK_ROOM) end
    local d = math.sqrt(x * x + y * y)
    if d > room then
        if room > 0 then
            x, y = x * room / d, y * room / d
        else
            x, y = 0, 0   -- not -0 ("x -0.00")
        end
    end
    return zoom, x, y
end

-- Whether a crop, as tuned (on `visible`), goes past the client's picture. The slack keeps a
-- crop tuned right on the edge (and rounded to three decimals) inside.
local function PastEdge(zoom, x, y)
    zoom, x, y = tonumber(zoom) or 1, tonumber(x) or 0, tonumber(y) or 0
    return zoom < 2 * visible - 0.001 or math.sqrt(x * x + y * y) > 0.5 - visible / zoom + 0.002
end

-- The kind's crop as a frame with this opening shows it; the 4th value: past the edge.
local function CropOf(kind, opening)
    local c = db.crops[kind] or DEFAULT_CROPS[kind] or NO_CROP
    local past = db.shrink and PastEdge(c.zoom, c.x, c.y) or false
    local zoom, x, y = Clamp(c.zoom, c.x, c.y, opening, past)
    return zoom, x, y, past
end

-- How the kind's crop is set, for the tuner and /cri status.
local function CropNote(kind)
    if db.crops[kind] then return "" end
    return DEFAULT_CROPS[kind] and " (default)" or " (not cropped)"
end

-- left, right, top, bottom for SetTexCoord.
local function Coords(zoom, x, y)
    local half = 0.5 / zoom
    return 0.5 + x - half, 0.5 + x + half, 0.5 + y - half, 0.5 + y + half
end

local frames = setmetatable({}, { __mode = "k" })    -- unit frames whose portrait we have seen
local cropped = setmetatable({}, { __mode = "k" })   -- portrait texture -> kind it is cropped for
local lastError

-- The black around a crop past the edge: a texture of our own laid over the portrait, in the
-- frame the portrait is drawn in (one sublevel above it), with the portrait's texcoords.
-- Media\Outside.tga is black but for a round hole the size of the client's picture, and its
-- edge pixels are black, so all beyond the picture is black. That also hides the client
-- stretching its picture's edge pixels out beyond it (the streaks the user saw, 2026-09-30).
-- Masked to the frame's opening: the ring is open there, so the black shows the same whether
-- it lands over or under the ring's texture (the target's shares the sublevel). Being part of
-- the unit frame it shows, hides and fades with it. A frame of our own behind the portrait
-- came out over the whole player frame (toplevel, low frame level) - frame levels are not
-- used. Made out of combat; one wanted in combat comes at the end of it. In combat only its
-- texcoords and alpha change.
local OUTSIDE = "Interface\\AddOns\\" .. ADDON .. "\\Media\\Outside.tga"
local ROUND_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local covers = setmetatable({}, { __mode = "k" })   -- unit frame -> { tex, mask, inset }
local coversWaiting = false

-- A Blizzard region's getter; secret or failed: nil.
local function Read(region, method)
    local ok, a, b = pcall(region[method], region)
    if ok and CanAccess(a) and CanAccess(b) then return a, b end
end

local function MakeCover(frame)
    local portrait = frame.portrait
    local owner = Read(portrait, "GetParent")
    local layer, sublevel = Read(portrait, "GetDrawLayer")
    if type(owner) ~= "table" or type(sublevel) ~= "number" then return end   -- unread: both nil
    local tex = owner:CreateTexture(nil, layer, nil, math.min(7, sublevel + 1))
    tex:SetTexture(OUTSIDE, "CLAMP", "CLAMP")
    tex:SetAllPoints(portrait)
    local mask = owner:CreateMaskTexture()
    mask:SetTexture(ROUND_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    tex:AddMaskTexture(mask)
    local cover = { tex = tex, mask = mask }
    covers[frame] = cover
    return cover
end

-- The mask on the frame's opening (out of combat); false if the portrait's size is unknown.
local function FitMask(cover, portrait, opening)
    local width = Read(portrait, "GetWidth")
    if type(width) ~= "number" or width <= 0 then return false end
    local inset = width * (0.5 - opening)
    if cover.inset ~= inset then
        cover.mask:ClearAllPoints()
        cover.mask:SetPoint("TOPLEFT", portrait, "TOPLEFT", inset, -inset)
        cover.mask:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", -inset, inset)
        cover.inset = inset
    end
    return true
end

-- Black around the frame's portrait for this crop, or none.
local function Cover(frame, wanted, zoom, x, y, opening)
    local cover = covers[frame]
    if InCombatLockdown() then
        if wanted and not (cover and cover.inset) then
            coversWaiting = true
            wanted = false
        end
        if not cover then return end
    elseif wanted then
        cover = cover or MakeCover(frame)
        if not cover then return end
        wanted = FitMask(cover, frame.portrait, opening)
    elseif not cover then
        return
    end
    if wanted then cover.tex:SetTexCoord(Coords(zoom, x, y)) end
    cover.tex:SetAlpha(wanted and 1 or 0)
end

local AQUATIC_SHOWN = "Classic Aquatic Form"
local swapped = setmetatable({}, { __mode = "k" })   -- portrait texture showing Aquatic.tga

-- redrawn: Blizzard has just drawn the client's picture (the hook), not a refresh of ours.
local function Apply(frame, redrawn)
    local portrait = frame.portrait
    if not portrait then return end
    frames[frame] = true
    if redrawn then swapped[portrait] = nil end
    if AquaticForFrame(frame) then
        portrait:SetTexture(AQUATIC_PICTURE)   -- every time: Blizzard may have drawn it over
        portrait:SetTexCoord(0, 1, 0, 1)
        swapped[portrait] = true
        cropped[portrait] = nil
        Cover(frame, false)
        return
    end
    if swapped[portrait] then
        -- Our picture without Blizzard drawing again since (a switch turned off): the
        -- client's picture back, as Blizzard draws it.
        swapped[portrait] = nil
        SetPortraitTexture(portrait, frame.unit)
    end
    local kind, why = KindForFrame(frame)
    if kind then
        local opening = OpeningOf(frame)
        local zoom, x, y, past = CropOf(kind, opening)
        portrait:SetTexCoord(Coords(zoom, x, y))
        cropped[portrait] = kind
        Cover(frame, past, zoom, x, y, opening)
    else
        -- A class icon atlas brought its own coords.
        if cropped[portrait] and why ~= CLASS_ICON then portrait:SetTexCoord(0, 1, 0, 1) end
        cropped[portrait] = nil
        Cover(frame, false)
    end
end

local function OnPortraitUpdate(frame, redrawn)
    local ok, err = pcall(Apply, frame, redrawn)
    if not ok then lastError = err end
end

local hooked = false
local function Hook()
    if hooked or type(UnitFramePortrait_Update) ~= "function" then return end
    hooksecurefunc("UnitFramePortrait_Update", function(frame) OnPortraitUpdate(frame, true) end)
    hooked = true
end

local function AddKnownFrames()
    local list = { PlayerFrame, TargetFrame, FocusFrame }
    if TargetFrame then list[#list + 1] = TargetFrame.totFrame end
    if FocusFrame then list[#list + 1] = FocusFrame.totFrame end
    if PartyFrame then
        for i = 1, 4 do list[#list + 1] = PartyFrame["MemberFrame" .. i] end
    end
    for i = 1, #list do
        local frame = list[i]
        if type(frame) == "table" and frame.portrait then frames[frame] = true end
    end
end

-- Crops again on the picture each frame already shows.
local function Refresh()
    for frame in pairs(frames) do OnPortraitUpdate(frame) end
end

-- Settings' class icon switch calls the UnitFramePortrait_Update it saved before the hook.
local CLASS_CVARS = { replacemyplayerportrait = true, replaceotherplayerportraits = true }
local refreshQueued = false
local function QueueRefresh()
    if refreshQueued then return end
    refreshQueued = true
    C_Timer.After(0, function()
        refreshQueued = false
        Refresh()
    end)
end
ModelsChanged = QueueRefresh

local function ClassicUIRing()
    local api = ClassicUIForeverAPI
    if type(api) ~= "table" or type(api.IsOn) ~= "function" then return false end
    local ok, on = pcall(api.IsOn, "unitFrames")
    return ok and on == true
end

local function LoadSettings()
    local saved = type(ClassicRaceIconsDB) == "table" and ClassicRaceIconsDB or {}
    if saved.enabled == nil then saved.enabled = DEFAULTS.enabled end
    if saved.others == nil then saved.others = DEFAULTS.others end
    if type(saved.npcs) ~= "boolean" then saved.npcs = DEFAULTS.npcs end
    if type(saved.aquatic) ~= "boolean" then saved.aquatic = DEFAULTS.aquatic end
    -- The players' votes: model file -> { kind -> count }.
    if type(saved.models) ~= "table" then saved.models = {} end
    for file, votes in pairs(saved.models) do
        if type(file) ~= "number" or type(votes) ~= "table" then
            saved.models[file] = nil
        else
            for kind, n in pairs(votes) do
                if not KINDS[kind] or type(n) ~= "number" or n < 1 then votes[kind] = nil end
            end
            if next(votes) == nil then saved.models[file] = nil end
        end
    end
    if type(saved.shrink) ~= "boolean" then saved.shrink = DEFAULTS.shrink end
    if type(saved.overlay) ~= "number" or not (saved.overlay >= 0 and saved.overlay <= 1) then
        saved.overlay = DEFAULTS.overlay
    end
    if type(saved.frames) ~= "table" then saved.frames = {} end
    for group, on in pairs(DEFAULTS.frames) do
        if type(saved.frames[group]) ~= "boolean" then saved.frames[group] = on end
    end
    -- Each race and sex; a save from before (one switch per race, `races`) keeps its races.
    local oldRaces = type(saved.races) == "table" and saved.races or {}
    if type(saved.kinds) ~= "table" then saved.kinds = {} end
    for kind, info in pairs(KINDS) do
        if type(saved.kinds[kind]) ~= "boolean" then saved.kinds[kind] = oldRaces[info.race] ~= false end
    end
    for kind in pairs(saved.kinds) do
        if not KINDS[kind] then saved.kinds[kind] = nil end
    end
    saved.races = nil
    if type(saved.crops) ~= "table" then saved.crops = {} end
    for kind, c in pairs(saved.crops) do
        if not KINDS[kind] or type(c) ~= "table" or type(c.zoom) ~= "number" then saved.crops[kind] = nil end
    end
    ClassicRaceIconsDB = saved
    db = saved
end

-- /cri tune ----------------------------------------------------------------------------------

local tuner, options   -- the windows (/cri tune, /cri options), made when first opened
local STEP, ZOOM_STEP = 0.01, 0.02

-- After a change: the open windows show it.
local function SyncWindows()
    if tuner and tuner:IsShown() then tuner:Update() end
    if options and options:IsShown() then options:Sync() end
end

local function TuneUnit()
    if KindOf("target") then return "target" end
    if KindOf("player") then return "player" end
end

local function SetCrop(kind, zoom, x, y)
    zoom, x, y = Clamp(zoom, x, y, nil, db.shrink)
    db.crops[kind] = { zoom = zoom, x = x, y = y }
    Refresh()
    SyncWindows()
end

-- The kind back to its default crop (or none).
local function ResetCrop(kind)
    db.crops[kind] = nil
    Refresh()
    SyncWindows()
end

-- A move goes only the way it was asked and stops where the picture ends: Clamp alone would
-- pull the head back towards the middle, which slides it along the edge (Right also moved it
-- up; the user, 2026-09-29). A zoom that leaves too little room still pulls it inwards. With
-- /cri shrink on, the edge is SHRINK_ROOM out instead of the picture's.
local function Nudge(kind, dZoom, dx, dy)
    local zoom, x, y = CropOf(kind)
    local room = math.max(0, 0.5 - visible / zoom)
    if db.shrink then room = math.max(room, SHRINK_ROOM) end
    local nx, ny = x + dx, y + dy
    local a = dx * dx + dy * dy
    if a > 0 and nx * nx + ny * ny > room * room then
        -- The way from (x, y) along (dx, dy) to the edge: |(x, y) + t (dx, dy)| = room. (x, y)
        -- is inside, so c <= 0 but for rounding; kept there, the root stays real and t >= 0.
        local b = 2 * (x * dx + y * dy)
        local c = math.min(0, x * x + y * y - room * room)
        local t = (-b + math.sqrt(b * b - 4 * a * c)) / (2 * a)
        nx, ny = x + t * dx, y + t * dy
    end
    SetCrop(kind, zoom + dZoom, nx, ny)
end

-- A movable window of the addon's own (the tuner, the options), with a title and a close button.
local function NewWindow(name, width, height)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetSize(width, height)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetBackdropColor(0, 0, 0, 0.9)

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOP", 0, -12)
    return f
end

local function CreateTuner()
    local SIZE = 160
    local f = NewWindow("ClassicRaceIconsTuner", 2 * SIZE + 60, SIZE + 200)

    -- A picture shown the way the frame shows it: only the ring's opening.
    local function Picture(anchorX, label)
        local holder = CreateFrame("Frame", nil, f)
        holder:SetSize(SIZE, SIZE)
        holder:SetPoint("TOPLEFT", anchorX, -36)
        local bg = holder:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 1)
        local mask = holder:CreateMaskTexture()
        mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetPoint("CENTER")
        holder.mask = mask
        bg:AddMaskTexture(mask)
        local tex = holder:CreateTexture(nil, "ARTWORK")
        tex:SetAllPoints()
        tex:AddMaskTexture(mask)
        holder.tex = tex
        local text = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("TOP", holder, "BOTTOM", 0, -4)
        text:SetText(label)
        return holder
    end

    f.live = Picture(20, "Your portrait - drag / mouse wheel")
    -- Black beyond the client's picture, as on the frames (Cover).
    f.live.cover = f.live:CreateTexture(nil, "ARTWORK", nil, 1)
    f.live.cover:SetTexture(OUTSIDE, "CLAMP", "CLAMP")
    f.live.cover:SetAllPoints()
    f.live.cover:AddMaskTexture(f.live.mask)
    f.live.cover:SetAlpha(0)
    f.classic = Picture(SIZE + 40, "Classic")
    f.classic.tex:SetTexCoord(0, 1, 0, 1)

    -- The old picture laid over yours, to line the heads up.
    f.ghost = f.live:CreateTexture(nil, "OVERLAY")
    f.ghost:SetAllPoints()
    f.ghost:AddMaskTexture(f.live.mask)
    f.ghost:SetAlpha(db.overlay)
    f.ghost:Hide()

    local live = f.live
    live:EnableMouse(true)
    live:EnableMouseWheel(true)
    live:SetScript("OnMouseWheel", function(_, delta)
        if f.kind then Nudge(f.kind, delta * ZOOM_STEP * (IsShiftKeyDown() and 5 or 1), 0, 0) end
    end)
    live:SetScript("OnMouseDown", function(self)
        self.dragX, self.dragY = GetCursorPosition()
    end)
    live:SetScript("OnMouseUp", function(self) self.dragX = nil end)
    live:SetScript("OnHide", function(self) self.dragX = nil end)
    live:SetScript("OnUpdate", function(self)
        if not self.dragX or not f.kind then return end
        local x, y = GetCursorPosition()
        local scale = self:GetEffectiveScale() * self:GetWidth()
        local zoom = CropOf(f.kind)
        local dx, dy = (x - self.dragX) / scale / zoom, (y - self.dragY) / scale / zoom
        if dx ~= 0 or dy ~= 0 then
            self.dragX, self.dragY = x, y
            Nudge(f.kind, 0, -dx, dy)   -- the head follows the cursor
        end
    end)

    local buttons = {}
    f.buttons = buttons
    local function Button(key, label, width, x, y, onClick)
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetSize(width, 22)
        b:SetPoint("TOPLEFT", x, y)
        b:SetText(label)
        b:SetScript("OnClick", onClick)
        buttons[key] = b
        return b
    end
    local function Mover(dZoom, dx, dy)
        return function()
            if not f.kind then return end
            local k = IsShiftKeyDown() and 5 or 1
            Nudge(f.kind, dZoom * k, dx * k, dy * k)
        end
    end
    local row1, row2 = -(SIZE + 60), -(SIZE + 86)
    Button("zoomOut", "Zoom -", 64, 20, row1, Mover(-ZOOM_STEP, 0, 0))
    Button("zoomIn", "Zoom +", 64, 88, row1, Mover(ZOOM_STEP, 0, 0))
    Button("up", "Up", 50, 160, row1, Mover(0, 0, STEP))
    Button("down", "Down", 50, 214, row1, Mover(0, 0, -STEP))
    Button("left", "Left", 50, 268, row1, Mover(0, STEP, 0))
    Button("right", "Right", 50, 322, row1, Mover(0, -STEP, 0))
    Button("ghost", "Overlay", 80, 20, row2, function()
        f.ghost:SetShown(not f.ghost:IsShown())
        if f.ghost:IsShown() and db.overlay == 0 then f.overlay:SetValue(DEFAULTS.overlay) end
    end)
    Button("reset", "Reset", 64, 104, row2, function()
        if f.kind then ResetCrop(f.kind) end
    end)

    -- Fader: how strongly the 3.3.5a picture shows over yours (saved). Moving it shows the
    -- overlay, 0% hides it. A plain slider: Blizzard's slider templates differ by client.
    local row3 = row2 - 32
    local fader = CreateFrame("Slider", nil, f, "BackdropTemplate")
    fader:SetOrientation("HORIZONTAL")
    fader:SetSize(180, 17)
    fader:SetPoint("TOPLEFT", 112, row3)
    fader:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 3, right = 3, top = 6, bottom = 6 },
    })
    fader:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    fader:SetMinMaxValues(0, 1)
    fader:SetValueStep(0.05)
    fader:SetObeyStepOnDrag(true)
    fader:SetValue(db.overlay)
    f.overlay = fader
    local faderLabel = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    faderLabel:SetPoint("TOPLEFT", 20, row3 - 2)
    faderLabel:SetText("Overlay strength")
    f.overlayText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.overlayText:SetPoint("LEFT", fader, "RIGHT", 8, 0)
    local function ShowOverlay(value)
        f.ghost:SetAlpha(value)
        f.overlayText:SetText(math.floor(value * 100 + 0.5) .. "%")
    end
    ShowOverlay(db.overlay)
    fader:SetScript("OnValueChanged", function(_, value)
        value = math.floor(value * 20 + 0.5) / 20
        db.overlay = value
        ShowOverlay(value)
        f.ghost:SetShown(value > 0)
    end)
    fader:EnableMouseWheel(true)
    fader:SetScript("OnMouseWheel", function(self, delta)
        self:SetValue(db.overlay + delta * 0.05)   -- the slider keeps it within 0-1
    end)

    f.values = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.values:SetPoint("TOPLEFT", 180, row2 - 5)
    f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.hint:SetPoint("BOTTOM", 0, 12)
    local HINT = "Shift = bigger steps. Saved per race and sex."
    local EDGE = "Edge of the client's picture: zoom in for more room."
    local PAST = "Past the client's picture: black around it (/cri shrink)."
    local FORM = "In a form: change back to calibrate."

    -- Picks the unit (target, else you) and draws both pictures.
    function f:Pick()
        self.unit = TuneUnit()
        self.kind = self.unit and KindOf(self.unit)
        self.form = self.kind and InForm(self.unit) ~= false
        if self.kind then
            SetPortraitTexture(self.live.tex, self.unit)
            self.classic.tex:SetTexture(KINDS[self.kind].picture)
            self.ghost:SetTexture(KINDS[self.kind].picture)
        end
        self:Update()
    end

    function f:Update()
        local opening = SIZE * 2 * visible
        self.live.mask:SetSize(opening, opening)
        self.classic.mask:SetSize(opening, opening)
        if not self.kind then
            self.title:SetText("Target a player of a classic race")
            self.values:SetText("")
            self.hint:SetText(HINT)
            self.live.cover:SetAlpha(0)
            return
        end
        local name = UnitName(self.unit)
        self.title:SetText(KINDS[self.kind].label .. (CanAccess(name) and name and (" - " .. name) or ""))
        local zoom, x, y, past = CropOf(self.kind)
        self.live.tex:SetTexCoord(Coords(zoom, x, y))
        self.live.cover:SetTexCoord(Coords(zoom, x, y))
        self.live.cover:SetAlpha(past and 1 or 0)
        self.values:SetText(string.format("zoom %.2f   x %.2f   y %.2f%s", zoom, x, y, CropNote(self.kind)))
        local room = math.max(0, 0.5 - visible / zoom)
        if db.shrink then room = math.max(room, SHRINK_ROOM) end
        self.hint:SetText(self.form and FORM or past and PAST
            or math.sqrt(x * x + y * y) >= room - 1e-6 and EDGE or HINT)
    end

    f:SetScript("OnEvent", function(self, event, unit)
        if event == "PLAYER_TARGET_CHANGED" or unit == self.unit then self:Pick() end
    end)
    f:SetScript("OnShow", function(self)
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
        self:RegisterEvent("UNIT_PORTRAIT_UPDATE")
        self:Pick()
    end)
    f:SetScript("OnHide", function(self) self:UnregisterAllEvents() end)
    f:Hide()
    return f
end

local function OpenTuner()
    tuner = tuner or CreateTuner()
    tuner:Show()
    tuner:Pick()
end

-- /cri options -------------------------------------------------------------------------------

-- The user's layout (2026-09-30). Every switch works at once and is saved.
local FRAME_SWITCHES = {
    { "player", "Player Portrait" },
    { "target", "Target Portrait" },         -- with its target of target
    { "focus", "Focus Portrait" },           -- with the focus's target
    { "party", "Party Frames Portrait" },
}
local RESET_ALL = "Reset All Custom Calibrations"
local CHECK_SCALE = 0.75   -- UICheckButtonTemplate is 32 px

-- What "Current" means: the kind the tuner takes (your target of a known race, else you).
local function CurrentKind()
    local unit = TuneUnit()
    return unit and KindOf(unit), unit
end

-- All kinds' own crops go.
local function ResetAll()
    db.crops = {}
    Refresh()
    SyncWindows()
end

local function CreateOptions()
    local f = NewWindow("ClassicRaceIconsOptions", 300, 620)
    f:ClearAllPoints()
    f:SetPoint("RIGHT", UIParent, "CENTER", -200, 0)   -- left of the tuner (380 px, centred)
    f.title:SetText("Classic Race Icons")
    local checks = {}   -- { button, get }
    f.frameChecks, f.kindChecks = {}, {}
    local y = -38

    local function Heading(text)
        local h = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        h:SetPoint("TOPLEFT", 16, y)
        h:SetText(text)
        y = y - 20
    end
    -- A check box at x on the current row; offsets are in its own (scaled) units.
    local function Check(x, label, get, set)
        local b = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
        b:SetScale(CHECK_SCALE)
        b:SetPoint("TOPLEFT", x / CHECK_SCALE, (y + 2) / CHECK_SCALE)
        local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", b, "RIGHT", 2, 0)
        text:SetText(label)
        b.label = text
        b:SetScript("OnClick", function(self)
            set(self:GetChecked() and true or false)
            Refresh()
            SyncWindows()
        end)
        checks[#checks + 1] = { button = b, get = get }
        return b
    end

    Heading("General")
    f.enable = Check(16, "Enable addon", function() return db.enabled end, function(v) db.enabled = v end)
    y = y - 24
    for _, s in ipairs(FRAME_SWITCHES) do
        local group = s[1]
        f.frameChecks[group] = Check(16, s[2], function() return db.frames[group] end,
            function(v) db.frames[group] = v end)
        y = y - 24
    end
    f.npcs = Check(16, "NPC Portraits", function() return db.npcs end, function(v) db.npcs = v end)
    y = y - 24
    f.aquatic = Check(16, "Classic Aquatic Form", function() return db.aquatic end, function(v) db.aquatic = v end)
    y = y - 24

    y = y - 8
    Heading("Race Overrides")
    for _, race in ipairs(RACE_ORDER) do
        local name = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("TOPLEFT", 24, y - 4)
        name:SetText(RACES[race])
        for _, sex in ipairs({ 2, 3 }) do
            local kind = race .. sex
            f.kindChecks[kind] = Check(sex == 2 and 118 or 196, SEXES[sex], function() return db.kinds[kind] end,
                function(v) db.kinds[kind] = v end)
        end
        y = y - 24
    end

    y = y - 8
    Heading("Calibration")
    f.current = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.current:SetPoint("TOPLEFT", 16, y)
    y = y - 20
    local function Button(label, onClick)
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetSize(240, 22)
        b:SetPoint("TOP", 0, y)
        b:SetText(label)
        b:SetScript("OnClick", onClick)
        y = y - 28
        return b
    end
    f.calibrate = Button("Calibrate Current Character", function() OpenTuner() end)
    f.resetCurrent = Button("Reset Current Calibration", function()
        local kind = CurrentKind()
        if kind then ResetCrop(kind) end
    end)
    -- Every kind's own crop: a second click within a few seconds does it.
    f.resetAll = Button(RESET_ALL, function(self)
        if not self.armed then
            local token = {}
            self.armed = token
            self:SetText("Click again to reset all")
            C_Timer.After(4, function()
                if self.armed ~= token then return end
                self.armed = nil
                self:SetText(RESET_ALL)
            end)
            return
        end
        self.armed = nil
        self:SetText(RESET_ALL)
        ResetAll()
    end)

    function f:Sync()
        for _, c in ipairs(checks) do c.button:SetChecked(c.get() and true or false) end
        local kind, unit = CurrentKind()
        if kind then
            local name = UnitName(unit)
            self.current:SetText("Current: " .. KINDS[kind].label .. (CanAccess(name) and name and (" - " .. name) or "")
                .. (db.crops[kind] and " (custom)" or CropNote(kind)))
        else
            self.current:SetText("Current: no player of a known race")
        end
        self.resetCurrent:SetEnabled(kind ~= nil and db.crops[kind] ~= nil)
    end

    f:SetScript("OnEvent", function(self) self:Sync() end)
    f:SetScript("OnShow", function(self)
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
        self:Sync()
    end)
    f:SetScript("OnHide", function(self) self:UnregisterAllEvents() end)
    f:Hide()
    return f
end

local function ToggleOptions()
    options = options or CreateOptions()
    options:SetShown(not options:IsShown())
end

-- Events ------------------------------------------------------------------------------------

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("CVAR_UPDATE")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
events:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON then
            LoadSettings()
            Hook()
        elseif arg1 == "Blizzard_UnitFrame" then
            Hook()
        end
    elseif event == "PLAYER_LOGIN" then
        Hook()
        visible = ClassicUIRing() and CLASSICUI_OPENING or 0.5
        AddKnownFrames()
        Refresh()
    elseif event == "CVAR_UPDATE" then
        if type(arg1) == "string" and CLASS_CVARS[arg1:lower()] then QueueRefresh() end
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Covers wait for it, and other players' forms can be read again.
        coversWaiting = false
        Refresh()
    elseif event == "UPDATE_SHAPESHIFT_FORM" then
        QueueRefresh()   -- your own form, in case it changes after the portrait is redrawn
    end
end)
Hook()

-- /cri --------------------------------------------------------------------------------------

local function Print(...)
    print("|cff33ff99Classic Race Icons|r:", ...)
end

local function OnOff(v) return v and "|cff00ff00on|r" or "|cffff4040off|r" end

local function RaceSwitches()
    local parts = {}
    for _, race in ipairs(RACE_ORDER) do
        local male, female = db.kinds[race .. 2], db.kinds[race .. 3]
        local state = male == female and OnOff(male) or ("|cffffff00" .. (male and "male" or "female") .. " only|r")
        parts[#parts + 1] = RACES[race] .. " " .. state
    end
    return table.concat(parts, ", ")
end

local function Summary()
    Print("portraits " .. OnOff(db.enabled) .. ", " .. RaceSwitches() .. ", other players " .. OnOff(db.others)
        .. ", NPCs " .. OnOff(db.npcs) .. ", Aquatic Form " .. OnOff(db.aquatic) .. ", past the edge " .. OnOff(db.shrink))
end

-- How many model files are built in; the players' votes stay quiet (the user, 2026-11-19:
-- only the first line).
local function Models()
    local builtIn = 0
    for _ in pairs(DEFAULT_MODELS) do builtIn = builtIn + 1 end
    Print("NPC models: " .. builtIn .. " built in (every race and sex, SD and HD) - NPCs need nothing more.")
end

local function FrameName(frame)
    local ok, name = pcall(frame.GetName, frame)
    if ok and CanAccess(name) and name then return name end
    return tostring(frame.unit or "?")
end

local function Shown(v)   -- for the status lines; a secret is only named
    if not CanAccess(v) then return "secret" end
    return tostring(v)
end

-- What the form test sees on the unit.
local function FormReport(unit)
    local parts = {}
    if IsMe(unit) then
        if type(GetShapeshiftFormID) == "function" then
            local _, form = pcall(GetShapeshiftFormID)
            parts[#parts + 1] = "form " .. Shown(form)
        end
        local info = C_PlayerInfo
        if info and info.GetDisplayID and info.GetNativeDisplayID then
            local _, shown = pcall(info.GetDisplayID)
            local _, native = pcall(info.GetNativeDisplayID)
            parts[#parts + 1] = "display " .. Shown(shown) .. " (native " .. Shown(native) .. ")"
        end
    else
        local _, _, class = pcall(UnitClass, unit)
        parts[#parts + 1] = Shown(class)
    end
    local found = FormAuras(unit)
    for i = 1, #found do found[i] = tostring(found[i]) end
    parts[#parts + 1] = "form auras " .. (#found > 0 and table.concat(found, " ") or "none")
        .. (FormAurasReadable() and "" or " (restricted)")
    local form = InForm(unit)
    parts[#parts + 1] = form == nil and "unknown" or form and "in a form" or "own form"
    return table.concat(parts, ", ")
end

local function Status()
    Summary()
    local switches = {}
    for _, s in ipairs(FRAME_SWITCHES) do switches[#switches + 1] = s[1] .. " " .. OnOff(db.frames[s[1]]) end
    Print("frames: " .. table.concat(switches, ", "))
    if not hooked then Print("|cffff4040UnitFramePortrait_Update not found - nothing is cropped|r") end
    Print("ring opening " .. visible .. (visible == CLASSICUI_OPENING and " (ClassicUI)" or ""))
    for _, race in ipairs(RACE_ORDER) do
        for sex = 2, 3 do
            local kind = race .. sex
            local zoom, x, y, past = CropOf(kind)
            Print(string.format("  %s: zoom %.2f x %.2f y %.2f%s%s", KINDS[kind].label, zoom, x, y,
                past and " past the edge" or "", CropNote(kind)))
        end
    end
    local list, idle = {}, 0
    for frame in pairs(frames) do
        if frame.unit and Flag(UnitExists, frame.unit) then list[#list + 1] = frame else idle = idle + 1 end
    end
    table.sort(list, function(a, b) return FrameName(a) < FrameName(b) end)
    for _, frame in ipairs(list) do
        local kind, why = KindForFrame(frame)
        if swapped[frame.portrait] then
            Print("  " .. FrameName(frame) .. " [" .. frame.unit .. "]: " .. AQUATIC_SHOWN)
        else
            Print("  " .. FrameName(frame) .. " [" .. frame.unit .. "]: "
                .. (cropped[frame.portrait] and "cropped" or "Blizzard") .. " (" .. tostring(why) .. ")")
        end
    end
    Print("  " .. idle .. " more frames without a unit")
    Print("  your form: " .. FormReport("player"))
    if Flag(UnitExists, "target") and not IsMe("target") and Flag(UnitIsPlayer, "target") then
        Print("  target's form: " .. FormReport("target"))
    end
    if lastError then Print("last error: " .. tostring(lastError)) end
end

SLASH_CLASSICRACEICONS1 = "/cri"
SLASH_CLASSICRACEICONS2 = "/classicraceicons"
SlashCmdList.CLASSICRACEICONS = function(msg)
    local cmd = (msg or ""):lower():match("^%s*(%S*)")
    if cmd == "on" or cmd == "off" then
        db.enabled = cmd == "on"
    elseif COMMANDS[cmd] then
        -- Both sexes: off if both were on, else on.
        local race = COMMANDS[cmd]
        local on = not (db.kinds[race .. 2] and db.kinds[race .. 3])
        db.kinds[race .. 2], db.kinds[race .. 3] = on, on
    elseif cmd == "shrink" then
        db.shrink = not db.shrink
    elseif cmd == "others" then
        db.others = not db.others
    elseif cmd == "npcs" then
        db.npcs = not db.npcs
    elseif cmd == "aquatic" then
        db.aquatic = not db.aquatic
    elseif cmd == "models" then
        Models()
        return
    elseif cmd == "tune" then
        OpenTuner()
        return
    elseif cmd == "options" or cmd == "config" then
        ToggleOptions()
        return
    elseif cmd == "reset" then
        ResetAll()
        Print("all crops back to the defaults")
        return
    elseif cmd == "status" then
        Status()
        return
    else
        Print("/cri options - the options window")
        Print("/cri tune - move and zoom the portrait for the target's race (or yours)")
        Print("/cri on | off - cropping " .. OnOff(db.enabled))
        Print("/cri human | dwarf | nightelf | gnome | orc | undead | tauren | troll | skyborne - toggle one race")
        Print("/cri others - other players too, or only you (" .. OnOff(db.others) .. ")")
        Print("/cri npcs - NPCs shaped like the races too (" .. OnOff(db.npcs) .. "); /cri models - how many models are built in")
        Print("/cri aquatic - druids in Aquatic Form get the Classic portrait (" .. OnOff(db.aquatic) .. ")")
        Print("/cri shrink - a portrait may go smaller or further than the client's picture, black around it (" .. OnOff(db.shrink) .. ")")
        Print("/cri reset - all crops back to the defaults")
        Print("/cri status - what each unit frame shows")
        return
    end
    Refresh()
    SyncWindows()
    Summary()
end

-- For the offline tests only.
ns.test = {
    Clamp = Clamp,
    Coords = Coords,
    Defaults = DEFAULT_CROPS,
    CropOf = CropOf,
    Nudge = Nudge,
    OpenTuner = OpenTuner,
    Tuner = function() return tuner end,
    Options = function() return options end,
    Visible = function() return visible end,
}
