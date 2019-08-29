import QtQuick 2.0

Item {
    property string led_on_color: "green"

    function demo_bhall1(led_state){

        if (led_state === 0){
            led_all_on()

        }else if (led_state === 1){
            platformInterface.demo_led11_color = "off"

        } else if (led_state === 2) {
            platformInterface.demo_led11_color = led_on_color
            platformInterface.demo_led12_color = "off"
            platformInterface.demo_led21_color = "off"

        } else if (led_state === 3) {
            platformInterface.demo_led12_color = led_on_color
            platformInterface.demo_led13_color = "off"
            platformInterface.demo_led21_color = led_on_color
            platformInterface.demo_led22_color = "off"
            platformInterface.demo_led31_color = "off"

        } else if (led_state === 4) {
            platformInterface.demo_led13_color = led_on_color
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led22_color = led_on_color
            platformInterface.demo_led23_color = "off"
            platformInterface.demo_led31_color = led_on_color
            platformInterface.demo_led32_color = "off"

        } else if (led_state === 5) {
            platformInterface.demo_led14_color = led_on_color
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led23_color = led_on_color
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led32_color = led_on_color
            platformInterface.demo_led33_color = "off"

        } else if (led_state === 6) {
            platformInterface.demo_led15_color = led_on_color
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led24_color = led_on_color
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led33_color = led_on_color
            platformInterface.demo_led34_color = "off"

        } else if (led_state === 7) {
            platformInterface.demo_led16_color = led_on_color
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led25_color = led_on_color
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led34_color = led_on_color
            platformInterface.demo_led35_color = "off"

        } else if (led_state === 8) {
            platformInterface.demo_led17_color = led_on_color
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led26_color = led_on_color
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led35_color = led_on_color
            platformInterface.demo_led36_color = "off"

        } else if (led_state === 9) {
            platformInterface.demo_led18_color = led_on_color
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led27_color = led_on_color
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led36_color = led_on_color
            platformInterface.demo_led37_color = "off"

        } else if (led_state === 10) {
            platformInterface.demo_led19_color = led_on_color
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led28_color = led_on_color
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led37_color = led_on_color
            platformInterface.demo_led38_color = "off"

        } else if (led_state === 11) {
            platformInterface.demo_led1A_color = led_on_color
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led29_color = led_on_color
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led38_color = led_on_color
            platformInterface.demo_led39_color = "off"

        } else if (led_state === 12) {
            platformInterface.demo_led1B_color = led_on_color
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led2A_color = led_on_color
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led39_color = led_on_color
            platformInterface.demo_led3A_color = "off"

        } else if (led_state === 13) {
            platformInterface.demo_led1C_color = led_on_color
            platformInterface.demo_led2B_color = led_on_color
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led3A_color = led_on_color
            platformInterface.demo_led3B_color = "off"

        } else if (led_state === 14) {
            platformInterface.demo_led2C_color = led_on_color
            platformInterface.demo_led3B_color = led_on_color
            platformInterface.demo_led3C_color = "off"

        }
    }

    function demo_bhall2(led_color){

        if (led_state === 0){
            led_all_on()

        }else if (led_state === 1){
            platformInterface.demo_led11_color = "off"

        } else if (led_state === 2) {
            platformInterface.demo_led11_color = "off"
            platformInterface.demo_led12_color = "off"

        } else if (led_state === 3) {
            platformInterface.demo_led11_color = led_on_color
            platformInterface.demo_led12_color = "off"
            platformInterface.demo_led13_color = "off"
            platformInterface.demo_led21_color = "off"

        } else if (led_state === 4) {
            platformInterface.demo_led12_color = led_on_color
            platformInterface.demo_led13_color = "off"
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led21_color = "off"
            platformInterface.demo_led22_color = "off"

        } else if (led_state === 5) {
            platformInterface.demo_led13_color = led_on_color
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led21_color = led_on_color
            platformInterface.demo_led22_color = "off"
            platformInterface.demo_led23_color = "off"
            platformInterface.demo_led31_color = "off"

        } else if (led_state === 6) {
            platformInterface.demo_led14_color = led_on_color
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led22_color = led_on_color
            platformInterface.demo_led23_color = "off"
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led31_color = "off"
            platformInterface.demo_led32_color = "off"

        } else if (led_state === 7) {
            platformInterface.demo_led15_color = led_on_color
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led23_color = led_on_color
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led31_color = led_on_color
            platformInterface.demo_led32_color = "off"
            platformInterface.demo_led33_color = "off"

        } else if (led_state === 8) {
            platformInterface.demo_led16_color = led_on_color
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led24_color = led_on_color
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led32_color = led_on_color
            platformInterface.demo_led33_color = "off"
            platformInterface.demo_led34_color = "off"

        } else if (led_state === 9) {
            platformInterface.demo_led17_color = led_on_color
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led25_color = led_on_color
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led33_color = led_on_color
            platformInterface.demo_led34_color = "off"
            platformInterface.demo_led35_color = "off"

        } else if (led_state === 10) {
            platformInterface.demo_led18_color = led_on_color
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led26_color = led_on_color
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led34_color = led_on_color
            platformInterface.demo_led35_color = "off"
            platformInterface.demo_led36_color = "off"

        } else if (led_state === 11) {
            platformInterface.demo_led19_color = led_on_color
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led27_color = led_on_color
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led35_color = led_on_color
            platformInterface.demo_led36_color = "off"
            platformInterface.demo_led37_color = "off"

        } else if (led_state === 12) {
            platformInterface.demo_led1A_color = led_on_color
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led28_color = led_on_color
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led36_color = led_on_color
            platformInterface.demo_led37_color = "off"
            platformInterface.demo_led38_color = "off"

        } else if (led_state === 13) {
            platformInterface.demo_led1B_color = led_on_color
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led29_color = led_on_color
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led37_color = led_on_color
            platformInterface.demo_led38_color = "off"
            platformInterface.demo_led39_color = "off"

        } else if (led_state === 14) {
            platformInterface.demo_led1C_color = led_on_color
            platformInterface.demo_led2A_color = led_on_color
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led38_color = led_on_color
            platformInterface.demo_led39_color = "off"
            platformInterface.demo_led3A_color = "off"

        } else if (led_state === 15) {
            platformInterface.demo_led2B_color = led_on_color
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led39_color = led_on_color
            platformInterface.demo_led3A_color = "off"
            platformInterface.demo_led3B_color = "off"

        } else if (led_state === 16) {
            platformInterface.demo_led2C_color = led_on_color
            platformInterface.demo_led3A_color = led_on_color
            platformInterface.demo_led3B_color = "off"
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 17) {
            platformInterface.demo_led3B_color = led_on_color
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 18) {
            platformInterface.demo_led3C_color = led_on_color
        }
    }

    function demo_bhall3(led_color){

        if (led_state === 0){
            led_all_on()

        }else if (led_state === 1){
            platformInterface.demo_led11_color = "off"

        } else if (led_state === 2) {
            platformInterface.demo_led11_color = "off"
            platformInterface.demo_led12_color = "off"

        } else if (led_state === 3) {
            platformInterface.demo_led11_color = "off"
            platformInterface.demo_led12_color = "off"
            platformInterface.demo_led13_color = "off"

        } else if (led_state === 4) {
            platformInterface.demo_led11_color = led_on_color
            platformInterface.demo_led12_color = "off"
            platformInterface.demo_led13_color = "off"
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led21_color = "off"

        } else if (led_state === 5) {
            platformInterface.demo_led12_color = led_on_color
            platformInterface.demo_led13_color = "off"
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led21_color = "off"
            platformInterface.demo_led22_color = "off"

        } else if (led_state === 6) {
            platformInterface.demo_led13_color = led_on_color
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led21_color = "off"
            platformInterface.demo_led22_color = "off"
            platformInterface.demo_led23_color = "off"

        } else if (led_state === 7) {
            platformInterface.demo_led14_color = led_on_color
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led21_color = led_on_color
            platformInterface.demo_led22_color = "off"
            platformInterface.demo_led23_color = "off"
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led31_color = "off"

        } else if (led_state === 8) {
            platformInterface.demo_led15_color = led_on_color
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led22_color = led_on_color
            platformInterface.demo_led23_color = "off"
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led31_color = "off"
            platformInterface.demo_led32_color = "off"

        } else if (led_state === 9) {
            platformInterface.demo_led16_color = led_on_color
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led23_color = led_on_color
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led31_color = "off"
            platformInterface.demo_led32_color = "off"
            platformInterface.demo_led33_color = "off"

        } else if (led_state === 10) {
            platformInterface.demo_led17_color = led_on_color
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led24_color = led_on_color
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led31_color = led_on_color
            platformInterface.demo_led32_color = "off"
            platformInterface.demo_led33_color = "off"
            platformInterface.demo_led34_color = "off"

        } else if (led_state === 11) {
            platformInterface.demo_led18_color = led_on_color
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led25_color = led_on_color
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led32_color = led_on_color
            platformInterface.demo_led33_color = "off"
            platformInterface.demo_led34_color = "off"
            platformInterface.demo_led35_color = "off"

        } else if (led_state === 12) {
            platformInterface.demo_led19_color = led_on_color
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led26_color = led_on_color
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led33_color = led_on_color
            platformInterface.demo_led34_color = "off"
            platformInterface.demo_led35_color = "off"
            platformInterface.demo_led36_color = "off"

        } else if (led_state === 13) {
            platformInterface.demo_led1A_color = led_on_color
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led27_color = led_on_color
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led34_color = led_on_color
            platformInterface.demo_led35_color = "off"
            platformInterface.demo_led36_color = "off"
            platformInterface.demo_led37_color = "off"

        } else if (led_state === 14) {
            platformInterface.demo_led1B_color = led_on_color
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led28_color = led_on_color
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led35_color = led_on_color
            platformInterface.demo_led36_color = "off"
            platformInterface.demo_led37_color = "off"
            platformInterface.demo_led38_color = "off"

        } else if (led_state === 15) {
            platformInterface.demo_led1C_color = led_on_color
            platformInterface.demo_led29_color = led_on_color
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led36_color = led_on_color
            platformInterface.demo_led37_color = "off"
            platformInterface.demo_led38_color = "off"
            platformInterface.demo_led39_color = "off"

        } else if (led_state === 16) {
            platformInterface.demo_led2A_color = led_on_color
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led37_color = led_on_color
            platformInterface.demo_led38_color = "off"
            platformInterface.demo_led39_color = "off"
            platformInterface.demo_led3A_color = "off"

        } else if (led_state === 17) {
            platformInterface.demo_led2B_color = led_on_color
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led38_color = led_on_color
            platformInterface.demo_led39_color = "off"
            platformInterface.demo_led3A_color = "off"
            platformInterface.demo_led3B_color = "off"

        } else if (led_state === 18) {
            platformInterface.demo_led2C_color = led_on_color
            platformInterface.demo_led39_color = led_on_color
            platformInterface.demo_led3A_color = "off"
            platformInterface.demo_led3B_color = "off"
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 19) {
            platformInterface.demo_led3A_color = led_on_color
            platformInterface.demo_led3B_color = "off"
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 20) {
            platformInterface.demo_led3B_color = led_on_color
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 21) {
            platformInterface.demo_led3C_color = led_on_color

        }

    }

    function demo_bhall4(led_color){

        if (led_state === 0){
            led_all_on()

        }else if (led_state === 1){
            platformInterface.demo_led11_color = "off"

        } else if (led_state === 2) {
            platformInterface.demo_led11_color = "off"
            platformInterface.demo_led12_color = "off"

        } else if (led_state === 3) {
            platformInterface.demo_led11_color = "off"
            platformInterface.demo_led12_color = "off"
            platformInterface.demo_led13_color = "off"

        } else if (led_state === 4) {
            platformInterface.demo_led11_color = "off"
            platformInterface.demo_led12_color = "off"
            platformInterface.demo_led13_color = "off"
            platformInterface.demo_led14_color = "off"

        } else if (led_state === 5) {
            platformInterface.demo_led11_color = led_on_color
            platformInterface.demo_led12_color = "off"
            platformInterface.demo_led13_color = "off"
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led21_color = "off"

        } else if (led_state === 6) {
            platformInterface.demo_led12_color = led_on_color
            platformInterface.demo_led13_color = "off"
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led21_color = "off"
            platformInterface.demo_led22_color = "off"

        } else if (led_state === 7) {
            platformInterface.demo_led13_color = led_on_color
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led21_color = "off"
            platformInterface.demo_led22_color = "off"
            platformInterface.demo_led23_color = "off"

        } else if (led_state === 8) {
            platformInterface.demo_led14_color = led_on_color
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led21_color = "off"
            platformInterface.demo_led22_color = "off"
            platformInterface.demo_led23_color = "off"
            platformInterface.demo_led24_color = "off"

        } else if (led_state === 9) {
            platformInterface.demo_led15_color = led_on_color
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led21_color = led_on_color
            platformInterface.demo_led22_color = "off"
            platformInterface.demo_led23_color = "off"
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led31_color = "off"

        } else if (led_state === 10) {
            platformInterface.demo_led16_color = led_on_color
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led22_color = led_on_color
            platformInterface.demo_led23_color = "off"
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led31_color = "off"
            platformInterface.demo_led32_color = "off"

        } else if (led_state === 11) {
            platformInterface.demo_led17_color = led_on_color
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led23_color = led_on_color
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led31_color = "off"
            platformInterface.demo_led32_color = "off"
            platformInterface.demo_led33_color = "off"

        } else if (led_state === 12) {
            platformInterface.demo_led18_color = led_on_color
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led24_color = led_on_color
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led31_color = "off"
            platformInterface.demo_led32_color = "off"
            platformInterface.demo_led33_color = "off"
            platformInterface.demo_led34_color = "off"

        } else if (led_state === 13) {
            platformInterface.demo_led19_color = led_on_color
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led25_color = led_on_color
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led31_color = led_on_color
            platformInterface.demo_led32_color = "off"
            platformInterface.demo_led33_color = "off"
            platformInterface.demo_led34_color = "off"
            platformInterface.demo_led35_color = "off"

        } else if (led_state === 14) {
            platformInterface.demo_led1A_color = led_on_color
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led26_color = led_on_color
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led32_color = led_on_color
            platformInterface.demo_led33_color = "off"
            platformInterface.demo_led34_color = "off"
            platformInterface.demo_led35_color = "off"
            platformInterface.demo_led36_color = "off"
            platformInterface.demo_led37_color = "off"

        } else if (led_state === 15) {
            platformInterface.demo_led1B_color = led_on_color
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led27_color = led_on_color
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led33_color = led_on_color
            platformInterface.demo_led34_color = "off"
            platformInterface.demo_led35_color = "off"
            platformInterface.demo_led36_color = "off"
            platformInterface.demo_led37_color = "off"
            platformInterface.demo_led38_color = "off"

        } else if (led_state === 16) {
            platformInterface.demo_led1C_color = led_on_color
            platformInterface.demo_led28_color = led_on_color
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led34_color = led_on_color
            platformInterface.demo_led35_color = "off"
            platformInterface.demo_led36_color = "off"
            platformInterface.demo_led37_color = "off"
            platformInterface.demo_led38_color = "off"

        } else if (led_state === 17) {
            platformInterface.demo_led29_color = led_on_color
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led35_color = led_on_color
            platformInterface.demo_led36_color = "off"
            platformInterface.demo_led37_color = "off"
            platformInterface.demo_led38_color = "off"
            platformInterface.demo_led39_color = "off"

        } else if (led_state === 18) {
            platformInterface.demo_led2A_color = led_on_color
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led36_color = led_on_color
            platformInterface.demo_led37_color = "off"
            platformInterface.demo_led38_color = "off"
            platformInterface.demo_led39_color = "off"
            platformInterface.demo_led3A_color = "off"

        } else if (led_state === 19) {
            platformInterface.demo_led2B_color = led_on_color
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led37_color = led_on_color
            platformInterface.demo_led38_color = "off"
            platformInterface.demo_led39_color = "off"
            platformInterface.demo_led3A_color = "off"
            platformInterface.demo_led3B_color = "off"

        } else if (led_state === 20) {
            platformInterface.demo_led2C_color = led_on_color
            platformInterface.demo_led38_color = led_on_color
            platformInterface.demo_led39_color = "off"
            platformInterface.demo_led3A_color = "off"
            platformInterface.demo_led3B_color = "off"
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 21) {
            platformInterface.demo_led39_color = led_on_color
            platformInterface.demo_led3A_color = "off"
            platformInterface.demo_led3B_color = "off"
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 22) {
            platformInterface.demo_led3A_color = led_on_color
            platformInterface.demo_led3B_color = "off"
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 23) {
            platformInterface.demo_led3B_color = led_on_color
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 24) {
            platformInterface.demo_led3C_color = led_on_color

        }
    }

    function demo_bhall5(led_color){

        if (led_state === 0){
            led_all_on()

        }else if (led_state === 1){
            platformInterface.demo_led11_color = "off"

        } else if (led_state === 2) {
            platformInterface.demo_led11_color = "off"
            platformInterface.demo_led12_color = "off"

        } else if (led_state === 3) {
            platformInterface.demo_led11_color = "off"
            platformInterface.demo_led12_color = "off"
            platformInterface.demo_led13_color = "off"

        } else if (led_state === 4) {
            platformInterface.demo_led11_color = "off"
            platformInterface.demo_led12_color = "off"
            platformInterface.demo_led13_color = "off"
            platformInterface.demo_led14_color = "off"

        } else if (led_state === 5) {
            platformInterface.demo_led11_color = "off"
            platformInterface.demo_led12_color = "off"
            platformInterface.demo_led13_color = "off"
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led15_color = "off"

        } else if (led_state === 6) {
            platformInterface.demo_led11_color = led_on_color
            platformInterface.demo_led12_color = "off"
            platformInterface.demo_led13_color = "off"
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led21_color = "off"

        } else if (led_state === 7) {
            platformInterface.demo_led12_color = led_on_color
            platformInterface.demo_led13_color = "off"
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led21_color = "off"
            platformInterface.demo_led22_color = "off"

        } else if (led_state === 8) {
            platformInterface.demo_led13_color = led_on_color
            platformInterface.demo_led14_color = "off"
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led21_color = "off"
            platformInterface.demo_led22_color = "off"
            platformInterface.demo_led23_color = "off"

        } else if (led_state === 9) {
            platformInterface.demo_led14_color = led_on_color
            platformInterface.demo_led15_color = "off"
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led21_color = "off"
            platformInterface.demo_led22_color = "off"
            platformInterface.demo_led23_color = "off"
            platformInterface.demo_led24_color = "off"

        } else if (led_state === 10) {
            platformInterface.demo_led15_color = led_on_color
            platformInterface.demo_led16_color = "off"
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led21_color = "off"
            platformInterface.demo_led22_color = "off"
            platformInterface.demo_led23_color = "off"
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led25_color = "off"

        } else if (led_state === 11) {
            platformInterface.demo_led16_color = led_on_color
            platformInterface.demo_led17_color = "off"
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led21_color = led_on_color
            platformInterface.demo_led22_color = "off"
            platformInterface.demo_led23_color = "off"
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led31_color = "off"

        } else if (led_state === 12) {
            platformInterface.demo_led17_color = led_on_color
            platformInterface.demo_led18_color = "off"
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led22_color = led_on_color
            platformInterface.demo_led23_color = "off"
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led31_color = "off"
            platformInterface.demo_led32_color = "off"

        } else if (led_state === 13) {
            platformInterface.demo_led18_color = led_on_color
            platformInterface.demo_led19_color = "off"
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led23_color = led_on_color
            platformInterface.demo_led24_color = "off"
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led31_color = "off"
            platformInterface.demo_led32_color = "off"
            platformInterface.demo_led33_color = "off"

        } else if (led_state === 14) {
            platformInterface.demo_led19_color = led_on_color
            platformInterface.demo_led1A_color = "off"
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led24_color = led_on_color
            platformInterface.demo_led25_color = "off"
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led31_color = "off"
            platformInterface.demo_led32_color = "off"
            platformInterface.demo_led33_color = "off"
            platformInterface.demo_led34_color = "off"

        } else if (led_state === 15) {
            platformInterface.demo_led1A_color = led_on_color
            platformInterface.demo_led1B_color = "off"
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led25_color = led_on_color
            platformInterface.demo_led26_color = "off"
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led31_color = "off"
            platformInterface.demo_led32_color = "off"
            platformInterface.demo_led33_color = "off"
            platformInterface.demo_led34_color = "off"
            platformInterface.demo_led35_color = "off"

        } else if (led_state === 16) {
            platformInterface.demo_led1B_color = led_on_color
            platformInterface.demo_led1C_color = "off"
            platformInterface.demo_led26_color = led_on_color
            platformInterface.demo_led27_color = "off"
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led31_color = led_on_color
            platformInterface.demo_led32_color = "off"
            platformInterface.demo_led33_color = "off"
            platformInterface.demo_led34_color = "off"
            platformInterface.demo_led35_color = "off"
            platformInterface.demo_led36_color = "off"

        } else if (led_state === 17) {
            platformInterface.demo_led1C_color = led_on_color
            platformInterface.demo_led27_color = led_on_color
            platformInterface.demo_led28_color = "off"
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led32_color = led_on_color
            platformInterface.demo_led33_color = "off"
            platformInterface.demo_led34_color = "off"
            platformInterface.demo_led35_color = "off"
            platformInterface.demo_led36_color = "off"
            platformInterface.demo_led37_color = "off"

        } else if (led_state === 18) {
            platformInterface.demo_led28_color = led_on_color
            platformInterface.demo_led29_color = "off"
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led33_color = led_on_color
            platformInterface.demo_led34_color = "off"
            platformInterface.demo_led35_color = "off"
            platformInterface.demo_led36_color = "off"
            platformInterface.demo_led37_color = "off"
            platformInterface.demo_led38_color = "off"

        } else if (led_state === 19) {
            platformInterface.demo_led29_color = led_on_color
            platformInterface.demo_led2A_color = "off"
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led34_color = led_on_color
            platformInterface.demo_led35_color = "off"
            platformInterface.demo_led36_color = "off"
            platformInterface.demo_led37_color = "off"
            platformInterface.demo_led38_color = "off"
            platformInterface.demo_led39_color = "off"

        } else if (led_state === 20) {
            platformInterface.demo_led2A_color = led_on_color
            platformInterface.demo_led2B_color = "off"
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led35_color = led_on_color
            platformInterface.demo_led36_color = "off"
            platformInterface.demo_led37_color = "off"
            platformInterface.demo_led38_color = "off"
            platformInterface.demo_led39_color = "off"
            platformInterface.demo_led3A_color = "off"

        } else if (led_state === 21) {
            platformInterface.demo_led2B_color = led_on_color
            platformInterface.demo_led2C_color = "off"
            platformInterface.demo_led36_color = led_on_color
            platformInterface.demo_led37_color = "off"
            platformInterface.demo_led38_color = "off"
            platformInterface.demo_led39_color = "off"
            platformInterface.demo_led3A_color = "off"
            platformInterface.demo_led3B_color = "off"

        } else if (led_state === 22) {
            platformInterface.demo_led2C_color = led_on_color
            platformInterface.demo_led37_color = led_on_color
            platformInterface.demo_led38_color = "off"
            platformInterface.demo_led39_color = "off"
            platformInterface.demo_led3A_color = "off"
            platformInterface.demo_led3B_color = "off"
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 23) {
            platformInterface.demo_led38_color = led_on_color
            platformInterface.demo_led39_color = "off"
            platformInterface.demo_led3A_color = "off"
            platformInterface.demo_led3B_color = "off"
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 24) {
            platformInterface.demo_led39_color = led_on_color
            platformInterface.demo_led3A_color = "off"
            platformInterface.demo_led3B_color = "off"
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 25) {
            platformInterface.demo_led3A_color = led_on_color
            platformInterface.demo_led3B_color = "off"
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 26) {
            platformInterface.demo_led3B_color = led_on_color
            platformInterface.demo_led3C_color = "off"

        } else if (led_state === 27) {
            platformInterface.demo_led3C_color = led_on_color

        }

    }

    function led_all_on(){
        platformInterface.demo_led11_color = led_on_color
        platformInterface.demo_led12_color = led_on_color
        platformInterface.demo_led13_color = led_on_color
        platformInterface.demo_led14_color = led_on_color
        platformInterface.demo_led15_color = led_on_color
        platformInterface.demo_led16_color = led_on_color
        platformInterface.demo_led17_color = led_on_color
        platformInterface.demo_led18_color = led_on_color
        platformInterface.demo_led19_color = led_on_color
        platformInterface.demo_led1A_color = led_on_color
        platformInterface.demo_led1B_color = led_on_color
        platformInterface.demo_led1C_color = led_on_color
        platformInterface.demo_led21_color = led_on_color
        platformInterface.demo_led22_color = led_on_color
        platformInterface.demo_led23_color = led_on_color
        platformInterface.demo_led24_color = led_on_color
        platformInterface.demo_led25_color = led_on_color
        platformInterface.demo_led26_color = led_on_color
        platformInterface.demo_led27_color = led_on_color
        platformInterface.demo_led28_color = led_on_color
        platformInterface.demo_led29_color = led_on_color
        platformInterface.demo_led2A_color = led_on_color
        platformInterface.demo_led2B_color = led_on_color
        platformInterface.demo_led2C_color = led_on_color
        platformInterface.demo_led31_color = led_on_color
        platformInterface.demo_led32_color = led_on_color
        platformInterface.demo_led33_color = led_on_color
        platformInterface.demo_led34_color = led_on_color
        platformInterface.demo_led35_color = led_on_color
        platformInterface.demo_led36_color = led_on_color
        platformInterface.demo_led37_color = led_on_color
        platformInterface.demo_led38_color = led_on_color
        platformInterface.demo_led39_color = led_on_color
        platformInterface.demo_led3A_color = led_on_color
        platformInterface.demo_led3B_color = led_on_color
        platformInterface.demo_led3C_color = led_on_color
    }
}
