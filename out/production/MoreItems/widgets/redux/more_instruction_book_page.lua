---
--- Created by zsh
--- DateTime: 2023/12/10 15:52
---

local docs = {
    --{
    --    name = "《序言》",
    --    desc = {
    --        "本物品是更多物品模组的模组说明书。"
    --    }
    --},
    {
        name = "更新日志",
        desc = {
            "2023/12/10",
            "1、添加了新的模组设置：避免老麦释放技能时容器UI被隐藏。但是请注意，开启该选项后，请在游戏内将拖拽后的容器复位，否则容器的默认位置可能会不在当前屏幕范围内。",
            "2、修复了智慧帽失效的bug",
            "2023/12/09",
            {
                type = "img",
                atlas = "images/DLC0000/inventoryimages.xml",
                image = "grass_umbrella.tex"
            },
            "1、新物品：神奇的花伞。装备时，击杀蝴蝶有更大概率掉落黄油。这个概率是和当前时间密切相关的，自己体会哈。你的随从击杀的目标也将视为被你本人击杀。",
            {
                type = "img",
                atlas = "images/DLC/inventoryimages3.xml",
                image = "winterometer.tex"
            },
            "2、新物品：神奇的温度计。高温或低温时候晚上会发光。",
        }
    },
    {
        name = "未来计划",
        desc = {
            "新物品计划：",
            "指南针：有个小格子，给予对应物品，地图上可探测到对应怪物或物品（如给骨片可找到无眼鹿，老鼠尾巴显示老鼠洞）",
            "启迪之冠：给启迪之冠加上铥矿头效果，以及防风暴，防水",
            "雨量计：下雨天塞进去青蛙腿可概率召唤青蛙雨，盐块会概率停雨（科学赌狗）",
            "饥饿腰带：可暂停大力士肌肉值掉落，穿戴去健身时候效果加倍",
            "天文护目镜：可显示科学家位置"
        }
    }
}


--local ImageButton = require "widgets/imagebutton"
--local Grid = require "widgets/grid"
--local Spinner = require "widgets/spinner"
--local TrueScrollList = require "widgets/truescrolllist"
--local TEMPLATES = require "widgets/redux/templates"

local Widget = require "widgets/widget"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Menu = require "widgets/menu"

local Scroller = require "widgets/redux/more_instruction_scroller"

require("util")

local BookPage = Class(Widget, function(self, parent_screen, category)
    Widget._ctor(self, "MoreItemsBookPage")

    self.parent_screen = parent_screen
    self.category = category or "instruction_book"

    self:InitLayout()

    return self
end)

local TOP_OFFSET = 275
local MENU_LEFT = -380
local MENU_TOP_OFFSET = 25
local MENU_TOP_OFFSET_UNIT = 10
local MENU_LEFT_OFFSET = 110
local MENU_ITEM_HEIGHT = 55

local DESC_LEFT = -240
local DESC_OFFSET = 30
local DESC_CONTENT_WIDTH = 710
local DESC_CONTENT_HEIGHT = 580

function BookPage:InitLayout()

    local scale = 0.8
    self.root = self:AddChild(Widget("contentRoot"))
    self.root:SetScale(scale, scale, scale)

    local menuList = {}
    for i, info in pairs(docs) do
        table.insert(menuList, { text = info.name, cb = function()
            self:CreateDesc(i)
        end })
    end

    self.menuScroller = self.root:AddChild(Scroller(
            0, -DESC_CONTENT_HEIGHT,
            MENU_LEFT_OFFSET * 2 + MENU_TOP_OFFSET_UNIT, DESC_CONTENT_HEIGHT + MENU_TOP_OFFSET_UNIT
    ))
    self.menuScroller:SetPosition(
            MENU_LEFT - MENU_LEFT_OFFSET,
            TOP_OFFSET, 0)
    self.menuScroller:SetScrollBound(MENU_ITEM_HEIGHT * #menuList + MENU_TOP_OFFSET_UNIT * 2)

    local leftMenu = self.menuScroller:PathChild(Menu(menuList, -MENU_ITEM_HEIGHT, false, "carny_long"))
    leftMenu:SetTextSize(35)
    leftMenu:SetPosition(MENU_LEFT_OFFSET, -MENU_TOP_OFFSET, 0)

    self:CreateDesc(1)
end

local IMG_MAX_WIDTH = 128

function BookPage:CreateDesc(index)
    if self.currentIndex == index then
        return
    end

    if self.descHolder ~= nil then
        self.descHolder:Kill()
    end

    local descList = docs[index].desc
    self.currentIndex = index

    self.descHolder = self.root:AddChild(Scroller(
            0, -DESC_CONTENT_HEIGHT, DESC_CONTENT_WIDTH, DESC_CONTENT_HEIGHT + 5
    ))
    self.descHolder:SetPosition(DESC_LEFT, TOP_OFFSET, 0)

    local top = 0

    for i, descInfo in ipairs(descList) do
        local contentHeight = 0

        if type(descInfo) == "string" or descInfo.type == "txt" then
            local descObj = type(descInfo) == "string" and { text = descInfo } or descInfo

            local text = self.descHolder:PathChild(Text(UIFONT, 35))
            text:SetHAlign(ANCHOR_LEFT)
            text:SetMultilineTruncatedString(descObj.text, 14, DESC_CONTENT_WIDTH, 200)

            if descObj.color then
                text:SetColour(
                        descObj.color[1] / 255,
                        descObj.color[2] / 255,
                        descObj.color[3] / 255,
                        (descObj.color[4] or 255) / 255
                )
            end

            local TW, TH = text:GetRegionSize()
            text:SetPosition(TW / 2, top - TH / 2)
            contentHeight = TH

        elseif descInfo.type == "img" then
            local atlas = descInfo.atlas
            local image = descInfo.image
            local name = descInfo.name

            -- Pay Attention
            if name ~= nil then
                if softresolvefilepath("images/instruction_book_images/" .. name .. ".xml") ~= nil then
                    atlas = "images/instruction_book_images/" .. name .. ".xml"
                end

                image = name .. ".tex"
            end

            local img = self.descHolder:PathChild(Image(atlas, image))

            local w, h = img:GetSize()
            local scale = 1

            if descInfo.scale ~= nil then
                scale = descInfo.scale
            elseif w > IMG_MAX_WIDTH then
                scale = IMG_MAX_WIDTH / w
            end

            img:SetScale(scale, scale)
            w = w * scale
            h = h * scale

            img:SetPosition(DESC_CONTENT_WIDTH / 2, top - h / 2)
            contentHeight = h

        elseif descInfo.type == "anim" then
            local anim = self.descHolder:PathChild(UIAnim())
            anim:GetAnimState():SetBuild(descInfo.build)
            anim:GetAnimState():SetBankAndPlayAnimation(
                    descInfo.bank or descInfo.build,
                    descInfo.anim or "idle",
                    descInfo.loop ~= false
            )
            if descInfo.opacity ~= nil then
                anim:GetAnimState():SetMultColour(1, 1, 1, descInfo.opacity)
            end

            anim:SetScale(descInfo.scale or 1)

            anim:SetPosition(
                    DESC_CONTENT_WIDTH / 2 + (descInfo.left or 0),
                    top - descInfo.height + (descInfo.top or 0)
            )
            contentHeight = descInfo.height
        end

        top = top - contentHeight - DESC_OFFSET
    end

    self.descHolder:SetScrollBound(-top)
end

return BookPage
