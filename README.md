# 💊残薬量の確認💊

## 何をするの?
慢性の持病があると長期にわたって薬を飲み続けることになるわけですが、服薬が無意識のルーチンと化すあまり、 __飲んだか飲んでいないかの記憶がなくて不安__ になったりすることもあります。もちろん、「朝食後・昼食後・夕食後・就寝前」のように区切られた箱に、それぞれの時点で飲むべき薬を前夜のうちに入れておくことで飲み忘れを防ぐ、という方法も世の中にはありますが、そういう方法が合わないと感じる人もいるでしょう。

というわけで、自分にとっての必要性から、 __「飲み忘れていなければ残量が幾つになっているはずか」の表示__ をしてくれるスクリプトを作りました。不安になったら即実行。表示された数と残量を比較して、ずれがあれば、(飲み忘れに気づき次第すぐ飲むべき薬なら) すぐ飲むようにしています。時々飲み忘れるくらいなら放置しても構わないという薬なら、ずれには設定ファイルの修正で対応します。

飲み忘れの不安がなくても、とりあえず1日に何回か実行しておくと安心です。

なお、スクリプトのファイル名は `alarm.pl` ですが、考えてみたら、あまり警告っぽくない処理ですね。あえて言えば、自分に対する警告のために実行するといいかもよ、という感じでしょうか。

## どうやって使うの?
1. サンプル (`sample.txt`) を参考にして、自分に合わせた設定ファイル (`alarm_data.txt`) を作成してください。設定ファイルのファイル名は固定です。
2. Perlスクリプト (`alarm.pl`) と設定ファイルを同じディレクトリに置いてください。スクリプトには実行権限を与えておくと便利です。
3. 飲み忘れが不安になったりした場合などに、スクリプトを実行してください。たとえば `~/Documents/foo/bar/` にスクリプトがある場合、`~/.bashrc` に
````
alias kusuri='~/Documents/foo/bar/alarm.pl
````
などと設定しておくと、`kusuri` と打つだけですぐ実行できて便利です (頭の悪そうなエイリアスですみません)。
4. 薬が処方されたときや、飲み忘れにより残量が狂ったときなどには、適宜設定ファイルを修正してください。

## どんな感じの出力になるの?
サンプル (`sample.txt`) のように設定して、8月1日と2日に飲み忘れがなければ、8月3日の実行結果が以下のようになります。絵文字は単なる趣味です。ちょっと可愛くしてみました。

````
🍄 ✨ 本日 (2017年8月3日) のお薬についてお知らせしますよ ✨ 🍄
  💊 ほげほげ錠 [1回目]: 残り数量 51 → 50
  💊 ほげほげ錠 [2回目]: 残り数量 50 → 49
  🙊 今日はふがふが錠を服用する日ではありません (残り数量 13)
````

## ちなみに……
* 目薬や点鼻薬など、残量を個数として数えられないような薬については、考慮外です。
* __うっかり自分の飲んでいる薬を大公開しちゃうといけない__ ので、`.gitignore` に `alarm_data.txt` と書いておきました。しかし、「いついつにこれこれの薬が処方された」「いついつにこれこれの薬を飲み忘れたので設定ファイルを修正した」といった事実のログを取っておきたいという場合は、`alarm_data.txt` と書いてある行を `.gitignore` から削除する、という手もあります。

以上