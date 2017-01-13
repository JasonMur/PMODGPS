import smbus

def i2cWrite(busNr, devAddr, regAddr, values):
    bus = smbus.SMBus(busNr)
    bus.write_i2c_block_data(devAddr, regAddr, values)
    print("Writing ", format(int(values[0]), '#04X'), format(int(values[1]), '#04X'))

def i2cRead(busNr, devAddr, regAddr, numBytes):
    bus = smbus.SMBus(busNr)
    values = bus.read_i2c_block_data(devAddr, regAddr, numBytes)
    #for i in range(0,16):
    	#print("Read ", format(int(values[i]), '#04X'))
	#print(str(unichr(values[i])))
    return values

for o in range(0,100):
    values = i2cRead(1, 0x62, 0, 16)
    a = ''.join(chr(i) for i in values)
    print a




