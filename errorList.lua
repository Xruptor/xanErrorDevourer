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

xErrD = {
	[ERR_NO_ATTACK_TARGET] = true, --There is nothing to attack. 
	[ERR_OUT_OF_RAGE] = true, -- Not enough rage
	[ERR_OUT_OF_MANA] = true, -- Not enough mana
	[ERR_OUT_OF_HEALTH] = true, -- Not enough health
	[ERR_OUT_OF_ENERGY] = true, -- Not enough energy
	[ERR_OUT_OF_FOCUS] = true, -- Not enough focus
	[ERR_OUT_OF_RANGE] = true, -- Out of range.
	[ERR_OUT_OF_RUNES] = true, --Not enough runes
	[ERR_OUT_OF_RUNIC_POWER] = true, --Not enough runic power
	[ERR_OBJECT_IS_BUSY] = false, -- That object is busy.   (Not on by default)
	[ERR_ABILITY_COOLDOWN] = true, -- Ability is not ready yet.
	[ERR_BADATTACKFACING] = true, -- You are facing the wrong way!
	[ERR_BADATTACKPOS ] = true, -- You are too far away!
	[ERR_USE_TOO_FAR] = true, --You are too far away.
	[ERR_NOEMOTEWHILERUNNING] = true, --You can't do that while moving!
	[ERR_NOT_IN_COMBAT] = false, --You can't do that while in combat  (Not on by default)
	[ERR_NOT_WHILE_SHAPESHIFTED] = false, --You can't do that while shapeshifted.   (Not on by default)
	[ERR_SPELL_COOLDOWN] = true, --Spell is not ready yet.
	[ERR_SPELL_OUT_OF_RANGE] = true, --Out of range.
	[ERR_ATTACK_FLEEING] = true, --Can't attack while fleeing.
	[ERR_ATTACK_CHARMED] = true, --Can't attack while charmed.
	[ERR_ATTACK_CONFUSED] = true, --Can't attack while confused.
	[ERR_ATTACK_DEAD] = true, --Can't attack while dead.
	[ERR_ATTACK_PACIFIED] = true, --Can't attack while pacified.
	[ERR_ATTACK_STUNNED] = true, --Can't attack while stunned.
	[ERR_INVALID_ATTACK_TARGET] = true, --You cannot attack that target.
	[ERR_GENERIC_NO_TARGET] = true, --You have no target.
	[SPELL_FAILED_NOT_BEHIND] = true, --You must be behind your target
	[SPELL_FAILED_UNIT_NOT_INFRONT] = true, --Target needs to be in front of you
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true, --Another action is in progress
	[SPELL_FAILED_CASTER_AURASTATE] = true, --You can't do that yet
	[SPELL_FAILED_BAD_TARGETS] = true, --Invalid Target
	[SPELL_FAILED_NO_COMBO_POINTS] = true, --That ability requires combo points.
	[SPELL_FAILED_TARGETS_DEAD] = true, --Your target is dead
	[SPELL_FAILED_AFFECTING_COMBAT] = true, --You are in combat
	[SPELL_FAILED_TOO_CLOSE] = true,  --Target to close.
	[ERR_BADATTACKPOS] = true, --you are too far away
	[SPELL_FAILED_TARGET_FRIENDLY] = false, --target is friendly
}

--localized error messages
xErrD_LOC = GetLocale() == "enUS" and {
	["you are too far away"] = true,
	["can't attack while horrified."] = true,
	["can't do that while horrified."] = true,
} or { }


