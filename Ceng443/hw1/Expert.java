import java.awt.*;

public class Expert extends AgentDecorator {
    // TODO

    public Expert(Agent agent, Graphics2D g2d) {
        super(agent, Color.RED);
        // call experts draw method to draw its red badge.
        draw(g2d);

    }

    @Override
    public void draw(Graphics2D g2d) {
        // draws a red badge by specified points
        g2d.setPaint(this.getColor());
        g2d.fillRect(this.getPosition().getIntX()+34,this.getPosition().getIntY()-40,10,10);

    }

    @Override
    public void step() {

    }
}