package server;

import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.server.UnicastRemoteObject;

public class Server {
    static public void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.err.println("usage: /path/to/java Server port#");
            System.exit(1);
        }

        int index = 0;
        int port = Integer.parseInt(args[index++]);
        Registry registry = LocateRegistry.getRegistry(port);
        String qotd = "QuoteOfTheDay";
        Qotd quoteOfQotd = new QotdObject();
        Qotd stubQotd = (Qotd) UnicastRemoteObject.exportObject(quoteOfQotd, 5000);
        registry.rebind(qotd, stubQotd);
        System.out.println("Quote of the day bound to \"" + qotd + "\"");
    }
}
