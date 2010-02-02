#!/usr/bin/perl
use Image::Size; ## Set this to 0 if you don’t want this program to do anything
use File::Compare;
use File::stat;
$go = 1;

## Desktop background changer for GNOME
## By Anders Østhus (grapz666+perl@gmail.com)
## 27-04-2008
##
## You are free to use and spread this code as you like
## If you are spreading this code, or hacking on it for your own use
## I would appreciate an e-mail about it, just so I know that someone
## is actually useing it for something.
##
## Usage: ./wallpaper.pl /path/to/wallpapers/

if ($go eq 0) {
  exit();
}

## Some variable declarations
@files = ();
$dir = "";
$dir = @ARGV[0];
$previmg = "";
$wall = "";

## If you want a different background color, you can chage it here.
$bgcolor1 = "#000000";
$bgcolor2 = "#000000";

## Get the current image
$previmg = `gconftool -g /desktop/gnome/background/picture_filename`;

opendir(BIN, $dir) or die "Can’t open $dir: $!";

while( defined ($file = readdir BIN) ) {
  if ( $file eq "..") {
  } elsif ( $file eq ".") {
  } elsif ( $file eq "Thumbs.db") {
  } else {
    push(@files, $file);
  }
}

## Find out what resolution we are running…
## Current resolution ends up in $tmpres[3]
$res = `/usr/bin/xrandr | grep '*'`;
@tmpres = split(/ /, $res);
@subres = split(/x/, $tmpres[3]);

## As long as the selected image is the same as the previous image
## we select a new one
WALL:
$wall = $dir . @files[&getRand];
## I had to use stat on $previmg to make compare work...
$tmp = (stat(chomp($previmg)))[7];

if (compare($wall, $previmg) == 0) {
  print "Yo\n";
  goto WALL;
}

## Get the resolution of the image
my ($size_x, $size_y) = Image::Size::imgsize($wall);

## If the image is the same resolution as the desktop, set it centered
## If the image is smaller than the desktop, we keep it centered
## If the image is larger than the desktop, we set it to scaled

if ($subres[0] > $size_x || $subres[1] > $size_y) {
  $cent = "centered";
}
if ($subres[0] < $size_x || $subres[1] < $size_y) {
  $cent = "scaled";
}
if ($subres[0] eq $size_x && $subres[1] eq $size_y) {
  $cent = "centered";
}

## Sets the background image
$cmd = `gconftool -s /desktop/gnome/background/picture_filename "$wall" -t string`;
print "Setting ", $wall, "\n";

## Sets scaling option and background color(s).
## Also sets ‘draw_background’ to ‘1′, incase something has turned it off.
$cmd2 = `gconftool -s /desktop/gnome/background/picture_options $cent -t string`;
$cmd3 = `gconftool -s /desktop/gnome/background/primary_color $bgcolor1 -t string`;
$cmd4 = `gconftool -s /desktop/gnome/background/secondary_color $bgcolor2 -t string`;
$cmd5 = `gconftool -s /desktop/gnome/background/draw_background 1 -t bool`;

closedir(BIN);

## The function that returns a random image from the image array
sub getRand {
  my $range = scalar(@files);
  return int(rand($range));
}
