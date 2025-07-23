

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


with
    text_io,
    Ada.Strings, 
    Ada.Strings.fixed, 
    Ada.Strings.Unbounded,
--    Change_Vectors,
    FLTK.Widgets.Menus,
    FLTK.Asks,
    Windows.About;

use

    Ada.Strings, 
    Ada.Strings.fixed, 
    Ada.Strings.Unbounded;


package body sudoku is

    --  Forward declarations of helper functions.

    First_Time : Boolean := True;

    procedure Analyze_CB(Item : in out FLTK.Widgets.Widget'Class) ; --forward


    procedure Centre (Win : in out FLTK.Widgets.Groups.Windows.Window'Class);
    --  Global state of the text editor.
    About    : Windows.About.About_Window     := Windows.About.Create;
    Changed  : Boolean                      := False;
    Filename : Unbounded_String             := To_Unbounded_String (0);
----------------------------------------------------------------------------------

    procedure Add_New_Grid_Item
           (self : in out Sudoku_Window;
            r : Row_Range;
            c : Column_Range;
            Char : in Character) is
    begin
        case Char is
        when '0' =>
            self.Grid_1(r,c).Set_Value ("-");

        when '1' .. '9' =>
            declare
              dummy : string(1..1) := (1 => char);
            begin
              self.Grid_1(r,c).Set_Value (dummy);
              Self.Grid_1(r,c).Set_Readonly(True);
              Self.Grid_2(r,c).Set_Background_color(Fltk.RGB_Color(255,0,0));
            end;
        when others =>
            raise Program_Error with "bad char '" & char & "'";

        end case;
    end Add_New_Grid_Item;

-----------------------------------------------------------

    procedure Load_file(self : in out Sudoku_Window) is
      Data_File : Text_io.file_type;
      len : Natural := 0;
      buffer : string(1..100);
      filename : string := "sdk.dat";
      row : row_Range := 1;
      i : natural ;
    begin
      begin
        text_io.Open (Data_File, text_io.In_File, Filename);
        loop
          text_io.Get_Line(Data_File, Buffer, Len);
          for col in column_range loop
            i := integer(col);
            self.Add_New_Grid_Item (row,col,buffer(i));
          end loop;
          if row < 9 then
            row := row +1;
          end if;
        end loop;
      exception
       when text_io.End_Error => 
         text_io.close(Data_File);
      end;
            -- fix up look 
      for r in Row_Range loop
        for c in Column_Range loop
          if Self.Grid_1(r,c).Get_Value = "-" then
            Self.Grid_1(r,c).Set_Background_Color(Fltk.RGB_Color(128,128,128));
            Self.Grid_1(r,c).Set_Value("");
          end if;
        end loop;
      end loop; 
    end load_file;

--------------------------------------------------------------
    function Create return Sudoku_Window  is
        Width       : Integer := Min_Editor_Width;
        Height      : Integer := Min_Editor_Height;
        Menu_Height : constant Integer := 22;
        use all type Fltk.Color;
        offset_x : Natural := 0;
        offset_y : Natural := 0;
    begin
        return Self : Sudoku_Window :=
           (FLTK.Widgets.Groups.Windows.Forge.Create(1250,450,"Sudoku Helper")
        with
            Bar    =>  FLTK.Widgets.Menus.Menu_Bars.Forge.Create(0, 0, Width, Menu_Height, ""),
            Popup  =>  FLTK.Widgets.Menus.Menu_Buttons.Forge.Create(0, Menu_Height, Width, Height - Menu_Height, ""),
            Box_1  => FLTK.Widgets.Boxes.Forge.Create(Fltk.Border_Box, 0,0,310,350,""),
            Grid_1 => (others => (others => FLTK.Widgets.Inputs.Text.Forge.Create(10,20,50,50))),
            Box_2  => FLTK.Widgets.Boxes.Forge.Create(Fltk.Border_Box, 320,0,950,350,""),
            Grid_2 => (others => (others => FLTK.Widgets.Inputs.Text.Forge.Create(10,20,50,50))),
            btn_Analyze =>  FLTK.Widgets.Buttons.Enter.Forge.Create(50, 370, 150, 75, "Analyze")
           )
        do
            Self.Box_1.Set_Background_Color(Fltk.RGB_Color(0,255,0));
            Self.Add(Self.Box_1);

            Self.Box_2.Set_Background_Color(Fltk.RGB_Color(0,128,128));
            Self.Add(Self.Box_2);

            for r in Row_Range loop
              for c in Column_Range loop
                 if r > 6 then
                   offset_y := 20;
                 elsif r > 3 then
                   offset_y := 10;
                 else
                   offset_y := 0;
                 end if;
                 if c > 6 then
                   offset_x := 20;
                 elsif c > 3 then
                   offset_x := 10;
                 else
                   offset_x := 0;
                 end if;
--            text_io.put_line(r'img & c'img & offset_y'img & offset_x'img);
                 Self.Grid_1(r,c).Resize(X => offset_x + 30*c-16, Y => offset_y + 30*r-10, W => 25, H=> 25);
                 Self.Add (Self.Grid_1(r, c));

                 Self.Grid_2(r,c).Resize(X => offset_x + 100*c-70 +300, Y => offset_y + 30*r-10 , W => 70, H=> 25);
                 Self.Add (Self.Grid_2(r, c));
              end loop;
            end loop; 


            Self.btn_Analyze.Set_Box(Fltk.Plastic_Up_Box);
            Self.btn_Analyze.Set_Callback(Analyze_CB'access);
            Self.btn_Analyze.Set_Tooltip("a useful tooltip");
            Self.Add(Self.btn_Analyze); 



            -- fix up look 
            --for r in Row_Range loop
            --   for c in Column_Range loop
            --     if Self.Grid_1(r,c).Get_Value = "-" then
            --       Self.Grid_1(r,c).Set_Background_Color(Fltk.RGB_Color(128,128,128));
            --       Self.Grid_1(r,c).Set_Value("");
            --     end if;
            --  end loop;
            --end loop; 



 --           Self.Set_Callback (Hide_CB'Access);
--            Self.Set_Modal_State (W.Modal);
        end return;
    end Create;

    function check_row(self : in out Sudoku_Window;
                        n : Number_Range;
                        r : Row_Range;
                        c : Column_Range) return Boolean is
      ret : boolean := True;
    begin
      for cc in Column_Range loop
          if r=1 then
            text_io.put_line("'" & trim(self.Grid_1(r,cc).Get_Value,Both) & "' -> '" & trim(n'image,both) & "'");
          end if; 
        if trim(self.Grid_1(r,cc).Get_Value,Both) = trim(n'image,both) then
          ret := False;
          exit;
        end if;
      end loop;
      text_io.put_line("check_row ret " & ret'img);
      return ret ;

    end check_row;

    -------------------------------------

    function check_col(self : in out Sudoku_Window;
                        n : Number_Range;
                        r : Row_Range;
                        c : Column_Range) return Boolean is
      ret : boolean := True;
    begin
      for rr in Row_Range loop
          if c=1 then
            text_io.put_line("'" & trim(self.Grid_1(rr,c).Get_Value,Both) & "' -> '" & trim(n'image,both) & "'");
          end if; 
        if trim(self.Grid_1(rr,c).Get_Value,Both) = trim(n'image,both) then
          ret := False;
          exit; 
        end if;
      end loop;
      text_io.put_line("check_col ret " & ret'img);
      return ret ;
    end check_col;

    -------------------------------------

    function check_square(self : in out Sudoku_Window;
                        n : Number_Range;
                        r : Row_Range;
                        c : Column_Range) return Boolean is

--      is_ok : Boolean := True;
      c1,c2 :Column_Range;
      r1,r2 :row_Range;
    begin
 --     text_io.put_Line("check_square doing nothing");
 --     return True; 
      -- what square are we in?
      --  1|2|3
      --  4|5|6
      --  7|8|9
          ----- 

      case r is
        when 1..3 =>
          case c is
            when 1..3 => c1 := 1; c2:= 3; r1:=1; r2:=3; 
            when 4..6 => c1 := 4; c2:= 6; r1:=1; r2:=3;
            when 7..9 => c1 := 7; c2:= 9; r1:=1; r2:=3;
          end case;
        when 4..6 =>
          case c is
            when 1..3 => c1 := 1; c2:= 3; r1:=4; r2:=6; 
            when 4..6 => c1 := 4; c2:= 6; r1:=4; r2:=6;
            when 7..9 => c1 := 7; c2:= 9; r1:=4; r2:=6;
          end case;
        when 7..9 =>
          case c is
            when 1..3 => c1 := 1; c2:= 3; r1:=7; r2:=9; 
            when 4..6 => c1 := 4; c2:= 6; r1:=7; r2:=9;
            when 7..9 => c1 := 7; c2:= 9; r1:=7; r2:=9;
          end case;
      end case;
     
      for c0 in c1 .. c2 loop
         for r0 in r1 .. r2 loop
           if trim(self.grid_1(r0,c0).get_value,Both) = trim(n'image,both) then
              return false;
           end if;
         end loop;
      end loop;

      return True;

    end check_square;

    -------------------------------------


    ---------------------------------------------

    --  Main program interface.

   -----------------------------------------------------------

    w : Sudoku_Window := Create;
   -----------------------------------------------------------



    procedure Analyze_CB(Item : in out FLTK.Widgets.Widget'Class) is
        use type FLTK.Widgets.Buttons.State;
--        type Find_Window_Access is access all Find_Window;
--        Dialog : constant access Find_Window := Find_Window_Access (Item.Parent);
    begin
      text_io.put_Line("Analyze_CB start");

      if item in FLTK.Widgets.Buttons.Enter.Enter_Button then
         declare
            btn : FLTK.Widgets.Buttons.Enter.Enter_Button renames FLTK.Widgets.Buttons.Enter.Enter_Button(item);
         begin 
           text_io.put_Line("Analyze_CB Item is FLTK.Widgets.Buttons.Enter.Enter_Button ");
           text_io.put_Line("Analyze_CB Item state " & btn.Get_State'image );
           text_io.put_Line("Analyze_CB Item is_on " & btn.is_on'image );
           text_io.put_Line("Analyze_CB Item Get_Down_Box " & btn.Get_Down_Box'image );
           text_io.put_Line("Analyze_CB Item Get_Shortcut " & btn.Get_Shortcut'image );
           text_io.put_Line("Analyze_CB Item Get_Label " & btn.Get_Label'image );
           text_io.put_Line("Analyze_CB Item Get_Label_Color " & btn.Get_Label_Color'image );
           text_io.put_Line("Analyze_CB Item Get_Label_Font " & btn.Get_Label_Font'image );
           text_io.put_Line("Analyze_CB Item Get_Label_Size " & btn.Get_Label_Size'image );
           text_io.put_Line("Analyze_CB Item Get_Label_Kind " & btn.Get_Label_Kind'image );
           text_io.put_Line("Analyze_CB Item Get_X " & btn.Get_X'image );
           text_io.put_Line("Analyze_CB Item Get_Y " & btn.Get_Y'image );
           text_io.put_Line("Analyze_CB Item Get_W " & btn.Get_W'image );
           text_io.put_Line("Analyze_CB Item Get_H " & btn.Get_H'image );
           text_io.put_Line("Analyze_CB Item Is_Active " & btn.Is_Active'image );
           text_io.put_Line("Analyze_CB Item Get_Alignment " & btn.Get_Alignment'image );
           text_io.put_Line("Analyze_CB Item Get_Background_Color " & btn.Get_Background_Color'image );
           text_io.put_Line("Analyze_CB Item Get_Selection_Color " & btn.Get_Selection_Color'image );


           --clear grid2
           for r in Row_Range loop
             for c in Column_Range loop
               w.Grid_2(r,c).Set_Value("");
             end loop;
           end loop;


           for r in Row_Range loop
               for c in Column_Range loop
                   for n in number_range loop
                     declare
                       row_ok : boolean := False;
                       col_ok : boolean := False;
                       square_ok : boolean := False;
                     begin
                       row_ok := w.check_row(n,r,c);
                       col_ok := w.check_col(n,r,c);
                       square_ok := w.check_square(n,r,c);

                       if row_ok 
                         and col_ok
                         and square_ok 
                       then
                          declare
                            v : constant string := Trim(w.Grid_2(r,c).Get_Value,both);
                            nv : constant string := trim(n'image,both);
                            already_present : boolean := false;
                          begin 
                            for i in v'range loop
                              if v(i..i) = nv then
                                already_present := true;
                                exit;
                              end if;
                            end loop;

                            if not Already_present 
                              and then not w.Grid_1(r,c).is_readonly
                            then
                              w.Grid_2(r,c).Set_Value(v & nv);
                              if v'length + nv'length = 1 then
                                w.Grid_2(r,c).Set_Background_Color(Fltk.RGB_Color(0,255,0)); --green
                              elsif v'length + nv'length = 2 then
                                w.Grid_2(r,c).Set_Background_Color(Fltk.RGB_Color(0,0,255)); --blue
                              else
                                w.Grid_2(r,c).Set_Background_Color(Fltk.RGB_Color(255,0,0)); --red
                              end if;
                            end if;
                          end;
                       end if;
                     end;
                   end loop;
               end loop;
             end loop;
      --       first_time := False;
      --     end if; 

         end;
      else
         text_io.put_Line("Analyze_CB Item is NOT a button");
      end if;
      text_io.put_Line("Analyze_CB " & Item'image);
      text_io.put_Line("Analyze_CB stop");
    end Analyze_CB;

    ----------------------------------------------------------
    
--    function Handle
--           (This  : in out Enter_Button;
--           Event : in     Event_Kind)
--        return Event_Outcome;

    function Get_Menu_Bar(Self : in out Sudoku_Window)
        return FLTK.Widgets.Menus.Menu_Reference is
    begin
        return Ref : FLTK.Widgets.Menus.Menu_Reference (Self.Bar'Unchecked_Access);
    end Get_Menu_Bar;


    function Get_Rightclick_Menu(Self : in out Sudoku_Window)
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
      w.load_file;
      text_io.put_line("Sudoku.Show, 3");
    end Show;


    procedure Hide is
    begin
        About.Hide;
        w.Hide;
    end Hide;




    --  Callbacks for the menu.


    procedure Open_CB(Item : in out FLTK.Widgets.Widget'Class) is
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
    procedure Quit_CB(Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Hide;
    end Quit_CB;
    -----------------------------------
    procedure About_CB(Item : in out FLTK.Widgets.Widget'Class) is
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


