

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


package body Windows.Jump is


    package W  renames FLTK.Widgets.Groups.Windows;
    package WD renames FLTK.Widgets.Groups.Windows.Double;
    package BU renames FLTK.Widgets.Buttons;
    package EN renames FLTK.Widgets.Buttons.Enter;
    package IT renames FLTK.Widgets.Inputs.Text.Whole_Number;




    procedure Jump_M
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        type Jump_Window_Access is access all Jump_Window;
        Dialog : constant access Jump_Window := Jump_Window_Access (Item.Parent);

        Line : constant Long_Integer := Dialog.To_Line.Get_Value;
    begin
        if Dialog.Callback /= null then
            if Line <= 0 then
                Dialog.Callback (1);
            elsif Line > Long_Integer (Integer'Last) then
                Dialog.Callback (Integer'Last);
            else
                Dialog.Callback (Integer (Line));
            end if;
        end if;
    end Jump_M;




    function Create
        return Jump_Window
    is
        My_Width           : constant Integer := 350;
        My_Height          : constant Integer := 110;

        Button_Width       : constant Integer := 140;
        Button_Height      : constant Integer := 40;

        Input_Line         : constant Integer := 10;
        Button_Line        : constant Integer := 60;

        Input_Width        : constant Integer := 240;
        Input_Height       : constant Integer := 25;
        Input_Margin_Right : constant Integer := 10;
    begin
        return This : Jump_Window :=
           (WD.Forge.Create (0, 0, My_Width, My_Height, "Jump")
        with
            To_Line  => IT.Forge.Create
               (My_Width - Input_Width - Input_Margin_Right,
                Input_Line, Input_Width, Input_Height, "Jump to:"),
            Cancel   => BU.Forge.Create
               ((My_Width - 2 * Button_Width) / 3,
                Button_Line, Button_Width, Button_Height, "Cancel"),
            Go_Jump  => EN.Forge.Create
               ((My_Width - 2 * Button_Width) * 2 / 3 + Button_Width,
                Button_Line, Button_Width, Button_Height, "Jump"),
            Callback => null)
        do
            This.Add (This.To_Line);
            This.Add (This.Cancel);
            This.Cancel.Set_Callback (Hide_CB'Access);
            This.Add (This.Go_Jump);
            This.Go_Jump.Set_Callback (Jump_M'Access);

            This.Set_Icon (Logo);

            This.Set_Callback (Hide_CB'Access);
            This.Set_Modal_State (W.Modal);
        end return;
    end Create;




    procedure Set_Jump_Callback
           (This : in out Jump_Window;
            Func : in     Jump_Callback) is
    begin
        This.Callback := Func;
    end Set_Jump_Callback;


end Windows.Jump;


