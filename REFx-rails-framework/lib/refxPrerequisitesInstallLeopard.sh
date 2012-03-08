#!/bin/sh

touch /tmp/prerequisites-script-was-executedLeopard


platform='unknown'
unamestr=`uname -r | cut -f 1 -d .`
if [[ "$unamestr" == '10' ]]; then
    platform='universal-darwin10.0'
elif [[ "$unamestr" == '9' ]]; then
    platform='universal-darwin9.0'
elif [[ "$unamestr" == '11' ]]; then
    platform='universal-darwin11.0'
fi

echo $platform

getScriptPath () {
	echo ${0%/*}/
}

currentPath="`pwd`/$(getScriptPath)"
echo $currentPath

############################### APPSCRIPT
cd $currentPath
cd ../vendor/
echo 
echo "INSTALLING CORRECT APPSCRIPT GEM"

mv gems/rb-appscript-0.6.1 gemsDisabled/
mv gemsDisabled/rb-appscript-0.5.1 gems/

############################### SQLITE
echo "REMOVING SQLITE GEM"
mv gems/src-sqlite3-1.3.4 gemsDisabled/


