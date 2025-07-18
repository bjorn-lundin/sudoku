

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


with

    Ada.Command_Line,
    Ada.Directories,
    FLTK.Images.RGB.PNG,
    Here_I_Am;


package body Images is


    package ACom renames Ada.Command_Line;
    package ADir renames Ada.Directories;


    Dummy : constant FLTK.Color_Component_Array := (1 .. 0 => 0);




    function Load_Logo
        return FLTK.Images.RGB.RGB_Image'Class is
    begin
        declare
            Base_Path : constant String := ADir.Containing_Directory (Here_I_Am.Executable);
            Logo_Path : constant String :=
                ADir.Compose
               (ADir.Compose  --  No matter how many times I write this, still looks weird...
               (ADir.Compose
               (ADir.Compose (Base_Path, ".."), "share"), "adapad"), "logo.png");
        begin
            return FLTK.Images.RGB.PNG.Forge.Create (Logo_Path);
        end;
    exception
    when others =>
        return FLTK.Images.RGB.Forge.Create (Dummy, 0, 0);
    end Load_Logo;


end Images;


