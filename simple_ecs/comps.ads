with Globals;
with ECS;
package Comps is
   package Position is new ECS.Generic_Component_Store (Float, Globals.Position);
   package Velocity is new ECS.Generic_Component_Store (Float, Globals.Velocity);
end Comps;

