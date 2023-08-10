package server;

import java.util.Random;

public class QotdObject implements Qotd {

    String[] quotes = new String[] {
        "I got a fever and the only prescription is MORE COWBELL! - Christopher Walken",
        "Knowledge is power. - Francis Bacon",
        "Life is really simple, but we insist on making it complicated. - Confucius",
        "This above all, to thine own self be true. - William Shakespeare",
        "Never complain, never explain. - Katharine Hepburn",
        "I did it my way. - Frank Sinatra",
        "Yeah, well, that's just like ... your opinion ... man .... - The Dude",
        "If you are going through hell, keep going. - Winston Churchill",
        "The most common way people give up their power is by thinking they don't have any. - Alice Walker",
        "If you build it, they will come. - Shoeless Joe Jackson",
        "Without music, life would be a mistake. - Friedrich Nietzche",
        "If you want something said, ask a man; if you want something done, ask a woman. - Margaret Thatcher",
        "It does not require many words to speak the truth. - Chief Joseph"
    };

    public String getQuoteOfTheDay() {
        Random r = new Random();
        int index = r.nextInt(quotes.length);
        return quotes[index];
    }

}
