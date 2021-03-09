import java.awt.*;

public class SellOrder extends Order {
    // TODO
    //orders have a specific color. Buy order's color is pink.
    private Color color;


    public SellOrder(double x, double y, String initials) {
        super(x, y, initials, "SELL");
        this.color = Color.PINK;
    }

    @Override
    public void draw(Graphics2D g2d) {

        this.Move(); //sell order's position is changed by calling this method.
        // order is drawn by creating an filled green circle.
        g2d.setPaint(color);
        g2d.fillOval(this.position.getIntX(),this.position.getIntY(),15,15);

        //initials of the country is used to indicate an order
        g2d.setColor(color);
        g2d.drawString(this.getInitials(), position.getIntX() ,
                position.getIntY() -5);

        // value of the order is placed in the circle.
        g2d.setColor(Color.BLACK);
        g2d.drawString(String.valueOf(this.getAmount()), position.getIntX()+2,
                position.getIntY()+13);
    }
    // no need for step here.
    @Override
    public void step() {

    }
}