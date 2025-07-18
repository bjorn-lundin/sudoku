

--  Programmed by Jedidiah Barber
--  Released into the public domain


package Here_I_Am is


    Where_Is_Error : exception;


    --  Provides the full name and path of the running executable
    function Executable
        return String;


    --  Provides the full name and path of the running library
    function Module
        return String;


end Here_I_Am;


