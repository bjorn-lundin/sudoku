

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


with

    FLTK.Text_Buffers;

use type

    FLTK.Text_Buffers.Modification;


package body Change_Vectors is


    function Continues_Insert
           (Orig, Cont : in Change)
        return Boolean is
    begin
        return
            Orig.Action = FLTK.Text_Buffers.Insert and then
            Integer (Orig.Place) + Orig.Length = Integer (Cont.Place) and then
            Cont.Length = 1 and then
            (Element (Orig.Text, Orig.Length) /= ' ' or else Element (Cont.Text, 1) = ' ');
    end Continues_Insert;


    function Continues_Delete
           (Orig, Cont : in Change)
        return Boolean is
    begin
        return
            Orig.Action = FLTK.Text_Buffers.Delete and then
            Orig.Place = Cont.Place and then
            Cont.Length = 1;
    end Continues_Delete;


    function Continues_Backspace
           (Orig, Cont : in Change)
        return Boolean is
    begin
        return
            Orig.Action = FLTK.Text_Buffers.Delete and then
            Orig.Place = Cont.Place + 1 and then
            Cont.Length = 1;
    end Continues_Backspace;




    procedure Push
           (This : in out Change_Vector;
            Item : in     Change)
    is
        procedure App
               (Ch : in out Change) is
        begin
            Ch.Length := Ch.Length + 1;
            Append (Ch.Text, Item.Text);
        end App;

        procedure Pre
               (Ch : in out Change) is
        begin
            Ch.Length := Ch.Length + 1;
            Ch.Text := Item.Text & Ch.Text;
            Ch.Place := Ch.Place - 1;
        end Pre;
    begin
        if Item.Action = FLTK.Text_Buffers.Insert then
            if  This.Near > 0 and then
                Continues_Insert (This.List.Element (This.Near), Item)
            then
                This.List.Update_Element (This.Near, App'Access);
            else
                This.Near := This.Near + 1;
                This.List.Insert (This.Near, Item);
            end if;
        elsif Item.Action = FLTK.Text_Buffers.Delete then
            if This.Near > 0 then
                if Continues_Delete (This.List.Element (This.Near), Item)
                then
                    This.List.Update_Element (This.Near, App'Access);
                elsif
                    Continues_Backspace (This.List.Element (This.Near), Item)
                then
                    This.List.Update_Element (This.Near, Pre'Access);
                else
                    This.Near := This.Near + 1;
                    This.List.Insert (This.Near, Item);
                end if;
            end if;
        end if;
        This.Far := This.Near;
        while Integer (This.List.Length) > This.Far loop
            This.List.Delete_Last;
        end loop;
    end Push;


    function Pop
           (This : in out Change_Vector)
        return Boolean is
    begin
        if This.Near > 0 then
            This.Near := This.Near - 1;
            return True;
        else
            return False;
        end if;
    end Pop;


    procedure Pop
           (This : in out Change_Vector) is
    begin
        if This.Near > 0 then
            This.Near := This.Near - 1;
        end if;
    end Pop;


    function Peek
           (This : in     Change_Vector;
            Item :    out Change)
        return Boolean is
    begin
        if This.Near > 0 then
            Item := This.List.Element (This.Near);
            return True;
        else
            return False;
        end if;
    end Peek;


    procedure Peek
           (This : in     Change_Vector;
            Item :    out Change) is
    begin
        if This.Near > 0 then
            Item := This.List.Element (This.Near);
        end if;
    end Peek;


    function Re_Push
           (This : in out Change_Vector)
        return Boolean is
    begin
        if This.Near < This.Far then
            This.Near := This.Near + 1;
            return True;
        else
            return False;
        end if;
    end Re_Push;


    procedure Re_Push
           (This : in out Change_Vector) is
    begin
        if This.Near < This.Far then
            This.Near := This.Near + 1;
        end if;
    end Re_Push;




    function At_Start
           (This : in Change_Vector)
        return Boolean is
    begin
        return This.Near = 0;
    end At_Start;


    function At_End
           (This : in Change_Vector)
        return Boolean is
    begin
        return This.Near >= This.Far;
    end At_End;


end Change_Vectors;


