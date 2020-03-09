with ECS;
with Comps;

package Systems is
   use Comps;
   type Tick_Position is new ECS.System  with null record;
   procedure Run (S : in Tick_Position; E : ECS.Entity);
end Systems;