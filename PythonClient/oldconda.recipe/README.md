This is a conda recipe for building CARLA python API using name oldcarla
so that it can coexist with new version of API.

To build:

1. In directory containing `oldsetup.py` and this recipe:

   ~~~sh
   $ ln -s carla oldcarla
   ~~~

2. Build:

   ~~~sh
   $ conda build -c conda-forge oldconda.recipe
   ~~~

