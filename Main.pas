unit Main;

interface //#################################################################### ■

uses System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
     FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
     FMX.TreeView, FMX.Layouts, FMX.StdCtrls, FMX.Controls.Presentation,
     LUX.DICOM;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【 C L A S S 】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TForm1

     TForm1 = class( TForm )
       LayoutT     :TLayout;
         ButtonO   :TButton;
         LabelI    :TLabel;
       TreeView1   :TTreeView;
       OpenDialog1 :TOpenDialog;
       ///// イベント
       procedure FormCreate( Sender:TObject );
       procedure FormDestroy( Sender:TObject );
       procedure ButtonOClick( Sender:TObject );
       procedure TreeView1DragOver( Sender:TObject; const Data:TDragObject; const Point:TPointF; var Operation:TDragOperation );
       procedure TreeView1DragDrop( Sender:TObject; const Data:TDragObject; const Point:TPointF );
     private
       _File :TdcmFile;
       ///// メソッド
       procedure AddDataset( const Parent_:TFmxObject; const Dataset_:TdcmDataset );
       procedure ShowTree;
     public
       ///// メソッド
       procedure LoadFile( const FileName_:String );
     end;

var
   Form1 :TForm1;

implementation //############################################################### ■

{$R *.fmx}

uses LUX.DICOM.Dictio;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【 C L A S S 】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TForm1

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//////////////////////////////////////////////////////////////////////// メソッド

procedure TForm1.AddDataset( const Parent_:TFmxObject; const Dataset_:TdcmDataset );
var
   E :TdcmElement;
   N :TTreeViewItem;
   M :TTreeViewItem;
   S :String;
   L :String;
   K :String;
   I :Integer;
begin
     for E in Dataset_ do
     begin
          if E.VL = $FFFFFFFF then L := 'undef'
                              else L := E.VL.ToString;

          K := DictKeyword( E.Tag );

          S := E.Text( Dataset_.Charse );

          if S.Length > 128 then S := S.Substring( 0, 128 ) + '…';

          N := TTreeViewItem.Create( Self );

          N.Text := Format( '%s %s %s  %s', [ E.Tag.ToString, E.VRText, L, K ] );

          if S <> '' then N.Text := N.Text + ' = ' + S;

          N.Parent := Parent_;

          ///// SQ は Item ごとに子ノードへ再帰展開する（入れ子解析の実証）

          if E is TdcmSequence then
          begin
               for I := 0 to TdcmSequence( E ).Count-1 do
               begin
                    M := TTreeViewItem.Create( Self );

                    M.Text   := Format( 'Item #%d', [ I+1 ] );
                    M.Parent := N;

                    AddDataset( M, TdcmSequence( E )[ I ] );
               end;
          end;

          ///// カプセル化 Pixel Data はフラグメントの大きさを列挙する

          if E is TdcmFragments then
          begin
               for I := 0 to TdcmFragments( E ).Count-1 do
               begin
                    M := TTreeViewItem.Create( Self );

                    M.Text   := Format( 'Fragment #%d : %d バイト', [ I+1, Length( TdcmFragments( E )[ I ] ) ] );
                    M.Parent := N;
               end;
          end;
     end;
end;

//------------------------------------------------------------------------------

procedure TForm1.ShowTree;
var
   N :TTreeViewItem;
   S :String;
begin
     TreeView1.BeginUpdate;

     try
          TreeView1.Clear;

          N := TTreeViewItem.Create( Self );

          N.Text   := Format( 'File Meta（%d 要素）', [ _File.Meta.Count ] );
          N.Parent := TreeView1;

          AddDataset( N, _File.Meta );

          N.IsExpanded := True;

          N := TTreeViewItem.Create( Self );

          N.Text   := Format( 'Data Set（%d 要素）', [ _File.Body.Count ] );
          N.Parent := TreeView1;

          AddDataset( N, _File.Body );

          N.IsExpanded := True;

          ///// パース時の警告（Lenient で読み続けた規格違反）

          if _File.Issues.Count > 0 then
          begin
               N := TTreeViewItem.Create( Self );

               N.Text   := Format( 'Issues（%d 件）', [ _File.Issues.Count ] );
               N.Parent := TreeView1;

               for S in _File.Issues do
               begin
                    with TTreeViewItem.Create( Self ) do
                    begin
                         Text := S;  Parent := N;
                    end;
               end;

               N.IsExpanded := True;
          end;
     finally
          TreeView1.EndUpdate;
     end;

     LabelI.Text := ExtractFileName( _File.FileName ) + '　—　' + _File.Syntax.Name;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//////////////////////////////////////////////////////////////////////// メソッド

procedure TForm1.LoadFile( const FileName_:String );
begin
     try
          _File.LoadFromFile( FileName_ );

          ShowTree;
     except
          on E:Exception do LabelI.Text := 'ERROR: ' + E.Message;
     end;
end;

//////////////////////////////////////////////////////////////////////// イベント

procedure TForm1.FormCreate( Sender:TObject );
begin
     _File := TdcmFile.Create;

     LabelI.Text := 'DICOM ファイルをドロップするか、Open で開いてください。';

     if ( ParamCount >= 1 ) and FileExists( ParamStr( 1 ) ) then LoadFile( ParamStr( 1 ) );
end;

procedure TForm1.FormDestroy( Sender:TObject );
begin
     _File.Free;
end;

//------------------------------------------------------------------------------

procedure TForm1.ButtonOClick( Sender:TObject );
begin
     if OpenDialog1.Execute then LoadFile( OpenDialog1.FileName );
end;

//------------------------------------------------------------------------------

procedure TForm1.TreeView1DragOver( Sender:TObject; const Data:TDragObject; const Point:TPointF; var Operation:TDragOperation );
begin
     if Length( Data.Files ) > 0 then Operation := TDragOperation.Copy;
end;

procedure TForm1.TreeView1DragDrop( Sender:TObject; const Data:TDragObject; const Point:TPointF );
begin
     if Length( Data.Files ) > 0 then LoadFile( Data.Files[ 0 ] );
end;

end. //######################################################################### ■
