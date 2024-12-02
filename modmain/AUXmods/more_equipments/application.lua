---
--- @author zsh in 2023/5/20 14:15
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

if not config_data.more_equipments then
    return ;
end

local function isDebugReleased()
    return config_data.more_equipments_debug;
end

TUNING.MORE_EQUIPMENTS_ENABLED = true;

TUNING.MORE_ITEMS_MORE_EQUIPMENTS = {};

local VERSION = "";

--if isDebug() then
--    VERSION = "1.0";
--end

local MODULE_ROOT = "modmain/AUXmods/more_equipments/";

local FORGE_ITEMS_IMAGE_ROOT = "images/inventoryimages/forgeitemimages/";

local function assets()
    table.insert(env.Assets, Asset("IMAGE", FORGE_ITEMS_IMAGE_ROOT .. "forge_items.tex"));
    table.insert(env.Assets, Asset("ATLAS", FORGE_ITEMS_IMAGE_ROOT .. "forge_items.xml"));

    for _, file_name in ipairs({
        "steadfastarmor", "crystaltiara", "jaggedarmor", "riledlucy", "blossomedwreath",
        "reedtunic", "forge_woodarmor", "firebomb", "livingstaff", "bacontome",
        "flowerheadband", "clairvoyantcrown", "featheredwreath", "featheredtunic", "wovengarland",
        "silkenarmor", "infernalstaff", "splintmail", "forgedarts", "forginghammer",
        "pithpike", "petrifyingtome", "resplendentnoxhelm", "spiralspear", "noxhelm",
        "barbedhelm", "moltendarts",
    }) do
        table.insert(env.Assets, Asset("IMAGE", FORGE_ITEMS_IMAGE_ROOT .. file_name .. ".tex"));
        table.insert(env.Assets, Asset("ATLAS", FORGE_ITEMS_IMAGE_ROOT .. file_name .. ".xml"));
    end
end
assets();

local function prefabfiles()
    table.insert(env.PrefabFiles, "mone/mine/more_equipments");
end
prefabfiles();

local function recipetabs()
    local RecipeTabs = {};
    local key1 = "more_items_me";
    RecipeTabs[key1] = {
        filter_def = {
            name = "MONE_MORE_ITEMS_ME",
            atlas = "images/inventoryimages.xml",
            image = "sewing_tape.tex" -- sewing_kit
        },
        index = nil
    }
    STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key1].filter_def.name] = "更多物品·更多装备系列";
    AddRecipeFilter(RecipeTabs[key1].filter_def, RecipeTabs[key1].index);
end
recipetabs();

