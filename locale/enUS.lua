local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)
if not L then return end

--for non-english fonts
--https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/FrameXML/Fonts.xml

--Get the best possible font for the localization langugage.
--Some fonts are better than others to display special character sets.
L.GetFontType = "Fonts\\FRIZQT__.TTF"

L.NomNomNom = "|cFF99CC33Nom-Nom-Nom Errors!|r"
L.AddError = "Add Error"
L.RemoveError = "Remove Error"
L.InfoCustomAdd = "Please type the error exactly!  (Including Punctuation)"
L.Yes = "Yes"
L.No = "No"


xErrD_LOC = GetLocale() == "enUS" and {
	["you are too far away"] = true,
	["can't attack while horrified."] = true,
	["can't do that while horrified."] = true,
	["you cannot drink any more yet"] = false,
} or { }