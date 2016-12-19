---
layout:     post
title:      "Plain TeX 手册"
subtitle:   "翻译自 wikibooks —— LaTeX/Plain TeX"
date:       2016-09-29 14:35 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/railway-station-1363771_1280.jpg"
catalog: true
tags:
    - LaTeX
    - Plain TeX
    - 翻译
    - 手册

---

当你在使用 $\LaTeX$ 宏的时候，你会发现它是语法非常局限的。或许你会好奇你每次所使用的包（package）是如何用这么少的语法写出来的。实际上， $\LaTeX$ 是 Plain TeX 的一个子集，大部分的  $\LaTeX$  包都是用 Plain TeX 写的。 Plain TeX 更低层，所以它能实现更多的功能，但是也因此学习和编程起来更复杂。

<!-- While you play with $\LaTeX$ macros, you will notice that it is quite limited. You may wonder how all these packages you are using every day have been implemented with so little. In fact, LaTeX is a set of Plain TeX macros and most packages use Plain TeX code. Plain TeX is much more low-level, it has much more capabilities at the cost of a steep learning curve and complex programming. -->

除了极少数的例外，你可以在 $\LaTeX$ 文档中使用 Plain TeX 的全部语法，反过来不行

<!-- Up to a few exceptions, you can use the full Plain TeX language within a valid LaTeX document whereas the opposite is false. -->

## 1. 名词

为了避免困惑，我们先定义一些名词
<!-- To avoid confusion it seems necessary to explain some terms. -->