local function recipes()
    local Recipes = {};
    local Recipes_Locate = {};

    if isDebug() then
        --Recipes_Locate["me_forginghammer"] = true;
        --Recipes[#Recipes + 1] = {
        --    name = "me_forginghammer", tech = TECH.SCIENCE_TWO, filters = { "MONE_MORE_ITEMS_ME" },
        --    ingredients = {
        --        Ingredient("greenamulet", 1), Ingredient("greenstaff", 1)
        --    },
        --    config = {
        --        placer = nil, min_spacing = nil, nounlock = nil, numtogive = 1, builder_tag = nil,
        --        --atlas = FORGE_ITEMS_IMAGE_ROOT .. "forge_items.xml", -- 呃，这个图片处理的有问题...
        --        atlas = FORGE_ITEMS_IMAGE_ROOT .. "forginghammer.xml",
        --        image = "forginghammer.tex"
        --    },
        --};

        --Recipes_Locate["me_blossomedwreath"] = true;
        --Recipes[#Recipes + 1] = {
        --    name = "me_blossomedwreath", tech = TECH.SCIENCE_TWO, filters = { "MONE_MORE_ITEMS_ME" },
        --    ingredients = {
        --        Ingredient("flowerhat", 1), Ingredient("hivehat", 1), Ingredient("greengem", 1)
        --    },
        --    config = {
        --        placer = nil, min_spacing = nil, nounlock = nil, numtogive = 1, builder_tag = nil,
        --        atlas = FORGE_ITEMS_IMAGE_ROOT .. "blossomedwreath.xml",
        --        image = "blossomedwreath.tex"
        --    },
        --};
    end
    ------------

    Recipes_Locate["me_resplendentnoxhelm"] = true;
    Recipes[#Recipes + 1] = {
        name = "me_resplendentnoxhelm", tech = TECH.SCIENCE_TWO, filters = { "MONE_MORE_ITEMS_ME" },
        ingredients = {
            --Ingredient("pigskin", 1), Ingredient("rope", 1),
            --Ingredient("livinglog", 1),
            --Ingredient("stinger", 8),
            Ingredient("pigskin", 1), Ingredient("rope", 2),
            Ingredient("livinglog", 1),
            Ingredient("stinger", 8),
            Ingredient("goldnugget", 2),
        },
        config = {
            placer = nil, min_spacing = nil, nounlock = nil, numtogive = 1, builder_tag = nil,
            atlas = FORGE_ITEMS_IMAGE_ROOT .. "resplendentnoxhelm.xml",
            image = "resplendentnoxhelm.tex"
        },
    };

    Recipes_Locate["me_featheredwreath"] = true;
    Recipes[#Recipes + 1] = {
        name = "me_featheredwreath", tech = TECH.SCIENCE_TWO, filters = { "MONE_MORE_ITEMS_ME" },
        ingredients = {
            Ingredient("walrushat", 1), Ingredient("cane", 1), Ingredient("featherhat", 1), Ingredient("rabbit", 4),
        },
        config = {
            placer = nil, min_spacing = nil, nounlock = nil, numtogive = 1, builder_tag = nil,
            atlas = FORGE_ITEMS_IMAGE_ROOT .. "featheredwreath.xml",
            image = "featheredwreath.tex"
        },
    };

    Recipes_Locate["me_clairvoyantcrown"] = true;
    Recipes[#Recipes + 1] = {
        name = "me_clairvoyantcrown", tech = TECH.SCIENCE_TWO, filters = { "MONE_MORE_ITEMS_ME" },
        ingredients = {
            Ingredient("jellybean", 30), Ingredient("amulet", 4), Ingredient("greengem", 2)
        },
        config = {
            placer = nil, min_spacing = nil, nounlock = nil, numtogive = 1, builder_tag = nil,
            atlas = FORGE_ITEMS_IMAGE_ROOT .. "clairvoyantcrown.xml",
            image = "clairvoyantcrown.tex"
        },
    };

    if isDebugReleased() then
        Recipes_Locate["me_spiralspear"] = true;
        Recipes[#Recipes + 1] = {
            name = "me_spiralspear", tech = TECH.SCIENCE_TWO, filters = { "MONE_MORE_ITEMS_ME" },
            ingredients = {
                Ingredient("twigs", 4), Ingredient("rope", 2), Ingredient("flint", 2),
                Ingredient("goldnugget", 2),
            },
            config = {
                placer = nil, min_spacing = nil, nounlock = nil, numtogive = 1, builder_tag = nil,
                atlas = FORGE_ITEMS_IMAGE_ROOT .. "spiralspear.xml",
                image = "spiralspear.tex"
            },
        };
        Recipes_Locate["me_pithpike"] = true;
        Recipes[#Recipes + 1] = {
            name = "me_pithpike", tech = TECH.SCIENCE_TWO, filters = { "MONE_MORE_ITEMS_ME" },
            ingredients = {
                Ingredient("twigs", 4), Ingredient("rope", 2), Ingredient("flint", 2),
                Ingredient("goldnugget", 2),
            },
            config = {
                placer = nil, min_spacing = nil, nounlock = nil, numtogive = 1, builder_tag = nil,
                atlas = FORGE_ITEMS_IMAGE_ROOT .. "pithpike.xml",
                image = "pithpike.tex"
            },
        };
        Recipes_Locate["me_forginghammer"] = true;
        Recipes[#Recipes + 1] = {
            name = "me_forginghammer", tech = TECH.SCIENCE_TWO, filters = { "MONE_MORE_ITEMS_ME" },
            ingredients = {
                Ingredient("twigs", 4), Ingredient("rope", 2), Ingredient("flint", 2),
                Ingredient("goldnugget", 2),
            },
            config = {
                placer = nil, min_spacing = nil, nounlock = nil, numtogive = 1, builder_tag = nil,
                atlas = FORGE_ITEMS_IMAGE_ROOT .. "forginghammer.xml",
                image = "forginghammer.tex"
            },
        };
    end

    --Recipes_Locate["me_crystaltiara"] = true;
    --Recipes[#Recipes + 1] = {
    --    name = "me_crystaltiara", tech = TECH.SCIENCE_TWO, filters = { "MONE_MORE_ITEMS_ME" },
    --    ingredients = {
    --        Ingredient("blueamulet", 4), Ingredient("purplegem", 2), Ingredient("ice", 40)
    --    },
    --    config = {
    --        placer = nil, min_spacing = nil, nounlock = nil, numtogive = 1, builder_tag = nil,
    --        atlas = FORGE_ITEMS_IMAGE_ROOT .. "crystaltiara.xml",
    --        image = "crystaltiara.tex"
    --    },
    --};


    for _, v in pairs(Recipes) do
        env.AddRecipe2(v.name, v.ingredients, v.tech, v.config, v.filters);
    end
    for _, v in pairs(Recipes) do
        env.RemoveRecipeFromFilter(v.name, "MODS");
    end

    Recipes = nil;
    Recipes_Locate = nil;
