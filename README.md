maven-nailed
============

Speeds up Maven successive invocations by "keeping a copy of Maven running in the background" (avoiding reloading
plugin classes and taking advantage of a warmed up jvm).

Once installed, you can use `nvn` instead of `mvn`; `nvn` will transparently start `nvn-server` in the background if it
isn't already started, and then on hand all the command line args to nvn-server.

To stop `nvn-server`, run `nvn --stop` with no other args.

Currently is built with Maven 3.0.5, but should be relatively trivial to make it switchable to other versions (pull
requests welcome!)

Forked from [nigelzor's maven-nailgun](https://github.com/nigelzor/maven-nailgun) (many thanks!)

Similar to [mvnsh](https://github.com/jdillon/mvnsh), but uses [nailgun](http://martiansoftware.com/nailgun/) to run
Maven in the background rather than replacing your shell.

Prereqs:
--------

* gcc compiler
* bash and standard unix utils: nc, lsof, awk, xargs, sed, kill, cp
* nothing listening on port 45785 (`git grep MVN_NAILGUN_PORT` to see where to change this)

Installing:
-----------

To start using:

* run `mvn package` and follow instructions

To run integration tests or get a demo:

* run `mvn integration-test`

Installing manually:
--------------------

For use on Windows / other times when the packaging scripts fail.

* run `mvn pre-package` to create `target/maven-nailed-1.0-SNAPSHOT.jar`
* copy `nailgun-server-0.9.1.jar` (should be in your maven repo) and `maven-nailed-1.0-SNAPSHOT.jar` into maven's `/lib/ext/`
* in maven's /bin/, make copies of `mvn` and `m2.conf` (`mvn-ng-server` and `m2-ng.conf`)
* in `mvn-ng-server` change `"-Dclassworlds.conf=${M2_HOME}/bin/m2.conf"` to `"-Dclassworlds.conf=${M2_HOME}/bin/m2-ng.conf"`
* in `m2-ng.conf` change `org.apache.maven.cli.MavenCli` to `com.asparck.maven.nailed.Server`
* start the server with `mvn-ng-server localhost:2113`
* download and compile the [nailgun client from source](https://raw.github.com/martylamb/nailgun/nailgun-all-$NAILGUN_VERSION/nailgun-client/ng.c) to `ng`
* whenever you would call `mvn foo`, now use `ng com.asparck.maven.nailed.Client foo`
