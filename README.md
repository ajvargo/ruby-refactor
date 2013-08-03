# ruby-refactor.el

Ruby refactor is inspired by the Vim plugin vim-refactoring-ruby, currently found at https://github.com/ecomba/vim-ruby-refactoring.

I've implemented 5 refactorings
 - Extract to Method  (C-c C-r e)
 - Extract Local Variable  (C-c C-r v)
 - Extract Constant  (C-c C-r c)
 - Add Parameter  (C-c C-r p)
 - Extract to Let  (C-c C-r l)

# Install
To install manually, add ruby-refactor.el to your load path, then:

```lisp
(require 'ruby-refactor)
```

Alternatively, simply install the `ruby-refactor` package from
Marmalade or [MELPA](http://melpa.milkbox.net).

In both cases, you must enable `ruby-refactor-minor-mode` in `ruby-mode`:

```lisp
(add-hook 'ruby-mode-hook 'ruby-refactor-mode-launch)
```

# Usage

## Extract to Method:
Select a region of text and invoke `ruby-refactor-extract-to-method`.
You'll be prompted for a method name. The method will be created
above the method you are in with the method contents being the
selected region. The region will be replaced with a call to method.

## Extract Local Variable:
Select a region o text and invoke `ruby-refactor-extract-local-variable`.
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
as it will use it by default. There is a custom variable to set
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


## TODO
From the vim plugin, these remain to be done (I don't plan to do them all.)
 - remove inline temp (sexy!)
 - convert post conditional


# License
Copyright (C) 2013 Andrew J Vargo

Author: Andrew J Vargo <ajvargo@computer.org>

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
