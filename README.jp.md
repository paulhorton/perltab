# perltab -- Manipulate data in tabular form from the command line in a perl one-liner style.


## 使い始める
`% perltab -h`

## 回帰テスト
`% perl t/perltabCommandsOutputMatchExpected.t`


### 注意点
linux、Perlバージョンv5.18.2以外の環境での動作確認は行われていない。


### 使用例
* 身長と体重の列を表示する。
`% perltab -e 'say F(qw(height weight))'  heightWeight.tsv`

* 又は、qw()の省略し、perltabにそれを自動的に付け加えてもらう(-h qw を参照)。
`% perltab -e 'say F(height weight)'  heightWeight.tsv`

* 又は、更に短く、
`% perltab -e 'say F(hei wei)'  heightWeight.tsv`

* 列ラベルは一意的に決まる限り、ラベルの前置詞で略しても良い(-h labelを参照)。ここでは'h'と'w'から始まる列ラベルはそれぞれ'height'と'weight'のみと仮定した。
`% perltab -e 'say F(h w)'`

* 最初と最後の列を交換する。
`% perltab -pe 'swap 0, -1'  input.tsv`

* 列の交換には@Fを直接扱う、(より効率的な)方法もある。
`% perltab -e 'say  @F[-1, 1..$#F-1, 0]'  input.tsv`

* heightとweightの列を交換する。
`% perltab -pe 'swap qw(height weight)'  heightWeight.tsv`

* ラベルで指定した列の交換には%Nを利用して@Fを直接扱う、(より効率的な)方法もある。
`% perltab -pe '@I= N(height weight); @F[@I]= @F[reverse @I]'  heightWeight.tsv`

* 列IDを列weightの後に移動する。
`% perltab -pe 'movaft qw(weight ID)'  heightWeight.tsv`

* 手動で列IDを列weightの後に移動する。入力におけるIDがweightの前に来る前提の場合。
`% perltab -e '($x,$y)= N(D weight);  say @F[0..$x-1,$x+1..$y,$x,$y+1..$#F]'   heightWeight.tsv`

* c,d,eのいづれかから始まるラベルを削除する。
`% perltab -pe 'del grep /^[cde]/, @H'  animals.tsv`

* 欠損値(空文字列)を含むデータ行を飛ばしながら入力ファイルを表示する。
`% perltab -e 'speak @F'  heightWeight.tsv`

* 身長と体重の値がふたつとも記録してある行の体格指数"BMI"を表示する。
`% perltab -e '@V= nextNum F(height weight);  say 10000*$V[1]/$V[0]**2'   heightWeight.tsv`

* 欠損値(空文字列)を飛ばしながら、体格指数"BMI"の列をheightWeight.tsvの表に加える。
`% perltab -pe 'insAft "weight", "BMI"=>doNum{10000*$_[1]/$_**2} F(height weight)'  heightWeight.tsv`

* 列BMI中の数字の表示形式を変える。
`% perltab -pe 'reform "%.2f", F(BMI)'  heightWeightBMI.tsv`

* 列1,2のデータの内、両方が数値となっている行を表示する。
`% perltab -d 'donum {say @_} @F[1,2]'  heightWeight.tsv`

* タブ区切りファイルのラベルとその番号を表示する。
`% perltab -H 'say $_,$H[$_] for 0..$#H' input.tsv`

* 'height'という列を削除する。
`% perltab -pe 'del "height"' heightWeight.tsv`

* または、
`% perltab -e 'say F( grep {!/^height$/} @H )' heightWeight.tsv `

* heightWeight.tsvの内、IDリストにある行を抽出する。IDリストは、各行にひとつのIDという形式のファイルids.txtから読み込む。
`% perltab -b 'SNset %S, "ids.txt"'  -ge '$S{ F(ID)}'  heightWeight.tsv   > selected.tsv`

* ids.txtにあるIDの行を抽出した後、ids.txtと同じ順番に並べ替える。
`% perltab -b 'SNset %S, "ids.txt"' -s '$S{ F(ID) }' selected.tsv`

* 列'banana'の最小値を出力する。非数字の値(欠損値など)は静かに無視される。
`% perltab -e 'bemin $m, F(banana)' -z 'say $m'`

* 列'banana'にある数値が[0,1]の範囲に入るように線形正規化を行う。
`% perltab -p -e 'beminmax $min, $max, F(banana)'   -e2 'donum  sub{ $_= ($_-$min) / ($max-$min)}, F(banana)'   fruit.tsv`

* 'eight'を含む列ラベルを出力する。
`% perltab  -H 'say  grep /eight/, @H'`

* 数値でない値を持つ行を取り除く。
`% perltab -gd 'allnum @F'`

* 各列の平均値を出力する(非数値データはゼロとして扱われる)。
`% perltab  -d '$s[$_]+= num0 $F[$_] for 0..$#F'  -z 'say map {$_/(NR-1)} @s'`

* age.tsvとheightWeight.tsvの間の共通IDがage.tsvの中と同じ順番でheightWeight.tsvの先頭に来るようにheightWeight.tsvのデータ行を並べ替える。
`% perltab -e '$R{ F(ID)}= NR'  -s201U '$R{ F(ID)}'   age.tsv  -in2 heightWeight.tsv`

* 上記の例と同様であるが、共通IDをage.tsvを先頭ではなく、最後に移す。
`% perltab -e '$R{ F(ID)}= NR'  -s2U01 '$R{ F(ID)}'   age.tsv  -in2 heightWeight.tsv`

* age.tsvとheightWeight.tsvの間の共通IDがage.tsvの中と同じ順番でheightWeight.tsvの最後に来るようにheightWeight.tsvのデータ行を並べ替える。
`% perltab -e '$R{ F(ID)}= NR' -s201 '$R{ F(ID)}'  age.tsv  -in2 heightWeight.tsv`

* or one can use the default sort spec 'AB01NM'
`% perltab -e '$R{ F(ID)}= NR'  -s2 '$R{ F(ID)}'  age.tsv -in2 heightWeight.tsv`

* YYYYMMDD形式の入力ファイルに平成年度の列'FY'を追加する。
`% perltab -pe 'insaft qw(Date FY), sub{ ($y,$m)= unpack "a4a2", F(Date);  "H". (($m>3)+ $y-1989)}   YYYYMMDD.tsv`

* 行と列の転置。chopは行末のタブ文字を削除する。
`% perltab -e '$T[$_] .= "$F[$_]\t" for 0..$#F'   -z 'chop, say  for @T'  input.tsv`

* 各行の先頭に行番号の列を入れる。
`% perltab -e 'say NR,@F'  input.tsv`

* 最初の行を除き、行をラベルをABC順に並べ替える。-pではコメント行もそのまま表示される。
`% perltab -pe '@F= F($H[0], sort @H[1..$#H])'  fruit.tsv`

* 同上にラベルを並べ替えるが、コメント行は表示されない。
`% perltab -e 'say F($H[0], sort @H[1..$#H])'  fruit.tsv`

* ふたつの入力ファイルにあるデータから身長(height値)が最大の行を表示する。
`% perltab -d 'bemax $m, F(hei)' -gd2 'donum {$m==$_} F(hei)'  heightWeight.tsv more_heightWeight.tsv
          -in2 heightWeight.tsv more_heightWeight.tsv`

* もし欠損値がなければ、このコマンドでも良い、
`% perltab -d 'bemax $m, F(hei)' -gd2 '$m==F(hei)'  heightWeight.tsv more_heightWeight.tsv  -in2 heightWeight.tsv more_heightWeight.tsv`

### 開発者

Paul Horton.  Copyright 2016,2017.
