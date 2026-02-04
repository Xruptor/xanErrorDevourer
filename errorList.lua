--[[
	xanErrorDevour Error List
--]]

--[[------------------------
	Error List
	http://www.wowwiki.com/WoW_Constants/Errors
	http://www.wowpedia.org/WoW_Constants/Spells
	http://paste2.org/p/1134726
	https://github.com/phanx/wow-globalstrings/blob/master/enUS.lua
--------------------------]]

local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

xErrD = {}

local function setError(key, enabled)
	if key then
		xErrD[key] = enabled
	end
end

setError(ERR_NO_ATTACK_TARGET, true) --There is nothing to attack. 
setError(ERR_OUT_OF_RAGE, true) -- Not enough rage
setError(ERR_OUT_OF_MANA, true) -- Not enough mana
setError(ERR_OUT_OF_HEALTH, true) -- Not enough health
setError(ERR_OUT_OF_ENERGY, true) -- Not enough energy
setError(ERR_OUT_OF_FOCUS, true) -- Not enough focus
setError(ERR_OUT_OF_RANGE, true) -- Out of range.
setError(ERR_OUT_OF_RUNES, true) --Not enough runes
setError(ERR_OUT_OF_RUNIC_POWER, true) --Not enough runic power
setError(ERR_OBJECT_IS_BUSY, false) -- That object is busy.   (Not on by default)
setError(ERR_ABILITY_COOLDOWN, true) -- Ability is not ready yet.
setError(ERR_BADATTACKFACING, true) -- You are facing the wrong way!
setError(ERR_BADATTACKPOS, true) -- You are too far away!
setError(ERR_USE_TOO_FAR, true) --You are too far away.
setError(ERR_NOEMOTEWHILERUNNING, true) --You can't do that while moving!
setError(ERR_NOT_IN_COMBAT, false) --You can't do that while in combat  (Not on by default)
setError(ERR_NOT_WHILE_SHAPESHIFTED, false) --You can't do that while shapeshifted.   (Not on by default)
setError(ERR_SPELL_COOLDOWN, true) --Spell is not ready yet.
setError(ERR_SPELL_OUT_OF_RANGE, true) --Out of range.
setError(ERR_ATTACK_FLEEING, true) --Can't attack while fleeing.
setError(ERR_ATTACK_CHARMED, true) --Can't attack while charmed.
setError(ERR_ATTACK_CONFUSED, true) --Can't attack while confused.
setError(ERR_ATTACK_DEAD, true) --Can't attack while dead.
setError(ERR_ATTACK_PACIFIED, true) --Can't attack while pacified.
setError(ERR_ATTACK_STUNNED, true) --Can't attack while stunned.
setError(ERR_INVALID_ATTACK_TARGET, true) --You cannot attack that target.
setError(ERR_GENERIC_NO_TARGET, true) --You have no target.
setError(SPELL_FAILED_NOT_BEHIND, true) --You must be behind your target
setError(SPELL_FAILED_UNIT_NOT_INFRONT, true) --Target needs to be in front of you
setError(SPELL_FAILED_SPELL_IN_PROGRESS, true) --Another action is in progress
setError(SPELL_FAILED_CASTER_AURASTATE, true) --You can't do that yet
setError(SPELL_FAILED_BAD_TARGETS, true) --Invalid Target
setError(SPELL_FAILED_NO_COMBO_POINTS, true) --That ability requires combo points.
setError(SPELL_FAILED_TARGETS_DEAD, true) --Your target is dead
setError(SPELL_FAILED_AFFECTING_COMBAT, true) --You are in combat
setError(SPELL_FAILED_TOO_CLOSE, true)  --Target to close.
setError(SPELL_FAILED_TARGET_FRIENDLY, false) --target is friendly,
setError(ERR_POTION_COOLDOWN, false) --You cannot drink any more yet.
setError(ERR_ITEM_COOLDOWN, false)
setError(SPELL_FAILED_MOVING, false)
setError(SPELL_FAILED_TARGET_AURASTATE, false) --You can't do that yet
setError(SPELL_FAILED_NO_ENDURANCE, false)
setError(SPELL_FAILED_NOT_MOUNTED, false) --you are mounted
setError(SPELL_FAILED_NOT_ON_TAXI, false) --you are in flight
setError(ERR_PET_SPELL_OUT_OF_RANGE, false) --Your pet is out of range.

if IsRetail then
	setError(ERR_VOICE_CHAT_TARGET_NOT_FOUND, false) --Could not find the player to invite to to the voice chat channel.
end
