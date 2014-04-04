package com.asparck.maven.nailed;

import com.martiansoftware.nailgun.NGContext;

import org.apache.maven.cli.MavenCli;

public class Client {

    public static void nailMain(NGContext context) throws Exception {
        System.exit(run(context));
    }

    private static int run(NGContext context) throws Exception {
        MavenCli cli = new MavenCli(Server.currentClassWorld);
        // nailgun has already fixed System.out - pass null so that maven won't try to re-fix it
        return cli.doMain(context.getArgs(), context.getWorkingDirectory(), null, null);
    }
}
