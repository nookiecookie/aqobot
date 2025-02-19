--- @type Mq
local mq = require 'mq'
local class = require('classes.classbase')
local mez = require('routines.mez')
local timer = require('utils.timer')
local common = require('common')
local state = require('state')

class.class = 'enc'
class.classOrder = {'assist', 'mez', 'assist', 'cast', 'mash', 'burn', 'aggro', 'recover', 'buff', 'rest', 'managepet'}

class.SPELLSETS = {standard=1}
class.AURAS = {twincast=true, combatinnate=true, spellfocus=true, regen=true, disempower=true,}

class.addCommonOptions()
class.addCommonAbilities()
class.addOption('AURA1', 'Aura 1', 'twincast', class.AURAS, 'The first aura to keep up', 'combobox')
class.addOption('AURA2', 'Aura 2', 'combatinnate', class.AURAS, 'The second aura to keep up', 'combobox')
class.addOption('USEAOE', 'Use AOE', true, nil, 'Toggle use of AOE abilities', 'checkbox')
class.addOption('INTERRUPTFORMEZ', 'Interrupt for Mez', false, nil, 'Toggle interrupting current spell casts to cast mez', 'checkbox')
class.addOption('TASHTHENMEZ', 'Tash Then Mez', true, nil, 'Toggle use of tash prior to attempting to mez mobs', 'checkbox')
class.addOption('USECHAOTIC', 'Use Chaotic', true, nil, 'Toggle use of Chaotic mez line', 'checkbox')
class.addOption('USECHARM', 'Use Charm', false, nil, 'Attempt to maintain a charm pet instead of using a regular pet', 'checkbox')
class.addOption('USEDOT', 'Use DoT', true, nil, 'Toggle use of DoTs', 'checkbox')
class.addOption('USEHASTE', 'Buff Haste', true, nil, 'Toggle use of haste buff line', 'checkbox')
class.addOption('MEZST', 'Use Mez', true, nil, 'Use single target mez on adds within camp radius', 'checkbox')
class.addOption('MEZAE', 'Use AE Mez', true, nil, 'Use AE Mez if 3 or more mobs are within camp radius', 'checkbox')
class.addOption('MEZAECOUNT', 'AE Mez Count', 3, nil, 'Threshold to use AE Mez ability', 'inputint')
class.addOption('USEMINDOVERMATTER', 'Use Mind Over Matter', true, nil, 'Toggle use of Mind over Matter', 'checkbox')
class.addOption('USENIGHTSTERROR', 'Buff Nights Terror', true, nil, 'Toggle use of Nights Terror buff line', 'checkbox')
class.addOption('USENUKES', 'Use Nuke', true, nil, 'Toggle use of nukes', 'checkbox')
class.addOption('USEPHANTASMAL', 'Use Phantasmal', true, nil, 'Toggle use of Phantasmal', 'checkbox')
class.addOption('USEREPLICATION', 'Buff Mana Proc', true, nil, 'Toggle use of Replication buff line', 'checkbox')
class.addOption('USESHIELDOFFATE', 'Use Shield of Fate', true, nil, 'Toggle use of Shield of Fate', 'checkbox')
class.addOption('USESLOW', 'Use Slow', false, nil, 'Toggle use of single target slow ability', 'checkbox')
class.addOption('USESLOWAOE', 'Use Slow AOE', true, nil, 'Toggle use of AOE slow ability', 'checkbox')
class.addOption('USESPELLGUARD', 'Use Spell Guard', true, nil, 'Toggle use of Spell Guard', 'checkbox')
class.addOption('USEDEBUFF', 'Use Tash', false, nil, 'Toggle use of single target tash ability', 'checkbox')
class.addOption('USEDEBUFFAOE', 'Use Tash AOE', true, nil, 'Toggle use of AOE tash ability', 'checkbox')
class.addOption('USEDISPEL', 'Use Dispel', true, nil, 'Dispel mobs with Eradicate Magic AA', 'checkbox')

class.addSpell('composite', {'Composite Reinforcement', 'Dissident Reinforcement', 'Dichotomic Reinforcement'}) -- restore mana, add dmg proc, inc dmg
class.addSpell('alliance', {'Chromatic Coalition', 'Chromatic Covenant'})

