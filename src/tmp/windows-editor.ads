

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


with

    FLTK.Widgets.Menus,
    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Text_Displays;

private with

    FLTK.Widgets.Groups.Text_Displays.Text_Editors,
    FLTK.Widgets.Menus.Menu_Bars,
    FLTK.Widgets.Menus.Menu_Buttons;


package Windows.Editor is


    type Editor_Window is new Window with private;

    type Wrap_Mode is new FLTK.Widgets.Groups.Text_Displays.Wrap_Mode;


    Min_Editor_Height : constant Integer := 60;
    Min_Editor_Width  : constant Integer := 300;




    function Create
           (X, Y, W, H : in Integer;
            Label_Text : in String)
        return Editor_Window;

    function Create
           (W, H : in Integer)
        return Editor_Window;




    function Get_Buffer
           (This : in Editor_Window)
        return FLTK.Text_Buffers.Text_Buffer_Reference;

    procedure Set_Buffer
           (This : in out Editor_Window;
            Buff : in out FLTK.Text_Buffers.Text_Buffer);

    function Get_Menu_Bar
           (This : in out Editor_Window)
        return FLTK.Widgets.Menus.Menu_Reference;

    function Get_Rightclick_Menu
           (This : in out Editor_Window)
        return FLTK.Widgets.Menus.Menu_Reference;




    procedure Undo
           (This : in out Editor_Window);

    procedure Cut
           (This : in out Editor_Window);

    procedure Copy
           (This : in out Editor_Window);

    procedure Paste
           (This : in out Editor_Window);

    procedure Delete
           (This : in out Editor_Window);




    function Get_Insert_Position
           (This : in Editor_Window)
        return Natural;

    procedure Set_Insert_Position
           (This : in out Editor_Window;
            Pos  : in     Natural);

    procedure Show_Insert_Position
           (This : in out Editor_Window);

    procedure Next_Word
           (This : in out Editor_Window);

    procedure Previous_Word
           (This : in out Editor_Window);

    procedure Set_Wrap_Mode
           (This   : in out Editor_Window;
            Mode   : in     Wrap_Mode;
            Margin : in     Natural := 0);

    procedure Set_Linenumber_Width
           (This  : in out Editor_Window;
            Width : in     Natural);


private


    type Editor_Window is new Window with record
        Bar    : aliased FLTK.Widgets.Menus.Menu_Bars.Menu_Bar;
        Popup  : aliased FLTK.Widgets.Menus.Menu_Buttons.Menu_Button;
        Editor : FLTK.Widgets.Groups.Text_Displays.Text_Editors.Text_Editor;
    end record;


end Windows.Editor;


