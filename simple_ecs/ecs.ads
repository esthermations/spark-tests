with Simple_ECS;
with Globals;
package ECS is new Simple_ECS 
   (Max_Entities   => 1000, 
    Max_Systems    => 10, 
    Component_Kind => Globals.Component_Kind);
