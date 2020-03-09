with Comps;
package body Systems is
   procedure Run (S : in Tick_Position; E : ECS.Entity) is
      Pos :          Float := Comps.Position.Get (E);
      Vel : constant Float := Comps.Velocity.Get (E);
   begin
      Pos := Pos + Vel;
      Comps.Position.Set (E, Pos);
   end Tick_Position;
end Systems;