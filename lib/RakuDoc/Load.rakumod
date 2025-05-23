unit module RakuDoc::Load;

use X::RakuDoc::Load::SourceErrors;

=begin pod

=head1 NAME

RakuDoc::Load - Loads and compiles the RakuDoc documentation from a string, file or
filehandle.

=head1 SYNOPSIS

    use RakuDoc::Load;

    # Read a file handle.
    my $rakudoc = load("file-with.rakudoc".IO);
    say $rakudoc.raku; # Process it as a RakuDoc

    # Or use simply the file name (it should exist)
    my @rakudoc = load("file-with.rakudoc");
    say .raku for @rakudoc;

    my $string-with-rakudoc = q:to/HERE/;
    =begin pod
    This ordinary paragraph introduces a code block:
    =end pod
    HERE

    say load( $string-with-rakudoc ).raku;

=head1 DESCRIPTION

C<RakuDoc::Load> is a module with a simple task (and interface):
obtaining the documentation tree of an external file in a standard,
straightforward way. Its mechanism (using EVAL) is inspired by
L<C<RakuDoc::To::BigPage>|https://github.com/perl6/perl6-pod-to-bigpage>,
although it will use precompilation in case of files.

=head1 CAVEATS

The pod is obtained from the file or string via EVAL. That means that
it's going to run what is actually there. If you don't want that to
happen, strip all runnable code from the string (or file) before
submitting it to C<load>.

=head1 Credits

The utility of this module is completely due to the work of my friend 
and Raku mentor, Juan Merelo (aka JJ). This module started with a copy
of his 'RakuDoc::Load:ver<0.7.2>'. I have always found it useful, and know
that it will continue to be useful in the foreseeable future.

But it needed a 'face lift' to modernize
the contents with respect to the major changes involved from the rename
of Perl 6 to Raku and the ensuing changes such as the renaming of RakuDoc to RakuDoc.

=head2 Major changes

Most of the user code is the same but with the following changes:

=item Change 'RakuDoc' to 'RakuDoc'
=item Change 'pod' to 'rakudoc' (with one **important** exception, see the next item)
=item Keep the current restriction with Raku to only accept =begin/=end pod delimiters inside RakuDoc files
=item Convert the repository qstructure to be managed by **App::Mi6**

=head1 AUTHOR
Tom Browder <tbrowder@acm.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2025 Tom Browder

This library is free software; you can redistribute it and/or modify
it under the Artistic License 2.0. 

=end pod

use MONKEY-SEE-NO-EVAL;
use File::Temp; # For tempdir below

#| The string here should be valid RakuDoc markup, without the enclosing stuff
sub load-rakudoc( Str $string ) is export {
    return load(qq:to/EOP/);
=begin pod
$string
=end pod
EOP
}
# add an alias for the old 'load-pod' routine
constant &load-pod is export(:DEFAULT) = &load-rakudoc;

#| Loads a Raku code string, returns the RakuDoc that could be included in it
multi sub load ( Str $string ) is export {
    my $module-name = "m{rand}";
    my $copy = $string;
    $module-name ~~ s/\.//;
    $copy ~~ s/"use" \s+ "v6;"//;
    my @pod;
    if $copy ~~ /^^"="output/ {
        my @chunks = $copy.split( /"="output/ );
        @pod = (EVAL ("module $module-name \{\n" ~ @chunks[0] ~ "\}\n\$=pod;\n\n=output@chunks[1]"));
    } else {
        @pod = (EVAL ("module $module-name \{\n" ~ $copy ~ "\n\}\n\$=pod"));
    }
    return @pod;
}

my constant CUPSFS = ::("CompUnit::PrecompilationStore::File" ~ ("System","").first({ ::("CompUnit::PrecompilationStore::File$_") !~~ Failure }));

#| If it's an actual filename, loads a file and returns the pod
multi sub load( Str $file where .IO.e ) {
    use nqp;
    my $cache-path = tempdir;
    my $precomp-repo = CompUnit::PrecompilationRepository::Default.new(
            :store(CUPSFS.new(:prefix($cache-path.IO))),
            );
    my $handle = $precomp-repo.try-load(
            CompUnit::PrecompilationDependency::File.new(
                    :src($file),
                    :id(CompUnit::PrecompilationId.new-from-string($file)),
                    :spec(CompUnit::DependencySpecification.new(:short-name($file))),
                    )
            );
    CATCH {
        default {
            X::RakuDoc::Load::SourceErrors.new(:error( .message.Str )).throw
        }
    }
    nqp::atkey($handle.unit, '$=pod')
}

#| Compiles a file from source
multi sub load ( IO::Path $io ) is export {
    load( $io.path )
}
