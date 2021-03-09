

public abstract class Order extends Entity {
    // TODO
    //Orders attributes can be set here
    private  int amount;
    private double speed;
    private double minAmount = 1.0;
    private double maxAmount = 5.0;
    private  double maxSpeed = 2;
    private  double minSpeed = 1;
    private String initials;
    private  Position randomPosition;
    private Position pointToPointVector;
    private Position normalizedPointVector;
    private  String orderType;



    public Order(double x, double y, String initials, String orderType) {
        super(x, y);
        this.initials = initials;
        //set attributes
        speed = getSpeedRandomly();
        amount = getAmountRandomly();
        this.orderType = orderType;
        //random position is get from a static function
        randomPosition = new Position(GotoXY.getRandomX(), 0);
        //order moves to a random position which is above upperYLine.
        pointToPointVector = new Position(randomPosition.getX() - position.getX(),
                randomPosition.getY() - position.getY());
        normalizedPointVector = GotoXY.normalizeVector(pointToPointVector);

    }
    //getters
    public String getOrderType() {
        return orderType;
    }

    public String getInitials() {
        return initials;
    }

    public void Move(){
        // normalizedPointVector points to the randomPoint. Move method is shared
        // between child classes.
        this.position.setX(this.position.getX() + this.speed*normalizedPointVector.getX());
        this.position.setY(this.position.getY() + this.speed*normalizedPointVector.getY());

    }



    protected double getSpeedRandomly() {
        // by this formula random speed is kept within the range of min - max.
        return minSpeed + Common.getRandomGenerator().nextDouble() * (maxSpeed - minSpeed);

    }

    private int  getAmountRandomly(){
        // by this formula random amount is kept within the range of min - max.
        return (int)( minAmount + Common.getRandomGenerator().nextDouble() * (maxAmount - minAmount+1));
    }

    public int getAmount() {
        return this.amount;
    }
}