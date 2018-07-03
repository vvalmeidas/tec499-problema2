import serial
import time

f = open("crc.dat", "r");
file = f.readlines();

ser = serial.Serial('COM5');

for line in file:
    b1 = line[2:4];
    b2 = line[4:6];
    b3 = line[6:8];
    b4 = line[8:10];
    b1 = '0x'+b1;
    b2 = '0x'+b2;
    b3 = '0x'+b3;
    b4 = '0x'+b4;
    b1 = int(b1, 16);
    b2 = int(b2, 16);
    b3 = int(b3, 16);
    b4 = int(b4, 16);
    b1 = bytes([b1]);
    b2 = bytes([b2]);
    b3 = bytes([b3]);
    b4 = bytes([b4]);
    print(b1)
    print(b2)
    print(b3)
    print(b4)
    print("#")
    ser.write(b1);
    time.sleep(0.5);
    ser.write(b2);
    time.sleep(0.5);
    ser.write(b3);
    time.sleep(0.5);
    ser.write(b4);
    time.sleep(0.5);
ser.close();