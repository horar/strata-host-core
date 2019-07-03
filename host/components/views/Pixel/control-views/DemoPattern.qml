import QtQuick 2.0

Item {
    id: demopattern

    function demo_star1(led_state){

        if (led_state === 1){
            sgStatusLight11.status = "green"
        } else if (led_state === 2) {
            sgStatusLight11.status = "off"
            sgStatusLight12.status = "green"
        } else if (led_state === 3) {
            sgStatusLight12.status = "off"
            sgStatusLight13.status = "green"
        } else if (led_state === 4) {
            sgStatusLight13.status = "off"
            sgStatusLight14.status = "green"
        } else if (led_state === 5) {
            sgStatusLight14.status = "off"
            sgStatusLight15.status = "green"
        } else if (led_state === 6) {
            sgStatusLight15.status = "off"
            sgStatusLight16.status = "green"
        } else if (led_state === 7) {
            sgStatusLight16.status = "off"
            sgStatusLight17.status = "green"
        } else if (led_state === 8) {
            sgStatusLight17.status = "off"
            sgStatusLight18.status = "green"
        } else if (led_state === 9) {
            sgStatusLight18.status = "off"
            sgStatusLight19.status = "green"
        } else if (led_state === 10) {
            sgStatusLight19.status = "off"
            sgStatusLight1A.status = "green"
        } else if (led_state === 11) {
            sgStatusLight1A.status = "off"
            sgStatusLight1B.status = "green"
        } else if (led_state === 12) {
            sgStatusLight1B.status = "off"
            sgStatusLight1C.status = "green"
        }

        else {
            sgStatusLight1C.status = "off"

        }

    }
}
