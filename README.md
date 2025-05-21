[![Actions Status](https://github.com/tbrowder/RakuDoc-Load/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/RakuDoc-Load/actions) [![Actions Status](https://github.com/tbrowder/RakuDoc-Load/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/RakuDoc-Load/actions) [![Actions Status](https://github.com/tbrowder/RakuDoc-Load/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/RakuDoc-Load/actions)

NAME
====



**RakuDoc::Load** - Loads and compiles the RakuDoc documentation of an external file or a string

**Note**: As of this release, Raku cannot handle '=begin/= rakudoc' document delimiters.

SYNOPSIS
========



    use RakuDoc::Load;
    use X::RakuDoc::Load::SourceErrors;

    # Read a file handle.
    my $rakudoc = load("file-with.rakudoc".IO);
    say $rakudoc.raku; # Process it as a RakuDoc

    # Or simply use the file name
    my @rakudoc = load("file-with.rakudoc");
    say .raku for @rakudoc;

    # Or a string
    @rakudoc = load("=begin pod\nThis could be a comment with C<code>\n=end pod");

    # Or ditch the scaffolding and use the string directly:
    @rakudoc = load-rakudoc("This could be a comment with C<code>");

    # If there's an error, it will throw X::RakuDoc::Load::SourceErrors

DESCRIPTION
===========



RakuDoc::Load is a module with a simple task: obtain the documentation of an external file in a standard, straightforward way.

Its mechanism was originally inspired by [`Pod::To::BigPage`](https://github.com/perl6/perl6-pod-to-bigpage), from where the code to use the cache was taken.

### multi sub load

```raku
multi sub load(
    Str $string
) returns Mu
```

Loads a string, returns a RakuDoc object (`$=pod`).

### multi sub load

```raku
multi sub load(
    Str $file where { ... }
) returns Mu
```

If it's an actual filename, loads a file and returns the RakuDoc object.

### multi sub load

```raku
multi sub load(
    IO::Path $io
) returns Mu
```

Loads an IO::Path, returns a RakuDoc object.

### sub load-rakudoc

```raku
sub load-prakudoc(
    Str $string-with-rakudoc
) returns Mu
```

Loads a string with RakuDoc, returns a RakuDoc object.

Credits
=======



The utility of this entire module is the work of my Raku mentor and friend, Dr. Juan J. Merelo (aka @JJ). With his blessing, I started with a copy of his 'Pod::Load', fixed one small documentation error, and then made the following changes:

AUTHOR
======



Tom Browder 

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Tom Browder (tbrowder@acm.org)

This library is free software; you may redistribute or modify it under the Artistic License 2.0.

