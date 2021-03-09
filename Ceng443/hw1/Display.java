import javax.swing.*;
import java.awt.*;
import java.util.ArrayList;

public class Display extends JPanel {

    public Display()
    {
        this.setBackground(new Color(180, 180, 180));
    }

    @Override
    public Dimension getPreferredSize() { return super.getPreferredSize(); }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        //this method is called constantly.
        // gold price is drawn above the upperYLine.
        Common.getGoldPrice().draw((Graphics2D) g);
        g.drawLine(0, Common.getUpperLineY(), Common.getWindowWidth(), Common.getUpperLineY());

        // TODO
        //get all the countries created
        ArrayList<Country> countries = Common.getCountries();
        // loop through countries to draw them and their agents and orders.
        for(int i =0; i <countries.size(); i++ ){
            countries.get(i).draw((Graphics2D) g);
            countries.get(i).getIntelligenceAgent().draw((Graphics2D) g);

            for(int j=0; j < countries.get(i).getOrder().size(); j++){
                countries.get(i).getOrder().get(j).draw((Graphics2D) g);
            }

        }


    }



}