class.addSpell('mezst', {'Addle', 'Euphoria'}) -- 9 ticks
class.addSpell('mezst2', {'Addling Flash'}) -- 6 ticks
class.addSpell('mezae', {'Bewildering Wave', 'Neutralizing Wave', 'Bliss of the Nihil'}) -- targeted AE mez
class.addSpell('mezaehate', {'Confounding Glance'}) -- targeted AE mez + 100% hate reduction
class.addSpell('mezpbae', {'Bewilderment'})
class.addSpell('mezpbae2', {'Perilous Bewilderment'}) -- lvl 120
class.addSpell('meznoblur', {'Chaotic Puzzlement', 'Chaotic Deception'})
class.addSpell('mezaeprocblur', {'Mesmeric Stare'}) -- targeted AE mez
class.addSpell('mezshield', {'Ward of the Beguiler', 'Ward of the Deviser'}) -- mez proc on being hit

class.addSpell('rune', {'Marvel\'s Rune'}) -- 160k rune, self
class.addSpell('rune2', {'Rune of Tearc'}) -- 90k rune, single target
class.addSpell('dotrune', {'Aegis of Xetheg'}) -- absorb DoT dmg
class.addSpell('guard', {'Shield of Inevitability', 'Shield of Destiny', 'Shield of Order'}) -- spell + melee guard
class.addSpell('dotmiti', {'Deviser\'s Auspice', 'Transfixer\'s Auspice'}) -- DoT guard
class.addSpell('meleemiti', {'Eclipsed Auspice'}) -- melee guard
class.addSpell('spellmiti', {'Aegis of Sefra'}) -- 20% spell mitigation
class.addSpell('absorbbuff', {'Brimstone Endurance'}) -- increase absorb dmg

class.addSpell('aggrorune', {'Ghastly Rune'}) -- single target rune + hate increase

class.addSpell('groupdotrune', {'Legion of Xetheg', 'Legion of Cekenar'})
class.addSpell('groupspellrune', {'Legion of Liako', 'Legion of Kildrukaun'})
class.addSpell('groupaggrorune', {'Eclipsed Rune'}) -- group rune + aggro reduction proc

class.addSpell('dot', {'Mind Vortex', 'Mind Coil', 'Mind Shatter'}) -- big dot
class.addSpell('dot2', {'Throttling Grip', 'Pulmonary Grip'}) -- decent dot
class.addSpell('debuffdot', {'Perplexing Constriction'}) -- debuff + nuke + dot
class.addSpell('manadot', {'Tears of Xenacious'}) -- hp + mana DoT
class.addSpell('nukerune', {'Chromatic Flare'}) -- 15k nuke + self rune
class.addSpell('nuke', {'Psychological Appropriation'}) -- 20k
class.addSpell('nuke2', {'Chromashear'}) -- 23k
class.addSpell('nuke3', {'Polyluminous Assault'}) -- 27k nuke
class.addSpell('nuke4', {'Obscuring Eclipse'}) -- 27k nuke
class.addSpell('aenuke', {'Gravity Roil'}) -- 23k targeted ae nuke

class.addSpell('calm', {'Still Mind'})
class.addSpell('tash', {'Edict of Tashan', 'Proclamation of Tashan', 'Bite of Tashani'})
class.addSpell('stunst', {'Dizzying Vortex'}) -- single target stun
class.addSpell('stunae', {'Remote Color Conflagration'})
class.addSpell('stunpbae', {'Color Conflagration'})
class.addSpell('stunaerune', {'Polyluminous Rune', 'Polycascading Rune', 'Polyfluorescent Rune', 'Ethereal Rune', 'Arcane Rune'}) -- self rune, proc ae stun on fade

