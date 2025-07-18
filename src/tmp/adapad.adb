

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


with

    Ada.Strings.Unbounded,
    Change_Vectors,
    FLTK.Asks,
    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus,
    Windows.About,
    Windows.Editor,
    Windows.Find,
    Windows.Jump,
    Windows.Replace;

use

    Ada.Strings.Unbounded;


package body Adapad is


    --  Forward declarations of helper functions.

    procedure Set_Title;
    function Safe_To_Discard return Boolean;
    procedure Do_Save;
    procedure Do_Save_As;
    procedure Load_File (Name : in String);
    procedure Save_File (Name : in String);
    procedure Centre (Win : in out FLTK.Widgets.Groups.Windows.Window'Class);




    --  Global state of the text editor.

    Editor   : Windows.Editor.Editor_Window   := Windows.Editor.Create (800, 500);
    Buffer   : FLTK.Text_Buffers.Text_Buffer  := FLTK.Text_Buffers.Forge.Create;
    About    : Windows.About.About_Window     := Windows.About.Create;
    Find     : Windows.Find.Find_Window       := Windows.Find.Create;
    Replace  : Windows.Replace.Replace_Window := Windows.Replace.Create;
    Jump     : Windows.Jump.Jump_Window       := Windows.Jump.Create;

    Changed  : Boolean                      := False;
    Mod_List : Change_Vectors.Change_Vector := Change_Vectors.Empty_Vector;
    Filename : Unbounded_String             := To_Unbounded_String (0);




    --  Main program interface.

    procedure Show is
    begin
        Editor.Show;
    end Show;


    procedure Hide is
    begin
        About.Hide;
        Find.Hide;
        Replace.Hide;
        Jump.Hide;
        Editor.Hide;
    end Hide;




    --  Callbacks for the menu.

    procedure New_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if not Safe_To_Discard then
            return;
        end if;
        Filename := To_Unbounded_String (0);
        Buffer.Remove_Text (0, Buffer.Length);
        Changed := False;
        Buffer.Call_Modify_Callbacks;
    end New_CB;


    procedure Open_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if not Safe_To_Discard then
            return;
        end if;
        declare
            New_Filename : constant String :=
                FLTK.Asks.File_Chooser ("Open File?", "*", To_String (Filename));
        begin
            if New_Filename /= "" then
                Load_File (New_Filename);
            end if;
        end;
    end Open_CB;


    procedure Save_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Do_Save;
    end Save_CB;


    procedure Save_As_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Do_Save_As;
    end Save_As_CB;


    procedure Quit_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if not Safe_To_Discard then
            return;
        end if;
        Hide;
    end Quit_CB;


    procedure Undo_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        use type FLTK.Text_Buffers.Modification;
        Bar : constant FLTK.Widgets.Menus.Menu_Reference := Editor.Get_Menu_Bar;
        Ch  : Change_Vectors.Change;
    begin
        Buffer.Disable_Callbacks;

        if Mod_List.Peek (Ch) then
            if Ch.Action = FLTK.Text_Buffers.Insert then
                Buffer.Remove_Text (Integer (Ch.Place), Integer (Ch.Place) + Ch.Length);
                Editor.Set_Insert_Position (Integer (Ch.Place));
            else
                Buffer.Insert_Text (Integer (Ch.Place), To_String (Ch.Text));
                Editor.Set_Insert_Position (Integer (Ch.Place) + Ch.Length);
            end if;
            Editor.Show_Insert_Position;
            Mod_List.Pop;
            Changed := True;
            Set_Title;
            Bar.Find_Item ("&Edit/&Redo").Activate;
            if Mod_List.At_Start then
                Bar.Find_Item ("&Edit/&Undo").Deactivate;
            end if;
        end if;

        Buffer.Enable_Callbacks;
    end Undo_CB;


    procedure Redo_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        use type FLTK.Text_Buffers.Modification;
        Bar : constant FLTK.Widgets.Menus.Menu_Reference := Editor.Get_Menu_Bar;
        Ch  : Change_Vectors.Change;
    begin
        Buffer.Disable_Callbacks;

        if Mod_List.Re_Push then
            Mod_List.Peek (Ch);
            if Ch.Action = FLTK.Text_Buffers.Insert then
                Buffer.Insert_Text (Integer (Ch.Place), To_String (Ch.Text));
                Editor.Set_Insert_Position (Integer (Ch.Place) + Ch.Length);
            else
                Buffer.Remove_Text (Integer (Ch.Place), Integer (Ch.Place) + Ch.Length);
                Editor.Set_Insert_Position (Integer (Ch.Place));
            end if;
            Editor.Show_Insert_Position;
            Changed := True;
            Set_Title;
            Bar.Find_Item ("&Edit/&Undo").Activate;
            if Mod_List.At_End then
                Bar.Find_Item ("&Edit/&Redo").Deactivate;
            end if;
        end if;

        Buffer.Enable_Callbacks;
    end Redo_CB;


    procedure Cut_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Editor.Cut;
    end Cut_CB;


    procedure Copy_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Editor.Copy;
    end Copy_CB;


    procedure Paste_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Editor.Paste;
    end Paste_CB;


    procedure Delete_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Editor.Delete;
    end Delete_CB;


    procedure Select_All_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Buffer.Set_Selection (0, Buffer.Length);
    end Select_All_CB;


    procedure Find_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Centre (Find);
        Find.Show;
    end Find_CB;


    procedure Find_Next_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Find.Do_Callback (Windows.Find.Forward);
    end Find_Next_CB;


    procedure Find_Prev_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Find.Do_Callback (Windows.Find.Backward);
    end Find_Prev_CB;


    procedure Replace_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Centre (Replace);
        Replace.Show;
    end Replace_CB;


    procedure Jump_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Centre (Jump);
        Jump.Show;
    end Jump_CB;


    procedure Count_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Restore_Position : constant Natural := Editor.Get_Insert_Position;
        Current_Position, Result : Natural := 0;
    begin
        Editor.Set_Insert_Position (0);
        if Character'Pos (Buffer.Character_At (0)) > Character'Pos (' ') then
            Result := 1;
        end if;
        loop
            Editor.Next_Word;
            Current_Position := Editor.Get_Insert_Position;
            exit when Current_Position = Buffer.Length;
            Result := Result + 1;
        end loop;
        Editor.Set_Insert_Position (Restore_Position);
        FLTK.Asks.Message_Box ("There are " & Integer'Image (Result) & " words in the document.");
    end Count_CB;


    procedure Wrap_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if FLTK.Widgets.Menus.Menu (Item).Chosen.Get_State then
            Editor.Set_Wrap_Mode (Windows.Editor.Bounds);
        else
            Editor.Set_Wrap_Mode (Windows.Editor.None);
        end if;
    end Wrap_CB;


    procedure Lines_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if FLTK.Widgets.Menus.Menu (Item).Chosen.Get_State then
            --  50 pixels should be enough for 5 digit line numbers.
            Editor.Set_Linenumber_Width (50);
        else
            Editor.Set_Linenumber_Width (0);
        end if;
    end Lines_CB;


    procedure About_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Centre (About);
        About.Show;
    end About_CB;




    --  Callbacks for the text buffer.

    procedure Mod_CB
           (Action       : in FLTK.Text_Buffers.Modification;
            Place        : in FLTK.Text_Buffers.Position;
            Length       : in Natural;
            Deleted_Text : in String)
    is
        use type FLTK.Text_Buffers.Modification;
        Bar : constant FLTK.Widgets.Menus.Menu_Reference := Editor.Get_Menu_Bar;
        Pop : constant FLTK.Widgets.Menus.Menu_Reference := Editor.Get_Rightclick_Menu;
    begin
        if Action = FLTK.Text_Buffers.Insert or Action = FLTK.Text_Buffers.Delete then
            Changed := True;
            Set_Title;
            declare
                Ch : Change_Vectors.Change;
            begin
                Ch.Action := Action;
                Ch.Place := Place;
                Ch.Length := Length;
                if Action = FLTK.Text_Buffers.Insert then
                    Ch.Text := To_Unbounded_String
                        (Buffer.Text_At (Integer (Place), Integer (Place) + Length));
                else
                    Ch.Text := To_Unbounded_String (Deleted_Text);
                end if;
                Mod_List.Push (Ch);
                Bar.Find_Item ("&Edit/&Undo").Activate;
                if Mod_List.At_End then
                    Bar.Find_Item ("&Edit/&Redo").Deactivate;
                end if;
            end;
        end if;

        if Buffer.Has_Selection then
            Bar.Find_Item ("&Edit/Cu&t").Activate;
            Bar.Find_Item ("&Edit/&Copy").Activate;
            Bar.Find_Item ("&Edit/&Delete").Activate;
            Pop.Find_Item ("Cu&t").Activate;
            Pop.Find_Item ("&Copy").Activate;
            Pop.Find_Item ("&Delete").Activate;
        else
            Bar.Find_Item ("&Edit/Cu&t").Deactivate;
            Bar.Find_Item ("&Edit/&Copy").Deactivate;
            Bar.Find_Item ("&Edit/&Delete").Deactivate;
            Pop.Find_Item ("Cu&t").Deactivate;
            Pop.Find_Item ("&Copy").Deactivate;
            Pop.Find_Item ("&Delete").Deactivate;
        end if;
    end Mod_CB;




    --  Callbacks for the extra dialog windows.

    procedure Do_Find_CB
           (Item       : in String;
            Match_Case : in Boolean;
            Facing     : in Windows.Find.Direction)
    is
        use type Windows.Find.Direction;
        Bar : constant FLTK.Widgets.Menus.Menu_Reference := Editor.Get_Menu_Bar;
        Current_Position, Select_Start, Select_End, Found_At : Natural;
        Was_Found : Boolean;
    begin
        Find.Hide;

        --  Is it possible to improve this abomination with a modulo type?
        if Buffer.Get_Selection (Select_Start, Select_End) then
            if Facing = Windows.Find.Forward then
                Current_Position := Select_End;
            else
                if Select_Start = 0 then
                    Current_Position := Buffer.Length;
                else
                    Current_Position := Select_Start - 1;
                end if;
            end if;
        else
            Current_Position := Editor.Get_Insert_Position;
        end if;

        if Facing = Windows.Find.Forward then
            Was_Found := Buffer.Search_Forward (Current_Position, Item, Found_At, Match_Case)
                or else Buffer.Search_Forward (0, Item, Found_At, Match_Case);
        else
            Was_Found := Buffer.Search_Backward (Current_Position, Item, Found_At, Match_Case)
                or else Buffer.Search_Backward (Buffer.Length, Item, Found_At, Match_Case);
        end if;

        if Item /= "" and Was_Found then
            Buffer.Set_Selection (Found_At, Found_At + Item'Length);
            Editor.Set_Insert_Position (Found_At + Item'Length);
            Editor.Show_Insert_Position;
            Bar.Find_Item ("&Search/Find &Next").Activate;
            Bar.Find_Item ("&Search/Find &Previous").Activate;
        else
            FLTK.Asks.Alert ("No occurrences of '" & Item & "' found!");
            Bar.Find_Item ("&Search/Find &Next").Deactivate;
            Bar.Find_Item ("&Search/Find &Previous").Deactivate;
        end if;
    end Do_Find_CB;


    procedure Do_Replace_CB
           (Item, Replace_With      : in String;
            Match_Case, Replace_All : in Boolean)
    is
        use type FLTK.Asks.Choice_Result;
        User_Response : FLTK.Asks.Choice_Result;
        Found_At : Natural;
        Current_Position, Times_Replaced : Natural := 0;
    begin
        Replace.Hide;

        while Buffer.Search_Forward (Current_Position, Item, Found_At, Match_Case) loop
            Buffer.Set_Selection (Found_At, Found_At + Item'Length);
            Editor.Set_Insert_Position (Found_At);
            Editor.Show_Insert_Position;
            if not Replace_All then
                User_Response := FLTK.Asks.Choice ("Replace?", "No", "Yes", "Cancel");
            else
                User_Response := FLTK.Asks.Second;
            end if;
            exit when User_Response = FLTK.Asks.Third;
            if User_Response = FLTK.Asks.Second then
                Buffer.Remove_Selection;
                Buffer.Insert_Text (Found_At, Replace_With);
                Current_Position := Found_At + Replace_With'Length;
                Times_Replaced := Times_Replaced + 1;
            else
                Current_Position := Found_At + Item'Length;
            end if;
        end loop;

        if Times_Replaced > 0 then
            FLTK.Asks.Message_Box ("Replaced " & Integer'Image (Times_Replaced) & " occurrences.");
        else
            FLTK.Asks.Alert ("No occurrences of '" & Item & "' found!");
        end if;
    end Do_Replace_CB;


    procedure Do_Jump_CB
           (Line_Number : in Positive) is
    begin
        Jump.Hide;
        Editor.Set_Insert_Position (Buffer.Skip_Lines (0, Line_Number - 1));
        Editor.Show_Insert_Position;
    end Do_Jump_CB;




    --  Helper functions.

    procedure Set_Title is
        Title : Unbounded_String := To_Unbounded_String (0);
    begin
        if Changed then
            Append (Title, "*");
        end if;
        if Filename = "" then
            Append (Title, "(Untitled)");
        else
            Append (Title, Filename);
        end if;
        Editor.Set_Label (To_String (Title));
    end Set_Title;


    function Safe_To_Discard
        return Boolean
    is
        User_Response : FLTK.Asks.Choice_Result;
    begin
        if not Changed then
            return True;
        end if;
        User_Response := FLTK.Asks.Choice
           ("The current file has not been saved." & Character'Val (10) &
            "Would you like to save it now?",
            "Cancel", "Save", "Discard");
        case User_Response is
        when FLTK.Asks.First =>
            return False;
        when FLTK.Asks.Second =>
            Do_Save;
            return not Changed;
        when FLTK.Asks.Third =>
            return True;
        end case;
    end Safe_To_Discard;


    procedure Do_Save is
    begin
        if Filename = "" then
            Do_Save_As;
        else
            Save_File (To_String (Filename));
        end if;
    end Do_Save;


    procedure Do_Save_As is
        New_Filename : constant String := FLTK.Asks.File_Chooser
            ("Save File As?", "*", To_String (Filename));
    begin
        if New_Filename /= "" then
            Save_File (New_Filename);
        end if;
    end Do_Save_As;


    procedure Load_File
           (Name : in String) is
    begin
        Buffer.Load_File (Name);
        Filename := To_Unbounded_String (Name);
        Changed := False;
        Set_Title;
        Mod_List := Change_Vectors.Empty_Vector;
        Editor.Get_Menu_Bar.Find_Item ("&Edit/&Undo").Deactivate;
        Editor.Get_Menu_Bar.Find_Item ("&Edit/&Redo").Deactivate;
    exception
    when Storage_Error =>
        FLTK.Asks.Alert ("Error reading from file " & Name);
    end Load_File;


    procedure Save_File
           (Name : in String) is
    begin
        Buffer.Save_File (Name);
        Filename := To_Unbounded_String (Name);
        Changed := False;
        Set_Title;
    exception
    when Storage_Error =>
        FLTK.Asks.Alert ("Error writing to file " & Name);
    end Save_File;


    procedure Centre
           (Win : in out FLTK.Widgets.Groups.Windows.Window'Class)
    is
        Middle_X : constant Integer := Editor.Get_X + Editor.Get_W / 2;
        Middle_Y : constant Integer := Editor.Get_Y + Editor.Get_H / 2;
    begin
        Win.Reposition
           (Middle_X - Win.Get_W / 2,
            Middle_Y - Win.Get_H / 2);
    end Centre;




begin


    declare
        use FLTK;
        use FLTK.Widgets.Menus;
        Bar : constant Menu_Reference := Editor.Get_Menu_Bar;
    begin
        Bar.Add (Text => "&File", Flags => Flag_Submenu);
        Bar.Add ("File/&New", New_CB'Access, Mod_Ctrl + 'n');
        Bar.Add ("File/&Open...", Open_CB'Access, Mod_Ctrl + 'o');
        Bar.Add ("File/&Save", Save_CB'Access, Mod_Ctrl + 's');
        Bar.Add ("File/Save &As...", Save_As_CB'Access, Mod_Shift + Mod_Ctrl + 's', Flag_Divider);
        Bar.Add ("File/&Quit", Quit_CB'Access, Mod_Ctrl + 'q');

        Bar.Add (Text => "&Edit", Flags => Flag_Submenu);
        Bar.Add ("Edit/&Undo", Undo_CB'Access, Mod_Ctrl + 'z', Flag_Inactive);
        Bar.Add ("Edit/&Redo", Redo_CB'Access, Mod_Shift + Mod_Ctrl + 'z',
            Flag_Inactive + Flag_Divider);
        Bar.Add ("Edit/Cu&t", Cut_CB'Access, Mod_Ctrl + 'x', Flag_Inactive);
        Bar.Add ("Edit/&Copy", Copy_CB'Access, Mod_Ctrl + 'c', Flag_Inactive);
        Bar.Add ("Edit/&Paste", Paste_CB'Access, Mod_Ctrl + 'v');
        Bar.Add ("Edit/&Delete", Delete_CB'Access, No_Key, Flag_Inactive + Flag_Divider);
        Bar.Add ("Edit/Select &All", Select_All_CB'Access, Mod_Ctrl + 'a');

        Bar.Add (Text => "&Search", Flags => Flag_Submenu);
        Bar.Add ("Search/&Find...", Find_CB'Access, Mod_Ctrl + 'f');
        Bar.Add ("Search/Find &Next", Find_Next_CB'Access, Mod_Ctrl + 'g', Flag_Inactive);
        Bar.Add ("Search/Find &Previous", Find_Prev_CB'Access, Mod_Shift + Mod_Ctrl + 'g',
            Flag_Inactive);
        Bar.Add ("Search/&Replace...", Replace_CB'Access, Mod_Ctrl + 'h', Flag_Divider);
        Bar.Add ("Search/Jump To...", Jump_CB'Access, Mod_Ctrl + 'j');
        Bar.Add ("Search/Word Count", Count_CB'Access);

        Bar.Add (Text => "&Options", Flags => Flag_Submenu);
        Bar.Add ("Options/&Word Wrap", Wrap_CB'Access, No_Key, Flag_Toggle);
        Bar.Add ("Options/&Line Numbers", Lines_CB'Access, No_Key, Flag_Toggle);

        Bar.Add (Text => "&Help", Flags => Flag_Submenu);
        Bar.Add ("Help/&About", About_CB'Access);
    end;


    declare
        use FLTK;
        use FLTK.Widgets.Menus;
        Pop : constant Menu_Reference := Editor.Get_Rightclick_Menu;
    begin
        Pop.Add ("Cu&t", Cut_CB'Access, No_Key, Flag_Inactive);
        Pop.Add ("&Copy", Copy_CB'Access, No_Key, Flag_Inactive);
        Pop.Add ("&Paste", Paste_CB'Access);
        Pop.Add ("&Delete", Delete_CB'Access, No_Key, Flag_Inactive + Flag_Divider);
        Pop.Add ("Select &All", Select_All_CB'Access);
    end;


    Find.Set_Find_Callback (Do_Find_CB'Access);
    Replace.Set_Replace_Callback (Do_Replace_CB'Access);
    Jump.Set_Jump_Callback (Do_Jump_CB'Access);
    Buffer.Add_Modify_Callback (Mod_CB'Access);
    Editor.Set_Callback (Quit_CB'Access);


    Editor.Set_Buffer (Buffer);


end Adapad;


