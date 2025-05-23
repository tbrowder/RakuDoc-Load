[![Actions Status](https://github.com/tbrowder/RakuDoc-Load/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/RakuDoc-Load/actions) [![Actions Status](https://github.com/tbrowder/RakuDoc-Load/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/RakuDoc-Load/actions) [![Actions Status](https://github.com/tbrowder/RakuDoc-Load/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/RakuDoc-Load/actions)

NAME
====



**RakuDoc::Load** - Loads and compiles the RakuDoc documentation of an external file or a string

This is a drop-in replacement for the existing 'Pod::Load' but it will be updated as Raku's handling of RakuDoc changes.

**Note**: As of this release, Raku cannot handle '=begin/= rakudoc' document delimiters.

**Limitations**:

  * Pod::* remains the only official RakuDoc node type recognized by Raku and is **not** used herein

  * Newer terms for Rakudoc V2 classes and methods are **not** yet recognized by Raku and not used herein

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
sub load-rakudoc(
    Str $string-with-rakudoc # without =begin/=end pod
) returns Mu
```

Loads a string with RakuDoc, returns a RakuDoc object.

**Note** the routine name **load-rakudoc** is the only non-multi routine and it does **not** require the enclosing =begin/=end pod statements. If you do add them, you will probably get bad results because those statements are not supposed to be legal since RakuDoc is not designed to be embedded inside RakuDoc.

Note also you can still use 'load-pod' which is now an alias for 'load-pod'.

Credits
=======



The utility of this entire module is due to the work of my Raku mentor and friend, Dr. Juan J. Merelo (aka @JJ). With his permission and encouragement, I started with a copy of his 'Pod::Load:ver<0.7.2>', fixed one small documentation error, and then made the following changes:

    - Revamped the structure to enable the module to be managed by App::Mi6 ('mi6')
    - Changed to mi6 format
      + removed .appveyor.yml file
      + removed 00-meta.t which was failing on Windows
      + removed .github/workflows/test.yaml file
      + added .github/workflows/*.yml files, one for each OS:
          linux, macos, windows
      + added docs directory
      + converted old README.md to rakudoc format in docs/README.rakudoc
      + added dist.ini file with settings to rebuild
          the README.md with cmd: mi6 build; automatic with cmd: mi6 release
    - Changed all .p6 to .raku, perl6 to raku, .pm6 to .rakumod, and
          .pod6 to .rakudoc
    - Tweaked docs
      + removed the example with the HEREDOC (<<EOP) which doesn't seem to
          work
      + added missing description of sub load-pod
    - Added new test 4
      + ensure =begin/=end rakudoc works like =begin/=end pod
        This module can load such pod okay, but Raku cannot yet handle it.
    - Added bad-test/5-rakudo-rakudoc.rakutest for future use when Raku can
        handle =begin/=end rakudoc delimeters.
    - Removed test dependency on Test::META
    - Removed ./resources/examples directory

This module should continue to be useful during the transition from RakuDoc V1 to RakuDoc V2, and I am grateful to JJ for it.

AUTHOR
======



Tom Browder

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Tom Browder (tbrowder@acm.org)

This library is free software; you may redistribute or modify it under the Artistic License 2.0.

