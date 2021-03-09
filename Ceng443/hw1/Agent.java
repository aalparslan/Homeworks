public abstract class Agent extends Entity {
    // TODO
    //agent size is set from here and used throughout the application.
    private int agentSize = 80;
    private int cash;



    public Agent(double x, double y) {
        super(x, y);
        // initially agent has no cash
        this.cash = 0;
    }

    //getter methods for private attributes.
    public int getAgentSize() {
        return agentSize;
    }


    public void updateAgent(int amount){
        // amount of cash agent has can be updated by goldPrice and amount of gold that is acquired.
        this.cash += (int ) (Common.getGoldPrice().getCurrentPrice() * amount);
    }

    public int getCash() {
        return cash;
    }
}