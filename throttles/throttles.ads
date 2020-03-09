
package Throttles with SPARK_Mode is

   subtype Percent is Float range 0.0 .. 1.0;

   type Throttle is tagged record
      Value     : Percent := 0.0;
      Increment : Percent := 0.01;
      Is_Active : Boolean := False;
   end record;

   procedure Activate (T : in out Throttle)
      with Post    => T.Is_Active,
           Global  => null,
           Depends => (T => T);

   procedure Deactivate (T : in out Throttle)
      with Post    => not T.Is_Active,
           Global  => null,
           Depends => (T => T);

   procedure Toggle (T : in out Throttle)
      with Post    => T'Old.Is_Active = not T.Is_Active,
           Global  => null,
           Depends => (T => T);

   procedure Tick (T : in out Throttle)
      with Post           => T'Old.Is_Active = T.Is_Active and 
                             T'Old.Increment = T.Increment and
                             T.Value     in Percent and
                             T.Increment in Percent,
           Global         => null,
           Depends        => (T => T),
           Contract_Cases => 
              (    T.Is_Active => T.Value = Percent'Min (Percent'Last,  T'Old.Value + T.Increment), 
               not T.Is_Active => T.Value = Percent'Max (Percent'First, T'Old.Value - T.Increment));

end Throttles;