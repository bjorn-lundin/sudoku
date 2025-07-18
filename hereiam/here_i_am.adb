

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Interfaces.C.Strings,
    System.Storage_Elements;

use type

    Interfaces.C.int;


package body Here_I_Am is


    package Storage renames System.Storage_Elements;

    Null_Pointer : constant Storage.Integer_Address := Storage.To_Integer (System.Null_Address);




    function wai_getExecutablePath
           (Buffer : in Interfaces.C.Strings.chars_ptr;
            Length : in Interfaces.C.int;
            Dir    : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, wai_getExecutablePath, "wai_getExecutablePath");
    pragma Inline (wai_getExecutablePath);

    function wai_getModulePath
           (Buffer : in Interfaces.C.Strings.chars_ptr;
            Length : in Interfaces.C.int;
            Dir    : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, wai_getModulePath, "wai_getModulePath");
    pragma Inline (wai_getModulePath);




    function Executable
        return String
    is
        Path_Length : constant Interfaces.C.int :=
            wai_getExecutablePath (Interfaces.C.Strings.Null_Ptr, 0, Null_Pointer);
        Data_Buffer : aliased Interfaces.C.char_array :=
            (1 .. Interfaces.C.size_t (Path_Length) => Interfaces.C.nul);
        Code : constant Interfaces.C.int := wai_getExecutablePath
           (Interfaces.C.Strings.To_Chars_Ptr (Data_Buffer'Unchecked_Access),
            Path_Length,
            Null_Pointer);
    begin
        pragma Assert (Code >= 0);
        return Interfaces.C.To_Ada (Data_Buffer, False);
    exception
    when Ada.Assertions.Assertion_Error => raise Where_Is_Error with
        "wai_getExecutablePath returned int value of " & Interfaces.C.int'Image (Code);
    end Executable;


    function Module
        return String
    is
        Path_Length : constant Interfaces.C.int :=
            wai_getModulePath (Interfaces.C.Strings.Null_Ptr, 0, Null_Pointer);
        Data_Buffer : aliased Interfaces.C.char_array :=
            (1 .. Interfaces.C.size_t (Path_Length) => Interfaces.C.nul);
        Code : constant Interfaces.C.int := wai_getModulePath
           (Interfaces.C.Strings.To_Chars_Ptr (Data_Buffer'Unchecked_Access),
            Path_Length,
            Null_Pointer);
    begin
        pragma Assert (Code >= 0);
        return Interfaces.C.To_Ada (Data_Buffer, False);
    exception
    when Ada.Assertions.Assertion_Error => raise Where_Is_Error with
        "wai_getModulePath returned int value of " & Interfaces.C.int'Image (Code);
    end Module;


end Here_I_Am;


