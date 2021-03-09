public class BuyOrderFactory extends OrderFactory {
    // TODO

    // BUYOrderFactory separates orders by their initials. all the combinations of
    // buy orders can be created at one step.
    static Order createOrder(Position position, String name){

        Order order = null;

        if(name.equals("USA")){
            order  =  new BuyOrder(position.getX(), position.getY(), "US");

        }else if(name.equals("Israel")){
            order  =  new BuyOrder(position.getX(), position.getY(), "IL");

        }else if(name.equals("Turkey")){
            order  =  new BuyOrder(position.getX(), position.getY(), "TR");

        }else if(name.equals("Russia")){
            order  =  new BuyOrder(position.getX(), position.getY(), "RU");

        }else if(name.equals("China")){
            order  =  new BuyOrder(position.getX(), position.getY(), "CN");
        }





        return order;
    }

}