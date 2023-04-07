# perltab -- Manipulate data in tabular form from the command line in a perl one-liner style.


## 始めに
`% perltab -h`

## 回帰テスト
`% perl t/perltabCommandsOutputMatchExpected.t`


## 概要

perltabはテーブルデータ処理の利便性を高めるperl autosplitモードの拡張と考えることができる。私がperltabを開発した切っ掛けは欠損値を含む列数がそこそこあったバイオインフォマティクスのデータセットを分析していたことで、欠損値があると従来のコマンド行ツールで扱いにくいと感じたからである。perl autosplitモードでｎ番目の列は簡単に表示できる。

`% perl -F'\t' -anE 'say $F[1]'   heightWeight.tsv`

perltabではそれはもう少し楽になる。<BR>
`% perltab -e 'say $F[1]'  heightWeight.tsv`

更に列の番号ではなくラベルも(略しても)使える。<BR>
`% perltab -e 'say F(hei)'  heightWeight.tsv`

こういうのは便利であるが、perltabの利便性が本当に力を発揮するのは欠損値が関わってくる場合。

例えば、列の最小値は以下のコマンドで表示できる。<BR>
`% perltab  -d 'bemin $m, F(hei)'  -z 'say $m'`<BR>
-dオプションのスクリプトは列名のある最初の行に飛ばし、データ行のみに対して実行される。-zオプションのスクリプトは最後に１回実行される。

(列名が数値に見えなければ、以下のコマンドでも可)<BR>
`% perltab  -e 'bemin $m, F(hei)'  -z 'say $m'`


perltabを使わずにこれをコマンド行で行おうと思うと相当に長いコマンドを打たなければならないでしょう。欠損値を飛ばす必要もあるし、初期値を考える必要もある（例えば負数があればゼロは最小値の下限にならない）。perltabはこのような処理がより便利にできるいくつかの関数を提供している。


`% perltab -h`で表示できるperltabのマニュアルには50個程度の使用例を載せている。また、この使用例は回帰テストにも含まれている。


### 注意点
linux、Perlバージョンv5.18.2以外の環境での動作確認は行われていない。


### 使用例
* 身長と体重の列を表示する。<BR>
`% perltab -e 'say F(qw(height weight))'  heightWeight.tsv`

* 又は、qw()の省略し、perltabにそれを自動的に付け加えてもらう(-h qw を参照)。<BR>
`% perltab -e 'say F(height weight)'  heightWeight.tsv`

* 又は、更に短く、<BR>
`% perltab -e 'say F(hei wei)'  heightWeight.tsv`

* 列ラベルは一意的に決まる限り、ラベルの前置詞で略しても良い(-h labelを参照)。ここでは'h'と'w'から始まる列ラベルはそれぞれ'height'と'weight'のみと仮定した。<BR>
`% perltab -e 'say F(h w)'`

* 最初と最後の列を交換する。<BR>
`% perltab -pe 'swap 0, -1'  input.tsv`

* 列の交換には@Fを直接扱う、(より効率的な)方法もある。<BR>
`% perltab -e 'say  @F[-1, 1..$#F-1, 0]'  input.tsv`

* heightとweightの列を交換する。<BR>
`% perltab -pe 'swap qw(height weight)'  heightWeight.tsv`

* ラベルで指定した列の交換には%Nを利用して@Fを直接扱う、(より効率的な)方法もある。<BR>
`% perltab -pe '@I= N(height weight); @F[@I]= @F[reverse @I]'  heightWeight.tsv`

* 列IDを列weightの後に移動する。<BR>
`% perltab -pe 'movaft qw(weight ID)'  heightWeight.tsv`

* 手動で列IDを列weightの後に移動する。入力におけるIDがweightの前に来る前提の場合。<BR>
`% perltab -e '($x,$y)= N(ID weight);  say @F[0..$x-1,$x+1..$y,$x,$y+1..$#F]'   heightWeight.tsv`

* c,d,eのいづれかから始まるラベルを削除する。<BR>
`% perltab -pe 'del grep /^[cde]/, @H'  animals.tsv`

* 欠損値(空文字列)を含むデータ行を飛ばしながら入力ファイルを表示する。<BR>
`% perltab -e 'speak @F'  heightWeight.tsv`

* 身長と体重の値がふたつとも記録してある行の体格指数"BMI"を表示する。<BR>
`% perltab -e '@V= nextNum F(height weight);  say 10000*$V[1]/$V[0]**2'   heightWeight.tsv`

* 欠損値(空文字列)を飛ばしながら、体格指数"BMI"の列をheightWeight.tsvの表に加える。<BR>
`% perltab -pe 'insAft "weight", "BMI"=>doNum{10000*$_[1]/$_**2} F(height weight)'  heightWeight.tsv`

* 列BMI中の数字の表示形式を変える。<BR>
`% perltab -pe 'reform "%.2f", F(BMI)'  heightWeightBMI.tsv`

