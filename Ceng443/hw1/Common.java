import java.util.ArrayList;
import java.util.Random;

public class Common {
    private static final String title = "Gold Wars";
    private static final int windowWidth = 1650;
    private static final int windowHeight = 1000;
    private static final GoldPrice goldPrice = new GoldPrice(588, 62);
    private static final ArrayList<Country> countries = new ArrayList<Country>();
    private static final Random randomGenerator = new Random(1453);
    private static final int upperLineY = 100;
    static
    {
        // TODO: Here, you can initialize the fields you have declared
        String BasePath =  System.getProperty("user.dir");

// image and src file must be at the same level to load an image successfully.
        String cia =  BasePath+"/images/cia.png";
        String mossad =  BasePath+"/images/mossad.png";
        String mit =  BasePath+"/images/mit.png";
        String svr = BasePath+"/images/svr.png";
        String mss =  BasePath+"/images/mss.png";

// countries are loaded accordingly.
        countries.add(new Country(150,700,BasePath +"/images/usa.jpg","USA",cia, "CIA"));
        countries.add(new Country(450,700,BasePath+"/images/israel.jpg", "Israel",mossad,"Mossad"));
        countries.add(new Country(750,700,BasePath+"/images/turkey.jpg","Turkey",mit, "MIT"));
        countries.add(new Country(1050,700,BasePath+"/images/russia.jpg","Russia",svr,"SVR"));
        countries.add(new Country(1350,700,BasePath+"/images/china.jpg","China",mss,"MSS"));

    }

    // getters
    public static String getTitle() { return title; }
    public static int getWindowWidth() { return windowWidth; }
    public static int getWindowHeight() { return windowHeight; }

    // getter
    public static GoldPrice getGoldPrice() { return goldPrice; }
    public static  ArrayList<Country> getCountries(){return countries;}


    // getters
    public static Random getRandomGenerator() { return randomGenerator; }
    public static int getUpperLineY() { return upperLineY; }

    public static void stepAllEntities() {
        if (randomGenerator.nextInt(200) == 0) goldPrice.step();
        // TODO
        // Since gold price is changed, all the elements depending on gold price needs to be changed.
        for(int i =0; i <countries.size(); i++ ){
            countries.get(i).step(); // step all the countries.
        }

    }




    public static void handleCollisions(){
        for(int i=0; i< countries.size(); i++){
            //first loop iterates  for every agent
            Country country1 = countries.get(i);
            Position agentPosition = country1.getIntelligenceAgent().getPosition();
            double agentSize = country1.getIntelligenceAgent().getAgentSize();
            Position upperRightCorner = new Position(agentPosition.getX() + agentSize,agentPosition.getY());
            Position lowerLeftCorner = new Position(agentPosition.getX(), agentPosition.getY() + agentSize);
            for (int j=0; j < countries.size(); j++){
                //second loop iterates over every country
                Country country2 = countries.get(j);

                for(int k = 0; k < country2.getOrder().size(); k++){
                    //third loop iterates for every order of every country
                    Order order = country2.getOrder().get(k);

                    //if collusion occurs than remove order and update related fields in countries and agent
                    if(inBetween(upperRightCorner,lowerLeftCorner,order.getPosition() )){

                        // if order collided with its country's agent than then it wont be eaten.
                        if(country1.getName().equals(country2.getName())){
                            continue;
                        }
                        // collision occurred update collided agent, collided order's country, agent's
                        // country accordingly
                        countries.get(i).weStoleAnOrder(order);
                        countries.get(j).ourOrderIsStolen(order);

                        countries.get(j).orderRemove(k);

                    }
                }
            }


        }

    }


    private static boolean inBetween(Position upperRightCorner, Position lowerLeftCorner, Position point){
        if((lowerLeftCorner.getX() < point.getX() )&& (point.getX() < upperRightCorner.getX())){
            if((lowerLeftCorner.getY() > point.getY()) && (point.getY() >  upperRightCorner.getY())){
                return true;
            }
            return false;
        }

        return false;
    }
}