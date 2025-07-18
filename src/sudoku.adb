

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


with
    text_io,
    Ada.Strings.Unbounded,
--    Change_Vectors,
    FLTK.Widgets.Menus,
    FLTK.Asks,
    Windows.About;

use

    Ada.Strings.Unbounded;


package body sudoku is


    --  Forward declarations of helper functions.




    procedure Centre (Win : in out FLTK.Widgets.Groups.Windows.Window'Class);




    --  Global state of the text editor.

--    Editor   : Windows.Editor.Editor_Window   := Windows.Editor.Create (800, 500);
--    Buffer   : FLTK.Text_Buffers.Text_Buffer  := FLTK.Text_Buffers.Forge.Create;
    About    : Windows.About.About_Window     := Windows.About.Create;

    Changed  : Boolean                      := False;
--    Mod_List : Change_Vectors.Change_Vector := Change_Vectors.Empty_Vector;
    Filename : Unbounded_String             := To_Unbounded_String (0);

 




    --  Main program interface.

--------------------------------------------------------------
    function Create return Sudoku_Window  is
        Width       : Integer := Min_Editor_Width;
        Height      : Integer := Min_Editor_Height;
        Menu_Height : constant Integer := 22;
    begin
       

        return Self : Sudoku_Window :=
           (FLTK.Widgets.Groups.Windows.Forge.Create(1250,400,"Sudoku Helper")
        with
            Bar    =>  FLTK.Widgets.Menus.Menu_Bars.Forge.Create(0, 0, Width, Menu_Height, ""),
            Popup  =>  FLTK.Widgets.Menus.Menu_Buttons.Forge.Create(0, Menu_Height, Width, Height - Menu_Height, ""),
            Box_1  => FLTK.Widgets.Boxes.Forge.Create(Fltk.Border_Box, 0,0,300,300,""),
            Grid_1 => (others => (others => FLTK.Widgets.Inputs.Text.Forge.Create(10,20,50,50))),
            Box_2  => FLTK.Widgets.Boxes.Forge.Create(Fltk.Border_Box, 320,0,900,300,""),
            Grid_2 => (others => (others => FLTK.Widgets.Inputs.Text.Forge.Create(10,20,50,50)))
           )
        do
            Self.Box_1.Set_Background_Color(Fltk.RGB_Color(0,255,0));
            Self.Add(Self.Box_1);

            for r in Row_Range loop
              for c in Column_Range loop
                 Self.Grid_1(r,c).Resize(X => 30*c-10, Y => 30*r-10 , W => 25, H=> 25);
                 Self.Add (Self.Grid_1(r, c));
              end loop;
            end loop; 

            Self.Box_2.Set_Background_Color(Fltk.RGB_Color(0,128,128));
            Self.Add(Self.Box_2);

            for r in Row_Range loop
              for c in Column_Range loop
                 Self.Grid_2(r,c).Resize(X => 100*c-80 +300, Y => 30*r-10 , W => 100, H=> 25);
                 Self.Add (Self.Grid_2(r, c));
              end loop;
            end loop; 


 --           Self.Set_Callback (Hide_CB'Access);
--            Self.Set_Modal_State (W.Modal);
        end return;
    end Create;

   -----------------------------------------------------------

    w : Sudoku_Window := Create;
   -----------------------------------------------------------

    function Get_Menu_Bar
           (Self : in out Sudoku_Window)
        return FLTK.Widgets.Menus.Menu_Reference is
    begin
        return Ref : FLTK.Widgets.Menus.Menu_Reference (Self.Bar'Unchecked_Access);
    end Get_Menu_Bar;


    function Get_Rightclick_Menu
           (Self : in out Sudoku_Window)
        return FLTK.Widgets.Menus.Menu_Reference is
    begin
        return Ref : FLTK.Widgets.Menus.Menu_Reference (Self.Popup'Unchecked_Access);
    end Get_Rightclick_Menu;

     ------------------------------------------------------




    procedure Init(Self : in out Sudoku_Window) is
    begin 
   --     Self.Bar    := Self.Get_Menu_Bar;
   --     Self.Popup  := Self.Get_Rightclick_Menu;
   --     Self.Box1   := FLTK.Widgets.Boxes.Forge(self,10,20,30,40,"The box") ;    
        for r in 1..9 loop
          for c in 1..9 loop
null;
--            Self.Grid_1 := FLTK.Widgets.Inputs.Text.Forge.Create(r+10,c+10,15,15);
          end loop;
        end loop; 
    end Init;

    ----------------------------------------------

    procedure Show is
    begin
      text_io.put_line("Sudoku.Show, 1");
      w.Show;
      text_io.put_line("Sudoku.Show, 2");
    end Show;


    procedure Hide is
    begin
        About.Hide;
        w.Hide;
    end Hide;




    --  Callbacks for the menu.


    procedure Open_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        declare
            New_Filename : constant String :=
                FLTK.Asks.File_Chooser ("Open File?", "*", To_String (Filename));
        begin
            if New_Filename /= "" then
                FLTK.Asks.Message_Box (New_Filename);
            end if;
        end;
    end Open_CB;
    -----------------------------------
    procedure Quit_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Hide;
    end Quit_CB;
    -----------------------------------
    procedure About_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Centre (About);
        About.Show;
    end About_CB;
    -----------------------------------

   procedure Paste_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        text_io.put_line("Paste_CB");
    end Paste_CB;

---------------------------------------------

   procedure Delete_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        text_io.put_line("Delete_CB");
    end Delete_CB;

---------------------------------------------
    procedure Centre
           (Win : in out FLTK.Widgets.Groups.Windows.Window'Class)
    is
        Middle_X : constant Integer := w.Get_X + w.Get_W / 2;
        Middle_Y : constant Integer := w.Get_Y + w.Get_H / 2;
    begin
        Win.Reposition
           (Middle_X - Win.Get_W / 2,
            Middle_Y - Win.Get_H / 2);
    end Centre;

  -----------------------------------------

begin
    text_io.put_line("Sudoku.elaboration, 1");

    text_io.put_line("Sudoku.elaboration, 2");

    -------------------------------------------

    declare
        use FLTK;
        use FLTK.Widgets.Menus;
        Bar : constant Menu_Reference := w.Get_Menu_Bar;
    begin
        Bar.Add (Text => "&File", Flags => Flag_Submenu);
        Bar.Add ("File/&Quit", Quit_CB'Access, Mod_Ctrl + 'q');
        Bar.Add (Text => "&Help", Flags => Flag_Submenu);
        Bar.Add ("Help/&About", About_CB'Access);
    end;
    text_io.put_line("Sudoku.elaboration, 3");

    -------------------------------------------

    declare
        use FLTK;
        use FLTK.Widgets.Menus;
        Pop : constant Menu_Reference := w.Get_Rightclick_Menu;
    begin
--        Pop.Add ("Cu&t", Cut_CB'Access, No_Key, Flag_Inactive);
--        Pop.Add ("&Copy", Copy_CB'Access, No_Key, Flag_Inactive);
        Pop.Add ("&Paste", Paste_CB'Access);
        Pop.Add ("&Delete", Delete_CB'Access, No_Key, Flag_Inactive + Flag_Divider);
    --    Pop.Add ("Select &All", Select_All_CB'Access);
    end;

    text_io.put_line("Sudoku.elaboration, 4");

    w.Set_Callback (Quit_CB'Access);

    text_io.put_line("Sudoku.elaboration, 5");


end sudoku;


