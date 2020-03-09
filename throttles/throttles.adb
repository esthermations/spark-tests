
package body Throttles with SPARK_Mode => On is

   procedure Activate (T : in out Throttle) is
   begin
      T.Is_Active := True;
   end Activate;

   procedure Deactivate (T : in out Throttle) is
   begin
      T.Is_Active := False;
   end Deactivate;

   procedure Toggle (T : in out Throttle) is
   begin
      T.Is_Active := not T.Is_Active;
   end Toggle;

   procedure Tick (T : in out Throttle) is
   begin
      T.Value := 
         (if T.Is_Active 
          then Percent'Min (Percent'Last,  T.Value + T.Increment)
          else Percent'Max (Percent'First, T.Value - T.Increment));
   end Tick;

end Throttles;