import java.awt.*;

public abstract class AgentDecorator extends Agent {
    // TODO
    // shared attributes of subclasses hold here.
    private Agent decoratedAgent;
    private Color color;


    public AgentDecorator(Agent agent, Color color) {

        super(agent.getPosition().getX(), agent.position.getY());
        this.color = color;
        //  agent is decorated by the decorator pattern agent and hold in this class.
        decoratedAgent = agent;
    }


    // getter methods.
    public Color getColor() {
        return color;
    }

    public Agent getDecoratedAgent(){
        return decoratedAgent;
    }





}