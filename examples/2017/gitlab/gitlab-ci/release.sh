
if [ $# -ne 1 ] 
then 
	echo "@Usage ./release.sh branch"
	exit 1
fi

#branch
RELEASE_BRANCH=$1

## samba configuration
SMB_SERVER="//192.168.200.194/版本/  -U publish%sunjianjiao"

ROOT_PATH="万丰"
MODULE="production_management"

SRC_PATH="build/libs"

YML_FILE="src/main/resources/application.yml.example"
BUILD_INFO="build/resources/main/META-INF/build-info.properties"
SCRIPT="script"
RELEASE_JAR_FILE_NAME=$MODULE.jar


####  1. clean project and pull the latest code
git reset --hard
git checkout $RELEASE_BRANCH
git reset --hard

git pull origin $RELASE_BRANCH

git_full_commit_id=$(git log | sed -n '1p' | awk '{print $NF}')
git_short_commit_id=${git_full_commit_id:0:8}
version="$RELEASE_BRANCH"_`date +%Y-%m-%d`_$git_short_commit_id
echo $version
echo $RELEASE_BRANCH

sed -i "s/^.*version = .*$/version = \"$version\"/" build.gradle

#### 2. build the project 
chmod +x gradlew

./gradlew clean    # remove the build directory
./gradlew -x test build



local_release_dir_current="$MODULE"_$version
local_release_dir=$SRC_PATH/$local_release_dir_current
mkdir $local_release_dir
cp $YML_FILE $local_release_dir
cp $SRC_PATH/*.jar $local_release_dir/$RELEASE_JAR_FILE_NAME
cp $BUILD_INFO $local_release_dir/build-info.txt
cp $SCRIPT/* $local_release_dir



#### 3. release to 194
cd $SRC_PATH

RELEASE_PACKAGE=$local_release_dir_current.zip
zip $RELEASE_PACKAGE -r $local_release_dir_current

release_dir=`date +%Y-%m-%d_%H-%M`

smbclient $SMB_SERVER  << ENDOFMYSMBCOMMANDS
cd $ROOT_PATH

mkdir $MODULE
cd $MODULE

mkdir $release_dir
cd $release_dir
 
put $RELEASE_PACKAGE

exit
ENDOFMYSMBCOMMANDS

cd -
