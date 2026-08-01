# DICOMLoader

[English](../README.md) | [日本語](README.md)

医用画像フォーマット **DICOM** を解析し、ファイル内の全データ要素をグリッドに一覧表示する Delphi/FireMonkey 製サンプルアプリケーション。解析は [LUX.DICOM](https://github.com/LUXOPHIA/LUX.DICOM) ライブラリ上に構築されており、そのタグ辞書は 4,200 種類以上の公式 DICOM 属性を網羅する。

![DICOMLoader のスクリーンショット](../--------/_SCREENSHOT/DICOMLoader.png)

## 利用ライブラリ

* [**LUX**](https://github.com/LUXOPHIA/LUX) ：ベクトル・行列などの基盤数学ライブラリ。
* [**LUX.DICOM**](https://github.com/LUXOPHIA/LUX.DICOM) ：DICOM 医用画像フォーマットの読み込みライブラリ。

## 1. 概要

* `*.dcm` ファイルをウィンドウへドラッグ＆ドロップすると解析が実行され、全データ要素（タグのグループ／要素番号・VR・値の長さ・値のテキスト表現・データ辞書に基づく属性名）が表示される。
* パーサ（`LUX.DICOM` の `TdcmFile`）は DICOM プリアンブルを検証し、各データ要素を生のバイト配列（`TdcmData.Buff`）として読み込み、明示的／暗黙的 VR 符号化を要素ごとに自動判別する。
* 各要素のバイト列は、紐付けられた「ポート」オブジェクト（`IdcmPort`）を介して解釈される。テキスト系 VR は文字列へ、バイナリ系 VR は数値レコード／配列へ、Pixel Data 要素 (7FE0,0010) はグループ 0028 の Image Pixel 属性から構成される 2 次元ピクセルアクセサへと復号される。
* タグ辞書（`TdcmBookTag`）は NEMA PS3.6 および PS3.7 のレジストリ [2][3] から生成されており、タグのグループごとに整理された 4,248 件のエントリを持つ。

### 1.1 制限事項

* バイトオーダーはリトルエンディアンを前提とする。Transfer Syntax UID (0002,0010) は表示されるが、デコーダの切り替えには使用されない。
* JPEG 系転送構文などのカプセル化（圧縮）された Pixel Data は生のバイト列として保持され、展開されない。
* ピクセルポートが対応する `Bits Allocated` は 8 ビットと 16 ビットのみ。Modality LUT や VOI ウィンドウ処理（2.3 節参照）は適用されない。

## 2. 技術的背景

### 2.1 DICOM ファイル構造

DICOM ファイル（PS3.10）は 128 バイトのプリアンブルと 4 バイトのマジックコード `DICM` で始まり、以降は「データ要素」の列が続く [1]。ローダはこのヘッダをパックレコード `TdcmHead` に対応付けている。

```
・DICOM ファイル（PS3.10）
  ┣・Preamble (128 bytes)
  ┣・"DICM"
  ┗・Data Element × N ･･･ Data Element, Data Element, …
```

`TdcmFile.LoadFromFile` は `DICM` プリフィックスをアサートしたのち、ファイル末尾までデータ要素を読み込み、タグをキーとする辞書へ格納する。

### 2.2 データ要素の符号化：タグ・VR・長さ

各データ要素は 4 バイトのタグ — 16 ビット数値の（グループ, 要素）ペアで、レコード `TdcmTag` としてモデル化される — で始まり、任意の値表現（VR）コードと値の長さが続く [1]。

```
・明示的 VR（短形式）
  ┗・Tag (4)
     ┗・VR (2)
        ┗・Length (2)
           ┗・Value (Length)

・明示的 VR（長形式）
  ┗・Tag (4)
     ┗・VR (2)
        ┗・Reserved (2)
           ┗・Len (4)
              ┗・Value (Length)

・暗黙的 VR
  ┗・Tag (4)
     ┗・Length (4)
        ┗・Value (Length)
```

* `TdcmBookVR.ReadStream` は 2 バイトを読み取り、31 種類の VR コードのレジストリ（PS3.5 の Table 6.2-1）と照合する。既知のコード（`AE`, `AS`, `AT`, `CS`, `DA`, `DS`, `DT`, `FL`, `FD`, `IS`, `LO`, `LT`, `OB`, `OD`, `OF`, `OL`, `OW`, `PN`, `SH`, `SL`, `SQ`, `SS`, `ST`, `TM`, `UC`, `UI`, `UL`, `UN`, `UR`, `US`, `UT`）に一致すれば明示的 VR、一致しなければストリームを巻き戻して暗黙的 VR（`vr00`）として扱う。
* 明示的 VR のうち短形式は 16 ビット長を持ち、長形式の VR（`OB OD OF OL OW SQ UC UN UR UT`）は 2 バイトの予約領域と 32 ビット長を挿入する。暗黙的 VR の長さは常に 32 ビットである（`TdcmData.ReadStream`）。
* 不定長 `0xFFFFFFFF`（シーケンスで使用、PS3.5 §7.5）は、[LUX](https://github.com/LUXOPHIA/LUX) ライブラリの `TSearchBM<Word>` による Boyer–Moore 探索で、長さ 0 の Sequence Delimitation Item `(FFFE,E0DD)` を検出して解決する。
* 値のバッファは、規格の要求どおり偶数バイトにパディングされる。
* 暗黙的 VR の要素については、タグが辞書上で唯一の候補 VR に対応する場合に、実効 VR（`TdcmData.RecVR`）が辞書から復元される。

### 2.3 ピクセルデータの解釈

Pixel Data 要素 (7FE0,0010) にアクセスすると、`TdcmData.MakePortImag` がグループ 0028 の Image Pixel Module 属性 — Photometric Interpretation (0028,0004)、Rows (0028,0010)、Columns (0028,0011)、Bits Allocated (0028,0100)、Bits Stored (0028,0101)、High Bit (0028,0102)、Pixel Representation (0028,0103) — を読み取り、Bits Allocated（8 または 16）と Pixel Representation（符号なし／あり）に応じて `TdcmPortImagU08 / S08 / U16 / S16` のいずれかを生成する。

格納された各サンプル $S$ は、$N$ = *Bits Allocated* ビットのコンテナ内で、ビット位置 $h$ = *High Bit* を上端とする $n$ = *Bits Stored* ビットを占める。ポートは 2 回のシフトで値 $V$ を抽出する。

```math
V \;=\; \bigl(\, S \ll (N-1-h) \,\bigr) \;\gg\; (N-n) \tag{1}
```

符号ありポートでは式 (1) の右シフトが算術シフトとなり、符号ビットが拡張される。光度解釈（`MONOCHROME1/2`, `PALETTE COLOR`, `RGB`, `YBR_*`）は列挙型 `TKindPixel` によって認識される。

規格はさらに Modality LUT — 例えば Rescale Slope (0028,1053) と Rescale Intercept (0028,1052) による線形変換 $HU = m\,SV + b$ — や、Window Center/Width (0028,1050/1051) による VOI ウィンドウ処理を定義している [1]。これらのタグは辞書に登録されているが、本ローダはこれらの変換を適用せず、格納値をそのまま表示する。

## 3. アーキテクチャ

### 3.1 クラス図

```
［処理の流れ］
・TForm1.OnDragDrop( *.dcm )
  ┗・TdcmFile.LoadFromFile
     ┗・ShowData

［所有関係］
・TForm1 (Main.pas)
  ┗・TdcmFile = TObjectDictionary<TdcmTag, TdcmData>
     ┣・TdcmHead              ･･･ 128 バイトのプリアンブル + "DICM"
     ┗・TdcmData（要素ごとに 1 つ）
        ┣・Tag :TdcmTag       ･･･ タグ辞書へのキー
        ┣・ExpVR :TKindVR     ･･･ VR レジストリへのキー
        ┣・Buff :TBytes       ･･･ 生の値バイト列
        ┗・Port :IdcmPort     ･･･ Buff の型付きビュー
           ┣・TdcmPortText<T> ･･･ AE AS CS DA DS DT IS LO LT PN SH ST TM …
           ┣・TdcmPort<T>     ･･･ AT FL FD SL SS UL US
           ┣・TdcmPort1D<T>   ･･･ OB OD OF OL OW UN SQ
           ┗・TdcmPortImag<T> ･･･ U08/S08/U16/S16 ← (7FE0,0010) Pixel Data

［参照：TdcmData.Tag → _BookTag_］
・_BookTag_ :TdcmBookTag       ･･･ タグ辞書
  ┗・TdcmGrup
     ┗・TdcmElem              ･･･ 名前 / VR / 説明

［参照：TdcmData.ExpVR → _BookVR_］
・_BookVR_ :TdcmBookVR         ･･･ VR レジストリ
  ┗・TdcmVR                   ･･･ コード / ヘッダ長
```

ポートは遅延生成され（`TdcmData.GetPort`）、`RecVR` — 明示的 VR があればそれ、なければ辞書に登録された唯一の VR — に基づいて選択される。

### 3.2 ファイル構成

```
・DICOMLoader/
  ┣・DICOMLoader.dpr           ･･･ プログラムエントリ（FireMonkey アプリ）
  ┣・DICOMLoader.dproj         ･･･ RAD Studio プロジェクト（Win32 / Win64）
  ┣・Main.pas / Main.fmx       ･･･ TForm1：D&D ビューア（TStringGrid）
  ┣・_DATA/                    ･･･ サンプル DICOM ファイル（CR/DX, *.dcm）
  ┣・_LIBRARY/LUXOPHIA/
  ┃  ┣・LUX/                  ･･･ 基盤ユーティリティ（THex4, TSearchBM, …）
  ┃  ┗・LUX.DICOM/            ･･･ DICOM 解析ライブラリ
  ┃     ┣・LUX.DICOM.pas      ･･･ TdcmHead / TdcmPort<T> / TdcmData / TdcmFile
  ┃     ┣・LUX.DICOM.VRs.pas  ･･･ TKindVR / TdcmVR / TdcmBookVR
  ┃     ┣・LUX.DICOM.Tags.pas ･･･ TdcmTag / TdcmElem / TdcmGrup / TdcmBookTag
  ┃     ┣・Tags/              ･･･ グループ別辞書（4,248 エントリ）
  ┃     ┗・Ports/             ･･･ 型付きアクセサ（Text/Reco/D1/D2/D2.Imag）
  ┗・--------/_SCREENSHOT/     ･･･ スクリーンショット
```

## 4. 使い方

| 操作 | 結果 |
|---|---|
| `DICOMLoader.exe` を起動 | 空のグリッドウィンドウが表示される。 |
| `*.dcm` ファイルをグリッドへドラッグ＆ドロップ | ファイルが解析され、全データ要素がタグ順にソートされて一覧表示される。 |

グリッドの列：

| 列 | 意味 |
|---|---|
| No. | タグ順ソート後の行番号。 |
| Grup / Elem | タグのグループ番号／要素番号。 |
| OriVR | データ辞書にそのタグ用として登録された VR（複数可）。 |
| ExpVR | ファイルから読み取られた明示的 VR（暗黙的 VR の場合は空欄）。 |
| Size | 値の長さ（バイト数）。 |
| Data | `Port.Text` によるテキスト表現。 |
| Desc | 辞書に基づく属性名（プライベート／未知のタグは `?`）。 |

## 5. ビルド

1. RAD Studio（Delphi, FireMonkey フレームワーク。プロジェクトファイルは ProjectVersion 20.4 で保存）で `DICOMLoader.dproj` を開く。
2. ターゲットプラットフォーム `Win32` または `Win64` を選択してビルドする。外部 DLL やサードパーティ製品のインストールは不要で、依存ライブラリはすべて git-subtree コピーとして `_LIBRARY/` 以下に同梱されている。
3. 実行し、`_DATA/` のサンプルファイル（例：`CR_LEE_IR6a.dcm`）をウィンドウへドロップする。`*_JPG_*` のサンプルはカプセル化された JPEG ピクセルデータを持ち、一覧表示はされるが展開はされない（1.1 節参照）。

## 6. 参考文献

1. NEMA, [*DICOM PS3.5: Data Structures and Encoding*](https://dicom.nema.org/medical/dicom/current/output/html/part05.html), National Electrical Manufacturers Association.
2. NEMA, [*DICOM PS3.6: Data Dictionary*](https://dicom.nema.org/medical/dicom/current/output/html/part06.html), National Electrical Manufacturers Association.
3. NEMA, [*DICOM PS3.7: Message Exchange*](https://dicom.nema.org/medical/dicom/current/output/html/part07.html), National Electrical Manufacturers Association.
4. NEMA, [*DICOM PS3.10: Media Storage and File Format for Media Interchange*](https://dicom.nema.org/medical/dicom/current/output/html/part10.html), National Electrical Manufacturers Association.
5. [DICOM Standard Homepage](https://www.dicomstandard.org/).
6. Wikipedia, [*DICOM*](https://ja.wikipedia.org/wiki/DICOM).

## 💖 [Embarcadero](https://www.embarcadero.com/jp/) [**Delphi**](https://www.embarcadero.com/jp/products/delphi)
ネイティブなクロスプラットフォームアプリを開発するための統合開発環境（ＩＤＥ）。
### Free Download: [**Delphi** Community Edition](https://www.embarcadero.com/jp/products/delphi/starter)
