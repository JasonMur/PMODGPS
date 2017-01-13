import smbus

def i2cWrite(busNr, devAddr, regAddr, values):
    bus = smbus.SMBus(busNr)
    bus.write_i2c_block_data(devAddr, regAddr, values)
    print("Writing ", format(int(values[0]), '#04X'), format(int(values[1]), '#04X'))

def i2cRead(busNr, devAddr, regAddr, numBytes):
    bus = smbus.SMBus(busNr)
    values = bus.read_i2c_block_data(devAddr, regAddr, numBytes)
    return values

value = 0
values = [0]
while True:
    value = i2cRead(1,0x62,0,1)
    if value == [36]:
	a = ''.join(chr(i) for i in values)
	print a
	values = []
    else:
	values.append(value[0])
   




