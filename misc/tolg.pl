#!/usr/bin/env perl

use v5.22;

sub luat_str {
     my $PREFIX = "Production { ";
     my $SUFIX  = " }";

     my ($id, @l) = @_;

     my $prdc_id = "[\"id\"] = \"${id}\"";

     my $rhsp_elist = "[\"rhs\"] = { ";
     for my $p (@l) { $rhsp_elist .= "\"${p}\", "; }

     $rhsp_elist .= "}";

     return sprintf "%s%s, %s%s", $PREFIX, $prdc_id, $rhsp_elist, $SUFIX;
}

while (my $line = <STDIN>) {
     chomp $line;

     # ignoring comments and enpty lines
     next if ($line =~ /\(\*/ || !$line);

     $line =~ s/[ ;']//g; # remove white spaces and semicolumn (end line)

     my ($lhs, @rhs) = split /[\=\,]/, $line;

     say &luat_str($lhs, @rhs);
}
