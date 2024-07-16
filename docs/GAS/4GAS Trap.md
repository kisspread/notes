title:Gas Common Pitfalls
comments:true

## GASComponent

- The initialization of GASComponent is after `BeginPlay`. If a node like `WaitGameplay` is called in `BeginPlay`, it usually can't register events to GAS because the GAS Component is null. This applies to both the server and client.
   ![alt text](<../assets/images/4GAS Trap_image.png>)

- `WaitGameplay`, the event "WaitGameplay" will be sent to all roles: ROLE_Authority (server), ROLE_AutonomousProxy (your character),So, always pay attention to which role the current code is running under.

- In multiplayer games, when players' behaviors are inconsistent, it's usually due to the confusion caused by the replication strategy of GE:
  In a multiple player game, the Player's GE Replicate Mode is Mixed, while NPC is set to Minimal.
   ![alt text](<../assets/images/4GAS Trap_image-1.png>)
  so the ROLE_SimulatedProxy (your game partner) will not have any Active Effects because the server does not replicate GE to them. So in this case, the node `Get Active Effects with All Tags` will always return an empty array. The same goes for NPCs.
 