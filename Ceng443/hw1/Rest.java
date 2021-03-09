public class Rest extends State {
    // TODO


    public Rest(Position position) {
        // give required parameters to initiate the super class.
        super("Rest", position);
        this.position = new Position(position.getX(),position.getY());
    }

    @Override
    public Position Move() {
        // no need to change the position,
        return position;
    }
}