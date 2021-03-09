import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class BasicAgent extends Agent {
    // TODO


    private  String name;
    private State state;
    private BufferedImage image; //buffered image method used
    private Font font = new Font("Verdana", Font.BOLD, 15);


    public BasicAgent(double x, double y, String imagePath, String name) {
        super(x, y);
        // Initiate agent's by getting their image
        getAgentImage(imagePath);
        this.name = name;
        // when the class initiated by calling buildState method initiate its state.
        state = State.buildState(this.position);

        // resize the image by agentSize given in the super class
        try {
            image = resizeImage(image,this.getAgentSize(),this.getAgentSize());
        } catch (IOException ex) {
            System.out.println("Error: resizing image of the agent");

        }

    }

    @Override
    public void draw(Graphics2D g2d) {
        // To move the agent call Move method of the state whichever the BasicAgent in.
        Position agentNewPosition  = state.Move();
        // Since draw method is called all the time we need to set the new calculated
        // position as agent's position
        this.position.setX(agentNewPosition.getX());
        this.position.setY( agentNewPosition.getY());

        // use Graphics2D methods to draw agents image constantly. Their coordinates
        // change to create an animated effect
        g2d.drawImage(image, position.getIntX(), position.getIntY(), null);
        // draw agent's name above its image. Set color and font.
        g2d.setColor(Color.BLACK);
        g2d.setFont(font);
        g2d.drawString(String.format(name), position.getIntX()+10 , position.getIntY() - 10);

        // draw agent's state's name below the image
        g2d.setColor(Color.BLUE);
        g2d.drawString(state.getName(), position.getIntX()+10,
                position.getIntY() + 90);

        // draw stolen total cash
        g2d.setColor(Color.RED);
        g2d.drawString(String.format( Integer.toString(this.getCash()) ), position.getIntX() + 10,
                position.getIntY() + 105);

    }

    @Override
    public void step() {
        // get a new state. Step is called all the time
         changeState();

    }



    //Read the image by buffered image method. Print an error message if image cannot be read.
    // image and src file must be at the same level to load an image successfully.
    private  void getAgentImage(String imagePath){
        try {
            this.image = ImageIO.read(new File(imagePath));
        } catch (IOException ex) {
            System.out.println("Error: loading image of the agent");
        }
    }

    // method to resize an image by specified sizes.
    private BufferedImage resizeImage(BufferedImage originalImage, int targetWidth, int targetHeight) throws IOException {
        BufferedImage resizedImage = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_ARGB);
        Graphics2D graphics2D = resizedImage.createGraphics();
        graphics2D.drawImage(originalImage, 0, 0, targetWidth, targetHeight, null);
        graphics2D.dispose();
        return resizedImage;
    }


    private void changeState(){
        state = State.buildState(this.position);
    }


}