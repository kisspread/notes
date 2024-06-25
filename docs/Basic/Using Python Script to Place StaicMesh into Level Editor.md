title:Python Script in Editor
comments:true

```python title='demo.py' 
import unreal

# Constants
WALL_MESH_PATH = "/Game/Assets/Dungeon/SM_Wall_4x2"
WALL_SPACING = 800
WALL_HEIGHT = 220


def create_wall():
    # Get the editor utility library
    editor_util = unreal.EditorLevelLibrary
    # Before creating the wall, delete all the walls
    world = editor_util.get_editor_world()
    actors = unreal.GameplayStatics.get_all_actors_of_class(world, unreal.StaticMeshActor.static_class())
    for actor in actors:
        if actor.get_actor_label().startswith("Wall"):
            editor_util.destroy_actor(actor)

    # Define wall segments
    wall_segments = [
        {"start": unreal.Vector(0, 0, WALL_HEIGHT), "end": unreal.Vector(4800, 0, WALL_HEIGHT), "rotation": 0, "label": "Wall-Up"},
        {"start": unreal.Vector(0, -4800, WALL_HEIGHT), "end": unreal.Vector(4800, -4800, WALL_HEIGHT), "rotation": 0, "label": "Wall-Down"},
        {"start": unreal.Vector(-900, 200, WALL_HEIGHT), "end": unreal.Vector(-900, -3800, WALL_HEIGHT), "rotation": -90, "label": "Wall-Left"},
        {"start": unreal.Vector(4600, 200, WALL_HEIGHT), "end": unreal.Vector(4600, -3800, WALL_HEIGHT), "rotation": -90, "label": "Wall-Right"},
    ]
    # Create walls
    for segment in wall_segments:
        create_wall_segment(editor_util, segment["start"], segment["end"], segment["rotation"], segment["label"])

    # Log a message
    unreal.log("Walls created")


def create_wall_segment(editor_util, start, end, rotation, label):
    # Calculate the number of walls needed
    distance = unreal.Vector.distance(start, end)
    num_walls = int(distance / WALL_SPACING)

    for i in range(num_walls + 1):
        direction = unreal.Vector.subtract(end, start).normal()
        location = start + direction * (i * WALL_SPACING)
        spawn_wall(editor_util, location, rotation, f"{label}-{i}")


def spawn_wall(editor_util, location, rotation, label):
    actor = editor_util.spawn_actor_from_class(unreal.StaticMeshActor, location)
    actor.set_actor_rotation(unreal.Rotator(0, 0, rotation), False)

    # Load the static mesh
    static_mesh = unreal.EditorAssetLibrary.load_asset(WALL_MESH_PATH)
    static_mesh = unreal.StaticMesh.cast(static_mesh)

    # Set the static mesh
    static_mesh_component = actor.static_mesh_component
    static_mesh_component.set_static_mesh(static_mesh)

    # Set the actor's label and folder
    actor.set_actor_label(label)
    actor.set_folder_path(unreal.Name("/Walls"))

    # Select the actor
    actors_to_select = unreal.Array(unreal.Actor)
    actors_to_select.append(actor)
    editor_util.set_selected_level_actors(actors_to_select=actors_to_select)


if __name__ == "__main__":
    create_wall()    

```    

![image](../assets/img/output_filename.webp){ loading=lazy }