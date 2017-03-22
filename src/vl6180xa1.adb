with STM32.Timers;    use STM32.Timers;
with STM32F4_Timer_Interrupts;  pragma Unreferenced (STM32F4_Timer_Interrupts);
with Ada.Real_Time;   use Ada.Real_Time;

package body VL6180XA1 is
   Rng_ALS : VL6180X_Rng_ALS (Sensor_Port'Access);

   --  7 segment digits

   --    -0-
   --  5|   |1
   --    -6-
   --  4|   |2
   --    -3-
   S0 : constant Digit := 2 ** 0;
   S1 : constant Digit := 2 ** 1;
   S2 : constant Digit := 2 ** 2;
   S3 : constant Digit := 2 ** 3;
   S4 : constant Digit := 2 ** 4;
   S5 : constant Digit := 2 ** 5;
   S6 : constant Digit := 2 ** 6;

   subtype Numerical is Display_Number range 0 .. 9;

   function To_Digit (C : Character) return Digit;
   function To_Digit (N : Numerical) return Digit;

   --------------------------------
   -- Initialize_IMU_IO_Hardware --
   --------------------------------

   procedure Initialize_Rng_ALS_Hardware
     (Port   : access I2C_Port;
      SCL    : GPIO_Point;
      SCL_AF : GPIO_Alternate_Function;
      SDA    : GPIO_Point;
      SDA_AF : GPIO_Alternate_Function;
      CS     : GPIO_Point
      )
   is
      GPIO_Conf            : GPIO_Port_Configuration;
      VL6180XA1_Clock_Speed : constant := 400_000;
   begin
      Enable_Clock (SCL);
      Enable_Clock (SDA);
      Enable_Clock (CS);

      Enable_Clock (Port.all);

      STM32.Device.Reset (Port.all);

      Configure_Alternate_Function (SCL, SCL_AF);
      Configure_Alternate_Function (SDA, SDA_AF);

      GPIO_Conf.Speed       := Speed_100MHz;
      GPIO_Conf.Mode        := Mode_AF;
      GPIO_Conf.Output_Type := Open_Drain;
      GPIO_Conf.Resistors   := Pull_Up;
      Configure_IO (SCL, GPIO_Conf);
      Configure_IO (SDA, GPIO_Conf);

      STM32.I2C.Configure
        (Port.all,
         (Clock_Speed              => VL6180XA1_Clock_Speed,
          Addressing_Mode          => Addressing_Mode_7bit,
          General_Call_Enabled     => False,
          Clock_Stretching_Enabled => True,
          Own_Address              => 16#00#,
          others                   => <>));

      Set_State (Port.all, Enabled => True);

   end Initialize_Rng_ALS_Hardware;

   procedure Reset_VL6180X_Via_Hardware is
   begin
      --  reset is active low
      Clear (VL6180XA1_GPIO0_Pin);
      delay until Clock + Milliseconds (10);
      Set (VL6180XA1_GPIO0_Pin);
      delay until Clock + Milliseconds (1);
      null;
   end Reset_VL6180X_Via_Hardware;

   ----------------
   -- Set_Up_IMU --
   ----------------

   procedure Set_Up_Rng_ALS is
   begin
      Initialize_Rng_ALS_Hardware
        (Port   => VL6180XA1_I2C_Port,
         SCL    => VL6180XA1_I2C_Clock_Pin,
         SCL_AF => VL6180XA1_I2C_Port_AF,
         SDA    => VL6180XA1_I2C_Data_Pin,
         SDA_AF => VL6180XA1_I2C_Port_AF,
         CS     => VL6180XA1_GPIO0_Pin
        );

      Reset_VL6180X_Via_Hardware;

      Rng_ALS.StaticInit;

   end Set_Up_Rng_ALS;

   --------------
   -- To_Digit --
   --------------

   function To_Digit (C : Character) return Digit is
   begin
      case C is
         when ' ' => return 0;
         when '-' => return S6;
         when '_' => return S3;
         when '=' => return S3 + S6;
         when '^' => return S0;

         when '?' => return S0 + S1 + S6 + S4;
         when '*' => return S0 + S1 + S2 + S3 + S4 + S5 + S6;
         when '[' => return S0 + S3 + S4 + S5;
         when ']' => return S0 + S3 + S1 + S2;

         when '0' => return S0 + S1 + S2 + S3 + S4 + S5;
         when '1' => return S1 + S2;
         when '2' => return S0 + S1 + S6 + S4 + S3;
         when '3' => return S0 + S1 + S6 + S2 + S3;
         when '4' => return S5 + S1 + S6 + S2;
         when '5' => return S0 + S5 + S6 + S2 + S3;
         when '6' => return S0 + S2 + S3 + S4 + S5 + S6;
         when '7' => return S0 + S1 + S2;
         when '8' => return S0 + S1 + S2 + S3 + S4 + S5 + S6;
         when '9' => return S0 + S1 + S2 + S3 + S5 + S6;

         when 'A' => return S0 + S1 + S2 + S4 + S5 + S6;
         when 'B' => return S0 + S1 + S2 + S3 + S4 + S5 + S6;
         when 'C' => return S0 + S3 + S4 + S5;
         when 'D' => return S0 + S1 + S2 + S3 + S4 + S5;
         when 'E' => return S0 + S3 + S4 + S5 + S6;
         when 'F' => return S0 + S4 + S5 + S6;
         when 'G' => return S0 + S2 + S3 + S4 + S5;
         when 'H' => return S1 + S2 + S4 + S5 + S6;
         when 'I' => return S1 + S2;
         when 'J' => return S1 + S2 + S3;
         when 'K' => return S1 + S4 + S5 + S6;
         when 'L' => return S3 + S4 + S5;
         when 'M' => return S0 + S1 + S2 + S4 + S5;
         when 'N' => return S0 + S1 + S2 + S4 + S5;
         when 'O' => return S0 + S1 + S2 + S3 + S4 + S5;
         when 'P' => return S0 + S1 + S4 + S5 + S6;
         when 'Q' => return S0 + S1 + S2 + S3 + S4 + S5;
         when 'R' => return S0 + S1 + S2 + S4 + S5 + S6;
         when 'S' => return S0 + S2 + S3 + S5 + S6;
         when 'T' => return S0 + S1 + S2;
         when 'U' => return S1 + S2 + S3 + S4 + S5;
         when 'V' => return S1 + S2 + S3 + S4 + S5;
         when 'W' => return S1 + S2 + S3 + S4 + S5;
         when 'X' => return S1 + S2 + S4 + S5 + S6;
         when 'Y' => return S1 + S2 + S5 + S6;
         when 'Z' => return S0 + S1 + S3 + S4 + S6;

         when others => return S0 + S6 + S3;
      end case;
   end To_Digit;

   --------------
   -- To_Digit --
   --------------

   function To_Digit (N : Numerical) return Digit is
   begin
      case N is
         when 0 => return S0 + S1 + S2 + S3 + S4 + S5;
         when 1 => return S1 + S2;
         when 2 => return S0 + S1 + S6 + S4 + S3;
         when 3 => return S0 + S1 + S6 + S2 + S3;
         when 4 => return S5 + S1 + S6 + S2;
         when 5 => return S0 + S5 + S6 + S2 + S3;
         when 6 => return S0 + S2 + S3 + S4 + S5 + S6;
         when 7 => return S0 + S1 + S2;
         when 8 => return S0 + S1 + S2 + S3 + S4 + S5 + S6;
         when 9 => return S0 + S1 + S2 + S3 + S5 + S6;
      end case;
   end To_Digit;

   function SwitchState return SwitchPos is
   begin
      if Set (VL6180XA1_Range_ALS_Switch) then
         return Is_Als;
      else
         return Is_Range;
      end if;
   end SwitchState;

   procedure DisplaySwitchState is
   begin
      if Set (VL6180XA1_Range_ALS_Switch) then
         Set_Display ("ALS ");
      else
         Set_Display ("RNG ");
      end if;
      delay until Clock + Milliseconds (1000);
   end DisplaySwitchState;

   procedure Init_VL6180X_Shield is
      GPIO_Conf            : GPIO_Port_Configuration;
   begin
      --  Set_Up_Rng_ALS below will use this GPIO vvvv
      Enable_Clock (VL6180XA1_GPIO0_Pin);
      GPIO_Conf.Mode        := Mode_Out;
      GPIO_Conf.Output_Type := Push_Pull;
      GPIO_Conf.Speed       := Speed_2MHz;
      GPIO_Conf.Resistors   := Floating;
      Configure_IO (VL6180XA1_GPIO0_Pin,
                    Config => GPIO_Conf);

      Set_Up_Rng_ALS;

      --  Setup the switch
      Enable_Clock (VL6180XA1_Range_ALS_Switch);
      GPIO_Conf.Mode        := Mode_In;
      GPIO_Conf.Speed       := Speed_100MHz;
      GPIO_Conf.Resistors   := Floating;
      Configure_IO (All_Anodes,
                    Config => GPIO_Conf);

      --  Setup the display
      Enable_Clock (All_Anodes);
      Enable_Clock (All_Cathodes);

      GPIO_Conf.Mode        := Mode_Out;
      GPIO_Conf.Output_Type := Push_Pull;
      GPIO_Conf.Speed       := Speed_100MHz;
      GPIO_Conf.Resistors   := Floating;
      Configure_IO (All_Anodes,
                    Config => GPIO_Conf);

      Configure_IO (All_Cathodes,
                    Config => GPIO_Conf);

      Set (All_Anodes); --  Set means turn them... off

      Enable_Clock (VL6180XA1_GPIO1_Pin);
      GPIO_Conf.Mode        := Mode_In;
      GPIO_Conf.Output_Type := Open_Drain;
      GPIO_Conf.Speed       := Speed_100MHz;
      GPIO_Conf.Resistors   := Pull_Up;
      Configure_IO (VL6180XA1_GPIO1_Pin,
                    Config => GPIO_Conf);

      --  Setup timer...
      --  You will be shown many timers... not all are populated in an
      --  STM32F401RE... driver example is Timer_9... Timer_9 doesn't exist on the
      --  ^^^ part in Q.

      Enable_Clock (Timer_5);

      Reset (Timer_5);

      --  Prescaler: 42 MHz Clock down to 1 MHz
      --  Period: ~ 4x 60hz ~240hz
      Configure (Timer_5, Prescaler => 42 - 1, Period => 4166);

      Enable_Interrupt (Timer_5, Timer_Update_Interrupt);

      Enable (Timer_5);

      Message (0) := To_Digit ('F');
      Message (1) := To_Digit ('A');
      Message (2) := To_Digit ('C');
      Message (3) := To_Digit ('E');

      MessageIdx := DigitIdx'First;

   end Init_VL6180X_Shield;

   procedure ShowDisplay is
      Val : Digit;
   begin
      Set (All_Anodes);
      Val := Message (MessageIdx);
      if (Val and (2 ** 0)) = (2 ** 0) then
         Clear (VL6180XA1_Display_A);
      else
         Set (VL6180XA1_Display_A);
      end if;
      if (Val and (2 ** 1)) = (2 ** 1) then
         Clear (VL6180XA1_Display_B);
      else
         Set (VL6180XA1_Display_B);
      end if;
      if (Val and (2 ** 2)) = (2 ** 2) then
         Clear (VL6180XA1_Display_C);
      else
         Set (VL6180XA1_Display_C);
      end if;
      if (Val and (2 ** 3)) = (2 ** 3) then
         Clear (VL6180XA1_Display_D);
      else
         Set (VL6180XA1_Display_D);
      end if;
      if (Val and (2 ** 4)) = (2 ** 4) then
         Clear (VL6180XA1_Display_E);
      else
         Set (VL6180XA1_Display_E);
      end if;
      if (Val and (2 ** 5)) = (2 ** 5) then
         Clear (VL6180XA1_Display_F);
      else
         Set (VL6180XA1_Display_F);
      end if;
      if (Val and (2 ** 6)) = (2 ** 6) then
         Clear (VL6180XA1_Display_G);
      else
         Set (VL6180XA1_Display_G);
      end if;
      --  No decimal point... for now
      Set (VL6180XA1_Display_DP);

      case MessageIdx is
         when 0 => Clear (VL6180XA1_Display_D1);
         when 1 => Clear (VL6180XA1_Display_D2);
         when 2 => Clear (VL6180XA1_Display_D3);
         when 3 => Clear (VL6180XA1_Display_D4);
      end case;
      MessageIdx := MessageIdx + 1;
   end ShowDisplay;

   -------------------
   --  Set_Display  --
   -------------------

   procedure Set_Display (Str  : Segment_String) is
   begin
      for I in 1 .. 4 loop
         Message (DigitIdx (I - 1)) := To_Digit (Str (I));
      end loop;
   end Set_Display;

   -------------------
   --  Set_Display  --
   -------------------

   procedure Set_Display (Num  : Display_Number)
   is
      Temp : Display_Number;
      Sign : Display_Number;
      N    : Numerical;
      D    : Digit;
   begin
      if Num > 0 then
         Sign := 1;
         Temp := Num;
      else
         Sign := 1;
         Temp := -Num;
      end if;

      for J in 1 .. 4 loop
         if Temp = 0 then
            if J = 1 then
               D := To_Digit (0);
            elsif Sign = -1 then
               D := To_Digit ('-');
               Sign := 1;
            else
               D := To_Digit (' ');
            end if;
         else
            N := Temp mod 10;
            Temp := Temp / 10;
            D := To_Digit (N);
         end if;

         Message (DigitIdx (3 - (J - 1))) := D;

      end loop;
   end Set_Display;

   procedure UpdateRange is
      Range_Val : UInt8;
   begin
      Range_Val := Rng_ALS.ReadRange (20);
      if Range_Val = 16#ff# then
         Set_Display ("----");
      else
         Set_Display (Display_Number (Range_Val));
      end if;
   end UpdateRange;

   procedure UpdateALS is
      ALS_Val : UInt16;
   begin
      ALS_Val := Rng_ALS.ReadAls (200);
      Set_Display (Display_Number (ALS_Val));
   end UpdateALS;

end VL6180XA1;
