#!perl
use strict;
use warnings;
use Test::More tests => 11;

{
  package MyError;
  use Moose;
  extends 'Throwable::Error';
  no Moose;
}

sub throw_x {
  die MyError->new('foo bar baz');
}

sub call_throw_x {
  throw_x;
}

warn MyError->new({ message => 'm' });

eval { call_throw_x; };

my $error = $@;

isa_ok($error, 'MyError',          'the error');
isa_ok($error, 'Throwable::Error', 'the error');
is($error->message, q{foo bar baz}, "error message is correct");

my $trace = $error->stack_trace;

isa_ok($trace, 'Devel::StackTrace', 'the trace');

my @frames = $trace->frames;
is(@frames, 4, "we have four frames in our trace");
is($frames[0]->subroutine, q{Throwable::throw},   'correct frame 0');
is($frames[1]->subroutine, q{main::throw_x},      'correct frame 1');
is($frames[2]->subroutine, q{main::call_throw_x}, 'correct frame 2');
is($frames[3]->subroutine, q{(eval)},             'correct frame 3');

{
   eval { MyError->throw('shucks howdy'); };

   my $error = $@;
   isa_ok($error, 'MyError', 'the error');
   is($error->message, q{shucks howdy}, "error message is correct");
}
