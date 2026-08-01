# DICOMLoader

[English](../README.md) | [日本語](README.md)

医用画像フォーマット **DICOM** を解析し、ファイルの全データ要素をツリー表示する Delphi／FireMonkey 製サンプルアプリケーション。全面書き直しされた [LUX.DICOM](https://github.com/LUXOPHIA/LUX.DICOM) ライブラリの上に構築されており、解析は転送構文に駆動され、シーケンスは再帰的に展開され、カプセル化された画素データはフラグメントへ分解され、公式 PS3.6 ソースから生成した約 5,300 属性の辞書がキーワードを与える。

![Screenshot of DICOMLoader](../--------/_SCREENSHOT/DICOMLoader.png)

## 利用ライブラリ

* [**LUX.DICOM**](https://github.com/LUXOPHIA/LUX.DICOM) ：DICOM 医用画像フォーマットを読み書きするためのライブラリ。

## 1. 概要

* `*.dcm` ファイルはドラッグ＆ドロップ・**Open...** ボタン・第 1 コマンドライン引数のいずれでも開ける。
* File Meta とデータセットをツリーで表示する。各ノードは *タグ | VR | 長さ | キーワード = 値* の形式で、VR はストリーム上のもの（未知の VR 名も保全）、`undef` は未定義長を表し、テキスト値は Specific Character Set に従って復号される（ISO 2022 IR 87 の日本語人名を含む）。
* シーケンス（SQ）は `Item #n` の子ノードへ再帰的に展開され、カプセル化された画素データはフラグメントの大きさとともに列挙される。Lenient パーサが読み続けた規格違反は `Issues` ノードに列挙される。
* どの転送構文のファイルも閲覧できる。コーデック未登録は画素のデコードにのみ影響し、タグアクセスには影響しない。

## 2. ビルド

Win64 のみ：

```
msbuild DICOMLoader.dproj /t:Build /p:Config=Release /p:Platform=Win64
```

ライブラリのソースは [LUX.DICOM](https://github.com/LUXOPHIA/LUX.DICOM) リポジトリの git subtree として `_LIBRARY/LUXOPHIA/LUX.DICOM` に取り込まれている。更新は `git subtree pull --squash` で行う。

## 3. サンプルデータ

`_DATA/` には JIRA 日本標準テスト画像 8 ファイルが含まれる。同一の CR／DX 撮影が Explicit VR Little Endian と JPEG ロスレス（Process 14, SV1）の両形式で、ISO 2022 IR 87 文字集合の有無つきで収録されている。8 ファイル全てが Issue ゼロで解析される。

## 4. 参考文献

1. NEMA, [*DICOM PS3.5 — Data Structures and Encoding*](https://dicom.nema.org/medical/dicom/current/output/html/part05.html).
2. NEMA, [*DICOM PS3.6 — Data Dictionary*](https://dicom.nema.org/medical/dicom/current/output/html/part06.html).
3. NEMA, [*DICOM Standard — Current Edition*](https://www.dicomstandard.org/current).

## 💖 [Embarcadero](https://www.embarcadero.com/jp/) [**Delphi**](https://www.embarcadero.com/jp/products/delphi)
ネイティブなクロスプラットフォームアプリを開発するための統合開発環境（ＩＤＥ）。
### Free Download: [**Delphi** Community Edition](https://www.embarcadero.com/jp/products/delphi/starter)