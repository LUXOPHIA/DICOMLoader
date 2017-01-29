# DICOMLoader

医用画像フォーマット「[DICOM](https://www.wikiwand.com/ja/DICOM)」を読み込む方法。4,200種類以上の公式タグに対応。

![](https://github.com/LUXOPHIA/DICOMLoader/raw/26ad3798ecb86b3f1d521745196c30619cbffd10/--------/_SCREENSHOT/DICOMLoader.png)

各のエレメントのデータは、型のないバイト配列として```TdcmData```クラス内に保持されるが、さらにそこへ紐付けられた入出力管理クラス```TdcmPort```を介することで、VR の変数型に応じた入出力が可能（現状テキスト型データのみ対応）。

----

* __TdcmFile__  
DICOMファイルクラス
    * __LoadFromFile__( FileName_:String )
    * __TagsToArray__ :TArray<TdcmTag>
    * __Data[ \*, \* ]__ :TdcmData  
エレメントクラス。
        * __Tag__ :TdcmTag  
タグ番号。
        * __ExpVR__ :TKindVR  
明示的VR（暗黙的な場合は vr00 ）。
        * __Size__ :Cardinal  
Data のバイト数。
        * __Data__ :TBytes  
バイト配列。
        * __Port__ :TdcmPort  
Data を VR に応じて解釈する管理クラス。
            * __Text__ :String  
Data をテキストとして入出力。

----

* __LUX.DICOM.VRs__  
－TNameVR  
－TKindVR  
－TKindsVR  
＋TdcmVR  
＋TdcmBookVR
    * __LUX.DICOM.Tags__  
－TdcmTag  
－TdcmTagSort  
＋TdcmElem  
＋TdcmGrup  
＋TdcmBookTag
        * __LUX.DICOM.Tags.G0000__  
＋TdcmGrup0000
        * __LUX.DICOM.Tags.G0002__  
＋TdcmGrup0002
        * __LUX.DICOM.Tags.G003A__  
＋TdcmGrup003A  
        * ～
    * __LUX.DICOM__  
－TdcmHead  
＋TdcmPort  
＋TdcmData  
＋TdcmFile
        * __LUX.DICOM.Ports__  
－TdcmDate  
－TdcmTime  
－TdcmZone  
－TdcmDateTime  
＋TdcmPortText  
＋TdcmPortImag
            * __LUX.DICOM.Ports.Text__  
＋TdcmPortAE  
＋TdcmPortAS  
＋TdcmPortCS  
　～
            * __LUX.DICOM.Ports.Imag__  
＋TdcmPortImagU8  
＋TdcmPortImagS8  
＋TdcmPortImagU16  
　～

----

* [The DICOM Standard](http://dicom.nema.org/standard.html)
    * [Part 5: Data Structures and Encoding](http://dicom.nema.org/medical/dicom/current/output/html/part05.html)
        * [6.2. Value Representation (VR)](http://dicom.nema.org/medical/dicom/current/output/html/part05.html#sect_6.2)
        * [7.1.2. Data Element Structure with Explicit VR](http://dicom.nema.org/medical/dicom/current/output/html/part05.html#sect_7.1.2)
        * [7.1.3. Data Element Structure with Implicit VR](http://dicom.nema.org/medical/dicom/current/output/html/part05.html#sect_7.1.3)
    * [Part 6: Data Dictionary](http://dicom.nema.org/medical/dicom/current/output/html/part06.html)
        * [6. Registry of DICOM Data Elements](http://dicom.nema.org/medical/dicom/current/output/html/part06.html#chapter_6)
        * [7. Registry of DICOM File Meta Elements](http://dicom.nema.org/medical/dicom/current/output/html/part06.html#chapter_7)
        * [8. Registry of DICOM Directory Structuring Elements](http://dicom.nema.org/medical/dicom/current/output/html/part06.html#chapter_8)
    * [Part 7: Message Exchange](http://dicom.nema.org/medical/dicom/current/output/html/part07.html)
        * [E.1. Registry of DICOM Command Elements](http://dicom.nema.org/medical/dicom/current/output/html/part07.html#sect_E.1)
        * [E.2. Retired Command Fields](http://dicom.nema.org/medical/dicom/current/output/html/part07.html#sect_E.2)

[![Delphi Starter](http://img.en25.com/EloquaImages/clients/Embarcadero/%7B063f1eec-64a6-4c19-840f-9b59d407c914%7D_dx-starter-bn159.png)](https://www.embarcadero.com/jp/products/delphi/starter)
