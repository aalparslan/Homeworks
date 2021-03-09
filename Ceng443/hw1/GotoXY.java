public class GotoXY extends State {
    // TODO

    private  Position randomPosition;
    // speed is calculated randomly but withing a certain range.
    private double speed;
    // numberOfSteps is indicates how many steps needs to be taken to arrive the destination
    // since step function is called discretely our agent moves  discretely.
    private  double numberOfSteps;
    // pointToPointVector and normalizedPointVector vectors is use to perform a basic vector addition
    // from current point  to the destination.

    private Position pointToPointVector;
    private  Position normalizedPointVector;

    public GotoXY(Position position) {
        super("GotoXY", position);
        initMovement();
    }



    @Override
    public Position Move( ) {

        if(numberOfSteps < 0){
            initMovement();
            return  position;
           // Move();
        }
        numberOfSteps--;
        this.position.setX(this.position.getX() + this.speed*normalizedPointVector.getX());
        this.position.setY(this.position.getY() + this.speed*normalizedPointVector.getY());

        // We want our agents not to cross the upperYLine
        if(position.getY() < 100.0){
            position.setY(100.0);
        }
        // We want our agents not to cross the 10000 since window size is 10000
        if(position.getX() > 1000.0){
            position.setX(1000.0);
        }
        return  position;
    }

    void initMovement(){
        this.position = new Position(position.getX(),position.getY());
        // randomPosition is calculated so that agents stay within the expected boundaries of the screen.
        randomPosition = new Position(getRandomX(), getRandomY());
        speed = this.getSpeedRandomly();
        //set attributes
        numberOfSteps = getLength(position, randomPosition) /this.speed;
        pointToPointVector = new Position(randomPosition.getX() - position.getX(),
                randomPosition.getY() - position.getY());
        normalizedPointVector = normalizeVector(pointToPointVector);


    }





}