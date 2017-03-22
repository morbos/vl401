with HAL; use HAL;
with VL6180X_I2C;   use VL6180X_I2C;  --  the VL6180X with comms based on I2C
with STM32.Device;  use STM32.Device;
with STM32.GPIO;    use STM32.GPIO;
with STM32.I2C;     use STM32.I2C;
with VL6180X_I2C_IO;

use STM32; --  for GPIO_Alternate_Function

package VL6180XA1 is
   --  7 segments digit
   subtype Digit is HAL.UInt7;

   subtype Segment_String is String (1 .. 4);
   subtype Display_Number is Integer range -999 .. 9999;

   subtype Display_Digits is GPIO_Point;

   type DigitIdx is mod 4;

   type MessageT is array (DigitIdx) of Digit;

   Message : MessageT;

   MessageIdx : DigitIdx;

   --  Switch on the shield
   type SwitchPos is (Is_Range, Is_Als);

   function SwitchState return SwitchPos;

   procedure DisplaySwitchState;

   --  sensor resource
   VL6180XA1_I2C_Port      : constant access I2C_Port := I2C_1'Access;
   VL6180XA1_I2C_Port_AF   : constant GPIO_Alternate_Function := GPIO_AF_4_I2C1;
   VL6180XA1_I2C_Clock_Pin : GPIO_Point renames PB8;
   VL6180XA1_I2C_Data_Pin  : GPIO_Point renames PB9;
   VL6180XA1_GPIO0_Pin     : GPIO_Point renames PA5; --  Chip enable
   VL6180XA1_GPIO1_Pin     : GPIO_Point renames PA6; --  Interrupt

   Sensor_Port : aliased VL6180X_I2C_IO.IO_Port := (VL6180XA1_I2C_Port, VL6180X_Primary_Address);

   --  Switch resource
   VL6180XA1_Range_ALS_Switch  : GPIO_Point renames PA7;

   --  Display resource

   VL6180XA1_Display_D1  : Display_Digits renames PB0;
   VL6180XA1_Display_D2  : Display_Digits renames PA4;
   VL6180XA1_Display_D3  : Display_Digits renames PA1;
   VL6180XA1_Display_D4  : Display_Digits renames PA0;

   All_Anodes : GPIO_Points :=
     VL6180XA1_Display_D1 &
     VL6180XA1_Display_D2 &
     VL6180XA1_Display_D3 &
     VL6180XA1_Display_D4;

   VL6180XA1_Display_A   : Display_Digits renames PB6;
   VL6180XA1_Display_B   : Display_Digits renames PC7;
   VL6180XA1_Display_C   : Display_Digits renames PA9;
   VL6180XA1_Display_D   : Display_Digits renames PA8;
   VL6180XA1_Display_E   : Display_Digits renames PB10;
   VL6180XA1_Display_F   : Display_Digits renames PB4;
   VL6180XA1_Display_G   : Display_Digits renames PB5;
   VL6180XA1_Display_DP  : Display_Digits renames PB3;

   All_Cathodes : GPIO_Points :=
     VL6180XA1_Display_A   &
     VL6180XA1_Display_B   &
     VL6180XA1_Display_C   &
     VL6180XA1_Display_D   &
     VL6180XA1_Display_E   &
     VL6180XA1_Display_F   &
     VL6180XA1_Display_G   &
     VL6180XA1_Display_DP;

   procedure Initialize_Rng_ALS_Hardware
     (Port   : access I2C_Port;
      SCL    : GPIO_Point;
      SCL_AF : GPIO_Alternate_Function;
      SDA    : GPIO_Point;
      SDA_AF : GPIO_Alternate_Function;
      CS     : GPIO_Point
      );

   procedure Reset_VL6180X_Via_Hardware;

   procedure Set_Up_Rng_ALS;

   procedure Init_VL6180X_Shield;

   procedure ShowDisplay;

   procedure UpdateRange;

   procedure UpdateALS;

   procedure Set_Display (Num  : Display_Number);

   procedure Set_Display (Str  : Segment_String);

end VL6180XA1;