* 列1,2のデータの内、両方が数値となっている行を表示する。<BR>
`% perltab -d 'donum {say @_} @F[1,2]'  heightWeight.tsv`

* タブ区切りファイルのラベルとその番号を表示する。<BR>
`% perltab -H 'say $_,$H[$_] for 0..$#H' input.tsv`

* 'height'という列を削除する。<BR>
`% perltab -pe 'del "height"' heightWeight.tsv`

* または、<BR>
`% perltab -e 'say F( grep {!/^height$/} @H )' heightWeight.tsv `

* heightWeight.tsvの内、IDリストにある行を抽出する。IDリストは、各行にひとつのIDという形式のファイルids.txtから読み込む。<BR>
`% perltab -b 'SNset %S, "ids.txt"'  -ge '$S{ F(ID)}'  heightWeight.tsv   > selected.tsv`

* ids.txtにあるIDの行を抽出した後、ids.txtと同じ順番に並べ替える。<BR>
`% perltab -b 'SNset %S, "ids.txt"' -s '$S{ F(ID) }' selected.tsv`

* 列'banana'の最小値を出力する。非数字の値(欠損値など)は静かに無視される。<BR>
`% perltab -e 'bemin $m, F(banana)' -z 'say $m'`

* 列'banana'にある数値が[0,1]の範囲に入るように線形正規化を行う。<BR>
`% perltab -p -e 'beminmax $min, $max, F(banana)'   -e2 'donum  sub{ $_= ($_-$min) / ($max-$min)}, F(banana)'   fruit.tsv`

* 'eight'を含む列ラベルを出力する。<BR>
`% perltab  -H 'say  grep /eight/, @H'`

* 数値でない値を持つ行を取り除く。<BR>
`% perltab -gd 'allnum @F'`

* 各列の平均値を出力する(非数値データはゼロとして扱われる)。<BR>
`% perltab  -d '$s[$_]+= num0 $F[$_] for 0..$#F'  -z 'say map {$_/(NR-1)} @s'`

* age.tsvとheightWeight.tsvの間の共通IDがage.tsvの中と同じ順番でheightWeight.tsvの先頭に来るようにheightWeight.tsvのデータ行を並べ替える。<BR>
`% perltab -e '$R{ F(ID)}= NR'  -s201U '$R{ F(ID)}'   age.tsv  -in2 heightWeight.tsv`

* 上記の例と同様であるが、共通IDをage.tsvを先頭ではなく、最後に移す。<BR>
`% perltab -e '$R{ F(ID)}= NR'  -s2U01 '$R{ F(ID)}'   age.tsv  -in2 heightWeight.tsv`

* age.tsvとheightWeight.tsvの間の共通IDがage.tsvの中と同じ順番でheightWeight.tsvの最後に来るようにheightWeight.tsvのデータ行を並べ替える。<BR>
`% perltab -e '$R{ F(ID)}= NR' -s201 '$R{ F(ID)}'  age.tsv  -in2 heightWeight.tsv`

* or one can use the default sort spec 'AB01NM'.<BR>
`% perltab -e '$R{ F(ID)}= NR'  -s2 '$R{ F(ID)}'  age.tsv -in2 heightWeight.tsv`

* YYYYMMDD形式の入力ファイルに平成年度の列'FY'を追加する。<BR>
`% perltab -pe 'insaft qw(Date FY), sub{ ($y,$m)= unpack "a4a2", F(Date);  "H". (($m>3)+ $y-1989)}   YYYYMMDD.tsv`

* 行と列の転置。chopは行末のタブ文字を削除する。<BR>
`% perltab -e '$T[$_] .= "$F[$_]\t" for 0..$#F'   -z 'chop, say  for @T'  input.tsv`

* 各行の先頭に行番号の列を入れる。<BR>
`% perltab -e 'say NR,@F'  input.tsv`

* 最初の行を除き、行をラベルをABC順に並べ替える。-pではコメント行もそのまま表示される。<BR>
`% perltab -pe '@F= F($H[0], sort @H[1..$#H])'  fruit.tsv`

* 同上にラベルを並べ替えるが、コメント行は表示されない。<BR>
`% perltab -e 'say F($H[0], sort @H[1..$#H])'  fruit.tsv`

* ふたつの入力ファイルにあるデータから身長(height値)が最大の行を表示する。<BR>
`% perltab -d 'bemax $m, F(hei)' -gd2 'donum {$m==$_} F(hei)'  heightWeight.tsv more_heightWeight.tsv
          -in2 heightWeight.tsv more_heightWeight.tsv`

* もし欠損値がなければ、このコマンドでも良い、<BR>
`% perltab -d 'bemax $m, F(hei)' -gd2 '$m==F(hei)'  heightWeight.tsv more_heightWeight.tsv  -in2 heightWeight.tsv more_heightWeight.tsv`


### 関連ツール
fastapl


### 開発者
Paul Horton.  Copyright 2016,2017.
