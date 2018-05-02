.pragma library

/*
  GPIO direction command
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
GPIO Set Output
*/
var gpio_output = {
    "cmd":"digital_set_output",
    "payload": {
        "port": "",
        "bit": "",
        "output_value": "",  // high or low
    }
}

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
    gpio_direction.payload.direction= direction;
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

/*
  For testing
*/
function printGpioCommand()
{
    console.log(JSON.stringify(gpio_direction));
    console.log(JSON.stringify(gpio_output));
    console.log(JSON.stringify(gpio_read));
}
/*
  For testing
*/
function printPwmCommand()
{
    console.log(JSON.stringify(pwm_frequency_duty_cycle));

}

function getDirectionCommand()
{
    return JSON.stringify(gpio_direction);
}

function getOutputCommand()
{
    return JSON.stringify(gpio_output);
}

