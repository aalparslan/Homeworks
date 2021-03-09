package project.parts.logics;

import project.SimulationRunner;
import project.components.Factory;
import project.components.Robot;
import project.parts.Part;
import project.utility.Common;

public class Supplier extends Logic
{
    @Override public void run ( Robot robot )
    {
        // TODO
        // Following messages are appropriate for this class
        // System.out.printf( "Robot %02d : Supplying a random part on production line.%n", ...);
        // System.out.printf( "Robot %02d : Production line is full, removing a random part from production line.%n", ...);
        // System.out.printf( "Robot %02d : Waking up waiting builders.%n", ...);

        //cant sync the whole productionLine class therefore sync only the ones that are used ( parts)
        synchronized (SimulationRunner.factory.productionLine.parts){

            int itemCountInProductionLine = SimulationRunner.factory.productionLine.parts.size();
            int productionLineCapacity = SimulationRunner.factory.productionLine.maxCapacity;
            if(itemCountInProductionLine < productionLineCapacity){
                // means production line is not full
                System.out.printf( "Robot %02d : Supplying a random part on production line.%n",
                        Common.get(robot,"serialNo") );

                Part randomPart;
                String[] partsArr = {"Builder","Fixer","Inspector","Supplier","Arm","Camera","Gripper",
                        "MaintenanceKit", "Welder"};
                int randomIndex = Common.random.nextInt( 10 );

                if(randomIndex == 9){
                    randomPart = Factory.createBase();
                }else{
                    randomPart = Factory.createPart(partsArr[randomIndex]);
                }

                SimulationRunner.factory.productionLine.parts.add(randomPart);


            }else{
                // means production line is full
                System.out.printf( "Robot %02d : Production line is full, removing a random part from production line.%n",
                        Common.get(robot,"serialNo") );
                int randomIndex = Common.random.nextInt( SimulationRunner.factory.productionLine.parts.size());
                SimulationRunner.factory.productionLine.parts.remove(randomIndex);
            }

            // access to robotDsiplay using sync
            synchronized (SimulationRunner.robotsDisplay){
                SimulationRunner.robotsDisplay.repaint();
            }

            // access to productionLineDisplay using sync
            synchronized (SimulationRunner.productionLineDisplay){
                SimulationRunner.productionLineDisplay.repaint();
            }
            // access to storageDisplay using sync
            synchronized (SimulationRunner.storageDisplay){
                SimulationRunner.storageDisplay.repaint();

            }

            SimulationRunner.factory.productionLine.parts.notifyAll();
        }

    }
}