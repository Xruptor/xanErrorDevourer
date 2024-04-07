local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhCN")
if not L then return end

L.NomNomNom = "|cFF99CC33Nom-Nom-Nom 错误！|r"
L.AddError = "添加红字错误提示"
L.RemoveError = "删除红字错误提示"
L.InfoCustomAdd = "请准确的输入红字错误提示！（包括标点符号）"
L.Yes = "是"
L.No = "否"
