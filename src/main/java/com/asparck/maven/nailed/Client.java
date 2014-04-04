package com.asparck.maven.nailed;

import com.martiansoftware.nailgun.NGContext;

import org.apache.maven.cli.NoSyspropChangingMavenCli;

public class Client {

    public static void nailMain(NGContext context) throws Exception {
        System.exit(run(context));
    }

    private static int run(NGContext context) throws Exception {
        NoSyspropChangingMavenCli cli = new NoSyspropChangingMavenCli(Server.currentClassWorld);
        return cli.doMain(context.getArgs(), context.getWorkingDirectory(), null, null);
    }
}
