### 函数库和类库开发思考

#### 编程规范初版

1. 借鉴 `Python` 包概念，`__init__.lua` 用于导出作用
    - 用户通过 `require("x.x.x.__init__")` 获得当前包内的内容，更直观。对于开发者来说，可以 `require` 更小粒度，更灵活。
    - 1993\. Lua 诞生于巴西 [LuaRocks][1]
      ```txt
      Lua 最初是为了满足嵌入式系统和游戏开发的需求，强调轻量级和可扩展性，因此它常常被用作脚本语言嵌入到其他应用程序中。
      ```
    - 1991\. Python 首次发布
      ```txt
      Python 设计时旨在强调代码的可读性和简洁性，使得程序员能够用更少的代码实现更多的功能。它用于多种应用场景，包 括网络开发、数据分析、人工智能等。
      ```
2. `base.lua` 内的文件永远不会依赖 `shihao` 下的所有文件
3. `utils.lua` 文件依赖于其他文件，比如 `base.lua, module/*`
4. 将 `__init__.lua` 类比 `Python` 的 `__init__.py` 即可，外界需要导入库的话都从这里取。

#### 编程规范初版扩展
1. 父目录绝不允许依赖子目录
2. 同一目录下的文件相互依赖的话，应该将其抽取到 `__shared__.lua` 文件中
3. module 目录下的文件允许 class 目录下的文件调用，反之不允许？【待定】
4. 还是那个问题，如何解决循环依赖问题。  <br>
   如果 module 目录下的文件只依赖 base.lua，那么其他文件就可以随意引用了！  <br>
   也就是说，要求 module 目录下的文件不依赖外部文件！顶多依赖自己。而依赖自己的话，可以将方法抽入 `__shared__.lua` 文件中！  <br>
5. 根目录不能依赖子目录的 `__shared__.lua`！
6. 我发现，如果不存在循环依赖，那么任何一个 lua 文件都可以在任何地点执行测试？
7. shihao.module 目录下的文件将被 class 目录 和 shihao 目录下的 .lua 文件依赖  <br>
   因此目前的情况是：shihao.module 只依赖 base.lua 文件，其他文件绝对不会依赖！  <br>
   那这意味着什么？同级文件只依赖 __shared__.lua 文件被破坏！所以有问题！【待解决】  <br>
8. 需要一个 builtin 目录，该目录下只依赖 lua
   需要一个 functions(module) 目录，该目录存放函数，只依赖 builtin
   需要一个 classes 目录，该目录存放类，只依赖 functions
   需要回答 functions(module) 是否要依赖 classes 目录！ 

> 注意，上面所说的关于 base.lua 的要求，个人认为不太好，太依赖约定了，而且这是我自己的约定，理当找到权威和最佳实践学习。
>
> 当然，自己也是可以有创新的，哪怕比不上别人的最佳实践，但是终究还是有自己的思考过程。
>
> > 简而言之，最佳实践是很重要，但是没有个人实践来碰壁，对于这些最佳实践的理解还是很难到位的。
> > - 多看书，多看好书
> > - 多实践，多做可以上线的项目
---

#### 关于循环依赖

**注意**，我发现一个应该**还算不错**的办法？  <br>
如果秉承当前目录的文件永远不会依赖子目录，同级目录的文件不要相互依赖（这个太苛刻...）  <br>
再看吧！（2025-01-06）  <br>
先锻炼一下自己，出问题大不了重构（当然还得是静态语言重构方便）  <br>
---

1. First item
2. Second item
3. Third item
    1. Indented item
    2. Indented item
4. Fourth item
---

```json
{
  "firstName": "John",
  "lastName": "Smith",
  "age": 25
}
```
---

~~删除线~~

==HighLight==

:joy:

- [x] Write the press release
- [ ] Update the website
- [ ] Contact the media

Here's a simple footnote,[^1] and here's a longer one.[^bignote]

[^1] This is the first footnote.

[^bignote] Here's one with multiple paragraphs and code.

    Indent paragraphs to include them in the footnote.

    `{ my code }`

    Add as many paragraphs as you like.

---

[1]: https://luarocks.org/