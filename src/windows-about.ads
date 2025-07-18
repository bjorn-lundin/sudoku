

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


private with

    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Enter;


package Windows.About is


    type About_Window is new Window with private;


    function Create
        return About_Window;


private


    type About_Window is new Window with record
        Picture : FLTK.Widgets.Boxes.Box;
        Heading : FLTK.Widgets.Boxes.Box;
        Blurb   : FLTK.Widgets.Boxes.Box;
        Author  : FLTK.Widgets.Boxes.Box;
        Dismiss : FLTK.Widgets.Buttons.Enter.Enter_Button;
    end record;


end Windows.About;


