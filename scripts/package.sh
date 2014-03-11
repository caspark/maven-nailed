#!/bin/bash

# Downloads maven & the nailgun client source, compiles & copies the latter into the maven dir, then creates some
# scripts in the downloaded maven's bin dir.

M2_REPOSITORY=$1
PROJECT_VERSION=$2
NAILGUN_VERSION=$3
MAVEN_VERSION=$4

[[ -d target ]] || ( echo "target directory not found; run mvn package instead of invoking this script directly" && exit 1 )

cd target

MAVEN_URL=http://www.us.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz

[[ -e apache-maven-$MAVEN_VERSION-bin.tar.gz ]] \
  || ( ( echo "Downloading maven $MAVEN_VERSION" && wget $MAVEN_URL -nv  ) \
    || ( echo "Download failed; aborting!" && exit 1 ) )

[[ -d apache-maven-$MAVEN_VERSION ]] && rm -r apache-maven-$MAVEN_VERSION

echo "Extracting apache-maven-$MAVEN_VERSION-bin.tar.gz"
tar xf apache-maven-$MAVEN_VERSION-bin.tar.gz

echo "Copying extension libs to apache-maven-$MAVEN_VERSION/lib/ext/"
cp maven-nailed-$PROJECT_VERSION.jar \
  $M2_REPOSITORY/com/martiansoftware/nailgun-server/$NAILGUN_VERSION/nailgun-server-$NAILGUN_VERSION.jar \
  apache-maven-$MAVEN_VERSION/lib/ext/

if [[ "$?" -ne 0 ]]; then
  echo "Copying extension libs failed; aborting!"
  exit 2
fi

NAILGUN_CLIENT_SRC_URL=https://raw.github.com/martylamb/nailgun/nailgun-all-$NAILGUN_VERSION/nailgun-client/ng.c

[[ -e ng.c ]] \
  || ( ( echo "Downloading nailgun client source v$NAILGUN_VERSION" && wget -nv $NAILGUN_CLIENT_SRC_URL ) \
    || ( echo "Download failed; aborting!" && exit 3 ) )

echo "Compiling nailgun $NAILGUN_VERSION client to 'ng'"
gcc ng.c -o ng
if [[ "$?" -ne 0 ]]; then
  echo "Compiling nailgun client (ng) failed; aborting!"
  exit 4
fi

echo "Copying 'ng' to apache-maven-$MAVEN_VERSION/bin/"
cp ng apache-maven-$MAVEN_VERSION/bin/
if [[ "$?" -ne 0 ]]; then
  echo "Copying ng to maven bin dir failed; aborting!"
  exit 5
fi

echo "Creating nvn & nvn-server scripts in apache-maven-$MAVEN_VERSION/bin/"
sed 's/-Dclassworlds.conf=${M2_HOME}\/bin\/m2.conf/-Dclassworlds.conf=${M2_HOME}\/bin\/nvn-server.conf/' apache-maven-$MAVEN_VERSION/bin/mvn > apache-maven-$MAVEN_VERSION/bin/nvn-server \
  && sed 's/org.apache.maven.cli.MavenCli/com.asparck.maven.nailed.Server/' apache-maven-$MAVEN_VERSION/bin/m2.conf > apache-maven-$MAVEN_VERSION/bin/nvn-server.conf \
  && cp ../scripts/nvn.sh apache-maven-$MAVEN_VERSION/bin/nvn \
  && chmod +x apache-maven-$MAVEN_VERSION/bin/nvn apache-maven-$MAVEN_VERSION/bin/nvn-server

if [[ "$?" -ne 0 ]]; then
  echo "Creating maven scripts failed; aborting!"
  exit 6
fi

echo "Successfully repackaged maven"
echo "Next steps:"
echo "- Try using ./target/apache-maven-$MAVEN_VERSION/bin/nvn in place of mvn a few times"
echo "- You probably want to move ./target/apache-maven-$MAVEN_VERSION/ somewhere & symlink bin/nvn"
