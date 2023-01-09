---@type Mq
local mq = require 'mq'
local class = require('classes.classbase')
local assist = require('routines.assist')
local camp = require('routines.camp')
local logger = require('utils.logger')
local timer = require('utils.timer')
local common = require('common')
local config = require('configuration')
local state = require('state')

class.class = 'mag'
class.classOrder = {'assist', 'mash', 'cast', 'burn', 'heal', 'recover', 'buff', 'rest', 'managepet'}

class.SPELLSETS = {standard=1}
class.PETTYPE = {Water=true, Fire=true, Earth=true, Air=true,}

class.addCommonOptions()
class.addCommonAbilities()
class.addOption('PETTYPE', 'Pet Type', 'Water', class.PETTYPE, nil, 'combobox')
class.addOption('USEUNITY', 'Use Unity AA', true, nil, 'Check if you have max Unity AA', 'checkbox')
class.addOption('USEDEBUFF', 'Use Malo', false, nil, 'Check if you want to use Malo AA', 'checkbox')
class.addOption('SUMMONMODROD', 'Summon Mod Rods', true, nil, 'Summons Modrods', 'checkbox')
class.addOption('USEDS', 'Use Group DS', true, nil, 'Check if you want Group DS', 'checkbox')
class.addOption('USETEMPDS', 'Use Temp DS', true, nil, 'Check for DS on Tank', 'checkbox')
class.addOption('USEECLIPTIC', 'Use Ecliptic Companion', true, nil, '', 'checkbox')

--Pet Spells
class.addSpell('pethaste', {'Burnout XV', 'Burnout XIV', 'Burnout XIII', 'Burnout XII', 'Burnout XI', 'Burnout X', 'Burnout IX', 'Burnout VIII'})
class.addSpell('petbuff', {'Iceflame Barricade Rk. II', 'Iceflame Rampart', 'Iceflame Keep', 'Iceflame Armaments', 'Iceflame Eminence', 'Iceflame Armor', 'Iceflame Ward', 'Iceflame Efflux'})
class.addSpell('petheal', {'63724', 'Renewal of Evreth', 'Renewal of Ioulin', 'Renewal of Calix', 'Renewal of Hererra', 'Renewal of Sirqo', 'Renewal of Volark', 'Renewal of Cadwin'}, {opt='HEALPET', pet=50}) -- pet heal
class.addSpell('companion', {'Ecliptic Companion', 'Composite Companion', 'Dissident Companion', 'Dichotomic Companion'})
class.addSpell('auspice', {'Auspice of Valia', 'Auspice of Kildrukaun', 'Auspice of Esianti', 'Auspice of Eternity', 'Auspice of Shadows'})

	if class.OPTS.PETTYPE.value == 'Water' then
		class.addSpell('pet', {'Conscription of Water'})
	elseif class.OPTS.PETTYPE.value == 'Fire' then
		class.addSpell('pet', {'Conscription of Fire'})
	elseif class.OPTS.PETTYPE.value == 'Air' then
		class.addSpell('pet', {'Conscription of Air'})
	elseif class.OPTS.PETTYPE.value == 'Earth' then
		class.addSpell('pet', {'Conscription of Earth'})
	end
	
--Summon Spells
class.addSpell('orb', {'Summon Molten Komatiite Orb'}, {summons={'Molten Komatiite Orb'}, summonMinimum=1})
class.addSpell('summonfrost', {'Grant Voidfrost Paradox'}, {summons={'Summoned: Voidfrost Paradox'}, summonMinimum=1})
class.addSpell('summonearth', {'Summon Forbearing Servant'}, {summons={'Summoned: Exigent Servant XXIV'}, summonMinimum=1})
class.addSpell('summonfire', {'Summon Forbearing Minion'}, {summons={'Summoned: Exigent Minion XXIV'}, summonMinimum=1})
class.addSpell('summonsickle', {'Sickle of Umbral Modulation'}, {summons={'Sickle of Umbral Modulation'}, summonMinimum=1})
class.addSpell('armor', {'Grant the Centien\'s Plate'}) -- targeted, Summon Folded Pack of Spectral Plate
class.addSpell('weapons', {'Grant Shak Dathor\'s Armaments'}) -- targeted, Summons Folded Pack of Spectral Armaments
class.addSpell('jewelry', {'Grant the Diabo\'s Heirlooms'}) -- targeted, Summons Folded Pack of Enibik's Heirlooms, includes muzzle
class.addSpell('mask', {'Grant Visor of Shoen'}) -- Summoned: mask

--DPS Spells
class.addSpell('servant', {'Roiling Servant'})
class.addSpell('nuke1', {'Barrage of Many'})
class.addSpell('nuke2', {'Chaotic Calamity'})
class.addSpell('nuke3', {'Spear of Molten Luclinite'})
class.addSpell('nuke4', {'Shock of Carbide Steel'})
class.addSpell('nuke5', {'Luclinite Bolt'})
class.addSpell('sptwincast', {'Twincast'})

--unity buffs
class.addSpell('shield', {'Shield of Shadow'})
class.addSpell('bodyguard', {'Ophiolite Bodyguard'})
class.addSpell('chaotic', {'Chaotic Largesse'})
class.addSpell('guardian', {'Relentless Guardian'})

--Buffs
class.addSpell('ds', {'Circle of Emberweave Coat'}, {opt='USEDS'})
class.addSpell('bigds', {'Volcanic Veil'}, {opt='USETEMPDS', classes={WAR=true,SHD=true,PAL=true}})
class.addSpell('aura', {'Arcane Distillect'})

