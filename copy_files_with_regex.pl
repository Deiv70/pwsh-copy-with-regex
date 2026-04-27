#!/usr/bin/env perl
use strict;
use warnings;

use File::Find;
use File::Copy qw(copy);
use File::Path qw(make_path);
use File::Basename qw(dirname basename);
use POSIX qw(mktime);

my ($src, $dst, $regex, $only_print, $change_name, $no_nesting, $dates_from_regex) = @ARGV;

die "Usage: perl script.pl <src> <dst> <regex> <only_print> <change_name> <no_nesting> <dates_from_regex>\n"
  unless defined $dates_from_regex;

my $re = qr/$regex/i; # i -> case-insensitive

# Carpeta destino para media que NO coincide con regex
my $unmatched_dir = "$dst/_unmatched_media";

# Extensiones imagen/video aceptadas
my $media_re = qr/\.(?:jpe?g|png|mp4)$/i;

find({
    wanted => sub {
        return unless -f $_;

        my $full = $File::Find::name;
        my $name = basename($full);

        my $is_media      = ($name =~ $media_re);
        my $matches_regex = ($name =~ $re);
        my %captures = $matches_regex ? %+ : ();

        # Si no coincide con regex y tampoco es imagen/video, ignorar
        return unless $matches_regex || $is_media;
        print " File: '$name'\n";

        my $relative = $full;
        $relative =~ s/^\Q$src\E[\/\\]?//;

        if ($only_print eq "true") {
            print "$full\n";
            return;
        }

        my $dest_file;
        my ($year, $month, $day, $h, $m, $s);

        if ($matches_regex) {
            if ($dates_from_regex eq "true") {
                $year  = $captures{year};
                $month = $captures{month};
                $day   = $captures{day};

                $h = defined $captures{hours}   ? $captures{hours}   : ($captures{hours_wa}   // 0);
                $m = defined $captures{minutes} ? $captures{minutes} : ($captures{minutes_wa} // 0);
                $s = defined $captures{seconds} ? $captures{seconds} : 0;
            }

            if ($change_name eq "true") {
                my ($ext) = $name =~ /(\.[^.]+)$/;
                $ext //= "";

                $name = sprintf(
                    "%04d_%02d_%02d-%02d_%02d_%02d%s",
                    $year, $month, $day, $h, $m, $s, $ext
                );
            }

            # Los que coinciden: renombrados y SIN estructura de carpetas
            $dest_file = "$dst/$name";
        } elsif ($no_nesting eq "false") {
            # Imagen/video que NO coincide: conservar estructura en otra carpeta
            $dest_file = "$unmatched_dir/$relative";
        } else {
            # Imagen/video que NO coincide: sin estructura, en la raíz de unmatched
            $dest_file = "$unmatched_dir/$name";
        }

        make_path(dirname($dest_file));
        if (-e $dest_file) {
            print "  [SKIP]: '$dest_file'\n\n";
            return;
        }
        print "  [COPY]: '$dest_file'\n\n";
        copy($full, $dest_file) or die "Copy failed: $full -> $dest_file: $!";

        my @st = stat($full);
        my ($atime, $mtime) = ($st[8], $st[9]);

        if ($matches_regex && $dates_from_regex eq "true") {
            my $ts = mktime($s, $m, $h, $day, $month - 1, $year - 1900);
            $atime = $mtime = $ts;
        }

        utime($atime, $mtime, $dest_file);
    },
    no_chdir => 1
}, $src);
