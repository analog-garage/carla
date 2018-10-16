<h1>How to build CARLA on Mac OSX (experimental)</h1>

INote that unlike the Linux build, this one uses the standard Mac compiler tools and
the standard Unreal Engine 4.19 distribution.

Prerequisites
-------------

Install the build tools and dependencies

    $ brew install git cmake ninja python3 sed curl wget unzip autoconf automake libtool

To avoid compatibility issues between Unreal Engine and the CARLA dependencies,
the best configuration is to compile everything with the same compiler version
and C++ runtime library. We use clang 3.9 and LLVM's libc++. You may need to
change your default clang version to compile Unreal. 

### Install Xcode 9.2

If you are running macOS "Sierra" 10.12.6, then Xcode 9.2 is the most up-to-date
version, so you should simply be able to install from the AppStore, otherwise
you can install from [Apple's developer downloads](https://developer.apple.com/download/more/).

If you have installed more than one version of Xcode, you should activate 9.2 using
the `xcode-select` command line utility. This will set `/usr/bin/clang` and `/usr/bin/clang++`
to the appropriate versions, and these are what will be used in the build.

Note that Apple's has it's own clang versioning scheme that tracks the Xcode versions,
so it is not obvious how the features compare to the LLVM distributions, but this version
should fully support c++14 features.

### Install Unreal Engine 4.19

Install the [Epic Games Launcher](https://www.epicgames.com/unrealtournament/download)
and use it to download version 4.19 of the Unreal Engine. The default install location
is `/Users/Shared/Epic Games/`, but it is a good idea to eliminate the space in the path
and instead use `/Users/Shared/EpicGames/` since some tools seem to have problems with
the space.

Although, you don't need to build the engine from source, you do need to add the file
[GenerateProjectFiles.sh](https://github.com/EpicGames/UnrealEngine/blob/4.19/GenerateProjectFiles.sh) to the root directory from a copy of the Unreal Engine source tree.

### Install the build tools and dependencies

~~~sh
$ brew install git cmake ninja python3 sed curl wget unzip autoconf automake libtool
~~~

Build CARLA
-----------

Clone or download the project from our
[GitHub repository](https://github.com/carla-simulator/carla)

    $ git clone https://github.com/carla-simulator/carla

Note that the `master` branch contains the latest fixes and features, for the
latest stable code may be best to switch to the latest release tag.

Run the setup script to download the content and build all dependencies. It
takes a while (you can speed up the process by parallelizing the script with the
`--jobs=8` flag)

    $ ./Xcode9.2Setup.sh

Once it's done it should print "Success" if everything went well.

To build CARLA, use the rebuild script. This script deletes all intermediate
files, rebuilds whole CARLA, and launches the editor. Use it too for making a
clean rebuild of CARLA

    $ UE4_ROOT=/Users/Shared/EpicGames/UE_4.18
    $ ./MacRebuild.sh

It looks at the environment variable `UE4_ROOT` to find the right version of
Unreal Engine. You can also add this variable to your "~/.bashrc" or similar.

Later, if you need to compile some changes without doing a full rebuild, you can
use the Makefile generated in the Unreal project folder

    $ cd Unreal/CarlaUE4
    $ make CarlaUE4Editor

Updating CARLA
--------------

Every new release of CARLA we release a new package with the latest changes in
the CARLA assets. To download the latest version, run the "Update" script

    $ git pull
    $ ./Update.sh

Launching the editor
--------------------

As long as CarlaUE4 was built against the standard 4.18 engine from the
Epic Games installer launcher, you can launch the editor from the Epic Games
Launcher or by opening the `.uproject` file from the finder or by using the
open command:

   $ open Unreal/CarlaUE4/CarlaUE4.uproject

If you didn't use the standard engine, you can launch the editor using:

    $ cd Unreal/CarlaUE4
    $ open -a ${UE4_ROOT}/Engine/Binaries/Mac/UE4Editor.app "$PWD/CarlaUE4.uproject"

Test (Optional)
---------------

A set of unit tests is available for testing the CarlaServer library (note that
these tests launch the python client, they require python3 and protobuf for
python3 installed, as well as ports 2000 and 4000 available)

    $ make check
