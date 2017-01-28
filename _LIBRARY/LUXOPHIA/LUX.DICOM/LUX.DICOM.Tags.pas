unit LUX.DICOM.Tags;

interface //#################################################################### ■

uses System.Generics.Defaults, System.Generics.Collections,
     LUX, LUX.DICOM.VRs;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     TdcmTagSort = class;
     TdcmElem    = class;
     TdcmGrup    = class;
     TdcmBookTag = class;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdcmTag

     TdcmTag = packed record
     private
     public
       Grup :THex4;
       Elem :THex4;
       /////
       constructor Create( const Grup_,Elem_:THex4 );
       ///// メソッド
       function ToString :String;
     end;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdcmTagSort

     TdcmTagSort = class( TComparer<TdcmTag> )
     private
     protected
     public
       ///// メソッド
       function Compare(const Left_,Right_:TdcmTag ) :Integer; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdcmElem

     TdcmElem = class
     private
     protected
       _Grup  :TdcmGrup;
       _Code  :THex4;
       _Name  :AnsiString;
       _Kinds :TKindsVR;
       _Desc  :String;
     public
       constructor Create( const Grup_:TdcmGrup; const Code_:THex4; const Name_:AnsiString; const Kinds_:TKindsVR; const Desc_:String );
       ///// プロパティ
       property Grup  :TdcmGrup   read _Grup ;
       property Code  :THex4      read _Code ;
       property Name  :AnsiString read _Name ;
       property Kinds :TKindsVR   read _Kinds;
       property Desc  :String     read _Desc ;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdcmGrup

     TdcmGrup = class( TObjectDictionary<THex4,TdcmElem> )
     private
     protected
       _Book       :TdcmBookTag;
       _Code       :THex4;
       _NameToElem :TDictionary<AnsiString,TdcmElem>;
       ///// アクセス
       function GetElem( const Name_:AnsiString ) :TdcmElem;
       ///// メソッド
       procedure Add( const Code_:THex4; const Name_:AnsiString; const Kind_:TKindsVR; const Desc_:String );
     public
       constructor Create( const Book_:TdcmBookTag; const Code_:THex4 );
       destructor Destroy; override;
       ///// プロパティ
       property Book                           :TdcmBookTag read   _Book;
       property Code                           :THex4       read   _Code;
       property Elem[ const Name_:AnsiString ] :TdcmElem    read GetElem;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdcmBookTag

     TdcmBookTag = class( TObjectDictionary<THex4,TdcmGrup> )
     private
     protected
       ///// アクセス
       function GetElem( const Tag_:TdcmTag ) :TdcmElem;
     public
       constructor Create;
       destructor Destroy; override;
       ///// プロパティ
       property Elem[ const Tag_:TdcmTag ] :TdcmElem read GetElem; default;
       ///// メソッド
       function Contains( const Tag_:TdcmTag ) :Boolean;
       function Find( const Tag_:TdcmTag ) :TdcmElem;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

    _BookTag_ :TdcmBookTag;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses LUX.DICOM.Tags.G0000,
     LUX.DICOM.Tags.G0002,
     LUX.DICOM.Tags.G0004,
     LUX.DICOM.Tags.G0008,
     LUX.DICOM.Tags.G0010,
     LUX.DICOM.Tags.G0012,
     LUX.DICOM.Tags.G0014,
     LUX.DICOM.Tags.G0018,
     LUX.DICOM.Tags.G0020,
     LUX.DICOM.Tags.G0022,
     LUX.DICOM.Tags.G0024,
     LUX.DICOM.Tags.G0028,
     LUX.DICOM.Tags.G0032,
     LUX.DICOM.Tags.G0038,
     LUX.DICOM.Tags.G003A,
     LUX.DICOM.Tags.G0040,
     LUX.DICOM.Tags.G0042,
     LUX.DICOM.Tags.G0044,
     LUX.DICOM.Tags.G0046,
     LUX.DICOM.Tags.G0048,
     LUX.DICOM.Tags.G0050,
     LUX.DICOM.Tags.G0052,
     LUX.DICOM.Tags.G0054,
     LUX.DICOM.Tags.G0060,
     LUX.DICOM.Tags.G0062,
     LUX.DICOM.Tags.G0064,
     LUX.DICOM.Tags.G0066,
     LUX.DICOM.Tags.G0068,
     LUX.DICOM.Tags.G0070,
     LUX.DICOM.Tags.G0072,
     LUX.DICOM.Tags.G0074,
     LUX.DICOM.Tags.G0076,
     LUX.DICOM.Tags.G0078,
     LUX.DICOM.Tags.G0080,
     LUX.DICOM.Tags.G0082,
     LUX.DICOM.Tags.G0088,
     LUX.DICOM.Tags.G0100,
     LUX.DICOM.Tags.G0400,
     LUX.DICOM.Tags.G1000,
     LUX.DICOM.Tags.G1010,
     LUX.DICOM.Tags.G2000,
     LUX.DICOM.Tags.G2010,
     LUX.DICOM.Tags.G2020,
     LUX.DICOM.Tags.G2030,
     LUX.DICOM.Tags.G2040,
     LUX.DICOM.Tags.G2050,
     LUX.DICOM.Tags.G2100,
     LUX.DICOM.Tags.G2110,
     LUX.DICOM.Tags.G2120,
     LUX.DICOM.Tags.G2130,
     LUX.DICOM.Tags.G2200,
     LUX.DICOM.Tags.G3002,
     LUX.DICOM.Tags.G3004,
     LUX.DICOM.Tags.G3006,
     LUX.DICOM.Tags.G3008,
     LUX.DICOM.Tags.G300A,
     LUX.DICOM.Tags.G300C,
     LUX.DICOM.Tags.G300E,
     LUX.DICOM.Tags.G4000,
     LUX.DICOM.Tags.G4008,
     LUX.DICOM.Tags.G4010,
     LUX.DICOM.Tags.G4FFE,
     LUX.DICOM.Tags.G50xx,
     LUX.DICOM.Tags.G5200,
     LUX.DICOM.Tags.G5400,
     LUX.DICOM.Tags.G5600,
     LUX.DICOM.Tags.G60xx,
     LUX.DICOM.Tags.G7Fxx,
     LUX.DICOM.Tags.G7FE0,
     LUX.DICOM.Tags.GFFFA,
     LUX.DICOM.Tags.GFFFC,
     LUX.DICOM.Tags.GFFFE;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdcmTag

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TdcmTag.Create( const Grup_,Elem_:THex4 );
begin
     Grup := Grup_;
     Elem := Elem_;
