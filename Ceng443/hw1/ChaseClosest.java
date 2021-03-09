import java.util.ArrayList;

public class ChaseClosest extends State {
    // TODO
    // speed is calculated randomly but withing a certain range.
    private double speed;
    // numberOfSteps is indicates how many steps needs to be taken to arrive the destination
    // since step function is called discretely our agent moves  discretely.
    private  double numberOfSteps = -1.0;
    // pointToPointVector and normalizedPointVector vectors is use to perform a basic vector addition
    // from current point  to the destination.
    private Position pointToPointVector;
    private  Position normalizedPointVector;


    public ChaseClosest(Position position) {
        super("ChaseClosest", position);

        //set attributes
        this.position = new Position(position.getX(), position.getY());
        speed = this.getSpeedRandomly();
        pointToPointVector = new Position(0,0);


    }

    @Override
    public Position Move( ) {

        // if point is arrived then find another point to chase.
        if(numberOfSteps <= 0){

            chase();
        }else{
            // means point is not arrived.
            numberOfSteps--;

            this.position.setX(this.position.getX() + this.speed*normalizedPointVector.getX());
            this.position.setY(this.position.getY() + this.speed*normalizedPointVector.getY());
        }

        // We want our agents to move within the range of 100 to 600 in y axis.
        if(this.position.getY() > 600 ){
            this.position.setY(600);
        }
        // We want our agents to move within the range of 0 to 1000 in x axis.
        if(this.position.getX() > 1000){
            this.position.setX(1000);
        }
        return this.position;
    }



    private void chase(){
        // find the closest order among all the orders then pick the closest
        // and perform vector additions then set attributes accordingly
        Position positionToChase = findClosest();
        numberOfSteps = getLength(position, positionToChase) /this.speed;
        double xCoordinate = positionToChase.getX() - position.getX();
        double yCoordinate = positionToChase.getY() - position.getY();
        pointToPointVector.setX(xCoordinate);
        pointToPointVector.setY(yCoordinate);
        normalizedPointVector = normalizeVector(pointToPointVector);

    }


    private Position findClosest(){

        // finds closest order to current position of the agent and returns this orders postion
         ArrayList<Country> countries = Common.getCountries();
         // if there is no object closest agents position will be returned.
         Position closestOrderPosition = new Position(this.position.getX(), this.position.getY() );
         double closestLength = Double.MAX_VALUE;

         for(int i = 0; i < countries.size(); i++){
             Country country = countries.get(i);
             for(int j = 0; j < country.getOrder().size(); j++){
                 double length = getLength(position, country.getOrder().get(j).getPosition());
                 if(length < closestLength){
                     double xCoordinate = country.getOrder().get(j).getPosition().getX();
                     double yCoordinate = country.getOrder().get(j).getPosition().getY();
                     closestOrderPosition.setX(xCoordinate);
                     closestOrderPosition.setY(yCoordinate);
                     closestLength = length;
                 }
             }
         }

         return closestOrderPosition;
    }


}