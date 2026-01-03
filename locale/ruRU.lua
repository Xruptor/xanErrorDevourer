local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "ruRU")
if not L then return end
-- Translator ZamestoTV
L.NomNomNom = "|cFF99CC33Ням-Ням-Ням Ошибки!|r"
L.AddError = "Добавить ошибку"
L.RemoveError = "Удалить ошибку"
L.InfoCustomAdd = "Введите ошибку точно! (Включая знаки препинания)"
L.Yes = "Да"
L.No = "Нет"


xErrD_LOC = GetLocale() == "ruRU" and {
    ["you are too far away"] = "вы слишком далеко",
    ["can't attack while horrified."] = "нельзя атаковать в состоянии ужаса.",
    ["can't do that while horrified."] = "нельзя это делать в состоянии ужаса.",
    ["you cannot drink any more yet"] = "вы ещё не можете пить",
} or { }
