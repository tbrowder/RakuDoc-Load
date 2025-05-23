unit module RakuDoc::Load;

use X::RakuDoc::Load::SourceErrors;

use MONKEY-SEE-NO-EVAL;
use File::Temp; # For tempdir below

#| The string here should be valid RakuDoc markup, without the
#| enclosing stuff
sub load-rakudoc( Str $string ) is export {
    return load(qq:to/EOP/);
=begin pod
$string
=end pod
EOP
}
# add an alias for the old 'load-pod' routine
constant &load-pod is export(:DEFAULT) = &load-rakudoc;

#| Loads a Raku code string, returns the RakuDoc that could be
#| included in it
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
