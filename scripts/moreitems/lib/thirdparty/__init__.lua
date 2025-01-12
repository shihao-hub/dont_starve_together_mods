return {
    dkjson = require("moreitems.lib.thirdparty.dkjson.dkjson"),
    inspect = require("moreitems.lib.thirdparty.inspect.inspect"),
    json = require("moreitems.lib.thirdparty.json.json"),
    luafun = require("moreitems.lib.thirdparty.luafun.fun"),
    lustache = require("moreitems.lib.thirdparty.lustache.lustache"),
    middleclass = require("moreitems.lib.thirdparty.middleclass.middleclass"),

    extensions = require("moreitems.lib.thirdparty.extensions"),
}

--[[
luafun:
    iter, range, duplicate, tabulate
    take, drop
    filter, grep
    map
    foldl, sum
    zip, chain
    totable, map

    1. 基本迭代器操作
        iter(obj)
        将对象转换为迭代器。支持表、字符串、函数等。

    2. 生成器
        range(start, stop, step)
        生成一个数值范围的迭代器。

        duplicate(value)
        生成一个无限重复某个值的迭代器。

        tabulate(fun)
        生成一个通过函数计算的无限序列。

    3. 切片操作
        take(n, iter)
        从迭代器中取出前 n 个元素。

        drop(n, iter)
        跳过迭代器中的前 n 个元素。

    4. 过滤操作
        filter(fun, iter)
        过滤迭代器中满足条件的元素。

        grep(regexp, iter)
        过滤迭代器中匹配正则表达式的字符串。

    5. 映射操作
        map(fun, iter)
        对迭代器中的每个元素应用函数。

    6. 归约操作
        foldl(fun, init, iter)
        从左到右对迭代器中的元素进行归约。

        sum(iter)
        计算迭代器中元素的和。

    7. 组合操作
        zip(iter1, iter2, ...)
        将多个迭代器组合成一个迭代器，每次返回一个元组。

        chain(iter1, iter2, ...)
        将多个迭代器连接成一个迭代器。

    8. 其他操作
        totable(iter)
        将迭代器转换为表。

        tomap(iter)
        将迭代器转换为映射表。

    9. 操作符
        operator
        提供了一些常用的操作符函数，例如加法、乘法、比较等。

]]
