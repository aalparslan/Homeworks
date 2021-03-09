public class Shake extends State {
    // TODO

    private  double newXCoord;
    private  double newYCoord;
    // shake at most 10 pixel away.
    private  double maxChange = 10;


    public Shake(Position position) {
        super("Shake", position);
        this.position = new Position(position.getX(),position.getY());

    }

    @Override
    public Position Move() {
            // random displacement is add on always the same position therefore
            // agents does the shake around a certain point which is the point
            // where the agent pass to the shake state firstly
            newXCoord = this.position.getX() + randomDisplacement();
            newYCoord = this.position.getY() + randomDisplacement();
            Position newPosition = new Position(newXCoord, newYCoord);

            return  newPosition;
    }

    private double randomDisplacement(){
        if (Common.getRandomGenerator().nextInt(10) == 0){
            double change = Common.getRandomGenerator().nextDouble() * maxChange;
            change = Common.getRandomGenerator().nextBoolean() ?   change : - change;
            return  change;
        }
        return  0;

    }



}