class.addSpell('pet', {'Constance\'s Animation', 'Aeidorb\'s Animation'})
class.addSpell('pethaste', {'Invigorated Minion'})
class.addSpell('charm', {'Marvel\'s Command'})
-- buffs
class.addSpell('unity', {'Marvel\'s Unity', 'Deviser\'s Unity'}) -- mez proc on being hit
class.addSpell('procbuff', {'Mana Rebirth', 'Mana Flare'}) -- single target dmg proc buff
class.addSpell('kei', {'Scrying Visions', 'Sagacity', 'Voice of Quellious'})
class.addSpell('keigroup', {'Voice of Perception', 'Voice of Sagacity'})
class.addSpell('haste', {'Speed of Itzal', 'Speed of Cekenar'}) -- single target buff
class.addSpell('grouphaste', {'Hastening of Jharin', 'Hastening of Cekenar'}) -- group haste
class.addSpell('nightsterror', {'Night\'s Perpetual Terror', 'Night\'s Endless Terror'}) -- melee attack proc
-- auras - mana, learners, spellfocus, combatinnate, disempower, rune, twincast
class.addSpell('twincast', {'Twincast Aura'})
class.addSpell('regen', {'Marvel\'s Aura', 'Deviser\'s Aura'}) -- mana + end regen aura
class.addSpell('spellfocus', {'Enhancing Aura', 'Fortifying Aura'}) -- increase dmg of DDs
class.addSpell('combatinnate', {'Mana Radix Aura', 'Mana Replication Aura'}) -- dmg proc on spells, Issuance of Mana Radix == place aura at location
class.addSpell('disempower', {'Arcane Disjunction Aura'})
-- unity buffs
class.addSpell('shield', {'Shield of Shadow', 'Shield of Restless Ice'})
class.addSpell('ward', {'Ward of the Beguiler', 'Ward of the Transfixer'})

class.addSpell('synergy', {'Mindreap', 'Mindrift', 'Mindslash'}) -- 63k nuke
if class.spells.synergy then
    if class.spells.synergy.name:find('reap') then
        class.addSpell('nuke5', {'Mindrift', 'Mindslash'})
    elseif class.spells.synergy.name:find('rift') then
        class.addSpell('nuke5', {'Mindslash'})
    end
end
if state.emu then
    class.addSpell('nuke5', {'Chromaburst', 'Ancient: Neurosis', 'Madness of Ikkibi', 'Insanity'})
    class.addSpell('unified', {'Unified Alacrity'})
    class.addSpell('dispel', {'Abashi\'s Disempowerment', 'Recant Magic'})
    class.addSpell('spasm', {'Synapsis Spasm'})
end
-- tash, command, chaotic, deceiving stare, pulmonary grip, mindrift, fortifying aura, mind coil, unity, dissident, mana replication, night's endless terror
-- entries in the dots table are pairs of {spell id, spell name} in priority order
local standard = {}
table.insert(standard, class.spells.tash)
if state.emu then
    table.insert(standard, class.spells.spasm)
end
table.insert(standard, class.spells.dotmiti)
table.insert(standard, class.spells.meznoblur)
table.insert(standard, class.spells.mezae)
table.insert(standard, class.spells.dot)
table.insert(standard, class.spells.dot2)
table.insert(standard, class.spells.synergy)
table.insert(standard, class.spells.nuke5)
table.insert(standard, class.spells.composite)
table.insert(standard, class.spells.stunaerune)
table.insert(standard, class.spells.guard)
table.insert(standard, class.spells.nightsterror)
table.insert(standard, class.spells.combatinnate)

table.insert(class.burnAbilities, common.getItem(mq.TLO.InvSlot('Chest').Item.Name()))
table.insert(class.burnAbilities, common.getItem('Rage of Rolfron'))

table.insert(class.burnAbilities, common.getAA('Silent Casting')) -- song, 12 minute CD
table.insert(class.burnAbilities, common.getAA('Focus of Arcanum')) -- buff, 10 minute CD
table.insert(class.burnAbilities, common.getAA('Illusions of Grandeur')) -- 12 minute CD, group spell crit buff
table.insert(class.burnAbilities, common.getAA('Calculated Insanity')) -- 20 minute CD, increase crit for 27 spells
table.insert(class.burnAbilities, common.getAA('Spire of Enchantment')) -- buff, 7:30 minute CD
table.insert(class.burnAbilities, common.getAA('Improved Twincast')) -- 15min CD
table.insert(class.burnAbilities, common.getAA('Chromatic Haze')) -- 15min CD
table.insert(class.burnAbilities, common.getAA('Companion\'s Fury')) -- 10 minute CD
table.insert(class.burnAbilities, common.getAA('Companion\'s Fortification')) -- 15 minute CD