end
recipes();

local function hook_associated_contents()
    local module_root = MODULE_ROOT .. "modmain/postinit/prefabs/";
    local COMMON_RECIPE_DESC = "鼠标放到右侧的气球图案上可以看到详细内容";
    local contents = {
        --["me_forginghammer"] = function(name)
        --    local MOD_STRINGS = STRINGS.MONE_STRINGS or {};
        --    local NAME = string.upper(name);
        --
        --    STRINGS.NAMES[NAME] = "锻锤 1.0";
        --    STRINGS.RECIPE_DESC[NAME] = COMMON_RECIPE_DESC;
        --    STRINGS.CHARACTERS.GENERIC.DESCRIBE[NAME] = nil;
        --
        --    --MOD_STRINGS[NAME] = [[
        --    --- 类似拆解法杖，但是双倍拆解
        --    --]];
        --
        --    MOD_STRINGS[NAME] = [[
        --    - 敬请期待...
        --    ]];
        --
        --    return ({ pcall(function()
        --        return Import(module_root .. "forginghammer.lua")();
        --    end) })[2];
        --end;
        --["me_blossomedwreath"] = function(name)
        --    local MOD_STRINGS = STRINGS.MONE_STRINGS or {};
        --    local NAME = string.upper(name);
        --
        --    STRINGS.NAMES[NAME] = "绽放花环 1.0";
        --    STRINGS.RECIPE_DESC[NAME] = COMMON_RECIPE_DESC;
        --    STRINGS.CHARACTERS.GENERIC.DESCRIBE[NAME] = nil;
        --
        --    MOD_STRINGS[NAME] = [[
        --    - 被佩戴时，生成回理智光环，范围内玩家每分钟恢复60理智
        --    ]];
        --
        --    return ({ pcall(function()
        --        return Import(module_root .. "blossomedwreath.lua")();
        --    end) })[2];
        --end;
        --["me_crystaltiara"] = function(name)
        --    local MOD_STRINGS = STRINGS.MONE_STRINGS or {};
        --    local NAME = string.upper(name);
        --
        --    STRINGS.NAMES[NAME] = "水晶头饰 1.0";
        --    STRINGS.RECIPE_DESC[NAME] = COMMON_RECIPE_DESC;
        --    STRINGS.CHARACTERS.GENERIC.DESCRIBE[NAME] = nil;
        --
        --    MOD_STRINGS[NAME] = [[
        --    - 每分钟恢复6精神值
        --    - 佩戴者攻击力增加10%
        --    - 佩戴者攻击目标时会给目标施加2点冰冻效果
        --    ]];
        --
        --    return ({ pcall(function()
        --        return Import(module_root .. "crystaltiara.lua")();
        --    end) })[2];
        --end;
        ------------
        ["me_featheredwreath"] = function(name)
            local MOD_STRINGS = STRINGS.MONE_STRINGS or {};
            local NAME = string.upper(name);

            STRINGS.NAMES[NAME] = "羽毛头环 " .. VERSION;
            STRINGS.RECIPE_DESC[NAME] = COMMON_RECIPE_DESC;
            STRINGS.CHARACTERS.GENERIC.DESCRIBE[NAME] = nil;

            -- 计划：兔人友好？
            -- 计划：佩戴者可以直接捡起兔子？这个很麻烦。添加新动作比较好...而且既然不会惊吓小动物，用陷阱抓呗...
            -- 计划：存放羽毛的时候增加攻击力/防御力/移动速度
            MOD_STRINGS[NAME] = [[
            - 有羽毛帽的部分功能
            - 增加25%的移动速度
            - 每分钟恢复6精神值，保暖120
            - 不会惊吓小动物：兔子、火鸡等
            ]];

            return ({ pcall(function()
                return Import(module_root .. "featheredwreath.lua")();
            end) })[2];
        end;
        ["me_resplendentnoxhelm"] = function(name)
            local MOD_STRINGS = STRINGS.MONE_STRINGS or {};
            local NAME = string.upper(name);

            STRINGS.NAMES[NAME] = "华丽的司夜女神头盔 " .. VERSION;
            STRINGS.RECIPE_DESC[NAME] = COMMON_RECIPE_DESC;
            STRINGS.CHARACTERS.GENERIC.DESCRIBE[NAME] = nil;

            MOD_STRINGS[NAME] = [[
            - 耐久和防御等于女武神头盔
            - 反弹给攻击者对你造成的伤害的十倍
            - 采集仙人掌、尖刺灌木等物品时不会受到伤害
            - 每次受到攻击也会对周围造成额外的范围伤害(排除友军等生物)
            ]];

            return ({ pcall(function()
                return Import(module_root .. "resplendentnoxhelm.lua")();
            end) })[2];
        end;
        ["me_clairvoyantcrown"] = function(name)
            local MOD_STRINGS = STRINGS.MONE_STRINGS or {};
            local NAME = string.upper(name);

            STRINGS.NAMES[NAME] = "洞察皇冠 " .. VERSION;
            STRINGS.RECIPE_DESC[NAME] = COMMON_RECIPE_DESC;
            STRINGS.CHARACTERS.GENERIC.DESCRIBE[NAME] = nil;

            MOD_STRINGS[NAME] = [[
            - 增加10%的移动速度
            - 生命值小于60%，佩戴者每秒恢复3滴血。
            - 生命值大于等于60%，佩戴者缓慢恢复血量。
            ]];

            return ({ pcall(function()
                return Import(module_root .. "clairvoyantcrown.lua")();
            end) })[2];
        end;
        ["me_spiralspear"] = function(name)
            if not isDebugReleased() then
                return ;
            end
            local MOD_STRINGS = STRINGS.MONE_STRINGS or {};
            local NAME = string.upper(name);

            STRINGS.NAMES[NAME] = "螺旋矛·初版 " .. VERSION;
            STRINGS.RECIPE_DESC[NAME] = COMMON_RECIPE_DESC;
            STRINGS.CHARACTERS.GENERIC.DESCRIBE[NAME] = nil;

            STRINGS.ACTIONS.CASTAOE[NAME] = "冲天刺 " .. VERSION;

            MOD_STRINGS[NAME] = [[
            - 右键地面，跳入高空，朝敌人向下猛击！
            ]];

            return ({ pcall(function()
                return Import(module_root .. "spiralspear.lua")();
            end) })[2];
        end;
        ["me_pithpike"] = function(name)
            if not isDebugReleased() then
                return ;
            end
            local MOD_STRINGS = STRINGS.MONE_STRINGS or {};
            local NAME = string.upper(name);

            STRINGS.NAMES[NAME] = "尖齿矛·初版 " .. VERSION;
            STRINGS.RECIPE_DESC[NAME] = COMMON_RECIPE_DESC;
            STRINGS.CHARACTERS.GENERIC.DESCRIBE[NAME] = nil;

            STRINGS.ACTIONS.CASTAOE[NAME] = "火刺 " .. VERSION;

            MOD_STRINGS[NAME] = [[
            - 右键地面，冲刺穿过敌人，并在冲刺时翻转一些坦克龟！
            - 提示：该技能伤害范围较小，推荐可以用来躲避伤害和近距离打出多次伤害(这个好变态的)。
            ]];

            return ({ pcall(function()
                return Import(module_root .. "pithpike.lua")();
            end) })[2];
        end;
        ["me_forginghammer"] = function(name)
            if not isDebugReleased() then
                return ;
            end
            local MOD_STRINGS = STRINGS.MONE_STRINGS or {};
            local NAME = string.upper(name);

            STRINGS.NAMES[NAME] = "锻锤·初版 " .. VERSION;
            STRINGS.RECIPE_DESC[NAME] = COMMON_RECIPE_DESC;
            STRINGS.CHARACTERS.GENERIC.DESCRIBE[NAME] = nil;

            STRINGS.ACTIONS.CASTAOE[NAME] = "铁砧攻击 " .. VERSION;

            MOD_STRINGS[NAME] = [[
            - 右键地面，在你的脚下摇动地面，一次击中一切！
            ]];

            return ({ pcall(function()
                return Import(module_root .. "forginghammer.lua")();
            end) })[2];
        end;
    }
    for name, fn in pairs(contents) do
        fn(name);
    end
