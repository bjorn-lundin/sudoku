

--  Programmed by Jedidiah Barber
--  Licensed under the Sunset License v1.0

--  See license.txt for further details


with

    FLTK.Text_Buffers,
    Ada.Strings.Unbounded;

use

    Ada.Strings.Unbounded;

private with

    Ada.Containers.Vectors;


package Change_Vectors is


    type Change_Vector is tagged private;

    type Change is record
        Action : FLTK.Text_Buffers.Modification;
        Place  : FLTK.Text_Buffers.Position;
        Length : Natural;
        Text   : Unbounded_String;
    end record;


    Empty_Vector : constant Change_Vector;




    procedure Push
           (This : in out Change_Vector;
            Item : in     Change);

    function Pop
           (This : in out Change_Vector)
        return Boolean;

    procedure Pop
           (This : in out Change_Vector);

    function Peek
           (This : in     Change_Vector;
            Item :    out Change)
        return Boolean;

    procedure Peek
           (This : in     Change_Vector;
            Item :    out Change);

    function Re_Push
           (This : in out Change_Vector)
        return Boolean;

    procedure Re_Push
           (This : in out Change_Vector);




    function At_Start
           (This : in Change_Vector)
        return Boolean;

    function At_End
           (This : in Change_Vector)
        return Boolean;


private


    package Internal_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Change);


    type Change_Vector is tagged record
        Near, Far : Natural;
        List      : Internal_Vectors.Vector;
    end record;


    Empty_Vector : constant Change_Vector :=
       (Near => 0,
        Far  => 0,
        List => Internal_Vectors.Empty_Vector);


end Change_Vectors;


