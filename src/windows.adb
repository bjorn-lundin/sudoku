

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


package body Windows is


    package WN renames FLTK.Widgets.Groups.Windows;




    --  Used to hide about/find/replace/etc windows instead
    --  of constantly creating and destroying them.

    procedure Hide_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        P : access FLTK.Widgets.Groups.Group'Class;
    begin
        if Item in WN.Window'Class then
            WN.Window (Item).Hide;
        else
            P := Item.Parent;
            loop
                if P = null then
                    return;
                end if;
                exit when P.all in WN.Window'Class;
                P := P.Parent;
            end loop;
            WN.Window (P.all).Hide;
        end if;
    end Hide_CB;


end Windows;