- `group` 是在大括号`{}`里的所有内容
- `token` 可以是一个字符（character）、一个控制序列（control sequence）或者一个 group
- `控制序列`（control sequence）是所有以 `\` 开始的字符串。它并不按原样输出，而是会根据它的类型被 TeX 引擎编译扩展
- `命令`（或叫`函数`、`宏`）（command, function or macro）是一个可能被扩展为文本、重定义的控制序列的一种控制序列
- `primitive` 是被 TeX 引擎硬编码的命令，也就是说，它不是用 Plain TeX 写的（译者注：而是 TeX 语言内置的）
- `register` 是 TeX 用来处理变量的方式。他们能使用的数目是有限制的，在传统的 TeX 中是 256 个，在 e-TeX 中是 32767 个。（译者注：可以把注册理解为变量）
- `length` 是包含一个 length（有单位的数字） 的控制序列。关于 length，可以参考 [Lengths](https://en.wikibooks.org/wiki/LaTeX/Lengths) （译者注：目前对 length 和 font 也不大了解，先保留翻译）
- `font` 是一个指向字体文件的控制序列。
- `box` 是一个用来输出的对象，任何出现在输出文件中的都是一个 box：字母、段落、页……
- `glue` 是当 box 被连接起来的时候，两个 box 之间一定的空间
- `counter` 是一个包含一个数字的 register

> 注：上述名词除了常用的“命令”和“控制序列”，为了以后使用过程中的方便理解（编译显示的错误都是英文的）和避免翻译带来的误解，均保留英文词汇，另外相信打算学习 LaTeX 宏编程的都至少有简单的英文基础吧？



<!-- - A group is everything after an opening brace and before the matching closing brace. -->
<!-- - A token is a character, a control sequence, or a group. -->
<!-- - A control sequence is anything that begins with a `\`. It is not printed as is, it is expanded by the TeX engine according to its type. -->
<!-- - A command (or function or macro) is a control sequence that may expand to text, to (re)definition of control sequences, etc. -->
<!-- - A primitive is a command that is hard coded in the TeX engine, i.e. it is not written in Plain TeX. -->
<!-- - A register is the TeX way to handle variables. They are limited in numbers (256 for each type of register in classic TeX, 32767 in e-TeX). -->
<!-- - A length is a control sequence that contains a length (a number followed by a unit). See [Lengths](/). -->
<!-- - A font is a control sequence that refers to a font file. See [Fonts](/). -->
<!-- - A box is an object that is made for printing. Anything that ends on the paper is a box: letters, paragraphs, pages... See [Boxes](/). -->
<!-- - A glue is a certain amount of space that is put between boxes when they are being concatenated. -->
<!-- - A counter is a register containing a number. See [Counters](/). -->

或许有更多的名词，但是我们希望这些暂时够用了。
<!-- There may be more terms, but we hope that it will do it for now. -->

## 2. Catcodes

在 TeX 中，一些字符并不是原样输出的。比如 `\` 就被用来表示控制序列，而不是输出一个斜杠（在某些编程语言中称为保留字符）
<!-- In TeX some characters have a special meaning that is not to print the associated glyph. For example, `\` is used to introduce a control sequence, and will not print a backslash by default. -->

为了区分字符的不同含义，TeX 给它们了不同的 `类别码(category codes)`，简称为 `catcodes`。在 TeX 中有 16 个类别码。
<!-- To distinguish between different meanings of the characters, TeX split them into `类别代码(category codes)`, or `catcodes` for short. There are 16 category codes in TeX. -->

TeX 中一个非常强大的特性是可以重定义语言自身。你可以使用`\catcode`命令把类别码（catcodes）改成任何字符。
<!-- A powerful feature of TeX is its ability to redefine the language itself, since there is a `\catcode` function that will let you change the category code of any characters. -->

但是并不推荐这样做，因为这会使代码变得非常难读。如果你非要在一个 class 或者 style 文件中重定义类别码（catcodes），记得在文件的最后把它定义回默认的。
<!-- However, this is not recommended, as it can make code difficult to read. Should you redefine any catcode in a class or in a style file, make sure to revert it back at the end of your file. -->

如果你在文档中重定义类别码（catcodes），一定要在序言（preamble）后定义，以免包（package）在加载的时候出现崩溃。
<!-- If you redefine catcodes in your document, make sure to do it after the preamble to prevent clashes with package loading. -->

| 代码 | 描述                                    | 默认设置                                                |
|------|----------------------------------------|---------------------------------------------------------------|
| 0    | 转义字符或者开始控制序列                   | `\`                                                           |
| 1    | group 的开始                            | `{`                                                           |
| 2    | group 的结束                            | `}`                                                           |
| 3    | 数学公式                                | `$`                                                           |
| 4    | 对齐标记                                | `&`                                                           |
| 5    | 行的结束                                | `^^M` (ASCII return)                                          |
| 6    | 宏的参数                                | `##`                                                          |
| 7    | 上标                                    | `^` and `^^K`                                                 |
| 8    | 下标                                   | `_` and `^^A`                                                 |
| 9    | 忽略的字符                                  | `^^@` (ASCII null)                                            |
| 10   | 空格                                  | `␣` and `^^I` (ASCII horizontal tab)                          |
| 11   | 字母                                   | `A...Z` and `a...z`                                           |
| 12   | 其他字符                                | everything not listed in the other catcodes. Most notably, @. |
| 13   | Active character                       | `~` and `^^L` (ASCII form feed)                               |
| 14   | 注释字符                                   | `%`                                                           |
| 15   | 无效字符                     | `^^?` (ASCII delete)                                          |

#### 2.1 Active characters

Active characters resemble macros: they are single characters that will expand before any other command.

```latex
\catcode`| = 13
\def|{\TeX}
...
This is a stupid example of |.
```

Note that an active character needs to be directly followed by a definition, otherwise the compilation will fail.

#### 2.2 例子

#### 2.3 \makeatletter 和 \makeatother

## 3. Plain TeX 宏(macros)

#### 3.1 Expanded definitions

#### 3.2 Global definitions

#### 3.3 Long definitions

#### 3.4 Outer definitions

#### 3.5 _let_ and _futurelet_

#### 3.6 Special control sequence name

#### 3.7 Controlling expansion

## 4. Registers

## 5. Arithmetic

## 6. Conditionals

#### 6.1 Self defined conditionals

#### 6.2 Case statement

## 7. Loops

## 8. Doing nothing

## 9. TeX characters

#### 9.1 _char_

#### 9.2 _chardef_ and _mathchardef_

#### 9.3 Font encoding map

## 10. Verbatim lines and spaces

## 11. Macros defining macros

## 12. Notes and References

> 本文翻译自 [WikiBooks - LaTeX/Plain_TeX](https://en.wikibooks.org/wiki/LaTeX/Plain_TeX)