end
hook_associated_contents();

--------------------------------------------------------------------------------------------------------------
---@type ReForged
ReForged = {}; -- 让 emmylua 插件认为这是全局变量。这样我写起来就方便了...

-- 有必要强调一点，ENV 这个表里变量要尽可能少
-- 至于 env 中的函数和 GLOBAL 中函数同名的情况，就目前我的经验告诉我，很少。暂时看来应该是没问题的。
-- 还有就是，这个结构我设计的很有问题，很不好理解。但是呢，无所谓了。害...
local ENV = setmetatable({
    _G = GLOBAL or _G;
    GLOBAL = GLOBAL or _G;
    env = env;
    -- 熔炉模块的全局环境。注意，相关内容是在 .../reforged/main.lua 中执行的时候被处理的。
    ReForged = ReForged;
    -- 这个 ENV 表里一般是没有什么东西的，目前来说，这个 ENV 基本上是在 prefabs 目录和 postinit 目录下使用的
    ENV = {
        ForgePrefab = Class(Prefab, function(self, name, fn, assets, deps, force_path_search, category, mod_id, atlas, image, swap_build, swap_data, admin_fn_override)
            Prefab._ctor(self, name, fn, assets, deps, force_path_search);
            ------------

            self.type = category;

            self.atlas = atlas and resolvefilepath(atlas) or resolvefilepath("images/inventoryimages.xml");
            self.imagefn = type(image) == "function" and image or nil
            self.image = self.imagefn == nil and image or "torch.tex";

            -- TODO make this a parameter so you can set the admin function
            -- spawn prefab function
            self.admin_fn = admin_fn_override or function(self, data)
                SpawnEntity(data.name, data.amount, data.player, category == "PETS")
            end

            -- Used for lobbyscreen equips
            self.swap_build = swap_build;
            local commonswapdata = {
                common_head1 = { swap = { "swap_hat" }, hide = { "HAIR_NOHAT", "HAIR", "HEAD" }, show = { "HAT", "HAIR_HAT", "HEAD_HAT" } },
                common_head2 = { swap = { "swap_hat" }, show = { "HAT" } },
                common_body = { swap = { "swap_body" } },
                common_hand = { swap = { "swap_object" }, hide = { "ARM_normal" }, show = { "ARM_carry" } }
            }
            self.swap_data = commonswapdata[swap_data] ~= nil and commonswapdata[swap_data] or swap_data;

            self.mod_id = mod_id
        end);

        --FORGE_ITEMS_IMAGE_XML = FORGE_ITEMS_IMAGE_ROOT .. "forge_items.xml"; -- 呃，图片处理的有问题...
        FORGE_ITEMS_IMAGE_ROOT = FORGE_ITEMS_IMAGE_ROOT;
        HEAD = {
            onequipfn = function(args, extra_fn)
                return function(inst, owner, ...)
                    owner.AnimState:OverrideSymbol("swap_hat", args.build, "swap_hat")
                    owner.AnimState:Show("HAT")
                    if args.hidesymbols then
                        owner.AnimState:Show("HAIR_HAT")
                        owner.AnimState:Show("HEAD_HAT")
                        owner.AnimState:Hide("HAIR_NOHAT")
                        owner.AnimState:Hide("HAIR")
                        owner.AnimState:Hide("HEAD")
                    end
                    if inst.components.fueled ~= nil then
                        inst.components.fueled:StartConsuming()
                    end
                    if extra_fn then
                        extra_fn(inst, owner, ...);
                    end
                end
            end,
            onunequipfn = function(args, extra_fn)
                return function(inst, owner, ...)
                    owner.AnimState:ClearOverrideSymbol("swap_hat")
                    owner.AnimState:Hide("HAT")
                    if args.hidesymbols then
                        owner.AnimState:Hide("HAIR_HAT")
                        owner.AnimState:Hide("HEAD_HAT")
                        owner.AnimState:Show("HAIR_NOHAT")
                        owner.AnimState:Show("HAIR")
                        owner.AnimState:Show("HEAD")
                    end
                    if inst.components.fueled ~= nil then
                        inst.components.fueled:StopConsuming()
                    end
                    if extra_fn then
                        extra_fn(inst, owner, ...);
                    end
                end
            end
        };
    }
}, {
    __index = function(t, k)
        return rawget(t, k) or rawget(env, k) or rawget(GLOBAL, k);
    end,
    __newindex = function(t, k, v)
        rawset(rawget(t, "ENV"), k, v);
    end
})

