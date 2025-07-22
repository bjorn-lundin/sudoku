
with  FLTK.Widgets.Groups.Windows;
with  FLTK.Widgets.Menus.Menu_Bars;
with  FLTK.Widgets.Menus.Menu_Buttons;
with  FLTK.Widgets.Inputs.Text;
with  FLTK.Widgets.Boxes;
with  FLTK.Widgets.Buttons.Enter;

package sudoku is

    Min_Editor_Height : constant Integer := 60;
    Min_Editor_Width  : constant Integer := 300;

    type Row_Range is range 1..9;
    function "*"(Left : Integer; Right : Row_Range) return Integer is (Left * Integer(Right));


    type Column_Range is range 1..9;
    function "*"(Left : Integer; Right : Column_Range) return Integer is (Left * Integer(Right));

    type Grid_Array is array(Row_Range, Column_Range) of FLTK.Widgets.Inputs.Text.Text_Input;

    type Sudoku_Window is new FLTK.Widgets.Groups.Windows.Window with record
        Bar    : aliased FLTK.Widgets.Menus.Menu_Bars.Menu_Bar;
        Popup  : aliased FLTK.Widgets.Menus.Menu_Buttons.Menu_Button;
        Box_1  : FLTK.Widgets.Boxes.Box;       
        Grid_1 : Grid_Array;
        Box_2  : FLTK.Widgets.Boxes.Box;       
        Grid_2 : Grid_Array;
        btn_Analyze :  FLTK.Widgets.Buttons.Enter.Enter_Button;
    end record;

    function Create return Sudoku_Window;
    procedure Add_New_Grid_Item
           (self : in out Sudoku_Window;
            r : Row_Range;
            c : Column_Range;
            Char : in Character);

    procedure Load_file(self : in out Sudoku_Window);


    procedure Show;

    procedure Hide;


end sudoku;