table.insert(class.DPSAbilities, common.getItem('Aged Shissar Focus Staff'))

--table.insert(AAs, getAAid_and_name('Glyph of Destruction (115+)'))
--table.insert(AAs, getAAid_and_name('Intensity of the Resolute'))

class.debuff = common.getAA('Bite of Tashani')
class.slow = common.getAA('Slowing Helix') -- single target slow
if state.emu then
    class.slow = common.getItem('Serpent of Vindication')
end
class.aeslow = common.getAA('Enveloping Helix') -- AE slow on 8 targets
class.dispel = common.getAA('Eradicate Magic') or class.spells.dispel

local mezbeam = common.getAA('Beam of Slumber')
local longmez = common.getAA('Noctambulate') -- 3min single target mez

local aekbblur = common.getAA('Beguiler\'s Banishment')
local kbblur = common.getAA('Beguiler\'s Directed Banishment')
local aeblur = common.getAA('Blanket of Forgetfulness')

local haze = common.getAA('Chromatic Haze') -- 10min CD, buff 2 nukes for group

local shield = common.getAA('Dimensional Shield')
local rune = common.getAA('Eldritch Rune')
local grouprune = common.getAA('Glyph Spray')
local reactiverune = common.getAA('Reactive Rune') -- group buff, melee/spell shield that procs rune
local manarune = common.getAA('Mind over Matter') -- absorb dmg using mana
local veil = common.getAA('Veil of Mindshadow') -- 5min CD, another rune?

local debuffdot = common.getAA('Mental Corruption') -- decrease melee dmg + DoT

-- Buffs
local unity = common.getAA('Orator\'s Unity')
-- Mana Recovery AAs
local azure = common.getAA('Azure Mind Crystal', {summons='Azure Mind Crystal', summonMinimum=1}) -- summon clicky mana heal
local gathermana = common.getAA('Gather Mana')
local sanguine = common.getAA('Sanguine Mind Crystal', {summons='Sanguine Mind Crystal', summonMinimum=1}) -- summon clicky hp heal
-- Agro
local stasis = common.getAA('Self Stasis')

table.insert(class.selfBuffs, class.spells.guard)
table.insert(class.selfBuffs, class.spells.stunaerune)
table.insert(class.selfBuffs, rune)
table.insert(class.selfBuffs, veil)
table.insert(class.selfBuffs, sanguine)
table.insert(class.selfBuffs, azure)
if class.spells.unified then
    table.insert(class.selfBuffs, class.spells.unified)
    class.kei = class.spells.unified
    class.haste = class.spells.unified
else
    table.insert(class.selfBuffs, class.spells.kei)
    class.kei = class.spells.kei
    class.haste = class.spells.haste
end
class.addRequestAlias(class.kei, 'kei')
class.addRequestAlias(class.haste, 'haste')

table.insert(class.petBuffs, class.spells.pethaste)
if state.emu then
    table.insert(class.auras, common.getAA('Auroria Mastery', {checkfor='Aura of Bedazzlement'}))
    class.spells.procbuff.classes={MAG=true,WIZ=true,NEC=true,ENC=true}
    table.insert(class.singleBuffs, class.spells.procbuff)
else
    table.insert(class.selfBuffs, common.getAA('Orator\'s Unity', {checkfor='Ward of the Beguiler'}))
end

--[[
    track data about our targets, for one-time or long-term affects.
    for example: we do not need to continually poll when to debuff a mob if the debuff will last 17+ minutes
    if the mob aint dead by then, you should re-roll a wizard.
]]--
local targets = {}

if class.spells.mezst then
    local function beforeMez()
        if not mq.TLO.Target.Tashed() and class.OPTS.TASHTHENMEZ.value and class.tash then
            class.tash:use()
        end
        return true
    end
    class.spells.mezst.precast = beforeMez
end
class.mez_unused = function()
    if class.OPTS.MEZAE.value then
        mez.do_ae(class.spells.mezae, class.OPTS.AEMEZCOUNT.value)
    end
    if class.OPTS.MEZST.value and not mq.TLO.Me.SpellInCooldown() then
        if not mq.TLO.Target.Tashed() and class.OPTS.TASHTHENMEZ.value and class.tash then
            class.tash:use()
        end
        mez.do_single(class.spells.mezst)
    end
