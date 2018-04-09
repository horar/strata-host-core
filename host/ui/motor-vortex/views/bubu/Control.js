.pragma library

/*
  GPIO direction command
 */
var  gpio_direction = {
    "cmd" : "digital_pin_direction",
    "payload": {
        "port": "",
        "bit" : "",
        "direction": "",

    }

}

function setPort(port)
{
    gpio_direction.payload.port = port;
}

function setBit(bit)
{
    gpio_direction.payload.bit = bit;
}

function setDirection(direction)
{
    gpio_direction.payload.direction= direction;
}
/*
  For testing
*/
function printCommand()
{
    console.log(JSON.stringify(gpio_direction));
}


