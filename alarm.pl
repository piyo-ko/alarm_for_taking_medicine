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
    # (なお、in_unitsだと「何ヶ月と何日間」の「何日間」しか返さないので、
    #  delta_daysを使うことにする。だが、delta_daysは二つの日付の差の絶対値を
    #  日数で表すので、常に0以上を返す。正負の判定には使えない。そのため、
    #  $duration と $days_passed の両方を使うことにする。なんだか冗長である。
    #  何かもっと良い方法がありそうな気もするが、とりあえずこうしておく。)

    #my $duration = $today - $init_date;
    my $duration = $today->subtract_datetime($init_date);
    my $days_passed = $today->delta_days($init_date)->in_units('days');
    #print "[*debugging...] \$days_passed = $days_passed\n";
    if ($duration->is_negative()) {
      print "  ⚠️ $name_of_drug\の開始日が未来になっているので、修正してね\n";
      next;
    }
    #my $days_passed = $duration->in_units('days');

    # 本日開始時点での残量を計算する。
    my $remainder;
    if ($interval == 1) { # 毎日飲む薬
      $remainder = $init_amount - $dose * $freq_per_day * $days_passed;
    } elsif ($interval > 1) { # $interval 日に1回、服用する日がやってくる薬
      my $num_of_days_where_drug_taken = int(($days_passed + $interval - 1) / $interval);
      $remainder = $init_amount - $dose * $freq_per_day * $num_of_days_where_drug_taken;
      #print "[debugging...] \$today = $today\n";
      #print "[debugging...] \$init_date = $init_date\n";
      #print "[debugging...] \$duration = $duration\n";
      #print "[debugging...] \$days_passed = $days_passed\n";
      #print "[debugging...] \$num_of_days_where_drug_taken = $num_of_days_where_drug_taken\n";
      #print "[debugging...] \$interval = $interval\n";
      #print "[debugging...] \$remainder = $remainder\n";
      #print "[debugging...] \$init_amount = $init_amount\n";
      #print "[debugging...] \$dose = $dose\n";
      #print "[debugging...] \$freq_per_day = $freq_per_day\n";
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
      if ($remainder > 1) { # 今回飲んでもまだ残りがある
        print "  💊 ";
      } elsif ($remainder == 1) { # 今回飲むと残量が0になる
        print "  🏥 ";
      } else { # すでに在庫切れになっている
        print "  😱 ";
      }
      print "$name_of_drug [$f\回目]: 残り数量 $remainder → ";
      $remainder -= $dose;
      print "$remainder\n";
    }

  } # それ以外の形式の場合はコメント行とみなして何もしない。
}

close($in_fh);