end

local function cast_synergy()
    if class.spells.synergy and not mq.TLO.Me.Song('Beguiler\'s Synergy')() and mq.TLO.Me.SpellReady(class.spells.synergy.name)() then
        if mq.TLO.Spell(class.spells.synergy.name).Mana() > mq.TLO.Me.CurrentMana() then
            return false
        end
        class.spells.synergy:use()
        return true
    end
    return false
end

-- composite
-- synergy
-- nuke5
-- dot2
class.find_next_spell = function()
    if not mq.TLO.Target.Tashed() and class.OPTS.USEDEBUFF.value and common.is_spell_ready(class.spells.tash) then return class.spells.tash end
    if common.is_spell_ready(class.spells.composite) then return class.spells.composite end
    if cast_synergy() then return nil end
    if state.emu and common.is_spell_ready(class.spells.spasm) then return class.spells.spasm end
    if common.is_spell_ready(class.spells.nuke5) then return class.spells.nuke5 end
    if common.is_spell_ready(class.spells.dot2) then return class.spells.dot2 end
    return nil -- we found no missing dot that was ready to cast, so return nothing
end

class.recover = function()
    -- modrods
    common.check_mana()
    local pct_mana = state.loop.PctMana
    if gathermana and pct_mana < 50 then
        -- death bloom at some %
        gathermana:use()
    end
    if pct_mana < 75 and azure then
        local cursor = mq.TLO.Cursor()
        if cursor and cursor:find(azure.name) then mq.cmd('/autoinventory') end
        local manacrystal = mq.TLO.FindItem(azure.name)
        common.use_item(manacrystal)
    end
end

local check_aggro_timer = timer:new(10)
class.aggro = function()
    if state.loop.PctHPs < 40 and sanguine then
        local cursor = mq.TLO.Cursor()
        if cursor and cursor:find(sanguine.name) then mq.cmd('/autoinventory') end
        local hpcrystal = mq.TLO.FindItem('='..sanguine.name)
        common.use_item(hpcrystal)
    end
    if mq.TLO.Me.CombatState() == 'COMBAT' and mq.TLO.Target() then
        if mq.TLO.Me.TargetOfTarget.ID() == state.loop.ID or check_aggro_timer:timer_expired() then
            if mq.TLO.Me.PctAggro() >= 90 then

            end
        end
    end
end

local function missing_unity_buffs(name)
    local spell = mq.TLO.Spell(name)
    for i=1,spell.NumEffects() do
        local trigger_spell = spell.Trigger(i)
        if not mq.TLO.Me.Buff(trigger_spell.Name())() then return true end
    end
    return false
end

-- group guards - legion of liako / xetheg
class.buff_unused = function()
    if mq.TLO.Me.Moving() then return end
