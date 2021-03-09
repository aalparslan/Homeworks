package project.utility;

import project.parts.Arm;
import project.parts.Base;
import project.parts.Part;
import project.parts.logics.Builder;
import project.parts.logics.Fixer;
import project.parts.logics.Inspector;
import project.parts.logics.Supplier;
import project.parts.payloads.Camera;
import project.parts.payloads.Gripper;
import project.parts.payloads.MaintenanceKit;
import project.parts.payloads.Welder;

import java.lang.reflect.Field;
import java.util.Random;

public class Common
{
    public static Random random = new Random() ;

    public static synchronized Object get (Object object , String fieldName )
    {

        // This function retrieves (gets) the private field of an object by using reflection
        // In case the function needs to throw an exception, throw this: SmartFactoryException( "Failed: get!" )
        try{
            // refletion usage
            Class cls = object.getClass();
            Field field = cls.getDeclaredField(fieldName);
            field.setAccessible(true);
            return   field.get(object);

        }catch (NoSuchFieldException e){
            throw  new SmartFactoryException( "Failed: get!" );
        }catch (IllegalAccessException e){
            throw  new SmartFactoryException( "Failed: get!" );
        }

    }

    public static synchronized void set ( Object object , String fieldName , Object value )
    {

        // This function modifies (sets) the private field of an object by using reflection
        // In case the function needs to throw an exception, throw this: SmartFactoryException( "Failed: set!" )
        try {
            Class cls = object.getClass();
            Field field = cls.getDeclaredField(fieldName);
            field.setAccessible(true);
            field.set(object,value);
        }catch (NoSuchFieldException e){
            throw  new SmartFactoryException( "Failed: set!" );
        }catch (IllegalAccessException e){
            throw  new SmartFactoryException( "Failed: set!" );
        }

    }

    public static synchronized Base creator1(int nextSerialNo){
        return new Base(nextSerialNo);
    }

    public static synchronized Part creator2(String name){
        // This function returns a robot part by applying factory and abstract factory patterns
        // In case the function needs to throw an exception, throw this: SmartFactoryException( "Failed: createPart!" )

        Part part = null;
        if(name.equals("Arm") ){
            part = new Arm();
        }else if(name.equals("Camera")){
            part = new Camera();
        }else if(name.equals("Gripper")){
            part = new Gripper();
        }else if(name.equals("MaintenanceKit")){
            part = new MaintenanceKit();
        }else  if(name.equals("Welder")){
            part = new Welder();
        }else if(name.equals("Builder")){
            part = new Builder();
        }else if(name.equals("Fixer")){
            part = new Fixer();
        }else if(name.equals("Inspector")){
            part = new Inspector();
        }else if(name.equals("Supplier")){
            part = new Supplier();
        }

        if( part == null){
            throw new SmartFactoryException( "Failed: createPart!" );
        }


        return part;
    }



}