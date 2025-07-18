

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


private with

    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Buttons.Enter,
    FLTK.Widgets.Buttons.Light.Check;


package Windows.Replace is


    type Replace_Window is new Window with private;

    type Replace_Callback is access procedure
           (Item, Replace_With  : in String;
            Match_Case, Rep_All : in Boolean);




    function Create
        return Replace_Window;




    procedure Set_Replace_Callback
           (This : in out Replace_Window;
            Func : in     Replace_Callback);


private


    type Replace_Window is new Window with record
        Find_What, Replace_With : FLTK.Widgets.Inputs.Text.Text_Input;
        Match_Case, Replace_All : FLTK.Widgets.Buttons.Light.Check.Check_Button;
        Cancel                  : FLTK.Widgets.Buttons.Button;
        Start                   : FLTK.Widgets.Buttons.Enter.Enter_Button;
        Callback                : Replace_Callback;
    end record;


end Windows.Replace;


