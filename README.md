# ruby-refactor.el

Ruby refactor is inspired by the Vim plugin vim-refactoring-ruby, currently found at https://github.com/ecomba/vim-ruby-refactoring.

These are the refactorings available
 - Extract to Method  (C-c C-r e)
 - Extract Local Variable  (C-c C-r v)
 - Extract Constant  (C-c C-r c)
 - Add Parameter  (C-c C-r p)
 - Extract to Let  (C-c C-r l)
 - Convert Post Conditional  (C-c C-r o)

# Install
The recommended way to install `ruby-refactor` is from Marmalade or [MELPA](http://melpa.milkbox.net).

```
M-x package-install RET ruby-refactor
```

To install manually, add ruby-refactor.el to your load path, then:

```lisp
(require 'ruby-refactor)
```

In both cases, you must enable `ruby-refactor-minor-mode` in `ruby-mode`:

```lisp
(add-hook 'ruby-mode-hook 'ruby-refactor-mode-launch)
```

# Usage

## Extract to Method:
Select a region of text and invoke `ruby-refactor-extract-to-method`.
You'll be prompted for a method name and a new argument list. If your
extracted method does not take parameters, leave it empty. The method
will be created above the method you are in with the method contents
being the selected region. The region will be replaced with a call to
the method.

## Extract Local Variable:
Select a region of text and invoke `ruby-refactor-extract-local-variable`.
You'll be prompted for a variable name.  The new variable will
be created directly above the selected region and the region
will be replaced with the variable.

## Extract Constant:
Select a region of text and invoke `ruby-refactor-extract-contant`.
You'll be prompted for a constant name.  The new constant will
be created at the top of the enclosing class or module directly
after any include or extend statements and the regions will be
replaced with the constant.

## Add Parameter:
`ruby-refactor-add-parameter`
This simply prompts you for a parameter to add to the current
method definition. If you are on a text, you can just hit enter
as it will use it by default. You can set `ruby-refactor-add-parens`
if you like parens on your params list.  Default values and the
like shouldn't confuse it.

## Extract to Let:
This is really for use with RSpec

`ruby-refactor-extract-to-let`
There is a variable for where the 'let' gets placed. It can be
"top" which is top-most in the file, or "closest" which just
walks up to the first describe/context it finds.
You can also specify a different regex, so that you can just
use "describe" if you want.
If you are on a line:

```ruby
a = Something.else.doing
```

becomes

```ruby
let(:a){ Something.else.doing }
```

If you are selecting a region:

```ruby
a = Something.else
a.stub(:blah)
```

becomes

```ruby
let :a do
  _a = Something.else
  _a.stub(:blah)
  _a
end
```

In both cases, you need the line, first line to have an ` = ` in it,
as that drives conversion.

There is also the bonus that the let will be placed *after* any other
let statements. It appends it to bottom of the list.

Oh, if you invoke with a prefix arg (`C-u`, etc.), it'll swap the placement
of the let.  If you have location as top, a prefix argument will place
it closest.  I kinda got nutty with this one.

## Convert Post Conditional:
Select a region of text and invoke `ruby-refactor-convert-post-conditional`.
This simply moves the expression inside of an 'if' or 'unless' block.

So this:

```ruby
do_some_stuff('blah') if condition
```

becomes

```ruby
if condition
  do_some_stuff('blah')
end
```


## TODO
From the vim plugin, these remain to be done (I don't plan to do them all.)
 - remove inline temp (sexy!)

## How to contribute
The first thing you'll need to do is to get your tests passing. The tests depend on [Cask](http://cask.github.io/index.html), [ecukes](https://github.com/ecukes/ecukes), and [espuds](https://github.com/ecukes/espuds). Cask is sort of like bundler for emacs and ecukes is basically cucumber for emacs.

To get started, install the necessary components:

    ~$ brew install cask
    ~$ cask

And run your tests (which should be green):

    ~$ cask exec ecukes

Tests are live in the `features/` directory.

# License
Copyright (C) 2013 Andrew J Vargo

Authors: Andrew J Vargo <ajvargo@computer.org>, Jeff Morgan <jeff.morgan@leandog.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
