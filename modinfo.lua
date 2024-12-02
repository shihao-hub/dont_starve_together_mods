---
--- @author zsh in 2023/2/5 13:54
---

local L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

local __name = L and "更多物品扩展包" or "MoreItems Expansion";
local __author = "心悦卿兮";
local __version = "3.1.0";

local fns = {};

function fns.description(folder_name, author, version, start_time, content)
    content = content or "";
    return (L and "                                                  感谢你的订阅！\n"
            .. content .. "\n"
            .. "                                                【模组】：" .. folder_name .. "\n"
            .. "                                                【作者】：" .. author .. "\n"
            .. "                                                【版本】：" .. version .. "\n"
            .. "                                                【时间】：" .. start_time .. "\n"
            or "                                                Thanks for subscribing!\n"
            .. content .. "\n"
            .. "                                                【mod    】：" .. folder_name .. "\n"
            .. "                                                【author 】：" .. author .. "\n"
            .. "                                                【version】：" .. version .. "\n"
            .. "                                                【release】：" .. start_time .. "\n"
    );
end

local start_time = "2023-02-05";
local folder_name = folder_name or "workshop";
local content = [[

    本模组是更多物品(2916137510)的扩展包，无法独立运行！
    由于更多物品模组已经很稳定了，所以有了本模组的出现，
    之后添加的新物品和部分新内容都会更新在这个模组里！

    说明：如果专服/云服出现三维固定为100的情况，请与作者反馈！
    目前本模组内容较少，所以可以迅速锁定出现这个问题的原因！
]];

name = __name;
author = __author;
version = __version;
description = fns.description(folder_name, author, version, start_time, content);

server_filter_tags = L and { "更多物品扩展包" } or { "More Items Expansion" };

client_only_mod = false;
all_clients_require_mod = true;

icon = "modicon.tex";
icon_atlas = "modicon.xml";

forumthread = "";
api_version = 10;
--priority = -2 ^ 63;
priority = -2 ^ 32;

--priority = -9998.5;

dont_starve_compatible = false;
reign_of_giants_compatible = false;
dst_compatible = true;

-- 测试分支
if not folder_name:find("2928706576") then
    if folder_name:find("MoreItems Expansion") then
        -- DoNothing
        --priority = -9998.5;
    else
        name = name .. "·测试版本";
        --version = version .. ".beta"; -- 不可改版本号，因为创意工坊网页检测不了...
        icon = nil;
        icon_atlas = nil;
    end
end

function fns.option(description, data, hover)
    return {
        description = description or "",
        data = data,
        hover = hover or ""
    };
end

local vars = {
    OPEN = L and "开启" or "Open";
    CLOSE = L and "关闭" or "Close";
};

function fns.largeLabel(label)
    return {
        name = "",
        label = label or "",
        hover = "",
        options = {
            fns.option("", 0)
        },
        default = 0
    }
end

function fns.common_item(name, label, hover, default)
    default = default ~= false and true or false;
    return {
        name = name;
        label = label or "";
        hover = hover or "";
        options = {
            fns.option(vars.OPEN, true),
            fns.option(vars.CLOSE, false),
        },
        default = default
    }
end

function fns.blank()
    return {
        name = "";
        label = "";
        hover = "";
        options = {
            fns.option("", 0)
        },
        default = 0
    }
end

-- 玩家经常崩溃...那就取消该选项吧！
---- 2023-03-23：？？？怎么还有玩家崩溃，什么玩意？
--if folder_name:find("workshop") then
--    mod_dependencies = {
--        {
--            ["workshop-2916137510"] = false;
--        }
--    }
--end

