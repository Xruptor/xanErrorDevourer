local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhTW")
if not L then return end

L.NomNomNom = "|cFF99CC33Nom-Nom-Nom 錯誤！|r"
L.AddError = "添加紅字錯誤提示"
L.RemoveError = "刪除紅字錯誤提示"
L.InfoCustomAdd = "請準確的輸入紅字錯誤提示！（包括標點符號）"
L.Yes = "是"
L.No = "否"
