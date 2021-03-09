import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

public class Country extends Entity {
    // TODO
    private String name;
    private int gold = 50;
    private int cash = 10000;
    private int worth;
    private BufferedImage image; //buffered image method is also used here
    private Font font = new Font("Verdana", Font.BOLD, 15);
    private  Agent intelligenceAgent;
    private  OrderFactory orderFactory; // orders created by factory pattern
    private ArrayList<Order> orders = new ArrayList<>(); // a country's order is held int an arraylist



    public Country(double x, double y, String imagePath, String name, String agentImagePath, String agentName) {
        super(x, y);
        getCountryImage(imagePath);
        this.name = name;
        calculateWorth(); //initiate worth
        this.intelligenceAgent = new BasicAgent(this.position.getX() + 20,
                this.position.getY() -150, agentImagePath, agentName);
    }

    //getters
    public String getName() {
        return name;
    }

    public Agent getIntelligenceAgent() {
        return intelligenceAgent;
    }


    public ArrayList<Order> getOrder() {
        return orders;
    }

    @Override
    public void draw(Graphics2D g2d) {

        Common.handleCollisions(); //check all the agents if they collided with orders
        countryFlagAndInfo(g2d); // set country flag and related info
        decorateAgent( g2d); // decorate agents if they satisfy certain criteria
    }

    @Override
    public void step() {
        // By this getRandomGenerator() function any we can determine how often we want
        // some function call to occur by changind the bound
        if (Common.getRandomGenerator().nextInt(200) == 0){
            intelligenceAgent.step();
        }
        // this is where  order frequency is controlled.
        if (Common.getRandomGenerator().nextInt(100) == 0){
            addOrderToOrders();
        }

        // if order crosses the line upper line then execute that order this is done by orderCheck
        orderCheck();

    }

    private void decorateAgent(Graphics2D g2d){
        // IA does not know the fact that it is being decorated.
        if(intelligenceAgent.getCash() > 2000 && intelligenceAgent.getCash() < 4000   ){
            intelligenceAgent = new Novice(intelligenceAgent, g2d).getDecoratedAgent();

        }else if( intelligenceAgent.getCash() > 4000 && intelligenceAgent.getCash() < 6000  ){
            intelligenceAgent = new Master(new Novice(intelligenceAgent, g2d)
                                    .getDecoratedAgent(), g2d).getDecoratedAgent();


        }else if(intelligenceAgent.getCash() > 6000  ){
            intelligenceAgent = new Expert(new Master(new Novice(intelligenceAgent, g2d)
                    .getDecoratedAgent(), g2d).getDecoratedAgent(), g2d).getDecoratedAgent();

        }
    }

     private void calculateWorth(){

        this.worth = (int) (Double.valueOf(this.gold)*Common.getGoldPrice().getCurrentPrice() + this.cash);
    }

    // This country's agent stole an order  then update the worth cash and gold
    public void weStoleAnOrder(Order order){

        if(order.getOrderType().equals("BUY")){
            this.cash += order.getAmount()*Common.getGoldPrice().getCurrentPrice();
        }else if(order.getOrderType().equals("SELL")){
            this.gold += order.getAmount();
        }else{
            System.out.println("Error: There is a problem with order type");
        }
        calculateWorth();

        intelligenceAgent.updateAgent(order.getAmount());
    }
    //This country's order is stolen. then update the worth cash and gold
    public void ourOrderIsStolen(Order order){
        if(order.getOrderType().equals("BUY")){
            this.cash -= order.getAmount()*Common.getGoldPrice().getCurrentPrice();
            if(this.cash < 0){
                this.cash = 0;
            }

        }else if(order.getOrderType().equals("SELL")){

            if(this.gold -order.getAmount() > 0){//if country rus out of gold do not execute the order.
                this.gold -= order.getAmount();
            }else{
                this.gold = 0;
            }

        }else{
            System.out.println("Error: There is a problem with order type");
        }
        calculateWorth();

    }

    private  void  orderCheck(){
        // if order crosses the line upper line then execute that order
        for(int i =0; i < orders.size(); i++){
            Order order = orders.get(i);
            if(order.getPosition().getY()  < Common.getUpperLineY()){
                if(order.getOrderType().equals("BUY")){
                    gold += order.getAmount();
                    cash -= order.getAmount()* Common.getGoldPrice().getCurrentPrice();
                    if(this.cash < 0){
                        this.cash = 0;
                    }

                }else if(order.getOrderType().equals("SELL")){
                    gold -= order.getAmount();
                    if(this.gold < 0){
                        this.gold = 0;
                    }
                    cash += order.getAmount()* Common.getGoldPrice().getCurrentPrice();

                }else{
                    System.out.println("There is a problem with orderCheck");
                }
                calculateWorth();
                orderRemove(i);
            }
        }
    }

    public void orderRemove(int orderIndex){

            orders.remove(orderIndex);

    }

    private void addOrderToOrders(){
        orders.add( OrderFactory.buildOrder(this.position,name));
    }

    private void countryFlagAndInfo(Graphics2D g2d){
        try {
            image = resizeImage(image,100,100);
        } catch (IOException ex) {
            // handle exception...
        }
        g2d.drawImage(image, position.getIntX(), position.getIntY(), null);

        // use Graphics2D methods to draw country image constantly. Their coordinates
        // change to create an animated effect
        g2d.setColor(Color.BLACK);
        g2d.setFont(font);
        // draw country name
        g2d.drawString(String.format(name), position.getIntX() + 30, position.getIntY() + 120);
        // draw gold count
        g2d.setColor(Color.YELLOW);
        g2d.drawString(String.format( Integer.toString(gold) + " gold"), position.getIntX() + 10,
                position.getIntY() + 140);
        // draw total cash
        g2d.setColor(Color.GREEN);
        g2d.drawString(String.format( Integer.toString(cash) + " cash"), position.getIntX() + 10,
                position.getIntY() + 160);
        // draw total worth
        g2d.setColor(Color.BLUE);
        g2d.drawString(String.format( "Worth: " + Integer.toString(worth)  ),
                position.getIntX() + 10, position.getIntY() + 180);
    }

    private void getCountryImage(String imagePath){
        try {
            image = ImageIO.read(new File(imagePath));
        } catch (IOException ex) {
            System.out.println("Error: loading image of the country");
        }
    }

    // method to resize an image by specified sizes.
    private BufferedImage resizeImage(BufferedImage originalImage, int targetWidth, int targetHeight) throws IOException {
        BufferedImage resizedImage = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics2D = resizedImage.createGraphics();
        graphics2D.drawImage(originalImage, 0, 0, targetWidth, targetHeight, null);
        graphics2D.dispose();
        return resizedImage;
    }


}