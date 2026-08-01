# DICOMLoader

[English](README.md) | [日本語](ja/README.md)

A Delphi/FireMonkey sample application that parses the medical-image format **DICOM** and displays every data element of a file as a tree. It is built on the rewritten [LUX.DICOM](https://github.com/LUXOPHIA/LUX.DICOM) library: the parse is driven by the transfer syntax, sequences are recursed into, encapsulated Pixel Data is decomposed into fragments, and a dictionary of some 5,300 attributes generated from the official PS3.6 source supplies the keywords.

![Screenshot of DICOMLoader](--------/_SCREENSHOT/DICOMLoader.png)

## 利用ライブラリ

* [**LUX.DICOM**](https://github.com/LUXOPHIA/LUX.DICOM) ：Library for reading and writing the DICOM medical image format.

## 1. Overview

* Open a `*.dcm` file by drag & drop, by the **Open...** button, or by passing its path as the first command-line argument.
* File Meta and the data set are shown as a tree. Each node reads *tag | VR | length | keyword = value*: the VR is the one on the stream (unknown VR names are preserved), `undef` marks undefined lengths, and text values — including Japanese person names under ISO 2022 IR 87 — are decoded per Specific Character Set.
* A sequence (SQ) expands into `Item #n` child nodes recursively; encapsulated Pixel Data expands into its fragments with their sizes. Standard violations that the lenient parser survived are listed under an `Issues` node.
* Files of any transfer syntax can be inspected — an unregistered codec only affects pixel decoding, never tag access.

## 2. Building

Win64 only:

```
msbuild DICOMLoader.dproj /t:Build /p:Config=Release /p:Platform=Win64
```

The library sources are embedded under `_LIBRARY/LUXOPHIA/LUX.DICOM` as a git subtree of the [LUX.DICOM](https://github.com/LUXOPHIA/LUX.DICOM) repository; update them with `git subtree pull --squash`.

## 3. Sample data

`_DATA/` contains the eight JIRA Japanese standard test images: the same CR/DX exposures in Explicit VR Little Endian and in JPEG Lossless (Process 14, SV1), with and without ISO 2022 IR 87 character sets. All eight parse with zero issues.

## 4. References

1. NEMA, [*DICOM PS3.5 — Data Structures and Encoding*](https://dicom.nema.org/medical/dicom/current/output/html/part05.html).
2. NEMA, [*DICOM PS3.6 — Data Dictionary*](https://dicom.nema.org/medical/dicom/current/output/html/part06.html).
3. NEMA, [*DICOM Standard — Current Edition*](https://www.dicomstandard.org/current).

## 💖 [Embarcadero](https://www.embarcadero.com/) [**Delphi**](https://www.embarcadero.com/products/delphi)
Integrated Development Environment (IDE) for Creating Native Cross-Platform Apps.
### Free Download: [**Delphi** Community Edition](https://www.embarcadero.com/products/delphi/starter)