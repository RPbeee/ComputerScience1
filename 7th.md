# コンピュータサイエンス第七回課題解答解説

## 今回のポイント
- 実行時間の計測(`time.perf_counter()`)とランダムなワークロードの作成
- ソートアルゴリズムの比較(選択・挿入・バブル・ヒープ・クイック・マージ・組み込み)
- 両対数グラフの読み方:傾きが$n$に対する増え方(計算量)を表す
- 観察結果をまとめるレポート(`observations.pdf`)の書き方

## 各問の解答解説
今回は、ノートブックを順に実行して実験を行い、グラフを分析して提出する課題です。必須のコードを書く部分はなく、ボーナス(`bubblesort`、`heapsort`、`selection_sort`の追加)でコードを書きます。提出物は`ipynb`、`sort_comparison_log_log.pdf`、`observations.pdf`の3つです。

### 実験の流れ
1. 冒頭の`my_student_ID`を自分の学籍番号に書き換える(グラフのタイトルに入ります)。
2. 上から順にセルを実行する。`create_random_list`、`timed_sort`、各ソート関数が定義され、実行時間が`runtime_data.csv`に保存される。
3. グラフのセルを実行すると、`sort_comparison_log_log.pdf`が作られる。
4. グラフを見て、`observations.pdf`を書く。
5. 「編集」→「出力をすべて消去」をしてから`ipynb`をダウンロードして提出する。

**細かい解説**
`timed_sort`は、データのコピーを作ってからソート関数を呼び、`perf_counter()`の差を実行時間(ms)として返します。ソート後に`sorted(data)`と比べ、結果が正しくなければエラーにします。
ワークロードは、すべてのアルゴリズムで同じリストを使い、公平に比較します。ソート関数の中の`data[:]`も、入力を書き換えないためのコピーです。

### ボーナス:ソート関数の追加
```python
from heapq import heappush, heappop, heapify

def heapsort(data):
    output = data[:]
    heapify(output)
    return [heappop(output) for _ in range(len(output))]


def bubblesort(data):
    output = data[:]
    n = len(output)
    for k in range(n-1, 0, -1):
        swapped = False
        for i in range(k):
            if output[i] > output[i+1]:
                output[i], output[i+1] = output[i+1], output[i]
                swapped = True
        if not swapped:
            break
    return output


def selection_sort(data):
    output = data[:]
    for i in range(len(output)):
        min_index = i
        for j in range(i+1, len(output)):
            if output[j] < output[min_index]:
                min_index = j
        output[i], output[min_index] = output[min_index], output[i]
    return output
```

これらを追加したら、`ALGORITHMS`の定義でコメントアウトされている3行(`Selection sort`、`Bubble sort`、`Heapsort`)のコメントを外して、全セルを再実行します。

`heapsort`は、第六回の`heapsort`と同じ考え方です。`data`のコピー`output`を`heapify`でヒープにして、`heappop`で最小値を1つずつ取り出して並べます。コピーを使うので、入力は書き換わりません(第六回と違い、`output`を使い切る形です)。計算量は$O(n \log n)$です。
`bubblesort`は、第六回の解答と同じです。隣り合う要素を比べて交換する1回のパスで最大値を右端に運び、それを繰り返します。`swapped`で、交換が1度もなければ整列済みとして終了します。最悪の計算量は$O(n^2)$ですが、最初から整列済みなら$O(n)$です(ランダムなリストでは効きません)。
`selection_sort`(選択ソート)は、まだ整列していない部分から最小値の位置`min_index`を探し、それを先頭`i`番目の要素と交換する、という操作を繰り返します。`i`番目までが確定していくので、比較は常に約$n^2/2$回で、計算量は入力によらず$O(n^2)$です。

**細かい解説**
`selection_sort`の流れを`[3, 1, 2]`で追ってみましょう。

```text
i=0  最小は1(位置1)  3と交換  [1, 3, 2]
i=1  最小は2(位置2)  3と交換  [1, 2, 3]
i=2  残りは3だけ              [1, 2, 3]
```

交換は多くても`n-1`回ですが、最小値を探す比較はどの入力でも同じ回数かかります。

####注.
ボーナスの点数は、`bubblesort`(+5点)、`heapsort`(+5点)、`selection_sort`(+10点)です。ただし、ソートの結果が正しくないと`timed_sort`がエラーになるので、追加した関数は必ずテストしてください。

### グラフの読み方と分析のヒント
`sort_comparison_log_log.pdf`は両対数グラフです。縦軸と横軸の1目盛りが10倍を表すので、折れ線の__傾き__が計算量に対応します。点線の$O(n)$、$O(n\log n)$、$O(n^2)$と比べて、傾きが近いものを探します。

実行する環境によって数字は変わりますが、次のような結果になるのが一般的です(例:$n=1280$の中央値)。

```text
Builtin sort    約 0.07 ms      (最速)
Heapsort        約 0.15 ms
Quicksort       約 0.6  ms
Merge sort      約 0.9  ms
Insertion sort  約 11   ms      傾き 約2  → O(n^2)
Selection sort  約 11   ms      傾き 約2  → O(n^2)
Bubble sort     約 20   ms      傾き 約2  → O(n^2)
```

**細かい解説**
グラフから言えることには、次のようなものがあります。

- 選択・挿入・バブルソートは傾きが約2で$O(n^2)$に平行、ヒープ・クイック・マージ・組み込みは$O(n\log n)$に近い。
- バブルソートは、挿入・選択ソートより遅い(交換が多いため)。
- ヒープソートは、純Pythonのクイック・マージより速いことが多い。これは`heapq`がC言語で実装されているためで、アルゴリズムそのものではなく実装の違いも含んだ比較になっている。
- 組み込みの`sorted`は、他より桁違いに速い(C言語で実装された、整列済みの部分を活用するアルゴリズムのため)。
- 入力が小さい($n$が10〜20)ときは、アルゴリズムの差が小さい。

ノートブックの「解析」セルにある例文の「builtinは他のどのアルゴリズムよりも少なくとも10倍は速い」は、ヒープソートを追加すると当てはまらないことがあります(上の例では約2倍の差)。例文を写さず、自分のデータを見て確かめましょう。

### observations.pdf の書き方
条件は、__1ページ__、簡潔な箇条書き、タイトル・学籍番号・氏名を明記することです。内容は、次のように構成するとまとめやすくなります。

- **観察:**グラフから読み取れる事実(傾き、グループ分け、倍率、小さい入力での差)を、数字を添えて書く。
- **考察:**なぜそうなるかを書く(例:$O(n^2)$と$O(n\log n)$の違い、`heapq`がC実装であること)。
- **限界:**データ量(最大$n$、繰り返し回数)、入力の種類(ランダムのみ)、測定誤差など。

####注.
グラフのPDFに表示される学籍番号は、冒頭の`my_student_ID`から入ります。書き換えを忘れると、別の学籍番号のグラフを提出することになるので気をつけましょう。
