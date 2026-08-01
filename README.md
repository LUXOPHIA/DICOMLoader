# DICOMLoader

[English](README.md) | [日本語](ja/README.md)

A Delphi/FireMonkey sample application that parses the medical image format **DICOM** and lists every data element of a file in a grid. It is built on the [LUX.DICOM](https://github.com/LUXOPHIA/LUX.DICOM) library, whose tag dictionary covers more than 4,200 official DICOM attributes.

![Screenshot of DICOMLoader](--------/_SCREENSHOT/DICOMLoader.png)

## 利用ライブラリ

* [**LUX**](https://github.com/LUXOPHIA/LUX) ：Base library of vectors, matrices and other core mathematics.
* [**LUX.DICOM**](https://github.com/LUXOPHIA/LUX.DICOM) ：Library for reading the DICOM medical image format.

## 1. Overview

* Drag & drop a `*.dcm` file onto the window to parse it and display all data elements: tag (group/element), VR, value length, value text, and the attribute name from the data dictionary.
* The parser (`TdcmFile` in `LUX.DICOM`) validates the DICOM preamble, reads each data element as a raw byte array (`TdcmData.Buff`), and detects explicit/implicit VR encoding automatically, element by element.
* Each element's bytes are interpreted through an attached *port* object (`IdcmPort`): text-based VRs are decoded to strings, binary VRs to numeric records/arrays, and the Pixel Data element (7FE0,0010) to a 2D pixel accessor configured from the Image Pixel attributes of group 0028.
* The tag dictionary (`TdcmBookTag`) is generated from the registries of NEMA PS3.6 and PS3.7 [2][3] and contains 4,248 entries organized per tag group.

### 1.1 Limitations

* Byte order is assumed to be little endian; the Transfer Syntax UID (0002,0010) is displayed but not used to switch decoders.
* Encapsulated (compressed) Pixel Data such as JPEG transfer syntaxes is stored as raw bytes and not decompressed.
* Only 8-bit and 16-bit `Bits Allocated` values are supported by the pixel port; the Modality LUT and VOI windowing (see Section 2.3) are not applied.

## 2. Technical Background

### 2.1 DICOM File Structure

A DICOM file (PS3.10) starts with a 128-byte preamble followed by the 4-byte magic code `DICM`; the remainder is a sequence of *data elements* [1]. The loader maps this header onto the packed record `TdcmHead`:

```
・DICOM file (PS3.10)
  ┣・Preamble (128 bytes)
  ┣・"DICM"
  ┗・Data Element × N ･･･ Data Element, Data Element, …
```

`TdcmFile.LoadFromFile` asserts the `DICM` prefix and then reads data elements until the end of the file, storing them in a dictionary keyed by tag.

### 2.2 Data Element Encoding: Tag, VR, and Length

Every data element begins with a 4-byte tag — a (group, element) pair of 16-bit numbers, modeled by the record `TdcmTag` — followed by an optional Value Representation (VR) code and the value length [1]:

```
・Explicit VR (short form)
  ┗・Tag (4)
     ┗・VR (2)
        ┗・Length (2)
           ┗・Value (Length)

・Explicit VR (long form)
  ┗・Tag (4)
     ┗・VR (2)
        ┗・Reserved (2)
           ┗・Len (4)
              ┗・Value (Length)

・Implicit VR
  ┗・Tag (4)
     ┗・Length (4)
        ┗・Value (Length)
```

* `TdcmBookVR.ReadStream` reads two bytes and checks them against the registry of 31 VR codes (Table 6.2-1 of PS3.5). If they match a known code (`AE`, `AS`, `AT`, `CS`, `DA`, `DS`, `DT`, `FL`, `FD`, `IS`, `LO`, `LT`, `OB`, `OD`, `OF`, `OL`, `OW`, `PN`, `SH`, `SL`, `SQ`, `SS`, `ST`, `TM`, `UC`, `UI`, `UL`, `UN`, `UR`, `US`, `UT`), the element is explicit VR; otherwise the stream is rewound and the element is treated as implicit VR (`vr00`).
* For explicit VR, the short form carries a 16-bit length, while the long-form VRs (`OB OD OF OL OW SQ UC UN UR UT`) insert 2 reserved bytes and a 32-bit length; for implicit VR the length is always 32-bit (`TdcmData.ReadStream`).
* An undefined length `0xFFFFFFFF` (used by sequences, PS3.5 §7.5) is resolved by a Boyer–Moore search (`TSearchBM<Word>` from the [LUX](https://github.com/LUXOPHIA/LUX) library) for the Sequence Delimitation Item `(FFFE,E0DD)` with zero length.
* Value buffers are padded to an even number of bytes, as required by the standard.
* For implicit-VR elements the effective VR (`TdcmData.RecVR`) is recovered from the data dictionary when the tag maps to exactly one candidate VR.

### 2.3 Pixel Data Interpretation

When the Pixel Data element (7FE0,0010) is accessed, `TdcmData.MakePortImag` reads the Image Pixel Module attributes of group 0028 — Photometric Interpretation (0028,0004), Rows (0028,0010), Columns (0028,0011), Bits Allocated (0028,0100), Bits Stored (0028,0101), High Bit (0028,0102), and Pixel Representation (0028,0103) — and instantiates one of `TdcmPortImagU08 / S08 / U16 / S16` according to Bits Allocated (8 or 16) and Pixel Representation (unsigned/signed).

Each stored sample $S$ occupies $n$ = *Bits Stored* bits ending at bit position $h$ = *High Bit* inside an $N$ = *Bits Allocated* container. The port extracts the value $V$ with a pair of shifts:

```math
V \;=\; \bigl(\, S \ll (N-1-h) \,\bigr) \;\gg\; (N-n) \tag{1}
```

For the signed ports the right shift in Eq. (1) is arithmetic, so the sign bit is extended. Photometric interpretations (`MONOCHROME1/2`, `PALETTE COLOR`, `RGB`, `YBR_*`) are recognized by the enumeration `TKindPixel`.

The standard further defines the Modality LUT — e.g. the linear rescale $HU = m\,SV + b$ with Rescale Slope (0028,1053) and Rescale Intercept (0028,1052) — and VOI windowing with Window Center/Width (0028,1050/1051) [1]. These tags are present in the dictionary, but the loader displays stored values without applying such transformations.

## 3. Architecture

### 3.1 Class Diagram

```
[Processing flow]
・TForm1.OnDragDrop( *.dcm )
  ┗・TdcmFile.LoadFromFile
     ┗・ShowData

[Ownership]
・TForm1 (Main.pas)
  ┗・TdcmFile = TObjectDictionary<TdcmTag, TdcmData>
     ┣・TdcmHead              ･･･ 128-byte preamble + "DICM"
     ┗・TdcmData (one per element)
        ┣・Tag :TdcmTag       ･･･ key into the tag dictionary
        ┣・ExpVR :TKindVR     ･･･ key into the VR registry
        ┣・Buff :TBytes       ･･･ raw value bytes
        ┗・Port :IdcmPort     ･･･ typed view over Buff
           ┣・TdcmPortText<T> ･･･ AE AS CS DA DS DT IS LO LT PN SH ST TM …
           ┣・TdcmPort<T>     ･･･ AT FL FD SL SS UL US
           ┣・TdcmPort1D<T>   ･･･ OB OD OF OL OW UN SQ
           ┗・TdcmPortImag<T> ･･･ U08/S08/U16/S16 ← (7FE0,0010) Pixel Data

[Reference: TdcmData.Tag → _BookTag_]
・_BookTag_ :TdcmBookTag       ･･･ tag dictionary
  ┗・TdcmGrup
     ┗・TdcmElem              ･･･ name / VRs / description

[Reference: TdcmData.ExpVR → _BookVR_]
・_BookVR_ :TdcmBookVR         ･･･ VR registry
  ┗・TdcmVR                   ･･･ code / header size
```

The port is created lazily (`TdcmData.GetPort`) from `RecVR`, i.e. the explicit VR when present, otherwise the unique VR registered for the tag in the dictionary.

### 3.2 File Layout

```
・DICOMLoader/
  ┣・DICOMLoader.dpr           ･･･ program entry (FireMonkey application)
  ┣・DICOMLoader.dproj         ･･･ RAD Studio project (Win32 / Win64)
  ┣・Main.pas / Main.fmx       ･･･ TForm1: drag & drop viewer (TStringGrid)
  ┣・_DATA/                    ･･･ sample DICOM files (CR/DX, *.dcm)
  ┣・_LIBRARY/LUXOPHIA/
  ┃  ┣・LUX/                  ･･･ base utilities (THex4, TSearchBM, …)
  ┃  ┗・LUX.DICOM/            ･･･ DICOM parsing library
  ┃     ┣・LUX.DICOM.pas      ･･･ TdcmHead / TdcmPort<T> / TdcmData / TdcmFile
  ┃     ┣・LUX.DICOM.VRs.pas  ･･･ TKindVR / TdcmVR / TdcmBookVR
  ┃     ┣・LUX.DICOM.Tags.pas ･･･ TdcmTag / TdcmElem / TdcmGrup / TdcmBookTag
  ┃     ┣・Tags/              ･･･ per-group dictionaries (4,248 entries)
  ┃     ┗・Ports/             ･･･ typed accessors (Text/Reco/D1/D2/D2.Imag)
  ┗・--------/_SCREENSHOT/     ･･･ screenshot
```

## 4. Usage

| Action | Result |
|---|---|
| Launch `DICOMLoader.exe` | An empty grid window appears. |
| Drag & drop a `*.dcm` file onto the grid | The file is parsed and all data elements are listed, sorted by tag. |

Grid columns:

| Column | Meaning |
|---|---|
| No. | Row number after sorting by tag. |
| Grup / Elem | Tag group / element number. |
| OriVR | VR(s) registered for the tag in the data dictionary. |
| ExpVR | Explicit VR read from the file (blank for implicit VR). |
| Size | Value length in bytes. |
| Data | Value rendered as text via `Port.Text`. |
| Desc | Attribute name from the dictionary (`?` for private/unknown tags). |

## 5. Building

1. Open `DICOMLoader.dproj` in RAD Studio (Delphi, FireMonkey framework; the project file was saved with ProjectVersion 20.4).
2. Select the `Win32` or `Win64` target platform and build. No external DLLs or third-party installations are required; all dependencies are vendored under `_LIBRARY/` as git-subtree copies.
3. Run and drop one of the sample files from `_DATA/` (e.g. `CR_LEE_IR6a.dcm`) onto the window. The `*_JPG_*` samples use encapsulated JPEG pixel data, which is listed but not decompressed (see §1.1).

## 6. References

1. NEMA, [*DICOM PS3.5: Data Structures and Encoding*](https://dicom.nema.org/medical/dicom/current/output/html/part05.html), National Electrical Manufacturers Association.
2. NEMA, [*DICOM PS3.6: Data Dictionary*](https://dicom.nema.org/medical/dicom/current/output/html/part06.html), National Electrical Manufacturers Association.
3. NEMA, [*DICOM PS3.7: Message Exchange*](https://dicom.nema.org/medical/dicom/current/output/html/part07.html), National Electrical Manufacturers Association.
4. NEMA, [*DICOM PS3.10: Media Storage and File Format for Media Interchange*](https://dicom.nema.org/medical/dicom/current/output/html/part10.html), National Electrical Manufacturers Association.
5. [DICOM Standard Homepage](https://www.dicomstandard.org/).
6. Wikipedia, [*DICOM*](https://en.wikipedia.org/wiki/DICOM).

## 💖 [Embarcadero](https://www.embarcadero.com/) [**Delphi**](https://www.embarcadero.com/products/delphi)
Integrated Development Environment (IDE) for Creating Native Cross-Platform Apps.
### Free Download: [**Delphi** Community Edition](https://www.embarcadero.com/products/delphi/starter)
