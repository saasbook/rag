# RedCard

[![Build Status](https://travis-ci.org/brixen/redcard.png?branch=master)](https://travis-ci.org/brixen/redcard)

RedCard provides a standard way to ensure that the running Ruby implementation
matches the desired language version, implementation, and implementation
version.

NOTE: In this documentation, Ruby version specifies the version of the Ruby
programming language itself. Historically, the word "Ruby" could have applied
to the language or the original implementation of the language. We refer to
the original implementation as MRI or Matz's Ruby Implementation. RedCard
distinguishes between Ruby language versions, Ruby implementations, and
implementation versions.


## Be Liberal

RedCard provides an API for specifying multiple implementations and versions.
There are two aspects of this API.

The first one, `RedCard.verify`, will raise an exception if the requirements
are not satisfied.

The parameter, requirements, is an Array of Symbols or Strings with an
optional final Hash of implementations as keys and implementation versions as
values.

```ruby
RedCard.verify *requirements
```

The following examples illustrate `RedCard.verify`:

```ruby
# Requires any version JRuby or Rubinius
RedCard.verify :rubinius, :jruby

# Requires Ruby language 1.9 and MRI or Rubinius
RedCard.verify :mri, :rubinius, "1.9"

# Requires Ruby language 1.9.3 or 2.0
RedCard.verify "1.9.3", "2.0"

# Requires Ruby language 1.9 and Rubinius version 2.0
RedCard.verify "1.9", :rubinius => "2.0"
```

The second one, `RedCard.check` will return `true` if the requirements are
satisfied and `false` if they are not. The requirements parameter has the same
specification as for `RedCard.verify`.

```ruby
RedCard.check *requirements
```

The following examples illustrate `RedCard.check`:

```ruby
if RedCard.check :rubinius
  # Use Rubinius-specific features
end

if RedCard.check :mri, :rubinius, "1.9"
  # Use Ruby language 1.9 features on MRI or Rubinius
end

if RedCard.check "1.9.3", "2.0"
  # Use Ruby language features found in 1.9.3 or 2.0
end

if RedCard.check "1.9", :rubinius => "2.0"
  # Use Ruby language 1.9 features on Rubinius version 2.0
end
```

## Be Conservative

RedCard provides some convenience files that define restrictive requirements.
Using these, you can easily restrict the application to a single language
version, implementation, and implementation version.

Requiring the file runs `RedCard.check` with certain parameters matching the
specification described by the required files.

The following examples illustrate this:

```ruby
# Requires at minimum Ruby version 1.9 but accepts anything greater
require 'redcard/1.9'

# Requires Rubinius 2.0
require 'redcard/rubinius/2.0'

# Requires Ruby 1.9 and Rubinius
require 'redcard/1.9'
require 'redcard/rubinius'
```

## Why Do We Need It?

Once upon a time, Ruby was a very simple universe. There was a single Ruby
implementation and a single stable version. Now there are multiple current
language versions, multiple implementations, and numerous versions of those
multiple implementations.

In an ideal world, every Ruby implementation would provide the same features
and all such features would have consistent behavior. In the real world, this
is not the case. Hence, the need arises to have some facility for restricting
the conditions under which an application or library runs. RedCard provides
various mechanisms for specifying what language version, implementation, and
implementation version are required without resorting to horrific hacks such
as `if RUBY_VERSION =~ /^1\.8/`.
