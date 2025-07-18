

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


with

    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Images.RGB,
    Images;


package Windows is


    type Window is new FLTK.Widgets.Groups.Windows.Double.Double_Window with private;


private


    type Window is new FLTK.Widgets.Groups.Windows.Double.Double_Window with null record;


    procedure Hide_CB
           (Item : in out FLTK.Widgets.Widget'Class);


    Logo : FLTK.Images.RGB.RGB_Image'Class := Images.Load_Logo;


end Windows;


