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
    "payload":{
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

function setPort(port)
{
    gpio_direction.payload.port = port;
    gpio_output.payload.port = port;
    gpio_read.payload.port = port;
}

function setBit(bit)
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

/*
  For testing
*/
function printCommand()
{
    console.log(JSON.stringify(gpio_direction));
    console.log(JSON.stringify(gpio_output));
    console.log(JSON.stringify(gpio_read));
}

function getDirectionCommand()
{
    return JSON.stringify(gpio_direction);
}

function getOutputCommand()
{
    return JSON.stringify(gpio_output);
}

