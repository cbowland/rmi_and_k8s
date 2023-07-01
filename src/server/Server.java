package server;

import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.server.UnicastRemoteObject;

import server.GreetingObject;
import server.Greeting;

public class Server
{
  static public void main(String[] args) throws Exception
  {
    if ( args.length == 0 ) {
      System.err.println("usage: /path/to/java Server port#");
      System.exit(1);
    }

    int index = 0;
    int port = Integer.parseInt(args[index++]);
    String name = "Greeting";
    Greeting greeting = new GreetingObject();
    Greeting stub = (Greeting)UnicastRemoteObject.exportObject(greeting, 5000);
    Registry registry = LocateRegistry.getRegistry(port);
    registry.rebind(name, stub);
    System.out.println("Greeting bound to \"" + name + "\"");
  }
}
