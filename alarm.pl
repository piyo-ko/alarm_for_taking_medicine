#!/usr/local/bin/perl

# Usage: perl alarm.pl
# (利用するデータファイルは、同じディレクトリにある alarm_data.txt だ、と決め打ちしている。)

use strict;
use warnings;
use utf8;
use DateTime;
use FindBin;
binmode STDOUT, ":utf8";

my ($in_fh);
open($in_fh, "<:utf8", "$FindBin::Bin/alarm_data.txt") || die("Cannot open alarm_data.txt");

my $today = DateTime->today( time_zone => 'Japan' );
my $today_str = $today->year . '年' . $today->month .'月' . $today->day . '日';
print "🍄 ✨ 本日 ($today_str) のお薬についてお知らせしますよ ✨ 🍄\n";

while (<$in_fh>) {
  chomp;
  if (/^(\d\d\d\d)-(\d\d)-(\d\d)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(.+)$/) {
    # データを1行読み取る。
    my ($year, $month, $day, $interval, $freq_per_day, $dose, $init_amount, $name_of_drug) = 
      ($1, $2, $3, $4, $5, $6, $7, $8);
    my $init_date = DateTime->new(year => $year, month => $month, day => $day, time_zone => 'Japan');

    # 本日までの経過日数を計算する。
    my $duration = $today - $init_date;
    if ($duration->is_negative()) {
      print "  ⚠️ $name_of_drug\の開始日が未来になっているので、修正してね\n";
      next;
    }
    my $days_passed = $duration->in_units('days');

    # 本日開始時点での残量を計算する。
    my $remainder;
    if ($interval == 1) { # 毎日飲む薬
      $remainder = $init_amount - $dose * $freq_per_day * $days_passed;
    } elsif ($interval > 1) { # $interval 日に1回、服用する日がやってくる薬
      my $num_of_days_where_drug_taken = int(($days_passed + $interval - 1) / $interval);
      $remainder = $init_amount - $dose * $freq_per_day * $num_of_days_where_drug_taken;
    } else {
      print "  ⚠️ $name_of_drug\の服用が何日に1回なのか、設定が変なので、修正してね\n";
      next;
    }

    # 今日はこの薬を飲む日か、調べる。
    if ($days_passed % $interval != 0) {
      print "  🙊 今日は$name_of_drug\を服用する日ではありません (残り数量 $remainder\)\n";
      next;
    }

    # 今日はこの薬を飲む日である、という場合。
    for (my $f=1; $f <= $freq_per_day; $f++) {
      print "  💊 $name_of_drug [$f\回目]: 残り数量 $remainder → ";
      $remainder -= $dose;
      print "$remainder\n";
    }

  } # それ以外の形式の場合はコメント行とみなして何もしない。
}

close($in_fh);

