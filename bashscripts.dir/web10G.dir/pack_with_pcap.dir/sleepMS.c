#include <stdio.h>
#include <stdlib.h>

void sleepMs(int);

int main(int argc, char *argv []){
        int t;
        t=atoi(argv[1]);
        sleepMs(t);
        return 0;
}

void sleepMs(int ms) {
usleep(ms*1000); //convert to microseconds
return;
}

