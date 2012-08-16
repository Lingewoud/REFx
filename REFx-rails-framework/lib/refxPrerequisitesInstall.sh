#!/bin/sh

touch /tmp/prerequisites-script-was-executed


platform='unknown'
unamestr=`uname -r | cut -f 1 -d .`
if [[ "$unamestr" == '10' ]]; then
    platform='universal-darwin10.0'
elif [[ "$unamestr" == '9' ]]; then
    exit 0
elif [[ "$unamestr" == '11' ]]; then
    platform='universal-darwin11.0'
elif [[ "$unamestr" == '12' ]]; then
    platform='universal-darwin12.0'
fi

echo $platform


getScriptPath () {
	echo ${0%/*}/
}

currentPath="`pwd`/$(getScriptPath)"
echo $currentPath

############################### APPSCRIPT
cd $currentPath
cd ../vendor/gems/rb-appscript-0.6.1
echo 
echo "INSTALLING APPSCRIPT GEM"

/usr/bin/install -c -m 0755 ae.bundle /Library/Ruby/Site/1.8/$platform
mkdir -p /Library/Ruby/Site/1.8/_aem
mkdir -p /Library/Ruby/Site/1.8/_appscript
/usr/bin/install -c -m 644 src/lib/_aem/aemreference.rb /Library/Ruby/Site/1.8/_aem
/usr/bin/install -c -m 644 src/lib/_aem/codecs.rb /Library/Ruby/Site/1.8/_aem
/usr/bin/install -c -m 644 src/lib/_aem/connect.rb /Library/Ruby/Site/1.8/_aem
/usr/bin/install -c -m 644 src/lib/_aem/encodingsupport.rb /Library/Ruby/Site/1.8/_aem
/usr/bin/install -c -m 644 src/lib/_aem/findapp.rb /Library/Ruby/Site/1.8/_aem
/usr/bin/install -c -m 644 src/lib/_aem/mactypes.rb /Library/Ruby/Site/1.8/_aem
/usr/bin/install -c -m 644 src/lib/_aem/send.rb /Library/Ruby/Site/1.8/_aem
/usr/bin/install -c -m 644 src/lib/_aem/typewrappers.rb /Library/Ruby/Site/1.8/_aem
/usr/bin/install -c -m 644 src/lib/_appscript/defaultterminology.rb /Library/Ruby/Site/1.8/_appscript
/usr/bin/install -c -m 644 src/lib/_appscript/referencerenderer.rb /Library/Ruby/Site/1.8/_appscript
/usr/bin/install -c -m 644 src/lib/_appscript/reservedkeywords.rb /Library/Ruby/Site/1.8/_appscript
/usr/bin/install -c -m 644 src/lib/_appscript/safeobject.rb /Library/Ruby/Site/1.8/_appscript
/usr/bin/install -c -m 644 src/lib/_appscript/terminology.rb /Library/Ruby/Site/1.8/_appscript
/usr/bin/install -c -m 644 src/lib/aem.rb /Library/Ruby/Site/1.8
/usr/bin/install -c -m 644 src/lib/appscript.rb /Library/Ruby/Site/1.8
/usr/bin/install -c -m 644 src/lib/kae.rb /Library/Ruby/Site/1.8
/usr/bin/install -c -m 644 src/lib/osax.rb /Library/Ruby/Site/1.8

############################### SQLITE
cd $currentPath
cd ../vendor/gems/src-sqlite3-1.3.4/
echo "INSTALLING SQLITE GEM"

mkdir -p /Library/Ruby/Site/1.8/$platform/sqlite3
/usr/bin/install -c -m 644 ext/sqlite3/sqlite3_native.bundle /Library/Ruby/Site/1.8/$platform/sqlite3

mkdir -p /Library/Ruby/Site/1.8/sqlite3
/usr/bin/install -c -m 644 lib/sqlite3.rb /Library/Ruby/Site/1.8/
/usr/bin/install -c -m 644 lib/sqlite3/constants.rb /Library/Ruby/Site/1.8/sqlite3/
/usr/bin/install -c -m 644 lib/sqlite3/database.rb /Library/Ruby/Site/1.8/sqlite3/
/usr/bin/install -c -m 644 lib/sqlite3/errors.rb /Library/Ruby/Site/1.8/sqlite3/
/usr/bin/install -c -m 644 lib/sqlite3/pragmas.rb /Library/Ruby/Site/1.8/sqlite3/
/usr/bin/install -c -m 644 lib/sqlite3/resultset.rb /Library/Ruby/Site/1.8/sqlite3/
/usr/bin/install -c -m 644 lib/sqlite3/statement.rb /Library/Ruby/Site/1.8/sqlite3/
/usr/bin/install -c -m 644 lib/sqlite3/translator.rb /Library/Ruby/Site/1.8/sqlite3/
/usr/bin/install -c -m 644 lib/sqlite3/value.rb /Library/Ruby/Site/1.8/sqlite3/
/usr/bin/install -c -m 644 lib/sqlite3/version.rb /Library/Ruby/Site/1.8/sqlite3/

cd ../../
mv  gems/src-sqlite3-1.3.4 gemsDisabled/
mv  gems/sqlite3-ruby-1.2.5 gemsDisabled/



