
--pragma Profile (Ravenscar); 

generic
   type Component_Kind is (<>);
   Max_Entities : Positive; --  Depends on your game, but could be 100_000+. 
   Max_Systems  : Positive; --  Probably more like 20-50.
package Simple_ECS with SPARK_Mode is

   pragma Assertion_Policy (Pre => Check, Post => Check);

--   type Component_Kind is (Position, Velocity, Other);
--   Max_Entities : constant := 101;
--   Max_Systems  : constant := 10;

   ----------------
   --  Entities  --
   ----------------

   subtype Entity is Integer range 0 .. Max_Entities; 

   Next_Entity : Entity := Entity'First;

   type Entity_Array is array (Positive range <>) of Entity;
   
   procedure Create_Entity (E : out Entity)
      with Global  => (In_Out => Next_Entity),
           Depends => (E           => Next_Entity,
                       Next_Entity => Next_Entity),
           Pre     => Next_Entity < Max_Entities,
           Post    => Next_Entity = Next_Entity'Old + 1;

   ------------------
   --  Components  --
   ------------------

   type Selected_Components is array (Component_Kind) of Boolean with Pack;

   No_Components : constant Selected_Components := (others => False);

   function "+" (C : Component_Kind) return Selected_Components;

   function "+" (S : Selected_Components; C : Component_Kind) 
      return Selected_Components;

   function "+" (C1, C2 : Component_Kind) return Selected_Components 
      is ((+C1) + C2);

   function Matches (Requires, Has : in Selected_Components) return Boolean
      is (for all C in Component_Kind => (if Requires (C) then Has (C)));

   generic
      type Component_Data is private;
      Kind : Component_Kind;
   package Generic_Component_Store is

      type Component_Array is array (Entity range <>) of Component_Data
         with Pack;

      --  Yep. That simple.
      Components : Component_Array (Entity); 

      function Has (E : in Entity) return Boolean;

      function Get (E : in Entity) return Component_Data
         with Inline,
              Global  => (Input => Components),
              Depends => (Get'Result => (E, Components)),
              Pre     => Has (E),
              Post    => Has (E) and Get'Result = Components (E);

      procedure Set (E : Entity; Data : Component_Data) 
         with Inline,
              Global  => (Output => (Components)),
              Depends => (Components => (E, Data)),
              Post    => Has (E) and Data = Components (E);

   end Generic_Component_Store;

   ---------------
   --  Systems  --
   ---------------

   subtype System_Number is Positive range 1 .. Max_Systems;

   --type System_Kernel is access procedure (E : in Entity);

   type System is interface; 
   procedure Run (S : not null access System; E : in Entity) is abstract;

   ---------------
   --  Manager  --
   ---------------

   package Manager is

      Next_System : System_Number := 1;
      Systems    : array (System_Number) of access System;
      --  List of systems
      Components : array (System_Number) of Selected_Components;
      --  Which systems have which components
      Enabled    : array (Entity) of Selected_Components := (others => No_Components);
      --  Which entities have which components

      procedure Register_System (S : in System; Comps : in Selected_Components)
         with Global  => (In_Out => Next_System,
                          Output => Systems),
              Depends => (Next_System => Next_System,
                          Systems     => (S, Next_System)),
              Pre     => Next_System < Max_Systems and then
                         Comps /= No_Components,
              Post    => Next_System = Next_System'Old + 1 and then
                         S = Systems (Next_System'Old);

      procedure Run_Systems
         with Global => (Input => Systems);

      function Has_Component (E : Entity; C : Component_Kind) return Boolean
         is (Enabled (E) (C));

      procedure Add_Component (E : Entity; C : Component_Kind)
         with Global  => (In_Out => Enabled),
              Depends => (Enabled => (Enabled, E, C)),
              Post    => (Enabled (E) (C));

      function Num_Query_Matches (SC : Selected_Components) return Natural
         with Global  => (Input => Enabled),
              Depends => (Num_Query_Matches'Result => (SC, Enabled)),
              Pre     => (for some C of SC => C),
              Post    => (if Num_Query_Matches'Result = 0 
                          then (for all ESC of Enabled => 
                                   (for all C in SC'Range => not ESC (C))));

      function Query (SC : Selected_Components) return Entity_Array
         with Global  => (Input => Enabled),
              Depends => (Query'Result => (SC, Enabled)),
              Pre     => (for some C of SC => C),
              Post    => Query'Result'Length = Num_Query_Matches (SC) and
                         (for all E of Query'Result => 
                             Matches (SC, Enabled (E))); 

   end Manager;

end Simple_ECS;