-- 熔炉全局环境：ReForged
Import(MODULE_ROOT .. "modmain/reforged/main.lua", ENV);

local function ImportPrefabFiles(modulename)
    modulename = MODULE_ROOT .. "scripts/prefabs/" .. modulename;
    if not string.find(modulename, "%.lua$") then
        modulename = modulename .. ".lua";
    end
    return Import(modulename, ENV);
end

-- 说明：时间有限，先实现部分物品，而且该部分物品功能也不应复杂化。未来优化的时候重置一下，并复杂化，不然白白浪费了贴图。
--[[
    2023-05-20 随便写的一些设定

    锻锤：forginghammer
        1. 类似于拆解法杖，但双倍拆解，向上取整
        2. 无耐久的普通锤子？
    花式头戴：flowerheadband
        1. 类似棱镜的发光头饰
    √? 羽毛头环：featheredwreath
        1. 增加 20% 的移动速度
        2. 不会惊吓小动物
        3. 每分钟恢复 3 精神值：3/60
    绽放花环：blossomedwreath
        1. 被佩戴时，生成回理智光环，范围内队友每分钟恢复60理智
    √? 洞察皇冠：clairvoyantcrown
        1. 增加 10% 的移动速度
        2. 每秒恢复 2hp，最多恢复到 80%
    √? 华丽的司夜女神头盔：resplendentnoxhelm
        1. 主要是使用头盔的贴图，功能上暂定为普通的猪皮头盔吧
        2. 反弹伤害
    生命魔杖：livingstaff
        1. 将范围内多个目标(或者单一目标)的松树变为树精
        2. 特殊功能扩展：召唤出来的树精可以跟随召唤者，类似猪哥，给予木头增加忠诚时间
        其他：3. 根据攻击特效来的灵感，降低目标移动速度
    召唤之书：bacontome
        1. 攻击时有概率将目标眩晕(因为动画很像...)，但是没特效欸...

    2023-05-21 新说明：手持装备都有新动作！我去！666666
    炉火晶石、召唤之书、锻锤、铁匠的刀刃 这几个物品原封不动地实现，然后加强微调一下。非常的棒！

    编制花环的佩戴者等于植物人？

    水晶头饰很好看，攻击时附带冰冻效果？

    熔炉的盔甲增加最大生命值的方式值得参考，目前简单看来和我的食物随便就兼容了。很强！

    卧槽，吹箭可以齐射！

    火刺！卧槽，冲天刺！

    哇塞，露西斧头可以投掷！让露西闭嘴，然后保留砍树效率，无耐久的斧头，还可以投掷！很棒！
]]

