package server;

import java.rmi.Remote;
import java.rmi.RemoteException;

public interface Qotd extends Remote {

    public String getQuoteOfTheDay() throws RemoteException;
    
}
