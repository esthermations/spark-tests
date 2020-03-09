with Ada.Text_IO;
with Globals;
with Systems;
with Comps;
with ECS;

procedure Main with SPARK_Mode is

   use ECS;
   use Globals;

   Ents : ECS.Entity_Array (1 .. Max_Entities);

begin

   ECS.Manager.Register_System (new Systems.Tick_Position'(Comps => (Position + Velocity)'Class);

   for E of Ents loop
      ECS.Create_Entity (E);
      if E mod 5 = 0 then
         ECS.Manager.Add_Component (E, Position);
         ECS.Manager.Add_Component (E, Velocity);
         Comps.Position.Set (E, Float (E));
         Comps.Velocity.Set (E, Float (E));
      end if;
   end loop;

   for E of ECS.Manager.Query (Position + Velocity) loop
      Ada.Text_IO.Put_Line (E'Img & " : Position = " & Comps.Position.Get (E)'Img);
   end loop;

   Ada.Text_IO.Put_Line ("RUNNING SYSTEMS.");
   ECS.Manager.Run_Systems;
   Ada.Text_IO.Put_Line ("DONE.");

   for E of ECS.Manager.Query (Position + Velocity) loop
      Ada.Text_IO.Put_Line (E'Img & " : Position = " & Comps.Position.Get (E)'Img);
   end loop;

end Main;