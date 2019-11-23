# aa_xr_clusters
xr clusters

current issues:
    some sectors still green or pink
    red/white glow on objects in space

mod must-haves:
    textures in cluster/textures must be properly mapped in material_library
    textures in planets/textures must be properly mapped in material_library
    break shader for cluster_b_nebula_mask and cluster_d_nebula_mask
    add material_library entry for:
        t_env_stars - copy gen_stars_large
        these next ones need copied from XR and fix shader line
            stars
            stars_v2
            stars_v2b
            stars_v2b_few - also need to bring over texture
            stars_v2c
            stars_v3 - also need to bring over texture
            stars_v4
            cluster_m_gasgiant
            cluster_m_gasgiant_haze - also need to bring over texture
            cluster_m_moon
            cluster_m_planet
            cluster_m_planet_haze
            cluster_m_planet_clouds
            cluster_m_background - need to break shader and bring over textures
            cluster_l_background - need to break shader and bring over textures
            cluster_l_planet
            cluster_l_planet_haze
            cluster_l_planet_clouds
            cluster_l_planet_volcano
            cluster_l_planet_volcanolava
            cluster_n_planet
            cluster_n_planet_haze
            cluster_n_planet_rings
            cluster_c_earthlike_haze
            bg_vertexcolor_solid - also need to bring over texture


cluster_a
tppirate_cluster_97_macro
    needs a good placement for the sector, but otherwise good

cluster_b
tppirate_cluster_96_macro
    requires broken shader XU_simple_background_neb on cluster_b_nebula_mask

cluster_c
tppirate_cluster_95_macro
    bad glow memes on the big planet
    sector needs to be in petri dish

cluster_d
tppirate_cluster_94_macro
    generally good - originally missing planet textures

cluster_e
tppirate_cluster_93_macro
    needs a good placement for the sector, but otherwise good

cluster_f
tppirate_cluster_92_macro
    needs a good placement for the sector, but otherwise good

cluster_g
tppirate_cluster_91_macro
    more brocken moon - generally good and looks like a wide range of options for sector placement

cluster_h
tppirate_cluster_90_macro
    planets look weird....sector is otherwise ok

cluster_i
tppirate_cluster_88_macro
    needs a good placement for the sector, but otherwise good

cluster_c_v2
tppirate_cluster_87_macro
    needs a good placement for the sector, but otherwise good

cluster_c_v3
tppirate_cluster_86_macro
    needs a good placement for the sector, but otherwise good

cluster_c_v4
tppirate_cluster_85_macro
    needs a good placement for the sector, but otherwise good

cluster_h2
tppirate_cluster_84_macro
    requires broken shader XU_simple_background_neb on cluster_d_nebula_mask
    needs a good placement for the sector, otherwise planets look odd

cluster_h4
tppirate_cluster_83_macro
    generally good, might need a nice placement

cluster_darkspace
tppirate_cluster_82_macro
    no planets
    works great as is :)

cluster_c_v5
tppirate_cluster_81_macro
    needs a good placement for the sector, otherwise planets look odd

cluster_i2
tppirate_cluster_80_macro
    might need a good sector placement, but i like it

cluster_c_v6
meditech_Cluster_01_macro
    needs a good placement for the sector, but otherwise good
    petri dish with weird glow

cluster_sm_background
tpthree_cluster1158_macro
    definitely needs placement help, no petri dish, but black walls

cluster_sm2_background
tpthree_cluster178_macro
    possibly missing some planet textures?

cluster_t
tpthree_cluster177_macro
    needs good sector placement, possibly missing planet textures

cluster_t_v2
tpthree_cluster176_macro
    looks fine, this is the one with big stars

cluster_sm_te_background
tpthree_cluster195_macro
    needs good sector placement, possibly missing planet textures

cluster_m
tpthree_cluster196_macro
    includes the bad shader XU_simple_background_neb on cluster_m_background

cluster_n
tpthree_cluster215_macro

cluster_l
tpthree_cluster110_macro
    includes the bad shader XU_simple_background_neb on cluster_l_background

cluster_sm_hol_background
tpthree_cluster1217_macro




IGNORE
planet_sun_a
tppirate_cluster_99_macro
invalid cluster

planet_sun_A
tppirate_cluster_98_macro
invalid cluster

cluster_htest
tppirate_cluster_89_macro
invalid macro (just a test file i think)