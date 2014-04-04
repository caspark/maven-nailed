package com.asparck.maven.nailed;

import java.net.InetAddress;

import org.codehaus.plexus.classworlds.ClassWorld;

import com.martiansoftware.nailgun.NGConstants;
import com.martiansoftware.nailgun.NGServer;

public class Server {

    public static void main(String[] args, ClassWorld classWorld) throws Exception {
        // bah, this should just be a call to NGServer.main(), but plexus doesn't want us to just return
        if (args.length != 1) {
            System.err.println("Expecting exactly one arg: [host:]port");
            return;
        }

        String[] argParts = args[0].split(":");
        InetAddress serverAddress = InetAddress.getByName(argParts[0]);
        int port = Integer.parseInt(argParts[1]);

        NGServer server = new NGServer(serverAddress, port, NGServer.DEFAULT_SESSIONPOOLSIZE);
        Thread t = new Thread(server);
        t.setName("NGServer(" + serverAddress + ", " + port + ")");
        t.start();

        int runningPort = server.getPort();
        while (runningPort == 0) {
            Thread.sleep(50);
            runningPort = server.getPort();
        }

        System.out.println("NGServer "
                + NGConstants.VERSION
                + " started on "
                + ((serverAddress == null) ? "all interfaces" : serverAddress.getHostAddress())
                + ", port " + runningPort + ".");

        // wait until someone tells us to die
        t.join();
    }

}