-- now buffs:
-- - class.spells.guard (shield of inevitability - quick-refresh, strong direct damage spell guard and melee-strike rune combined into one.)
-- - class.spells.stunaerune (polyluminous rune - quick-refresh, damage absorption rune with a PB AE stun once consumed.)
-- - rune (eldritch rune - AA rune, always pre-buffed.)
-- - veil (Veil of the Mindshadow – AA rune, always pre-buffed.)
    local tempName
    if class.spells.guard and not mq.TLO.Me.Buff(tempName)() then
        tempName = class.spells.guard.name
        if state.subscription ~= 'GOLD' then tempName = tempName:gsub(' Rk%..*', '') end
        if class.spells.guard:use() then return end
    end
    if class.spells.stunaerune and not mq.TLO.Me.Buff(tempName)() then
        tempName = class.spells.stunaerune.name
        if state.subscription ~= 'GOLD' then tempName = tempName:gsub(' Rk%..*', '') end
        if class.spells.stunaerune:use() then return end
    end
    if rune and not mq.TLO.Me.Buff(rune.name)() then
        if rune:use() then return end
    end
    if veil and not mq.TLO.Me.Buff(veil.name)() then
        if veil:use() then return end
    end
    common.check_combat_buffs()
    if not common.clear_to_buff() then return end

    if unity and missing_unity_buffs(unity.name) then
        if unity:use() then return end
    end

    local hpcrystal = sanguine and mq.TLO.FindItem(sanguine.name)
    local manacrystal = azure and mq.TLO.FindItem(azure.name)
    if hpcrystal and not hpcrystal() then
        if sanguine:use() then
            mq.cmd('/autoinv')
            return
        end
    end
    if manacrystal and not manacrystal() then
        if azure:use() then
            mq.cmd('/autoinv')
            return
        end
    end

    if state.emu and #class.auras > 0 then
        for _,aura in ipairs(class.auras) do
            if not mq.TLO.Me.Aura(aura.checkfor)() and not mq.TLO.Me.Song(aura.checkfor)() then
                aura:use()
            end
        end
    else
        if class.OPTS.AURA1.value == 'twincast' and class.spells.twincast and not mq.TLO.Me.Aura('Twincast Aura')() then
            if common.swap_and_cast(class.spells[class.OPTS.AURA1.value], 13) then return end
        elseif class.OPTS.AURA1.value ~= 'twincast' and class.spells[class.OPTS.AURA1.value] and not mq.TLO.Me.Aura(class.spells[class.OPTS.AURA1.value].name)() then
            if common.swap_and_cast(class.spells[class.OPTS.AURA1.value], 13) then return end
        end
        if class.OPTS.AURA2.value == 'twincast' and class.spells.twincast and not mq.TLO.Me.Aura('Twincast Aura')() then
            if common.swap_and_cast(class.spells[class.OPTS.AURA2.value], 13) then return end
        elseif class.OPTS.AURA2.value ~= 'twincast' and class.spells[class.OPTS.AURA2.value] and not mq.TLO.Me.Aura(class.spells[class.OPTS.AURA2.value].name)() then
            if common.swap_and_cast(class.spells[class.OPTS.AURA2.value], 13) then return end
        end
    end

    -- kei
    for _,buff in ipairs(class.selfBuffs) do
        if not mq.TLO.Me.Buff(buff.name)() then
            if buff:use() then return end
        end
    end
    -- haste

    common.check_item_buffs()

    if class.OPTS.BUFFPET.value and mq.TLO.Pet.ID() > 0 then
        --for _,buff in ipairs(buffs.pet) do
        --    if not mq.TLO.Pet.Buff(buff.name)() and mq.TLO.Spell(buff.name).StacksPet() and mq.TLO.Spell(buff.name).Mana() < mq.TLO.Me.CurrentMana() then
        --        common.swap_and_cast(buff.name, 13)
        --    end
        --end
    end
end

local composite_names = {['Composite Reinforcement']=true,['Dissident Reinforcement']=true,['Dichotomic Reinforcement']=true}
local check_spell_timer = timer:new(30)
class.check_spell_set = function()
    if not common.clear_to_buff() or mq.TLO.Me.Moving() or class.OPTS.BYOS.value then return end
    if state.spellset_loaded ~= class.OPTS.SPELLSET.value or check_spell_timer:timer_expired() then
        if class.OPTS.SPELLSET.value == 'standard' then
            common.swap_spell(class.spells.tash, 1)
            common.swap_spell(class.spells.dotmiti, 2)
            common.swap_spell(class.spells.meznoblur, 3)
            common.swap_spell(class.spells.mezae, 4)
            common.swap_spell(class.spells.dot, 5)
            common.swap_spell(class.spells.dot2, 6)
            common.swap_spell(class.spells.synergy, 7)
            common.swap_spell(class.spells.nuke5, 8)
            common.swap_spell(class.spells.composite, 9, composite_names)
            common.swap_spell(class.spells.stunaerune, 10)
            common.swap_spell(class.spells.guard, 11)
            common.swap_spell(class.spells.nightsterror, 12)
            common.swap_spell(class.spells.combatinnate, 13)
            state.spellset_loaded = class.OPTS.SPELLSET.value
        end
        check_spell_timer:reset()
    end
end

--[[
#Event CAST_IMMUNE                 "Your target has no mana to affect#*#"
#Event CAST_IMMUNE                 "Your target is immune to changes in its run speed#*#"
#Event CAST_IMMUNE                 "Your target is immune to snare spells#*#"
#Event CAST_IMMUNE                 "Your target is immune to the stun portion of this effect#*#"
#Event CAST_IMMUNE                 "Your target looks unaffected#*#"
]]--

return class