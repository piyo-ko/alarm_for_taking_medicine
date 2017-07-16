#!/usr/local/bin/perl

# Usage: ./___.pl < ___ > ___

use strict;
use warnings;
use utf8;
use DateTime;
use FindBin;
binmode STDOUT, ":utf8";

my ($in_fh);
open($in_fh, "<:utf8", "$FindBin::Bin/alarm_data.txt") || die("Cannot open alarm_data.txt");

my $today = DateTime->today();
my $today_str = $today->year . '年' . $today->month .'月' . $today->day . '日';
print "🍄 ✨ 本日 ($today_str) のお薬についてお知らせしますよ ✨ 🍄\n";

while (<$in_fh>) {
  chomp;
  if (/^(\d\d\d\d)-(\d\d)-(\d\d)\t(\d+)\t(\d+)\t(.+)$/) {
    my ($year, $month, $day, $freq_per_day, $init_amount, $name_of_drug) = 
      ($1, $2, $3, $4, $5, $6);
    my $init_date = DateTime->new(year => $year, month => $month, day => $day);
    my $duration = $today - $init_date;
    if ($duration->is_negative()) {
      print "  ⚠️ $name_of_drug\の開始日が未来になっているので修正してね\n";
      next;
    }
    my $days_passed = $duration->in_units('days');
    my $remainder = $init_amount - $freq_per_day * $days_passed;
    for (my $f=1; $f <= $freq_per_day; $f++) {
      print "  💊 $name_of_drug [$f\回目]: 残り数量 $remainder → ";
      $remainder--;
      print "$remainder\n";
    }
  } # それ以外の場合はコメントとみなして何もしない。
}

close($in_fh);

