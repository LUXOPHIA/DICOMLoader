unit Main;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Rtti,
  FMX.Grid.Style, FMX.Grid, FMX.Controls.Presentation, FMX.ScrollBox,
  LUX.DICOM, LUX.DICOM.Tags, LUX.DICOM.VRs;

type
  TForm1 = class(TForm)
    StringGrid1: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    StringColumn5: TStringColumn;
    StringColumn6: TStringColumn;
    StringColumn7: TStringColumn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
    procedure StringGrid1DragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
  private
    { private 宣言 }
    procedure ShowData;
  public
    { public 宣言 }
    _DICOM :TdcmFile;
  end;

var
  Form1: TForm1;

implementation //############################################################### ■

{$R *.fmx}

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

procedure TForm1.ShowData;
var
   I :Integer;
   Ts :TArray<TdcmTag>;
begin
     with StringGrid1 do
     begin
          RowCount := _DICOM.Count;

          Ts := _DICOM.TagsToArray;

          for I := 0 to _DICOM.Count-1 do
          begin
               with _DICOM[ Ts[ I ] ] do
               begin
                    Cells[ 0, I ] := (I+1).ToString;
                    Cells[ 1, I ] := Tag.Grup.ToString;
                    Cells[ 2, I ] := Tag.Elem.ToString;
                    Cells[ 4, I ] := ExpVR.ToString;
                    Cells[ 5, I ] := Size.ToString;
                    Cells[ 3, I ] := OriVR.ToString;
                    Cells[ 6, I ] := Desc;
               end;
          end;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     _DICOM := TdcmFile.Create;

     with StringGrid1 do
     begin
          OnDragOver := StringGrid1DragOver;
          OnDragDrop := StringGrid1DragDrop;
     end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     _DICOM.Free;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.FormShow(Sender: TObject);
begin
     StringColumn7.Width := 300;
end;

//------------------------------------------------------------------------------

procedure TForm1.StringGrid1DragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
     Operation := TDragOperation.Link;
end;

procedure TForm1.StringGrid1DragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
begin
     _DICOM.LoadFromFile( Data.Files[0] );

     ShowData;
end;

end. //######################################################################### ■
