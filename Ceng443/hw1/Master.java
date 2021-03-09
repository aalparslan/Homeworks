import java.awt.*;

public class Master extends AgentDecorator {
    // TODO



    public Master(Agent agent, Graphics2D g2d) {
        super(agent, Color.YELLOW);
        // call Master draw method to draw its yellow badge.
        draw(g2d);

    }


    @Override
    public void draw(Graphics2D g2d) {
        // draws a yellow badge by specified points
        g2d.setPaint(this.getColor());
        g2d.fillRect(this.getPosition().getIntX()+22,this.getPosition().getIntY()-40,10,10);

    }

    @Override
    public void step() {

    }


}