--gathermana
class.addSpell('gather', {'Gather Vigor'})

table.insert(class.DPSAbilities, common.getItem('Aged Sarnak Channeler Staff'))
table.insert(class.DPSAbilities, common.getAA('Force of Elements'))

--Burn AAs
table.insert(class.burnAbilities, common.getAA('Fundament: First Spire of the Elements'))
table.insert(class.burnAbilities, common.getAA('Host of the Elements', {delay=1500}))
table.insert(class.burnAbilities, common.getAA('Servant of Ro', {delay=500}))
table.insert(class.burnAbilities, common.getAA('Frenzied Burnout'))

--Pet Buffs
table.insert(class.petBuffs, class.spells.petbuff)
table.insert(class.petBuffs, class.spells.pethaste)
table.insert(class.petBuffs, class.spells.auspice)

table.insert(class.healAbilities, class.spells.petheal)

--buffs
class.spells.orb.classes={self}
table.insert(class.singleBuffs, class.spells.orb)
class.spells.summonfrost.classes={MAG=true}
table.insert(class.singleBuffs, class.spells.summonfrost)
class.spells.summonearth.classes={MAG=true}
table.insert(class.singleBuffs, class.spells.summonearth)
class.spells.summonfire.classes={MAG=true}
table.insert(class.singleBuffs, class.spells.summonfire)
class.spells.summonsickle.classes={MAG=true}
table.insert(class.singleBuffs, class.spells.summonsickle)
table.insert(class.selfBuffs, class.spells.ds)
table.insert(class.selfBuffs, common.getAA('Summon Modulation Shard', {opt='SUMMONMODROD', summons='Summoned: Dazzling Modulation Shard', summonMinimum=1}))
table.insert(class.combatBuffs, common.getAA('Fire Core'))
table.insert(class.singleBuffs, class.spells.bigds)

local unity = common.getAA('Thaumaturge\'s Unity')

if state.emu then
	table.insert(class.selfBuffs, class.spells.shield)
	table.insert(class.selfBuffs, class.spells.bodyguard)
	table.insert(class.selfBuffs, class.spells.chaotic)
	table.insert(class.selfBuffs, class.spells.guardian)
else
	table.insert(class.selfBuffs, common.getAA('Thaumaturge\'s Unity', {opt=USEUNITY, checkfor='Chaotic Largesse'}))
end

class.debuff = common.getAA('Malaise')

local standard = {}
table.insert(standard, class.spells.servant)
table.insert(standard, class.spells.nuke1)
table.insert(standard, class.spells.nuke2)
table.insert(standard, class.spells.nuke3)
table.insert(standard, class.spells.nuke4)
table.insert(standard, class.spells.nuke5)
table.insert(standard, class.spells.sptwincast)
table.insert(standard, class.spells.orb)
table.insert(standard, class.spells.summonfrost)
table.insert(standard, class.spells.companion)
table.insert(standard, class.spells.auspice)
table.insert(standard, class.spells.gather)
table.insert(standard, class.spells.petheal)

class.spellRotations = {
    standard=standard
}

class.addRequestAlias(class.spells.summonfrost, 'frost')
class.addRequestAlias(class.spells.ds, 'ds')
class.addRequestAlias(class.spells.weapons, 'arm')
class.addRequestAlias(class.spells.jewelry, 'jewelry')
class.addRequestAlias(class.spells.armor, 'armor')
class.addRequestAlias(class.spells.mask, 'mask')

local function missing_unity_buffs(name)
    local spell = mq.TLO.Spell(name)
    for i=1,spell.NumEffects() do
        local trigger_spell = spell.Trigger(i)
        if not mq.TLO.Me.Buff(trigger_spell.Name())() then return true end
    end
    return false
end

    if unity and missing_unity_buffs(unity.name) then
        if unity:use() then return end
    end

local check_spell_timer = timer:new(30)
class.check_spell_set = function()
    if not common.clear_to_buff() or mq.TLO.Me.Moving() or common.am_i_dead() or class.OPTS.BYOS.value then return end
    if state.spellset_loaded ~= class.OPTS.SPELLSET.value or check_spell_timer:timer_expired() then
        if class.OPTS.SPELLSET.value == 'standard' then
            common.swap_spell(class.spells.servant, 1)
            common.swap_spell(class.spells.nuke1, 2)
            common.swap_spell(class.spells.nuke2, 3)
            common.swap_spell(class.spells.nuke3, 4)
            common.swap_spell(class.spells.nuke4, 5)
            common.swap_spell(class.spells.nuke5, 6)
            common.swap_spell(class.spells.sptwincast, 7)
            common.swap_spell(class.spells.orb, 8)
            common.swap_spell(class.spells.summonfrost, 9)
            common.swap_spell(class.spells.companion, 10)
			common.swap_spell(class.spells.auspice, 11)
            common.swap_spell(class.spells.gather, 12)
            common.swap_spell(class.spells.petheal, 13)
            state.spellset_loaded = class.OPTS.SPELLSET.value
        end
        check_spell_timer:reset()
    end
end


class.pull_func = function()
    if mq.TLO.Navigation.Active() then mq.cmd('/nav stop') end
    mq.cmd('/multiline ; /pet attack ; /pet swarm')
    mq.delay(1000)
end

return class