end;

/////////////////////////////////////////////////////////////////////// メソッド

function TdcmTag.ToString :String;
begin
     Result := '(' + Grup.ToString + ',' + Elem.ToString + ')';
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdcmTagSort

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

function TdcmTagSort.Compare( const Left_,Right_:TdcmTag ) :Integer;
begin
     Result := ( Left_ .Grup shl 16 or Left_ .Elem )
             - ( Right_.Grup shl 16 or Right_.Elem );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdcmElem

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TdcmElem.Create( const Grup_:TdcmGrup; const Code_:THex4; const Name_:AnsiString; const Kinds_:TKindsVR; const Desc_:String );
begin
     inherited Create;

     _Grup  := Grup_ ;
     _Code  := Code_ ;
     _Name  := Name_ ;
     _Kinds := Kinds_;
     _Desc  := Desc_ ;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdcmGrup

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TdcmGrup.GetElem( const Name_:AnsiString ) :TdcmElem;
begin
     if _NameToElem.ContainsKey( Name_ ) then Result := _NameToElem[ Name_ ]
                                         else Result := nil;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TdcmGrup.Add( const Code_:THex4; const Name_:AnsiString; const Kind_:TKindsVR; const Desc_:String );
var
   E :TdcmElem;
begin
     E := TdcmElem.Create( Self, Code_, Name_, Kind_, Desc_ );

     inherited Add( Code_, E );

     if Name_ <> '' then _NameToElem.Add( Name_, E );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TdcmGrup.Create( const Book_:TdcmBookTag; const Code_:THex4 );
begin
     inherited Create( [ doOwnsValues ] );

     _NameToElem := TDictionary<AnsiString,TdcmElem>.Create;

     _Book := Book_;
     _Code := Code_;

     _Book.Add( Code_, Self );
end;

