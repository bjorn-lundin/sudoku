

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


package body Windows.About is


    package W  renames FLTK.Widgets.Groups.Windows;
    package WD renames FLTK.Widgets.Groups.Windows.Double;
    package BX renames FLTK.Widgets.Boxes;
    package EN renames FLTK.Widgets.Buttons.Enter;




    function Create
        return About_Window
    is
        My_Width      : constant Integer := 350;
        My_Height     : constant Integer := 250;

        Logo_Line     : constant Integer := 30;
        Logo_Width    : constant Integer := 50;
        Logo_Height   : constant Integer := 50;

        Button_Width  : constant Integer := 140;
        Button_Height : constant Integer := 40;

        Heading_Line  : constant Integer := 90;
        Blurb_Line    : constant Integer := 132;
        Author_Line   : constant Integer := 157;
        Button_Line   : constant Integer := 190;

        Heading_Size  : constant Integer := 22;
        Text_Size     : constant Integer := 12;

        Heading_Text  : constant String := "sudoku 0.1";
        Blurb_Text    : constant String := "FLTK based simple sudoku helper written in Ada";
        Author_Text   : constant String := "Programmed by Björn Lundin inspired by Jed Barber's AdaPad";
    begin
        return This : About_Window :=
           (WD.Forge.Create (0, 0, My_Width, My_Height, "About Sudoku")
        with
            Picture => BX.Forge.Create
               ((My_Width - Logo_Width) / 2,
                Logo_Line, Logo_Width, Logo_Height, ""),
            Heading => BX.Forge.Create
               (0, Heading_Line, My_Width, Heading_Size, Heading_Text),
            Blurb   => BX.Forge.Create
               (0, Blurb_Line, My_Width, Text_Size, Blurb_Text),
            Author  => BX.Forge.Create
               (0, Author_Line, My_Width, Text_Size, Author_Text),
            Dismiss => EN.Forge.Create
               ((My_Width - Button_Width) / 2,
                Button_Line, Button_Width, Button_Height, "Close"))
        do
            This.Add (This.Picture);
            This.Add (This.Heading);
            This.Heading.Set_Label_Size (FLTK.Font_Size (Heading_Size));
            This.Add (This.Blurb);
            This.Add (This.Author);
            This.Add (This.Dismiss);
            This.Dismiss.Set_Callback (Hide_CB'Access);

            This.Set_Icon (Logo);
            This.Picture.Set_Image (Logo);

            This.Set_Callback (Hide_CB'Access);
            This.Set_Modal_State (W.Modal);
        end return;
    end Create;


end Windows.About;


