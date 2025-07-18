

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


private with

    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Buttons.Enter,
    FLTK.Widgets.Buttons.Light.Check;


package Windows.Find is


    type Find_Window is new Window with private;

    type Direction is (Forward, Backward);

    type Find_Callback is access procedure
           (Item       : in String;
            Match_Case : in Boolean;
            Facing     : in Direction);




    function Create
        return Find_Window;




    procedure Set_Find_Callback
           (This : in out Find_Window;
            Func : in     Find_Callback);

    procedure Do_Callback
           (This : in Find_Window;
            Dir  : in Direction := Forward);


private


    type Find_Window is new Window with record
        Find_What  : FLTK.Widgets.Inputs.Text.Text_Input;
        Match_Case : FLTK.Widgets.Buttons.Light.Check.Check_Button;
        Cancel     : FLTK.Widgets.Buttons.Button;
        Start      : FLTK.Widgets.Buttons.Enter.Enter_Button;
        Callback   : Find_Callback;
    end record;


end Windows.Find;


