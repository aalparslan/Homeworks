import java.awt.*;

public class Novice extends AgentDecorator {
    // TODO


    public Novice(Agent agent, Graphics2D g2d) {
        super(agent, Color.WHITE);
        // call Novice draw method to draw its white badge.

        draw(g2d);

    }



    @Override
    public void draw(Graphics2D g2d) {
        // draws a white badge by specified points

        g2d.setPaint(this.getColor());
        g2d.fillRect(this.getPosition().getIntX()+10,this.getPosition().getIntY()-40,10,10);


    }

    @Override
    public void step() {

    }
}