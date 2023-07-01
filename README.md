# TreeGenerator
A procedural and customizable tree generator for the TIC80 fantasy computer

# Settings
- Trunk Width - The width in pixels of the main trunk

 ![trunk_width](https://github.com/archaicvirus/TreeGenerator/assets/25288625/8c16fa2c-d290-4ab7-be37-b94f9f736000)

- Trunk Height - The total height of the combined strunk segments

![trunk_height](https://github.com/archaicvirus/TreeGenerator/assets/25288625/bd3e1e89-4b7b-4d4c-abbf-42ba5b31c5a4)

- Step Height - The height in pixels of each vertical trunk segment

![step_height](https://github.com/archaicvirus/TreeGenerator/assets/25288625/ea9f9d65-8430-401d-945f-2f3a48e6c348)

- Shift/Step - The random horizontal shift range in pixels, to shift each trunk segment as it 'grows' upwards

![shift-step](https://github.com/archaicvirus/TreeGenerator/assets/25288625/bf1af58b-2225-472a-b27c-335ace92fac8)

- Sprite Id - The sprite id use for the mesh fill algorithm - (used in the trunk and branch texture)

![sprite_id](https://github.com/archaicvirus/TreeGenerator/assets/25288625/a7943595-8e94-4459-b9ff-491ced8b7075)

- Sprite id's 0-15 (the top row of tiles) can be selected to change the tree's texture

![sprite_ids](https://github.com/archaicvirus/TreeGenerator/assets/25288625/fa5d4f02-e25e-447b-ab45-2a890a9c298a)

- Branch Length - The total overal (average) length in pixels of each branch

![branch_length](https://github.com/archaicvirus/TreeGenerator/assets/25288625/52e4371d-fd21-4a64-9c60-21b0bb75a278)

- Branch Width - The width in pixel of each branch segment as the branch frows outwards (higher values lead to straighter branches)

![branch_width](https://github.com/archaicvirus/TreeGenerator/assets/25288625/abe6cda4-3f12-49d3-8c97-4e1adae84104)

- Branch Thickness - The height in pixels of each horizontal branch segment, as the segments 'grows' outwards

![branch_thickness](https://github.com/archaicvirus/TreeGenerator/assets/25288625/e9b2250a-818a-4db4-a711-355c55b21b35)

- Branch height - The average height to generate the branches, snapped to the nearest vertex of the main trunk

![branch_height](https://github.com/archaicvirus/TreeGenerator/assets/25288625/caf5a559-6fe9-4cce-859a-718582525d69)

- Branch Shift - The random range in pixels that the branches are allowed to shift upwards at each growth step in the generation process

![branch_shift](https://github.com/archaicvirus/TreeGenerator/assets/25288625/86839abb-b687-4d3a-aed2-303b6f63f268)

- Total Branches - The total amount of branches to spawn

![total_branches](https://github.com/archaicvirus/TreeGenerator/assets/25288625/8372995c-02ad-4164-b928-23780cf35ad2)

- Branch Deviation - The relative offset between branches, scaled based on number of branches and this number, offset also by branch height parameter

![branch_deviation](https://github.com/archaicvirus/TreeGenerator/assets/25288625/4b94daf7-7875-4be7-a94a-ee7e027ff3c5)

- Leaf Density - A float 0.0 - 1.0 The average chance that leaves will spawn. Leaves are spawned starting from the tip of each branch, snapped to branch vertices, going towards the trunk.

![leaf_density](https://github.com/archaicvirus/TreeGenerator/assets/25288625/d0288276-8e0b-4a47-8059-74563804e6b8)

- Leaf Cull Distance - The distance (in number of branch segments) from the tip of each branch toward the tree's trunk, to limit leaf drawing

![leaf_cull_dist](https://github.com/archaicvirus/TreeGenerator/assets/25288625/ffda6a15-4aed-446d-bb08-cddd8f593ac2)

- Leaf Fill Radius - The radius in pixels to randomly spread leaves (seperate from leaf generation on branches). Always locked to top of tree trunk

![leaf_fill_radius](https://github.com/archaicvirus/TreeGenerator/assets/25288625/b5178bf9-d057-4da3-940a-cbbbca269935)

- Leaf Fill Count - The total amount of tries to randomly distribute leaves within the fill radius

![leaf_fill_count](https://github.com/archaicvirus/TreeGenerator/assets/25288625/f2536a36-d94c-448f-9794-fc4ea0c34930)

- Vine Count - The total amount of vines to spawn. Vines are spawned by picking vertices of two randomly selected branch segments, and have a random 'sag' amount to vary the look

![vine_count](https://github.com/archaicvirus/TreeGenerator/assets/25288625/d88631c1-97ff-4262-84f6-377d92db9407)

- Fruit ID - The sprite id to use for the layers of fruits/flowers. These are spawned using the same leaf-spawn method for the branches

![fruit_id](https://github.com/archaicvirus/TreeGenerator/assets/25288625/0d8e0b86-aef5-4ae8-a12f-f4650d3f33ba)

- Fruit Density - 0.0 - 1.0 Chance to spawn fruits/flowers

![fruit_density](https://github.com/archaicvirus/TreeGenerator/assets/25288625/57802afe-d407-43b9-bb38-a937f2e1d5ae)

- Save Width & Height - in pixels, the rectangular are of screen ram to copy to sprite ram using `memcpy`

![save_width_height](https://github.com/archaicvirus/TreeGenerator/assets/25288625/d6f4be3a-57c9-423f-a579-07aa90b5a1f8)

- Save X & Y - The top-left corner of the rectangular area to copy & save to sprite/tile ram.

![save_x_y](https://github.com/archaicvirus/TreeGenerator/assets/25288625/253c63f0-c4bf-4166-926d-025f62fc10cf)

- Save ID - 0 - 511 - The tile/sprite id to paste the copied rectangle
 
![save_id](https://github.com/archaicvirus/TreeGenerator/assets/25288625/0bd238ca-a901-494b-8fa8-16c0e5d50803)

- Background Color - The current background color (for transparency reasons) - will be copied as background when saving tree

![background_color](https://github.com/archaicvirus/TreeGenerator/assets/25288625/452fd2a9-13a8-4245-9ccf-8f320cd7110d)
