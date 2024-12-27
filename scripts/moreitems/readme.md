注意，请把 luarocks 配置好！！！

https://www.cnblogs.com/yang37/p/16648277.html

2024-12-05-15:43：
```txt
    难以置信，通过上面的教程得到的最新 luarocks，用 lua for windows 的 lua.exe 执行时，存在以下问题：
    1. D:\Software\LuaForWindows\5.1\luarocks\lua\luarocks\core\persist.lua
        该文件中执行 load 函数时，提示：bad argument #1 to 'load' (function expected, got string)
        我不理解，lua 的 load 函数不给传字符串的话，为什么 luarocks 要这样实现？
            https://www.lua.org/manual/5.1/manual.html#pdf-load
            按照官方参考手册，确实第一个参数只能传递函数。
            作用：
                动态代码执行
                    load 函数允许你在运行时根据条件生成或加载代码块。这在需要根据用户输入或其它动态内容执行不确定的代码时非常有用。
                加载和执行外部文件
                    可以将 load 与文件操作结合使用，动态加载一个文件中的 Lua 代码。
                模块化和代码分块
                    当需要将一个大的代码块拆分为多个部分并动态加载时，可以使用 load。
                    这可以使代码更清晰，并允许在需要时按需加载代码。
                设计 DSL（领域特定语言）
                    在某些情况下，开发者可能希望实现一种简单的领域特定语言，可以用来快速定义和执行特定操作。
                    使用 load 可以方便地执行这种自定义的代码。
                安全性和沙箱执行
                    通过限制 load 函数的环境和上下文，开发者可以安全地执行来自不信任来源的代码。
                    例如，你可以在一个沙箱环境中运行加载的代码，以防止其影响主程序的状态。
            所以，luarocks 为什么要这样使用 load？为什么第一个参数传的是字符串而不是函数？
                
    2. D:\Software\LuaForWindows\5.1\luarocks\config-5.1
        执行到该文件的时候提示 home 这个变量为 nil
        
```


简单局限于 lua 是毫无意义的，请深入。

举个例子：

1、lua + c 小项目行不行呢？哪怕 c 用网上其他人写好的库也行啊。

```txt
    
```

2、redis lua 如何？

```txt
    通过 Lua 脚本支持在服务器端进行复杂的数据操作。
```

3、web lua？

```txt
    Nginx：中间件可使用 Lua 脚本来扩展功能（通过 ngx_lua 模块），使其成为一个高性能的 Web 服务器和反向代理服务器。
    OpenResty：基于 Nginx 的平台，结合了 Lua，可以方便地构建任何需要 API 和 Web 应用程序的项目。
    Blender: 尽管 Blender 主要使用 Python 作为脚本语言，但它的一些插件和扩展可以使用 C/C++ 和 Lua 结合开发。
```

4、游戏引擎

```txt
    Corona SDK: 一款移动应用程序开发框架，使用 Lua 作为脚本语言来开发游戏和应用。
```

