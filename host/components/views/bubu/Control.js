.pragma library


/*
  GPIO direction
 */
var gpio_direction = {
    "cmd" : "digital_pin_direction",
    "payload": {
        "port": "",
        "bit" : "",
        "direction": "",
    }
}

/*
    GPIO output
*/
var gpio_output = {
    "cmd":"digital_set_output",
    "payload": {
        "port": "",
        "bit": "",
        "output_value": "",  // high or low
    }
}
/*
    GPIO read
*/
var gpio_read = {
    "cmd": "digital_pin_read",
    "payload": {
        "port": "",
        "bit": "",
    }
}
/*
   PWM Frequency and Duty cycle
*/
var pwm_frequency_duty_cycle =  {
    "cmd" : "set_pwm",
    "payload": {
        "port": "",
        "bit": "",
        "frequency": "", //in Hz
        "duty_cycle": "" //in percentage
    }
}

/*
  I2C Configure
*/
var i2c_configure = {
    "cmd" : "i2c_configure",
    "payload" : {
        "bus_number" : "",
        "i2c_frequency_set" :  "",
    }
}

/*
  I2C Write
 */
var i2c_write = {
    "cmd" : "i2c_write",
    "payload" : {
        "bus_number" : "",
        "slave_address" :  "",
        "register_address": "",
        "write_data": "",
    }
}

/*
  I2C Read
*/
var i2c_read = {
    "cmd" : "i2c_read",
    "payload" : {
        "bus_number" : " ",
        "slave_address" : " ",
        "register_address" : " ",
        "read_format" : "extended",

    }
}



function setI2cBusNumber(bus_number)
{
    i2c_configure.payload.bus_number = bus_number
    i2c_write.payload.bus_number = bus_number
    i2c_read.payload.bus_number = bus_number
}

function setI2cSlaveAddressRead(slave_address)
{

    i2c_read.payload.slave_address = slave_address
}

function setI2cSlaveAddressWrite(slave_address)
{
    i2c_write.payload.slave_address = slave_address

}

function setI2cRegisterAddressWrite(register_address)
{
    i2c_write.payload.register_address = register_address

}

function setI2cRegisterAddressRead(register_address)
{
    i2c_read.payload.register_address = register_address

}

function setI2cData(data)
{
    i2c_write.payload.write_data = data
}

function setI2cBusSpeed(bus_speed)
{
    i2c_configure.payload.bus_speed = bus_speed
}

function setRead_format(read_format)
{
    i2c_configure.payload.read_format = read_format
}

function setGpioPort(port)
{
    gpio_direction.payload.port = port;
    gpio_output.payload.port = port;
    gpio_read.payload.port = port;
}

function setGpioBit(bit)
{
    gpio_direction.payload.bit = bit;
    gpio_output.payload.bit = bit;
    gpio_read.payload.bit = bit;
}

function setDirection(direction)
{
    gpio_direction.payload.direction = direction;
}

function setOutputValue(output_value)
{
    gpio_output.payload.output_value = output_value;
}

function setPwmPort(port)
{
    pwm_frequency_duty_cycle.payload.port = port;
}

function setPwmBit(bit)
{
    pwm_frequency_duty_cycle.payload.bit = bit;
}

function setPwmFrequency(frequency)
{
    pwm_frequency_duty_cycle.payload.frequency = frequency;
}

function setDutyCycle(duty_cycle)
{
    pwm_frequency_duty_cycle.payload.duty_cycle = duty_cycle;
}


function getDirectionCommand()
{
    return JSON.stringify(gpio_direction);
}

function getOutputCommand()
{
    return JSON.stringify(gpio_output);
}

function getPwmCommand()
{
    return JSON.stringify(pwm_frequency_duty_cycle);
}

function getI2cConfigure()
{
    return JSON.stringify(i2c_configure);
}

function getI2cWrite()
{
    return JSON.stringify(i2c_write);
}

function getI2cRead()
{
    return JSON.stringify(i2c_read);
}
