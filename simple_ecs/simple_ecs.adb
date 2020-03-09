with Ada.Text_IO;

package body Simple_ECS with SPARK_Mode is

   ----------------
   --  Entities  --
   ----------------

   procedure Create_Entity (E : out Entity) is
   begin
      E           := Next_Entity;
      Next_Entity := Next_Entity + 1;
   end Create_Entity;


   ------------------
   --  Components  --
   ------------------


   function "+" (C : Component_Kind) return Selected_Components is
      Ret : Selected_Components := (others => False);
   begin
      Ret (C) := True;
      return Ret;
   end "+";

   function "+" (S : Selected_Components; C : Component_Kind) 
      return Selected_Components 
   is
      Ret : Selected_Components := S;
   begin
      Ret (C) := True;
      return Ret;
   end "+";

   package body Generic_Component_Store is


      function Has (E : in Entity) return Boolean 
         is (Manager.Has_Component (E, Kind));

      function Get (E : in Entity) return Component_Data is
      begin
         return Components (E);
      end Get;

      procedure Set (E : in Entity; Data : in  Component_Data) is
      begin
         Manager.Add_Component (E, Kind);
         Components (E) := Data;
      end Set;

   end Generic_Component_Store;

   ---------------
   --  Manager  --
   ---------------

   package body Manager is

      -----------------------
      --  Register_System  --
      -----------------------

      procedure Register_System (S : in System) is
      begin
         Systems (Next_System) := S;
         Next_System := Next_System + 1;
      end Register_System;

      -------------------
      --  Run_Systems  --
      -------------------

      procedure Run_Systems is
      begin
         for S of Systems loop
            exit when S.Kernel = null;
            pragma Assert (S.Kernel /= null);
            for E of Query (S.Comps) loop
               S.Run (E);
            end loop;
         end loop;
      end Run_Systems;

      ---------------------
      --  Add_Component  --
      ---------------------

      procedure Add_Component (E : Entity; C : Component_Kind) is
      begin
         Enabled (E) (C) := True;
      end Add_Component;

      procedure Put (SC : in Selected_Components) is
         use Ada.Text_IO;
      begin
         Put ("(");
         for C in SC'Range loop
            Put ((if SC (C) then C'Img else ""));
            Put (" ");
         end loop;
         Put (")");
      end Put;

      -------------------------
      --  Num_Query_Matches  --
      -------------------------

      function Num_Query_Matches (SC : Selected_Components) return Natural is
         Num_Matches : Natural := 0;
      begin
         for E in Enabled'Range loop
            if Matches (Requires => SC, Has => Enabled (E)) then
               Num_Matches := Num_Matches + 1;
            end if;
         end loop;

         Ada.Text_IO.Put_Line ("Num_Query_Matches returning " & Num_Matches'Img);
         
         return Num_Matches;
      end Num_Query_Matches;

      -------------
      --  Query  --
      -------------

      function Query (SC : Selected_Components) return Entity_Array is
         Num_Matches : constant Natural := Num_Query_Matches (SC);
         Ret        : Entity_Array (1 .. Num_Matches); 
         Idx         : Positive := 1;
      begin
         for E in Enabled'Range loop
            if Matches (Requires => SC, Has => Enabled (E)) then 
               Ret (Idx) := E;
               Idx := Idx + 1;
            end if;
         end loop;
         return Ret;
      end Query;

   end Manager;

end Simple_ECS;