destructor TdcmGrup.Destroy;
begin
     _NameToElem.Free;

     inherited;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TdcmBookTag

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TdcmBookTag.GetElem( const Tag_:TdcmTag ) :TdcmElem;
begin
     with Tag_ do Result := Items[ Grup ].Items[ Elem ];
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TdcmBookTag.Create;
begin
     inherited Create( [ doOwnsValues ] );

     TdcmGrup0000.Create( Self, $0000 );
     TdcmGrup0002.Create( Self, $0002 );
     TdcmGrup0004.Create( Self, $0004 );
     TdcmGrup0008.Create( Self, $0008 );
     TdcmGrup0010.Create( Self, $0010 );
     TdcmGrup0012.Create( Self, $0012 );
     TdcmGrup0014.Create( Self, $0014 );
     TdcmGrup0018.Create( Self, $0018 );
     TdcmGrup0020.Create( Self, $0020 );
     TdcmGrup0022.Create( Self, $0022 );
     TdcmGrup0024.Create( Self, $0024 );
     TdcmGrup0028.Create( Self, $0028 );
     TdcmGrup0032.Create( Self, $0032 );
     TdcmGrup0038.Create( Self, $0038 );
     TdcmGrup003A.Create( Self, $003A );
     TdcmGrup0040.Create( Self, $0040 );
     TdcmGrup0042.Create( Self, $0042 );
     TdcmGrup0044.Create( Self, $0044 );
     TdcmGrup0046.Create( Self, $0046 );
     TdcmGrup0048.Create( Self, $0048 );
     TdcmGrup0050.Create( Self, $0050 );
     TdcmGrup0052.Create( Self, $0052 );
     TdcmGrup0054.Create( Self, $0054 );
     TdcmGrup0060.Create( Self, $0060 );
     TdcmGrup0062.Create( Self, $0062 );
     TdcmGrup0064.Create( Self, $0064 );
     TdcmGrup0066.Create( Self, $0066 );
     TdcmGrup0068.Create( Self, $0068 );
     TdcmGrup0070.Create( Self, $0070 );
     TdcmGrup0072.Create( Self, $0072 );
     TdcmGrup0074.Create( Self, $0074 );
     TdcmGrup0076.Create( Self, $0076 );
     TdcmGrup0078.Create( Self, $0078 );
     TdcmGrup0080.Create( Self, $0080 );
     TdcmGrup0082.Create( Self, $0082 );
     TdcmGrup0088.Create( Self, $0088 );
     TdcmGrup0100.Create( Self, $0100 );
     TdcmGrup0400.Create( Self, $0400 );
     TdcmGrup1000.Create( Self, $1000 );
     TdcmGrup1010.Create( Self, $1010 );
     TdcmGrup2000.Create( Self, $2000 );
     TdcmGrup2010.Create( Self, $2010 );
     TdcmGrup2020.Create( Self, $2020 );
     TdcmGrup2030.Create( Self, $2030 );
     TdcmGrup2040.Create( Self, $2040 );
     TdcmGrup2050.Create( Self, $2050 );
     TdcmGrup2100.Create( Self, $2100 );
     TdcmGrup2110.Create( Self, $2110 );
     TdcmGrup2120.Create( Self, $2120 );
     TdcmGrup2130.Create( Self, $2130 );
     TdcmGrup2200.Create( Self, $2200 );
     TdcmGrup3002.Create( Self, $3002 );
     TdcmGrup3004.Create( Self, $3004 );
     TdcmGrup3006.Create( Self, $3006 );
     TdcmGrup3008.Create( Self, $3008 );
     TdcmGrup300A.Create( Self, $300A );
     TdcmGrup300C.Create( Self, $300C );
     TdcmGrup300E.Create( Self, $300E );
     TdcmGrup4000.Create( Self, $4000 );
     TdcmGrup4008.Create( Self, $4008 );
     TdcmGrup4010.Create( Self, $4010 );
     TdcmGrup4FFE.Create( Self, $4FFE );

     TdcmGrup50xx.Create( Self, $5000 );

     TdcmGrup5200.Create( Self, $5200 );
     TdcmGrup5400.Create( Self, $5400 );
     TdcmGrup5600.Create( Self, $5600 );

     TdcmGrup60xx.Create( Self, $6000 );

     TdcmGrup7Fxx.Create( Self, $7F00 );

     TdcmGrup7FE0.Create( Self, $7FE0 );
     TdcmGrupFFFA.Create( Self, $FFFA );
     TdcmGrupFFFC.Create( Self, $FFFC );
     TdcmGrupFFFE.Create( Self, $FFFE );
end;

destructor TdcmBookTag.Destroy;
begin

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

function TdcmBookTag.Contains( const Tag_:TdcmTag ) :Boolean;
begin
     with Tag_ do Result := ContainsKey( Grup ) and Items[ Grup ].ContainsKey( Elem );
end;

function TdcmBookTag.Find( const Tag_:TdcmTag ) :TdcmElem;
begin
     if ContainsKey( Tag_.Grup ) then
     begin
          with Items[ Tag_.Grup ] do
          begin
               if ContainsKey( Tag_.Elem ) then Result := Items[ Tag_.Elem ]
                                           else Result := nil;
          end;
     end
     else Result := nil;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

     _BookTag_ := TdcmBookTag.Create;

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

     _BookTag_.Free;

end. //######################################################################### ■
