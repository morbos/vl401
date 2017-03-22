with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);

with VL6180XA1;     use VL6180XA1;
with Ada.Real_Time; use Ada.Real_Time;

procedure vl401 is
   Switch : SwitchPos;
   LastSwitch : SwitchPos;
begin
   Init_VL6180X_Shield;
   DisplaySwitchState;
   LastSwitch := SwitchState;
   loop
      Switch := SwitchState;
      if LastSwitch /= Switch then
         DisplaySwitchState;
      end if;
      if Switch = Is_Range then
         UpdateRange;
      else
         UpdateALS;
      end if;
      LastSwitch := SwitchState;
      delay until Clock + Milliseconds (1000);
   end loop;
end vl401;
