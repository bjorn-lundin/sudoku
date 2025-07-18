

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


package body Windows.Find is


    package W  renames FLTK.Widgets.Groups.Windows;
    package WD renames FLTK.Widgets.Groups.Windows.Double;
    package IP renames FLTK.Widgets.Inputs.Text;
    package BU renames FLTK.Widgets.Buttons;
    package EN renames FLTK.Widgets.Buttons.Enter;
    package LC renames FLTK.Widgets.Buttons.Light.Check;




    procedure Find_M
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        use type BU.State;
        type Find_Window_Access is access all Find_Window;
        Dialog : constant access Find_Window := Find_Window_Access (Item.Parent);
    begin
        if Dialog.Callback /= null then
            Dialog.Callback.all
               (Dialog.Find_What.Get_Value,
                Dialog.Match_Case.Get_State = BU.On,
                Forward);
        end if;
    end Find_M;




    function Create
        return Find_Window
    is
        My_Width           : constant Integer := 350;
        My_Height          : constant Integer := 130;

        Button_Width       : constant Integer := 140;
        Button_Height      : constant Integer := 40;

        Input_Line         : constant Integer := 10;
        Case_Line          : constant Integer := 50;
        Button_Line        : constant Integer := 80;

        Input_Width        : constant Integer := 240;
        Input_Height       : constant Integer := 25;
        Input_Margin_Right : constant Integer := 10;

        Check_Width        : constant Integer := 100;
        Check_Height       : constant Integer := 20;
        Case_Margin_Left   : constant Integer := 50;

        Text_Size          : constant Integer := 12;
    begin
        return This : Find_Window :=
           (WD.Forge.Create (0, 0, My_Width, My_Height, "Find")
        with
            Find_What  => IP.Forge.Create
               (My_Width - Input_Width - Input_Margin_Right,
                Input_Line, Input_Width, Input_Height, "Find what:"),
            Match_Case => LC.Forge.Create
               (Case_Margin_Left, Case_Line, Check_Width, Check_Height, "Match case"),
            Cancel     => BU.Forge.Create
               ((My_Width - 2 * Button_Width) / 3,
                Button_Line, Button_Width, Button_Height, "Cancel"),
            Start      => EN.Forge.Create
               ((My_Width - 2 * Button_Width) * 2 / 3 + Button_Width,
                Button_Line, Button_Width, Button_Height, "Find"),
            Callback   => null)
        do
            This.Add (This.Find_What);
            This.Add (This.Match_Case);
            This.Add (This.Cancel);
            This.Cancel.Set_Callback (Hide_CB'Access);
            This.Add (This.Start);
            This.Start.Set_Callback (Find_M'Access);

            This.Set_Icon (Logo);

            This.Set_Callback (Hide_CB'Access);
            This.Set_Modal_State (W.Modal);
        end return;
    end Create;




    procedure Set_Find_Callback
           (This : in out Find_Window;
            Func : in     Find_Callback) is
    begin
        This.Callback := Func;
    end Set_Find_Callback;


    procedure Do_Callback
           (This : in Find_Window;
            Dir  : in Direction := Forward)
    is
        use type BU.State;
    begin
        if This.Callback /= null then
            This.Callback.all
               (This.Find_What.Get_Value,
                This.Match_Case.Get_State = BU.On,
                Dir);
        end if;
    end Do_Callback;


end Windows.Find;


