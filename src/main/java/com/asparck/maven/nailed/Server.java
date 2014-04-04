package com.asparck.maven.nailed;

import java.net.InetAddress;

import com.martiansoftware.nailgun.NGServer;

public class Server {

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.err.println("Expecting exactly one arg: [host:]port");
            return;
        }

        String[] argParts = args[0].split(":");
        InetAddress serverAddress = InetAddress.getByName(argParts[0]);
        int port = Integer.parseInt(argParts[1]);

        NGServer server = new NGServer(serverAddress, port, NGServer.DEFAULT_SESSIONPOOLSIZE);
        server.run();
    }

}
