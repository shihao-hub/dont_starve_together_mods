```txt
    dkjson: https://github.com/LuaDist/dkjson
    json: https://github.com/rxi/json.lua
    inspect: https://github.com/kikito/inspect.lua
    stdlib: https://github.com/lua-stdlib/lua-stdlib
```

1. json 不可以解析稀疏数组（invalid table: sparse array），dkjson 可以解析
2. inspect 可以类比 python 的 pprint，可以打印出结构化的数据
3. json 可以解析稀疏数组，但是解析出来是 nil，所以需要用 dkjson
4. luafun 很不错，而且 支持单纯的 module（应该是支持的） 或者 直接注入 _G 中使用（注入时还支持 override）
