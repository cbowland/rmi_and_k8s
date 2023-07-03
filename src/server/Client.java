package client;

import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import server.Greeting;

public class Client
{
  static public void main(String[] args) throws Exception
  {
    if ( args.length != 3 ) {
      System.err.println("usage: java Client host port myName");
      System.exit(1);
    }

    int index = 0;
    String host = args[index++];
    int port = Integer.parseInt(args[index++]);
    String myName = args[index++];
    String name = "Greeting";
    while (true) {
      Registry registry = LocateRegistry.getRegistry(host, port);
      System.out.println("Registry list: " + registry.list()[0]);
      Greeting greeting = (Greeting) registry.lookup(name);
      System.out.println(name + " reported: " + greeting.greet(myName));
      System.out.println("All done with greeting.");
      Thread.sleep(4000);
    }
  }
}
