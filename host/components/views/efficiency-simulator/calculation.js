function calculate(circuit, series) {
    var Temp1_justified_HS = 0
    var Temp2_justified_HS = 0
    var RTHS_justified_HS = circuit.rDSon_justified_HS
    var Temp1_justified_LS = 0
    var Temp2_justified_LS = 0
    var RTLS_justified_LS = circuit.rDSon_justified_LS

    var dutycycle_justified = circuit.dutycycle

    series.clear()

    for (var I = 1; I < 51; I++){

        var Loadcurrent = I / 50 * circuit.maximumoutputcurrent
        var PHC = RTHS_justified_HS * dutycycle_justified * ((Math.pow(Loadcurrent, 2)) + (Math.pow(circuit.currentripple, 2)) / 3)
        var Vsp = circuit.vth_HS + Loadcurrent / (circuit.gfs_HS * circuit.numberofFET_HS)
        var Idr_LH = Math.max(circuit.drivervoltage - Vsp, 0.001) / (circuit.sourcingresistance + circuit.rgex_HS + circuit.rgin_HS / circuit.numberofFET_HS)
        var Idr_HL = Vsp / (circuit.sinkingresistance + circuit.rgex_HS + circuit.rgin_HS / circuit.numberofFET_HS)
        var Qgs_sw = (circuit.qGD_HS + circuit.qGS_HS / 2) * circuit.numberofFET_HS
        var tr = Qgs_sw / Idr_LH / (1 + Qgs_sw / Idr_LH / 3E-08)
        var tf = Qgs_sw / Idr_HL
        var PswHS = 0.5 * circuit.inputvoltage * circuit.switchingfrequency * (tr * Math.max(Loadcurrent - circuit.currentripple, 0) + tf * (Loadcurrent + circuit.currentripple))

        var PconLS = (1 - dutycycle_justified - circuit.dRVH + circuit.dRVI) * RTLS_justified_LS * (Math.pow(Loadcurrent, 2) + Math.pow(circuit.currentripple, 2) / 3)

        var Qrr = Math.max(circuit.qRR_LS - circuit.coss_LS * 15, 0)

        var PQrr = circuit.inputvoltage * Loadcurrent * Qrr * circuit.numberofFET_LS / circuit.qRRmeasurementcurrent_LS * circuit.switchingfrequency

        var PDT = circuit.vSD_LS * Loadcurrent * (circuit.dRVH + circuit.dRVI) * circuit.switchingfrequency

        var Pout = Loadcurrent * circuit.outputvoltage

        var PdrHS = circuit.drivervoltage * circuit.qTOT_justified_HS * circuit.numberofFET_HS * circuit.switchingfrequency + circuit.drivervoltage * circuit.quiescentcurrent / 2

        var PdrLS = circuit.drivervoltage * circuit.qTOT_justified_LS * circuit.numberofFET_LS * circuit.switchingfrequency + circuit.drivervoltage * circuit.quiescentcurrent / 2

        var Pw = (Math.pow(Loadcurrent, 2) + Math.pow(circuit.currentripple, 2) / 3) * circuit.windingresistance * (1 + 0.002 * Temp2_justified_LS)

        var Pc = 0.03 / 300000 * circuit.switchingfrequency

        var Pcsw = (circuit.coss_HS * circuit.numberofFET_HS + 0.5 * circuit.coss_LS * circuit.numberofFET_LS) * circuit.inputvoltage * circuit.inputvoltage * circuit.switchingfrequency
//console.log(circuit.coss_HS, circuit.numberofFET_HS, circuit.coss_LS, circuit.numberofFET_LS, circuit.inputvoltage, circuit.switchingfrequency)
//        console.log(Pcsw)
        var Pesr = Math.pow(circuit.currentripple, 2) / 3 * circuit.eSR_Coutput

        var Efficiency = Pout / (PHC + PswHS + PconLS + PQrr + PDT + Pout + PdrHS + PdrLS + Pw + Pc + Pcsw + Pesr)
//        console.log(Efficiency)
        series.append(Loadcurrent, Efficiency*100)
//        console.log("Pout:", Pout, "PHC:", PHC, "PswHS:", PswHS, "PconLS:", PconLS, "PQrr:", PQrr, "PDT:", PDT, "Pout:", Pout, "PdrHS:", PdrHS, "PdrLS:", PdrLS, "Pw:", Pw, "Pc:", Pc, "Pcsw:", Pcsw, "Pesr:", Pesr)
        var PHS = PHC + PswHS + Pcsw / 2

        var PLS = PconLS + PDT + Pcsw / 2

        Temp1_justified_HS = PHS * circuit.rJA_HS / circuit.numberofFET_HS
        Temp2_justified_HS = Temp1_justified_HS / (1 + (Temp1_justified_HS / 150))
        RTHS_justified_HS = (Temp2_justified_HS * 0.85 * circuit.rDSontemperaturecoefficent_HS + 1) * circuit.rDSon_justified_HS

        Temp1_justified_LS = PLS * circuit.rJA_LS / circuit.numberofFET_LS
        Temp2_justified_LS = Temp1_justified_LS / (1 + (Temp1_justified_LS / 150))
        RTLS_justified_LS = (Temp2_justified_LS * 0.85 * circuit.rDSontemperaturecoefficent_LS + 1) * circuit.rDSon_justified_LS

        dutycycle_justified = (PHC + PswHS + PconLS + PQrr + PDT + Pout + PdrHS + PdrLS + Pw + Pc + Pcsw + Pesr) / circuit.inputvoltage / Loadcurrent
    }
}