-- 1. 此处不同于 scripts/prefabs/... 文件内的环境，此处的全局环境不止 GLOBAL，还有其他的
-- 2. reforged 目录下的文件是基于熔炉修改的，新动作太帅了！其余目录下的文件算是只使用了贴图。
local Prefabs = {};

-- 特效
UnionSeq(Prefabs, {
    ImportPrefabFiles("reforged/fx/reforged_fx");
}, {
    ImportPrefabFiles("reforged/fx/weaponsparks_fx");
}, {
    ImportPrefabFiles("reforged/fx/forgespear_fx");
});

UnionSeq(Prefabs, {
    -- 羽毛头环
    ImportPrefabFiles("head/featheredwreath");
}, {
    -- 洞察皇冠
    ImportPrefabFiles("head/clairvoyantcrown");
}, {
    -- 华丽的司夜女神头盔
    ImportPrefabFiles("head/resplendentnoxhelm");
}, {
    --水晶头饰：呃，目前的这个实现方法有两个问题：1. 不会冰冻目标 2. 使用冰魔杖会提前冰冻... 算了，之后再写吧！
    --ImportPrefabFiles("head/crystaltiara");
});

if isDebugReleased() then
    -- 可以释放技能的武器：得好好测试测试
    UnionSeq(Prefabs, {
        -- 尖齿矛
        ImportPrefabFiles("hands/reforged/pithpike");
    }, {
        -- 螺旋矛
        ImportPrefabFiles("hands/reforged/spiralspear");
    }, {
        -- 锻锤
        ImportPrefabFiles("hands/reforged/forginghammer");
    });
end

-- 2023-05-21-15:00：停止新内容的编写。

if isDebug() then
    UnionSeq(Prefabs, {
        -- 召唤之书：2023-05-21-14:30：涉及生物，为了再来学。这个生物简单，应该可以算作学习行为图的模板。
        --ImportPrefabFiles("hands/bacontome");
    }, {
        -- 花式头戴：设定不明
        --ImportPrefabFiles("head/flowerheadband");
    }, {
        -- 绽放花环：设定有问题，需要重新设定
        --ImportPrefabFiles("head/blossomedwreath");
    }, {
        -- 生命魔杖：无计划
        --ImportPrefabFiles("hands/livingstaff");
    });
end

TUNING.MORE_ITEMS_MORE_EQUIPMENTS.Prefabs = Prefabs;