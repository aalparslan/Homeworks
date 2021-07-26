all: monster world
	rm *.o

monster: monster.o
	g++  monster.o -o monster

monster.o: monster.cpp logging.c logging.h message.h
	g++ -c monster.cpp

world: world.o
	g++ world.o -o world

world.o: world.cpp logging.c logging.h message.h
	g++ -c world.cpp

clean:
	rm *.o monster world
