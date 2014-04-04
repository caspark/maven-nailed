package com.asparck.maven.nailed;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import com.martiansoftware.nailgun.NGContext;

import org.apache.maven.cli.MavenCli;

public class Client {

    public static void nailMain(NGContext context) throws Exception {
        System.exit(run(context));
    }

    private static int run(NGContext context) throws Exception {
        HashMap<Object, Object> originalSystemProperties = new HashMap<Object, Object>(System.getProperties());
        try {
            MavenCli cli = new MavenCli(Server.currentClassWorld);
            // nailgun has already fixed System.out - pass null so that maven won't try to re-fix it
            return cli.doMain(context.getArgs(), context.getWorkingDirectory(), null, null);
        } finally {
            // maven cli sets -D properties as system properties, which will interfere with our next invocation if we
            // don't unset them again
            restoreOriginalSystemProperties(originalSystemProperties);
        }
    }

    private static void restoreOriginalSystemProperties(HashMap<Object, Object> originalSystemProperties) {
        Set<String> currentProperties = System.getProperties().stringPropertyNames();
        for (String currentProperty : currentProperties) {
            System.clearProperty(currentProperty);
        }
        for (Map.Entry<Object, Object> originalPropertyEntry : originalSystemProperties.entrySet())
        {
            System.setProperty(originalPropertyEntry.getKey().toString(), originalPropertyEntry.getValue().toString());
        }
    }
}
