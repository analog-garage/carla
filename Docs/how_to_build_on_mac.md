<h1>How to build CARLA on Mac OSX (experimental)</h1>

Install the build tools and dependencies

    $ brew install git cmake ninja python3 sed curl wget unzip autoconf automake libtool

To avoid compatibility issues between Unreal Engine and the CARLA dependencies,
the best configuration is to compile everything with the same compiler version
and C++ runtime library. We use clang 3.9 and LLVM's libc++. You may need to
change your default clang version to compile Unreal. 

Xcode 8.2.1 is based on clang 3.9, so you can install and activate that by doing the following:

* Download Xcode 8.2.1 from Apple developer site:  
  https://developer.apple.com/download/more/.  
  You may first need to register as developer.

* Uncompress, rename `XCode8.2.1` to avoid clash with latest Xcode and 
  move to `/Applications` folder.

* Activate 8.2.1:

        $ sudo xcode-select -s /Applications/XCode.8.2.1/Contents/Developer

You can use `xcode-select` later to switch back to the original version.

Build Unreal Engine
-------------------

!!! note
    Unreal Engine repositories are set to private. In order to gain access you
    need to add your GitHub username when you sign up at
    [www.unrealengine.com](https://www.unrealengine.com).

Download and compile Unreal Engine 4.18. Here we will assume you install it at
"~/UnrealEngine_4.18", but you can install it anywhere, just replace the path
where necessary.

    $ git clone --depth=1 -b 4.18 https://github.com/EpicGames/UnrealEngine.git ~/UnrealEngine_4.18
    $ cd ~/UnrealEngine_4.18
    $ ./Setup.sh && ./GenerateProjectFiles.sh

Load the project into Xcode by double-clicking on the **UE4.xcworkspace** file. Select the **ShaderCompileWorker** for **My Mac** target in the title bar, then select the 'Product > Build' menu item. When Xcode finishes building, do the same for the **UE4** for **My Mac** target. Compiling may take anywhere between ? minutes and an hour, depending on your system specs (not much data on this yet).

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

    $ ./Xcode8.2.1Setup.sh

Once it's done it should print "Success" if everything went well.

To build CARLA, use the rebuild script. This script deletes all intermediate
files, rebuilds whole CARLA, and launches the editor. Use it too for making a
clean rebuild of CARLA

    $ UE4_ROOT=~/UnrealEngine_4.18 ./MacRebuild.sh

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

To open the editor once the project is already built

    $ cd Unreal/CarlaUE4
    $ open -a ~/UnrealEngine_4.18/Engine/Binaries/Mac/UE4Editor.app "$PWD/CarlaUE4.uproject"

Test (Optional)
---------------

A set of unit tests is available for testing the CarlaServer library (note that
these tests launch the python client, they require python3 and protobuf for
python3 installed, as well as ports 2000 and 4000 available)

    $ make check
