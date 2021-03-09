public abstract class OrderFactory {
    // TODO
    public static Order buildOrder(Position position, String name)
    { //Order type is randomized so that countries do not know what type of order they are creating.


        return Common.getRandomGenerator().nextBoolean() ?
                 SellOrderFactory.createOrder(position, name):
                 BuyOrderFactory.createOrder(position, name);
    }
}