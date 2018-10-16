#! /bin/bash

################################################################################
# CARLA Xcode9.2Setup.sh
#
# This script sets up the environment and dependencies for compiling CARLA on
# Mac OSX assuming that Xcode 9.2 is the active Xcode version.
#
#   1) Download CARLA Content if necessary.
#   2) Download other third-party libraries and compile them with libc++.
#
# Thanks to the people at https://github.com/Microsoft/AirSim for providing the
# important parts of this script.
################################################################################

# TODO - check or install dependencies:
#   cmake, git, wget, autoconf, automake, ninja ...
#   Installing tac command required coreutils plus manual hack to link tac to gtac.

set -e

DOC_STRING="Download and compile CARLA content and dependencies."

USAGE_STRING="Usage: $0 [-h|--help] [-s|--skip-download] [--jobs=N]"

# ==============================================================================
# -- Parse arguments -----------------------------------------------------------
# ==============================================================================

UPDATE_SCRIPT_FLAGS=
NUMBER_OF_ASYNC_JOBS=1

OPTS=`getopt -o hs --long help,skip-download,jobs:: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "$USAGE_STRING" ; exit 2 ; fi

eval set -- "$OPTS"

while true; do
  case "$1" in
    -s | --skip-download )
      UPDATE_SCRIPT_FLAGS=--skip-download;
      shift ;;
    --jobs)
        case "$2" in
          "") NUMBER_OF_ASYNC_JOBS=4 ; shift 2 ;;
          *) NUMBER_OF_ASYNC_JOBS=$2 ; shift 2 ;;
        esac ;;
    -h | --help )
      echo "$DOC_STRING"
      echo "$USAGE_STRING"
      exit 1
      ;;
    * )
      break ;;
  esac
done

# ==============================================================================
# -- Set up environment --------------------------------------------------------
# ==============================================================================

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$SCRIPT_DIR" >/dev/null

# Require xcode 9.2
command -v xcodebuild >/dev/null 2>&1 || {
  echo >&2 "Xcode 9.2 is required, but no Xcode version is installed";
  exit 1;
}

if !(xcodebuild -version | grep -q 'Xcode 9.2'); then
  echo >&2 "Xcode 9.2 is required, but is not currently active.";
  echo >&2 "Install Xcode 9.2 from Apple developer site and ";
  echo >&2 "Use xcode-select to switch to 9.2.";
  exit 1;
fi

mkdir -p Util/Build
pushd Util/Build >/dev/null

export C_COMPILER=clang
export COMPILER=clang++

# ==============================================================================
# -- Get Boost and compile it with libc++ --------------------------------------
# ==============================================================================

# Get boost source
if [[ ! -d "boost-source" ]]; then
  echo "Retrieving boost..."
  wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz
  tar -xvzf boost_1_67_0.tar.gz
  rm boost_1_67_0.tar.gz
  mv boost_1_67_0 boost-source
else
  echo "Folder boost-source already exists, skipping download..."
fi

pushd boost-source >/dev/null

BOOST_TOOLSET="clang"
BOOST_CFLAGS="-fPIC -std=c++14"
BOOST_LFLAGS="-stdlib=libc++"

./bootstrap.sh \
    --with-toolset=clang \
    --prefix=../boost-install \
    --with-libraries=system
./b2 clean
./b2 toolset="${BOOST_TOOLSET}" cxxflags="${BOOST_CFLAGS}" --prefix="../boost-install" -j $NUMBER_OF_ASYNC_JOBS stage release
./b2 install toolset="${BOOST_TOOLSET}" cxxflags="${BOOST_CFLAGS}" linkflags="${BOOST_LFLAGS}" --prefix="../boost-install" -j $NUMBER_OF_ASYNC_JOBS

popd >/dev/null

# ==============================================================================
# -- Get Protobuf and compile it with libc++ -----------------------------------
# ==============================================================================

# Get protobuf source
if [[ ! -d "protobuf-source" ]]; then
  echo "Retrieving protobuf..."
  git clone --depth=1 -b v3.3.0 --recurse-submodules https://github.com/google/protobuf.git protobuf-source
else
  echo "Folder protobuf-source already exists, skipping git clone..."
fi

pushd protobuf-source >/dev/null

./autogen.sh
./configure \
    CC="clang" \
    CXX="clang++" \
    CXXFLAGS="-fPIC -stdlib=libc++"  \
    LDFLAGS="-stdlib=libc++ " \
    --prefix="$PWD/../protobuf-install" \
    --disable-shared
make -j $NUMBER_OF_ASYNC_JOBS
make -j $NUMBER_OF_ASYNC_JOBS install

popd >/dev/null

# ==============================================================================
# -- Get GTest and compile it with libc++ --------------------------------------
# ==============================================================================

# Get googletest source
if [[ ! -d "googletest-source" ]]; then
  echo "Retrieving googletest..."
  git clone --depth=1 -b release-1.8.0 https://github.com/google/googletest.git googletest-source
else
  echo "Folder googletest-source already exists, skipping git clone..."
fi

pushd googletest-source >/dev/null

cmake -H. -B./build \
    -DCMAKE_C_COMPILER=${C_COMPILER} -DCMAKE_CXX_COMPILER=${COMPILER} \
    -DCMAKE_CXX_FLAGS="-std=c++14 -stdlib=libc++ " \
    -DCMAKE_INSTALL_PREFIX="../googletest-install" \
    -G "Ninja"

pushd build >/dev/null
ninja
ninja install
popd >/dev/null

popd >/dev/null

# ==============================================================================
# -- Other CARLA files ---------------------------------------------------------
# ==============================================================================

popd >/dev/null

CARLA_SETTINGS_FILE="./Unreal/CarlaUE4/Config/CarlaSettings.ini"

if [[ ! -f $CARLA_SETTINGS_FILE ]]; then
  echo "Copying CarlaSettings.ini..."
  sed -e 's/UseNetworking=true/UseNetworking=false/' ./Docs/Example.CarlaSettings.ini > $CARLA_SETTINGS_FILE
fi

./Util/Protoc.sh

# ==============================================================================
# -- Update CARLA Content ------------------------------------------------------
# ==============================================================================

echo
./Update.sh $UPDATE_SCRIPT_FLAGS

# ==============================================================================
# -- ...and we are done --------------------------------------------------------
# ==============================================================================

popd >/dev/null

set +x
echo ""
echo "****************"
echo "*** Success! ***"
echo "****************"
