

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


with
    text_io,
    FLTK,
    FLTK.Static,
    Sudoku;


function Main
    return Integer is
begin
    text_io.put_line("main, 1");
    FLTK.Static.Set_Scheme ("plastic");
    text_io.put_line("main, 2");
    Sudoku.Show;
    text_io.put_line("main, 3");
    return FLTK.Run;

end Main;


