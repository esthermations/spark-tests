with Ada.Text_IO;
with Ada.Real_Time;
with Throttles;

procedure Main with SPARK_Mode is

   type Throttle_Array is array (Positive range <>) of Throttles.Throttle;
   Ts : Throttle_Array (1 .. 6);

   use Ada.Real_Time;

   Tick_Interval  : Time_Span := Milliseconds (20);
   Next_Tick_Time : Time      := Clock;

   Num_Ticks : constant Positive := 100;

begin

   for I in Ts'Range loop
      Ts (I).Increment := Float (I) / Float (Ts'Last * 100);
      if I mod 7 = 0 then
         Ts (I).Is_Active := True;
      end if;
   end loop;

   for I in 1 .. Num_Ticks loop
      delay until Next_Tick_Time;
      Next_Tick_Time := Next_Tick_Time + Tick_Interval;

      for T of Ts loop

         T.Tick;

         if I mod 5 = 0 then
            T.Toggle;
         end if;

         Ada.Text_IO.Put (Ascii.ESC & (if T.Is_Active then "[1;32m" else "[1;31m"));
         Ada.Text_IO.Put ("  " & T.Value'Img);
         Ada.Text_IO.Put (Ascii.ESC & "[1;0m");

      end loop;
      Ada.Text_IO.New_Line;

   end loop;

end Main;