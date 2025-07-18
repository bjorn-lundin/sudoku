

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


private with

    FLTK.Widgets.Buttons.Enter,
    FLTK.Widgets.Inputs.Text.Whole_Number;


package Windows.Jump is


    type Jump_Window is new Window with private;

    type Jump_Callback is access procedure
        (Line_Number : in Positive);




    function Create
        return Jump_Window;




    procedure Set_Jump_Callback
           (This : in out Jump_Window;
            Func : in     Jump_Callback);


private


    type Jump_Window is new Window with record
        To_Line  : FLTK.Widgets.Inputs.Text.Whole_Number.Integer_Input;
        Cancel   : FLTK.Widgets.Buttons.Button;
        Go_Jump  : FLTK.Widgets.Buttons.Enter.Enter_Button;
        Callback : Jump_Callback;
    end record;


end Windows.Jump;


