

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


package body Windows.Replace is


    package W  renames FLTK.Widgets.Groups.Windows;
    package WD renames FLTK.Widgets.Groups.Windows.Double;
    package IP renames FLTK.Widgets.Inputs.Text;
    package BU renames FLTK.Widgets.Buttons;
    package EN renames FLTK.Widgets.Buttons.Enter;
    package LC renames FLTK.Widgets.Buttons.Light.Check;




    procedure Replace_M
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        use type BU.State;
        type Replace_Window_Access is access all Replace_Window;
        Dialog : constant access Replace_Window := Replace_Window_Access (Item.Parent);
    begin
        if Dialog.Callback /= null then
            Dialog.Callback.all
               (Dialog.Find_What.Get_Value,
                Dialog.Replace_With.Get_Value,
                Dialog.Match_Case.Get_State = BU.On,
                Dialog.Replace_All.Get_State = BU.On);
        end if;
    end Replace_M;




    function Create
        return Replace_Window
    is
        My_Width           : constant Integer := 350;
        My_Height          : constant Integer := 180;

        Button_Width       : constant Integer := 140;
        Button_Height      : constant Integer := 40;

        Find_Line          : constant Integer := 10;
        Replace_Line       : constant Integer := 40;
        Match_Line         : constant Integer := 80;
        Rep_All_Line       : constant Integer := 100;
        Button_Line        : constant Integer := 130;

        Input_Width        : constant Integer := 220;
        Input_Height       : constant Integer := 25;
        Input_Margin_Right : constant Integer := 10;

        Check_Width        : constant Integer := 100;
        Check_Height       : constant Integer := 20;
        Check_Margin_Left  : constant Integer := 50;

        Text_Size          : constant Integer := 12;
    begin
        return This : Replace_Window :=
           (WD.Forge.Create (0, 0, My_Width, My_Height, "Replace")
        with
            Find_What    => IP.Forge.Create
               (My_Width - Input_Width - Input_Margin_Right,
                Find_Line, Input_Width, Input_Height, "Find what:"),
            Replace_With => IP.Forge.Create
               (My_Width - Input_Width - Input_Margin_Right,
                Replace_Line, Input_Width, Input_Height, "Replace with:"),
            Match_Case   => LC.Forge.Create
               (Check_Margin_Left, Match_Line,
                Check_Width, Check_Height, "Match case"),
            Replace_All  => LC.Forge.Create
               (Check_Margin_Left, Rep_All_Line,
                Check_Width, Check_Height, "Replace all"),
            Cancel       => BU.Forge.Create
               ((My_Width - 2 * Button_Width) / 3,
                Button_Line, Button_Width, Button_Height, "Cancel"),
            Start        => EN.Forge.Create
               ((My_Width - 2 * Button_Width) * 2 / 3 + Button_Width,
                Button_Line, Button_Width, Button_Height, "Replace"),
            Callback     => null)
        do
            This.Add (This.Find_What);
            This.Add (This.Replace_With);
            This.Add (This.Match_Case);
            This.Add (This.Replace_All);
            This.Add (This.Cancel);
            This.Cancel.Set_Callback (Hide_CB'Access);
            This.Add (This.Start);
            This.Start.Set_Callback (Replace_M'Access);

            This.Set_Icon (Logo);

            This.Set_Callback (Hide_CB'Access);
            This.Set_Modal_State (W.Modal);
        end return;
    end Create;




    procedure Set_Replace_Callback
           (This : in out Replace_Window;
            Func : in     Replace_Callback) is
    begin
        This.Callback := Func;
    end Set_Replace_Callback;


end Windows.Replace;


