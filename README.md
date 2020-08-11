# spark-tests

These are experimental SPARK-proven modules for simple game engine structures I've been thinking of applying to cargame-ada.

## Simple-ECS

**simple-ecs** is an example of an Entity Component System, which is a data-oriented method of structuring a game engine. 
Entities have associated Components, and groupings of Components may or may not have associated Systems to update them.
The systems are run at set intervals as required, and Components are kept contiguously in memory for cache efficiency.

This sort of system scales extremely well to large and complicated systems with many kinds of entities in large numbers.

Unfortunately this implementation isn't actually working. The one in cargame-ada is similar, and does work, however.

## Throttle

This one does actually work and is SPARK-proven, however it is comically simple. It represents the concept of a "pedal"
or "throttle" that may be pressed or released. While it is pressed, it outputs more and more power until it reaches a maximum.
While released, its output power reduces until it hits a set minimum.

This is quite useful for mapping player input (pressing arrow keys, for example) to the movement of in-game objects in
a somewhat natural way.
