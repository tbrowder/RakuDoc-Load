#| Exception representing errors in the source of any kind
unit class X::RakuDoc::Load::SourceErrors is Exception;

has $.error;
method message { $!error }
