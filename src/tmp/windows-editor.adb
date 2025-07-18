

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


package body Windows.Editor is


    package WD renames FLTK.Widgets.Groups.Windows.Double;
    package TD renames FLTK.Widgets.Groups.Text_Displays;
    package TE renames FLTK.Widgets.Groups.Text_Displays.Text_Editors;
    package MB renames FLTK.Widgets.Menus.Menu_Bars;
    package MU renames FLTK.Widgets.Menus.Menu_Buttons;




    function Create
           (X, Y, W, H : in Integer;
            Label_Text : in String)
        return Editor_Window
    is
        use FLTK;

        Width       : Integer := Min_Editor_Width;
        Height      : Integer := Min_Editor_Height;

        Menu_Height : constant Integer := 22;
    begin
        if Width < W then
            Width := W;
        end if;
        if Height < H then
            Height := H;
        end if;

        return This : Editor_Window :=
           (WD.Forge.Create (X, Y, Width, Height, Label_Text)
        with
            Editor => TE.Forge.Create
               (0, Menu_Height, Width, Height - Menu_Height, ""),
            Bar    => MB.Forge.Create
               (0, 0, Width, Menu_Height, ""),
            Popup  => MU.Forge.Create
               (0, Menu_Height, Width, Height - Menu_Height, ""))
        do
            This.Editor.Set_Text_Font (Courier);
            This.Add (This.Editor);

            This.Bar.Set_Box (No_Box);
            This.Add (This.Bar);

            This.Popup.Set_Box (No_Box);
            This.Popup.Set_Popup_Kind (MU.Popup3);
            This.Add (This.Popup);

            This.Set_Resizable (This.Editor);
            This.Set_Size_Range (Min_Editor_Width, Min_Editor_Height);

            This.Set_Icon (Logo);

            This.Editor.Remove_Key_Binding (Mod_Ctrl + 'z');
        end return;
    end Create;


    function Create
           (W, H : in Integer)
        return Editor_Window is
    begin
        return Create (0, 0, W, H, "(Untitled)");
    end Create;




    function Get_Buffer
           (This : in Editor_Window)
        return FLTK.Text_Buffers.Text_Buffer_Reference is
    begin
        return This.Editor.Get_Buffer;
    end Get_Buffer;


    procedure Set_Buffer
           (This : in out Editor_Window;
            Buff : in out FLTK.Text_Buffers.Text_Buffer) is
    begin
        This.Editor.Set_Buffer (Buff);
    end Set_Buffer;


    function Get_Menu_Bar
           (This : in out Editor_Window)
        return FLTK.Widgets.Menus.Menu_Reference is
    begin
        return Ref : FLTK.Widgets.Menus.Menu_Reference (This.Bar'Unchecked_Access);
    end Get_Menu_Bar;


    function Get_Rightclick_Menu
           (This : in out Editor_Window)
        return FLTK.Widgets.Menus.Menu_Reference is
    begin
        return Ref : FLTK.Widgets.Menus.Menu_Reference (This.Popup'Unchecked_Access);
    end Get_Rightclick_Menu;




    procedure Undo
           (This : in out Editor_Window) is
    begin
        This.Editor.KF_Undo;
    end Undo;


    procedure Cut
           (This : in out Editor_Window) is
    begin
        This.Editor.KF_Cut;
    end Cut;


    procedure Copy
           (This : in out Editor_Window) is
    begin
        This.Editor.KF_Copy;
    end Copy;


    procedure Paste
           (This : in out Editor_Window) is
    begin
        This.Editor.KF_Paste;
    end Paste;


    procedure Delete
           (This : in out Editor_Window) is
    begin
        This.Editor.KF_Delete;
    end Delete;




    function Get_Insert_Position
           (This : in Editor_Window)
        return Natural is
    begin
        return This.Editor.Get_Insert_Position;
    end Get_Insert_Position;


    procedure Set_Insert_Position
           (This : in out Editor_Window;
            Pos  : in     Natural) is
    begin
        This.Editor.Set_Insert_Position (Pos);
    end Set_Insert_Position;


    procedure Show_Insert_Position
           (This : in out Editor_Window) is
    begin
        This.Editor.Show_Insert_Position;
    end Show_Insert_Position;


    procedure Next_Word
           (This : in out Editor_Window) is
    begin
        This.Editor.Next_Word;
    end Next_Word;


    procedure Previous_Word
           (This : in out Editor_Window) is
    begin
        This.Editor.Previous_Word;
    end Previous_Word;


    procedure Set_Wrap_Mode
           (This   : in out Editor_Window;
            Mode   : in     Wrap_Mode;
            Margin : in     Natural := 0) is
    begin
        This.Editor.Set_Wrap_Mode (TD.Wrap_Mode (Mode), Margin);
    end Set_Wrap_Mode;


    procedure Set_Linenumber_Width
           (This  : in out Editor_Window;
            Width : in     Natural) is
    begin
        This.Editor.Set_Linenumber_Width (Width);
    end Set_Linenumber_Width;


end Windows.Editor;