configuration_options = {
    {
        name = "show_prefab_name",
        label = "鼠标移到物品上可以显示代码",
        hover = "",
        options = {
            fns.option(vars.OPEN, true),
            fns.option(vars.CLOSE, false),
        },
        default = false
    },

    fns.largeLabel("万物打包带"),
    {
        name = "bundle_irreplaceable",
        label = "被打包的物体无法被带下线",
        hover = "和眼骨一样，下线、上下地洞就掉落",
        options = {
            fns.option(vars.OPEN, true),
            fns.option(vars.CLOSE, false),
        },
        default = false
    },
    fns.largeLabel("模组功能设置"),
    --{
    --    name = "",
    --    label = "修改背壳头盔的爆率",
    --    hover = "",
    --    options = {
    --        fns.option(vars.OPEN, true),
    --        fns.option(vars.CLOSE, false),
    --    },
    --    default = false
    --},
    {
        name = "mie_fish_box_animstate",
        label = "贮藏室贴图更换",
        hover = "锡鱼罐 -> 盐盒",
        options = {
            fns.option(vars.OPEN, true),
            fns.option(vars.CLOSE, false),
        },
        default = true
    },
    {
        name = "meatrack_hermit_beebox_hermit",
        label = "寄居蟹隐士的蜂箱和晾肉架可以被摧毁",
        hover = "",
        options = {
            fns.option(vars.OPEN, true),
            fns.option(vars.CLOSE, false),
        },
        default = false
    },

    fns.largeLabel("取消某件物品及其相关内容"),
    fns.common_item("sand_pit", "沙坑", "等价于半自动的转移物品功能，但占地面积小。"),
    --fns.common_item("fishingnet", "渔网", "官方的废稿，目前还未完善。"), -- 未完成的。有机会试试？算了吧！
    fns.common_item("mie_watersource", "水桶"),
    fns.common_item("mie_wooden_drawer", "抽屉"),
    fns.common_item("icemaker", "制冰机"),
    fns.common_item("mie_fish_box", "贮藏室"),
    fns.common_item("dummytarget", "皮痒傀儡"),
    fns.common_item("relic_2", "神秘的图腾"),
    fns.common_item("mie_obsidianfirepit", "黑曜石火坑"),
    fns.common_item("mie_bear_skin_cabinet", "熊皮保鲜柜"),
    fns.common_item("bundle", "万物打包带"),
    fns.common_item("waterpump", "升级版·消防泵"),
    fns.common_item("bushhat", "升级版·灌木从帽"),
    fns.common_item("tophat", "沃尔夫冈的高礼帽"),
    --fns.common_item("walterhat", "沃尔夫冈的帽子"),
    fns.common_item("mie_book_silviculture", "《论如何做一个懒人》"),
    fns.common_item("mie_book_horticulture", "《论如何做一个懒人+》"),

    fns.blank(),
    fns.common_item("mie_meatballs", "绝对吃不完的肉丸", "注意：开启主模组的绝对吃不完系列后，该选项完全失效。\n建议使用主模组的绝对吃不完系列，此处将不再更新。", false),
    fns.common_item("mie_bonestew", "绝对吃不完的炖肉汤", "注意：开启主模组的绝对吃不完系列后，该选项完全失效。\n建议使用主模组的绝对吃不完系列，此处将不再更新。", false),
    fns.common_item("mie_icecream", "绝对吃不完的冰淇淋", "注意：开启主模组的绝对吃不完系列后，该选项完全失效。\n建议使用主模组的绝对吃不完系列，此处将不再更新。", false),
    fns.common_item("mie_lobsterdinner", "绝对吃不完的龙虾正餐", "注意：开启主模组的绝对吃不完系列后，该选项完全失效。\n建议使用主模组的绝对吃不完系列，此处将不再更新。", false),
    fns.common_item("mie_perogies", "绝对吃不完的波兰水饺", "注意：开启主模组的绝对吃不完系列后，该选项完全失效。\n建议使用主模组的绝对吃不完系列，此处将不再更新。", false),
    fns.common_item("mie_leafymeatsouffle", "绝对吃不完的果冻沙拉", "注意：开启主模组的绝对吃不完系列后，该选项完全失效。\n建议使用主模组的绝对吃不完系列，此处将不再更新。", false),
    fns.common_item("mie_dragonpie", "绝对吃不完的火龙果派", "注意：开启主模组的绝对吃不完系列后，该选项完全失效。\n建议使用主模组的绝对吃不完系列，此处将不再更新。", false),
    fns.blank(),

    fns.common_item("mie_beefalofeed", "绝对吃不完的蒸树枝"),

    fns.blank(),
    fns.common_item("klei_items_switch", "总开关"),
    fns.common_item("ponds", "池塘", "就是原版物品可制作"),
    fns.common_item("handpillows", "枕头", "就是原版物品可制作"),
    fns.common_item("moonbase", "月台", "就是原版物品可制作"),
    fns.common_item("featherpencil", "羽毛笔", "一次制作4个"),
    fns.common_item("pigtorch", "猪火炬", "就是原版物品可制作"),
    fns.common_item("armor_bramble", "荆棘护甲", "就是原版物品可制作"),
    fns.common_item("trap_bramble", "荆棘陷阱", "就是原版物品可制作"),
    fns.common_item("giftwrap", "礼物包装", "就是原版物品可制作"),
    fns.common_item("fast_farmplot", "强化农场", "官方弃用物品"),
    fns.common_item("catcoonden", "中空树桩", "就是原版物品可制作"),
    fns.common_item("lureplantbulb", "食人花种子", "就是原版物品可制作"),
    fns.common_item("tallbirdnest", "高脚鸟巢穴", "就是原版物品可制作"),
    fns.common_item("slurtlehole", "蛞蝓龟巢穴", "就是原版物品可制作"),
    fns.common_item("warg", "座狼", "就是原版物品可制作", false),
    fns.common_item("portabletent_item", "沃尔特的帐篷卷", "就是原版物品可制作"),
    fns.common_item("madscience_lab", "疯狂科学家实验室", "就是原版物品可制作"),
    fns.common_item("beebox_hermit", "寄居蟹隐士的蜂箱", "就是原版物品可制作"),
    fns.common_item("meatrack_hermit", "寄居蟹隐士的晾肉架", "就是原版物品可制作"),

    --fns.largeLabel("作者的辅助功能"),
    -- 写的有问题。。。
    --{
    --    name = "log_charcoal",
    --    label = "木头燃烧额外获得木炭",
    --    hover = "",
    --    options = {
    --        fns.option(vars.OPEN, true),
    --        fns.option(vars.CLOSE, false),
    --    },
    --    default = false
    --},

    -- 给我的朋友 @小王者 提供的功能。
    ---- 但是为什么听玩家说有些玩家发现了怎么开这个的？离谱噢，这是怎么知道怎么打开的？
    fns.largeLabel("作者自用（开启无效）"),
    {
        name = "self_use_switch",
        label = "开关",
        hover = "",
        options = {
            fns.option(vars.OPEN, true),
            fns.option(vars.CLOSE, false),
        },
        default = true
    },
    fns.common_item("granary", "1", "粮仓(不好用)，一个可以放蔬果，一个可以放肉食，10倍保鲜。", false),
    fns.common_item("new_granary", "2", "谷仓，50格，10倍保鲜，可以放蔬菜、水果、种子、杂草。"),
    fns.common_item("mie_well", "3", "水井，水壶可以装水、可以遏制半径4格内的焖烧(冒烟)。"),
    fns.common_item("mie_bananafan_big", "4", "芭蕉宝扇，呼风唤雨。"),
    fns.common_item("mie_yjp", "5", "羊脂玉净瓶，半径3.75格内的农田满水满肥、枯萎的作物复活、灭火、停雨。"),
    fns.common_item("mie_cash_tree_ground", "6", "摇钱树，每隔两天左右随机掉落一个宝石、每分钟回复25理智。"),
    fns.common_item("mie_poop_flingomatic", "7", "粪便机，给植物和农场施肥。"),
    --2023-06-01：写完了，但是有点奇怪，比如有时候拉不过来，有时候让目标远离了...
    --fns.common_item("mie_myth_fuchen", "7", "拂尘，增加移速，消除生物仇恨，可以施展技能隔空取物！"),
    {
        name = "user_right",
        label = "开关",
        hover = "",
        options = {
            fns.option(vars.OPEN, false),
            fns.option(vars.CLOSE, true),
        },
        default = false -- false 时，文本显示“开启”
    },
}