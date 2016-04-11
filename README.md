# composable.el

[![Build Status](https://travis-ci.org/paldepind/composable.el.svg?branch=master)](https://travis-ci.org/paldepind/composable.el)
[![Coverage Status](https://coveralls.io/repos/github/paldepind/composable.el/badge.svg?branch=master)](https://coveralls.io/github/paldepind/composable.el?branch=master)
[![MELPA](https://melpa.org/packages/composable-badge.svg)](https://melpa.org/#/composable)

> Let there be composable editing!

composable.el brings composable text editing to Emacs. It improves the
basic editing power of Emacs by making commands combineable.

It's inspired by vim but implemented in a way that reuses existing
Emacs concepts. This makes it simple and compatible with existing
Emacs functionality and infrastructure. composable.el brings together
existing features in a more powerful way.

*Note:* composable.el is in early stages. It has a healthy amount of
features already but I am very open to ideas for additions. That as
well as feedback on the documentation and implementation is greatly
appreciated. I am aware that some people in the Emacs community are
skeptical towards composable editing. There is more to say about the
topic than this readme does. I'll probably write about that at some
point.

## Introduction

Composable editing is a simple abstraction that makes it possible to
combine _actions_ with _objects_. The key insight in composable.el is
that Emacs already provides all the primitives to implement composable
editing. An action is an Emacs command that operates on the region.
Thus `kill-region` and `comment-region` are actions. An object is
specified by a command that moves point and optionally sets the mark
as well. Examples are `move-end-of-line` and `mark-paragraph`.

> _Note for people familiar with vim:_ What composable.el calls an
action is called an operator in vim and the term object covers both
motion and text object in vim.

So actions and objects are just names for things already present in
Emacs. The primary feature that composable.el introduces is a
_composable command_. A composable command has an associated action.
Invoking it works like this:

1. If the region is active the associated action is invoked directly.
2. Otherwise nothing happens, but the editor is now listening for an
   object. This activates a set of bindings that makes it convenient
   to input objects. For instance pressing `l` makes the action
   operate on the current line.
3. After the object has been entered the action is invoked on the
   specified object.

## Benefits

One of the primary benefits of composable editing is that actions and
objects are _orthogonal_. When you learn a new motion you can apply
all existing actions to it and vice versa. Thus if you use 4 actions
and 8 objects you only need to remember 4+8=12 bindings instead of
4*8=32 bindings. As an additional benefit only actions need to be
always accessible, object can be bound only on the object layer. Thus
you can get away with only 4 regular bindings instead of 32.

## Features

* Based on normal Emacs functionality and concepts.
* [Object input bindings](#the-default-object-bindings) layer that
  makes selecting object easy and fast.
* [Easily repeat composable actions](#repeating) by repeating the
  final character that selected the object.
* Integration with the default mark command with
  [composable mark mode](#composable-mark-mode).
* Reuse bindings for several purposes with [prefix arguments](#prefix-arguments)

## Installation

Install through MELPA with `M-x package-install composable`.
Alternatively, download `composable.el` and place it in your load
path.

```
(require 'composable)
(composable-mode) ; Activates the default keybindings
(composable-mark-mode) ; Use composable with C-SPC
```

# Basic usage

composable.el ships with a default set of keybindings. These are
activated by `composable-mode`. Using `composable-mode` is optional, it
contains nothing but bindings. The mode overwrites a bunch of default
Emacs bindings with composable variants. For instance <kbd>C-w</kbd>
is bound to `composable-kill-region`. Invocations must be proceeded by
an object. For instance <kbd>C-w C-e</kbd> kill to end of line.

Here are a few examples of usage. Refer to the tables with key
bindings below to see the entire set of default commands.

* <kbd>C-w l</kbd>: Kill current line.
* <kbd>M-w 3 f</kbd>: Save 3 words to the kill ring.
* <kbd>M-; s</kbd>: Comment structured expression.
* <kbd>C-M-\\ h h</kbd>: Reindent the current paragraph and the next.
  The last <kbd>h</kbd> [repeats](#repeating) the action and object.

# Documentation

## The default bindings

The default bindings overwrite the "non-composable" default bindings
in Emacs. For instance `C-w` is bound to `composable-kill-region`
instead of `kill-region`.

| Binding  | Command                                  |
| -------- | ---------------------------------------- |
| <kbd>C-w</kbd>     | `composable-kill-region`       |
| <kbd>M-w</kbd>     | `composable-kill-ring-save`    |
| <kbd>M-;</kbd>     | `composable-comment-or-uncomment-region` |
| <kbd>C-M-\\</kbd>  | `composable-indent-region`     |
| <kbd>C-x C-u</kbd> | `composable-upcase-region`     |
| <kbd>C-x C-l</kbd> | `composable-downcase-region`     |

## The default object bindings

A composable command has to be followed by an object (which is any
command that moves point). It makes no sense to type a character after
invoking a composable command. Therefore a special layer of bindings
is activated after invoking a composable command. This makes it easy
to select objects without using modifiers.

Note that all normal bindings, except for the ones overwritten, are
still usable. You can for instance kill a word forward with both
<kbd>C-w f</kbd> and <kbd>C-w M-f</kbd>.

Besides the bindings mentioned below 0-9 are bound to
`digit-argument`, i.e. they work as numeric prefix arguments.

| Binding      | Command                   |
| ------------ | ------------------------- |
| <kbd>.</kbd> | `composable-end-argument` |
| <kbd>,</kbd> | `composable-begin-argument` |
| <kbd>a</kbd> | `move-beginning-of-line` |
| <kbd>f</kbd> | `forward-word` |
| <kbd>b</kbd> | `backward-word` |
| <kbd>n</kbd> | `next-line` |
| <kbd>p</kbd> | `previous-line` |
| <kbd>l</kbd> | `composable-mark-line` |
| <kbd>{</kbd> | `backward-paragraph` |
| <kbd>}</kbd> | `forward-paragraph` |
| <kbd>s</kbd> | `mark-sexp` |
| <kbd>w</kbd> | `mark-word` |
| <kbd>h</kbd> | `mark-paragraph` |
| <kbd>m</kbd> | `back-to-indentation` |
| <kbd>j</kbd> | `composable-mark-join` |
| <kbd>g</kbd> | Leave composable-obect-mode |
| <kbd>C-g</kbd> | Leave composable-obect-mode |

## Create custom composable command

Custom composable commands can be created with `composable-def`. The
function must be passed a list of actions (commands that operate on
the region).

```lisp
(composable-def '(foo bar baz))
```

The above example will define the composable commands
`composable-foo`, `composable-bar` and `composable-baz`.

## Repeating

Repeating is a feature that allows you to repeat the last action
object combination by pressing the last key in the sequence
repeatedly.

For instance <kbd>C-w l l l</kbd> has the same effect as <kbd>C-w
l</kbd><kbd>C-w l</kbd><kbd>C-w l</kbd>. Repetition can also be
combined with numeric prefixes. <kbd>C-w 10 l l l</kbd> kills 12
lines.

The feature can be disabled by setting `composable-repeat` to `nil`.

## Composable Mark mode

Composable mark mode activates the object bindings when the mark is
activated by pressing <kbd>C-SPC</kbd>(`set-mark-command`). The layer
is only active immediately after the mark has been set.

```lisp
(composable-mark-mode 1)
```

## Prefix arguments

composable.el defines two prefix arguments `composable-begin-argument`
and `composable-end-argument`. These modify how the chosen object is
used.

The idea is that if you can mark a thing then you know both where the
thing start and ends. Thus you can not only perform an action on the
entire thing, but also from point to the begining or end of the thing.

Similairly if you have have a pair of commands that move to the
beginning and end of a thing you can use the two in unison to mark the
entire thing.

This makes it possible to use bindings in multiple ways. For instance
if you often perform actions on an entire paragraph but rarely beform
actions from point to the end of a paragraph.

### With region commands

Given a prefix argument before selecting a region command only the end
or the beginning of the region will be used. I.e. instead of applying
the action to the entire marked region only the region between point
and the begining or end of region will be used.

For instance <kbd>C-w . l</kbd> deletes to the end of the
line—including the line break. This is because <kbd>l</kbd> marks the
entire line but due to <kbd>.</kbd> only the end of the marked region
is used.

Similairly <kbd>C-w h</kbd> will kill one paragraph from beginning to
end. But <kbd>C-w , h</kbd> will kill one paragraph backwards and
<kbd>C-w . h</kbd> will kill one paragraph forward.

### With pair movements

With the function `composable-add-pair` you can define movement
commands to be each others pair. For instance the following pair is
defined by default.

```lisp
(composable-add-pair 'forward-word 'backward-word)
```

Alternatively multiple several pairs can be defined with
`composable-add-pairs`.

When a prefix argument is specified before a paired movement command
(begin and end are treated the same) the two commands are used to
establish a region. For instance <kbd>M-w , f</kbd> will save the
current word to the kill ring.
