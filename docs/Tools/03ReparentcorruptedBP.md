title:UE5 Reparent corrupted BP
comments:true

----

### Reparent Corrupted BP

When we rename a BP, or move a BP to another folder, it will be corrupted, and not able to open and edit, The BP asset shows its parent as "None".

This tool allows you to reparent a corrupted BP to a new parent without restarting the editor.

#### Solution 1

this is the most common way

- using [CoreRedirects], put it in the `DefaultEngine.ini`
  ```.ini
  [CoreRedirects]
    +ClassRedirects=(OldName="Pawn",NewName="MyPawn",InstanceOnly=true)
    +ClassRedirects=(OldName="/Script/MyModule.MyOldClass",NewName="/Script/MyModule.MyNewClass")
    +ClassRedirects=(OldName="PointLightComponent",NewName="PointLightComponent",ValueChanges=(("PointLightComponent0","LightComponent0")))
    +ClassRedirects=(OldName="AnimNotify_PlayParticleEffect_C",NewName="/Script/Engine.AnimNotify_PlayParticleEffect",OverrideClassName="/Script/CoreUObject.Class")
    
    +EnumRedirects=(OldName="ENumbers",NewName="ELetters",ValueChanges=(("NumberTwo","LetterB"),("NumberThree","LetterC")))
    
 	+FunctionRedirects=(OldName="MyOldActor.OldFunction",NewName="MyNewActor.NewFunction")
    +FunctionRedirects=(OldName="MyActor.OldFunction",NewName="NewFunction")  

    +StructRedirects=(OldName="MyStruct",NewName="MyNewStruct")
  
  ```  

- then reopen Unreal Editor, the BP will be fixed
- open the BP and save it, now we can remove the [CoreRedirects]
- or just using "Update Redirector References" button
  ![alt text](../assets/images/03ReparentcorruptedBP_image.png)

#### Solution 2

This solution allows you to reparent a corrupted BP to a new parent without restarting the editor

- Using Editor Utility Blueprints
- create a new Editor Utility Blueprint from `Asset Action Utily`
- add a new function named "Reparent"
  ![alt text](../assets/images/03ReparentCrouptedBP_image.png)
  - [Blueprint node](https://dev.epicgames.com/community/snippets/xrmR/unreal-engine-reparent-bp-assets)
- select the BP you want to fix, click the "Reparent" button at `Scripted Asset Actions`
  ![alt text](../assets/images/03ReparentcorruptedBP_image-1.png)
   

### Reference

- [core redirects](https://dev.epicgames.com/documentation/en-us/unreal-engine/core-redirects-in-unreal-engine)

- [https://dev.epicgames.com/community/learning/tutorials/owYv/unreal-engine-getting-started-with-editor-utility-blueprints](https://dev.epicgames.com/community/learning/tutorials/owYv/unreal-engine-getting-started-with-editor-utility-blueprints)