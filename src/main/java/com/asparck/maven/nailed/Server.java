package com.asparck.maven.nailed;

import java.net.InetAddress;

import org.codehaus.plexus.classworlds.ClassWorld;

import com.martiansoftware.nailgun.NGServer;

public class Server {

    public static volatile ClassWorld currentClassWorld;

    public static void main(String[] args, ClassWorld classWorld) throws Exception {
        if (args.length != 1) {
            System.err.println("Expecting exactly one arg: [host:]port");
            return;
        }
        Server.currentClassWorld = classWorld;

        String[] argParts = args[0].split(":");
        InetAddress serverAddress = InetAddress.getByName(argParts[0]);
        int port = Integer.parseInt(argParts[1]);

        NGServer server = new NGServer(serverAddress, port, NGServer.DEFAULT_SESSIONPOOLSIZE);
        server.run();
    }

}
