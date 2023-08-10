package client;

import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

import server.Qotd;

public class QotdClient {

    static public void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("usage: java Client host port");
            System.exit(1);
        }

        int index = 0;
        String host = args[index++];
        int port = Integer.parseInt(args[index++]);
        String name = "QuoteOfTheDay";
        Registry registry = LocateRegistry.getRegistry(host, port);
        System.out.println("Registry list: " + registry.list()[0]);
        while (true) {
            Qotd quoteOfTheDay = (Qotd) registry.lookup(name);
            System.out.println(name + ": " + quoteOfTheDay.getQuoteOfTheDay());
            Thread.sleep(4000);
        }
    }
}
