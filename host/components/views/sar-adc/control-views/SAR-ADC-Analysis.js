//SAR ADC Post analysis code

//////////////////////////////////////////////////////
//  Post Analysis Functions							//
//////////////////////////////////////////////////////

// Fourier Transform Module used by FFT
function FourierTransform(bufferSize, sampleRate) {
    this.bufferSize = bufferSize;
    this.sampleRate = sampleRate;
    this.bandwidth = 2 / bufferSize * sampleRate / 2;

    this.spectrum = new Float64Array(bufferSize/2);
    this.real = new Float64Array(bufferSize);
    this.imag = new Float64Array(bufferSize);

    this.peakBand = 0;
    this.peak = 0;


    this.calculateSpectrum = function() {
        var spectrum = this.spectrum,
        real = this.real,
        imag = this.imag,
        bSi = 2 / this.bufferSize,
        sqrt = Math.sqrt,
        rval,
        ival,
        mag;

        for (var i = 0, N = bufferSize/2; i < N; i++) {
            rval = real[i];
            ival = imag[i];
            mag = bSi * (rval * rval + ival * ival);

            if (mag > this.peak) {
                this.peakBand = i;
                this.peak = mag;
            }

            spectrum[i] = mag;
        }
    };
}


/**
* FFT is a class for calculating the Discrete Fourier Transform of a signal
* with the Fast Fourier Transform algorithm.
*
* @param {Number} bufferSize The size of the sample buffer to be computed. Must be power of 2
* @param {Number} sampleRate The sampleRate of the buffer (eg. 44100)
*
* @constructor
*/
function FFT(bufferSize, sampleRate) {
    FourierTransform.call(this, bufferSize, sampleRate);

    this.reverseTable = new Uint32Array(bufferSize);
    var limit = 1;
    var bit = bufferSize >> 1;
    var i;

    while (limit < bufferSize) {
        for (i = 0; i < limit; i++) {
            this.reverseTable[i + limit] = this.reverseTable[i] + bit;
        }

        limit = limit << 1;
        bit = bit >> 1;
    }

    this.sinTable = new Float64Array(bufferSize);
    this.cosTable = new Float64Array(bufferSize);

    for (i = 0; i < bufferSize; i++) {
        this.sinTable[i] = Math.sin(-Math.PI/i);
        this.cosTable[i] = Math.cos(-Math.PI/i);
    }
}

/**
* Performs a forward transform on the sample buffer.
* Converts a time domain signal to frequency domain spectra.
*
* @param {Array} buffer The sample buffer. Buffer Length must be power of 2
*
* @returns The frequency spectrum array
*/
FFT.prototype.forward = function(buffer) {
    // Locally scope variables for speed up
    var bufferSize = this.bufferSize,
    cosTable = this.cosTable,
    sinTable = this.sinTable,
    reverseTable = this.reverseTable,
    real = this.real,
    imag = this.imag,
    spectrum = this.spectrum;

    var k = Math.floor(Math.log(bufferSize) / Math.LN2);

    if (Math.pow(2, k) !== bufferSize) { throw "Invalid buffer size, must be a power of 2."; }
    if (bufferSize !== buffer.length) { throw "Supplied buffer is not the same size as defined FFT. FFT Size: " + bufferSize + " Buffer Size: " + buffer.length; }

    var halfSize = 1,
    phaseShiftStepReal,
    phaseShiftStepImag,
    currentPhaseShiftReal,
    currentPhaseShiftImag,
    off,
    tr,
    ti,
    tmpReal,
    i;

    for (i = 0; i < bufferSize; i++) {
        real[i] = buffer[reverseTable[i]];
        imag[i] = 0;
    }

    while (halfSize < bufferSize) {
        phaseShiftStepReal = cosTable[halfSize];
        phaseShiftStepImag = sinTable[halfSize];

        currentPhaseShiftReal = 1;
        currentPhaseShiftImag = 0;

        for (var fftStep = 0; fftStep < halfSize; fftStep++) {
            i = fftStep;

            while (i < bufferSize) {
                off = i + halfSize;
                tr = (currentPhaseShiftReal * real[off]) - (currentPhaseShiftImag * imag[off]);
                ti = (currentPhaseShiftReal * imag[off]) + (currentPhaseShiftImag * real[off]);

                real[off] = real[i] - tr;
                imag[off] = imag[i] - ti;
                real[i] += tr;
                imag[i] += ti;

                i += halfSize << 1;
            }

            tmpReal = currentPhaseShiftReal;
            currentPhaseShiftReal = (tmpReal * phaseShiftStepReal) - (currentPhaseShiftImag * phaseShiftStepImag);
            currentPhaseShiftImag = (tmpReal * phaseShiftStepImag) + (currentPhaseShiftImag * phaseShiftStepReal);
        }

        halfSize = halfSize << 1;
    }

    return this.calculateSpectrum();
};

FFT.prototype.inverse = function(real, imag) {
    // Locally scope variables for speed up
    var bufferSize = this.bufferSize,
    cosTable = this.cosTable,
    sinTable = this.sinTable,
    reverseTable = this.reverseTable,
    spectrum = this.spectrum;

    real = real || this.real;
    imag = imag || this.imag;

    var halfSize = 1,
    phaseShiftStepReal,
    phaseShiftStepImag,
    currentPhaseShiftReal,
    currentPhaseShiftImag,
    off,
    tr,
    ti,
    tmpReal,
    i;

    for (i = 0; i < bufferSize; i++) {
        imag[i] *= -1;
    }

    var revReal = new Float64Array(bufferSize);
    var revImag = new Float64Array(bufferSize);

    for (i = 0; i < real.length; i++) {
        revReal[i] = real[reverseTable[i]];
        revImag[i] = imag[reverseTable[i]];
    }

    real = revReal;
    imag = revImag;

    while (halfSize < bufferSize) {
        phaseShiftStepReal = cosTable[halfSize];
        phaseShiftStepImag = sinTable[halfSize];
        currentPhaseShiftReal = 1;
        currentPhaseShiftImag = 0;

        for (var fftStep = 0; fftStep < halfSize; fftStep++) {
            i = fftStep;

            while (i < bufferSize) {
                off = i + halfSize;
                tr = (currentPhaseShiftReal * real[off]) - (currentPhaseShiftImag * imag[off]);
                ti = (currentPhaseShiftReal * imag[off]) + (currentPhaseShiftImag * real[off]);

                real[off] = real[i] - tr;
                imag[off] = imag[i] - ti;
                real[i] += tr;
                imag[i] += ti;

                i += halfSize << 1;
            }

            tmpReal = currentPhaseShiftReal;
            currentPhaseShiftReal = (tmpReal * phaseShiftStepReal) - (currentPhaseShiftImag * phaseShiftStepImag);
            currentPhaseShiftImag = (tmpReal * phaseShiftStepImag) + (currentPhaseShiftImag * phaseShiftStepReal);
        }

        halfSize = halfSize << 1;
    }

    var buffer = new Float64Array(bufferSize); // this should be reused instead
    for (i = 0; i < bufferSize; i++) {
        buffer[i] = real[i] / bufferSize;
    }

    return buffer;
};

function indexOfClosest(array,target){
    var index = 0;
    var diff = 1000000000;
    for (var i=0; i<array.length; i++){
        if (Math.abs(target - array[i]) < diff){
            diff = Math.abs(target - array[i]);
            index = i;
        }
    }
    return index;
}

function indexOfMax(array){
    if (array.length === 0){
        return -1;
    }
    var max = 0;
    var maxIndex = 0;

    for (var p=2; p<array.length; p++){
        if (array[p] > max){
            maxIndex = p;
            max = array[p];
        }
    }
    return maxIndex;
}
const arrAvg = arr => arr.reduce((a,b) => a + b, 0) / arr.length;

function estimatePeriod(array){
    //estimate period
    var jump = []
    for (var n=0;n<array.length;n++){
        jump.push(array[n+1]-array[n])
    }
    jump.pop(); // remove last element "nan"
    //find average
    var jumpAvg = arrAvg(jump);
    return jumpAvg;
}

function hist(array,codes){
    var bins = [];
    // create bins array (initialize to 0)
    for (var n=0;n<codes;n++){
        bins.push(0);
    }
    // shift data to align to complete period set
    //find the average value of the time domain data set

    var avg = arrAvg(array);

    //find the index of each average crossing.
    var avgXindex = [];
    var temp = 10000000;
    var mag = 0;
    var nextMag = 0;

    for (n=0;n<array.length;n++){
        mag = array[n]-avg;
        nextMag = array[n+1]-avg;
        //console.log(n+', '+array[n]+', '+avg+', '+mag+', '+temp);
        if(mag*nextMag < 0){  //check to see if the sign flipped
            avgXindex.push(n);
        }
    }
    //remove index values caused by noise
    var period = estimatePeriod(avgXindex);
    var newXindex = [];
    newXindex.push(avgXindex[0]);
    for(n=1;n<avgXindex.length;n++){
        if(avgXindex[n]-avgXindex[n-1] < period){
            //do nothing
        }
        else newXindex.push(avgXindex[n]);
    }

    //keep odd number of indexes to guarentee full periods
    if(newXindex.length % 2 == 0){
        newXindex.pop();
    }
    //clip input array for complete periods
    var clippedArray = []
    for(n=newXindex[0];n<newXindex[newXindex.length-1]+1;n++){
        clippedArray.push(array[n]);
    }
    // fill the histogram bins
    for (n=0;n<clippedArray.length;n++){
        bins[clippedArray[n]] = bins[clippedArray[n]]+1;
    }
    bins.pop();
    return [bins,clippedArray];
}

function histINL_DNL(array,codes){  //not ready for use yet
    //calculate INL and DNL from histogram data
    //clip the histogram to avoid edge codes
    var trim_hist = [];
    var trimL = 0;
    var trimH = 0;
    var windowSum = 0;
    for (var i=1;i<array.length;i++){
        if(array[i] >= 2 & array[i-1] === 0){
            trimL = i;
        }
        if(array[i] >= 2 & array[i+1] === 0){
            trimH = i;
        }
    }
    if(trimL === 0){
        trimL = 20;
    }
    else{
        trimL = trimL + 20;
    }
    if(trimH === codes-1){
        trimH = codes - 21;
    }
    else{
        trimH = trimH-20;
    }
    var sum = 0;
    for(var n=0;n<array.length;n++){
        if(n>=trimL & n<=trimH){
            trim_hist.push(array[n]);
            sum = sum+array[n];
        }
    }
    //find average (ideal) histogram level
    var ideal = sum/trim_hist.length;
    var DNL = [];
    var INL = [];
    var maxDNL = 0;
    var maxINL = 0;
    sum = 0;
    for (var j=0;j<trim_hist.length;j++){
        DNL.push(trim_hist-ideal);
        sum = sum + trim_hist-ideal;
        INL.push(sum);
        if(Math.abs(trim_hist-ideal) > maxDNL){
            maxDNL = Math.abs(trim_hist-ideal);
        }
        if(Math.abs(sum) > maxINL){
            maxINL = Math.abs(sum);
        }
    }

    return [maxDNL,maxINL];
}

//////////////////////////////////////////////////////////////////////////
//	Main ADC Post Process Functions    									//
//////////////////////////////////////////////////////////////////////////

function adcPostProcess(input_array,ADCclock,codes){

    var Fsample = ADCclock/16;
    //create power of 2 version of input_array
    var pow2 = [2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536];
    var newLen = 0;

    for (var y = 0;y < pow2.length; y++){
        if(input_array.length >= 65536){
            newLen = 65536;
        }
        else if(input_array.length < pow2[y] & input_array.length > pow2[y-1]){
            newLen = pow2[y-1];
        }
    }
    var trimmed_array = input_array.slice(0,newLen);
    var histRet = hist(input_array,codes);
    var hist_data = histRet[0];
    var clipped_hist_array = histRet[1];
    //center around zero to mitigate large DC offset
    var centered_input = [];
    for(var r=0;r<newLen;r++){
        centered_input.push(trimmed_array[r]-(codes/2));
    }

    var hann = [];
    var hann_point = 0;
    //generate hann window
    for (var n=0;n<newLen;n++){
        hann_point = 0.5*(1.0-Math.cos((2.0*Math.PI*n)/newLen));
        hann.push(hann_point);
    }

    var windowed_input = [];

    //apply hann window
    for (n=0;n<newLen;n++){
        windowed_input.push(centered_input[n]*hann[n]);
    }

    var fft = new FFT(newLen,Fsample);
    fft.forward(windowed_input);
    var mag_array = fft.spectrum;
    var T = (newLen)/Fsample;
    var DCband = 10;
    var frq = [];
    var fdomain_data = [];
    var tdomain_data = [];
    var time = [];
    var step = 0;

    var fmax_index = indexOfMax(mag_array);

    //create array for plotting frequency domain in GUI
    for (var i=0; i < newLen/2; i++){
        frq.push(i/T);
    }
    var magLog = [];

    var maxMag = mag_array[fmax_index];
    var magNorm = [];
    var magLogNorm = [];

    //normalize
    for (i=0; i<newLen/2;i++){
        magNorm.push(mag_array[i]/maxMag);
    }
    //convert mag_array to log scale
    for (i=0; i<newLen/2;i++){
        magLogNorm.push(10*Math.log10(magNorm[i]));
    }
    for (i=0; i<newLen/2;i++){
        fdomain_data.push([frq[i],magLogNorm[i]]);
    }
    //create array for plotting time domain in GUI
    for (i=0;i<trimmed_array.length;i++){
        time.push(step);
        step = step + 1/Fsample;
    }
    for (i=0; i<trimmed_array.length;i++){
        tdomain_data.push([time[i],trimmed_array[i]]);
    }
    //find the max signal (fundemental) and the appropirate window around the fundemental

    var fmax = frq[fmax_index];
    var fnyquist = frq[(newLen/2)-1];
    var winH = frq[fmax_index]*1.5;
    var winL = frq[fmax_index]*0.5;
    var diffH = 0;
    var diffL = 0;
    var current_diffH = 10000000000000;
    var current_diffL = 10000000000000;
    var winL_index = 0;
    var winH_index = 0;

    for (i=0;i<newLen/2;i++){
        diffH = Math.abs(winH - frq[i])
        diffL = Math.abs(winL - frq[i])
        if(diffH < current_diffH){
            current_diffH = diffH;
            winH_index = i;
        }
        if(diffL < current_diffL){
            current_diffL = diffL;
            winL_index = i;
        }
    }
    if(winL_index < DCband){
        winL_index = DCband;
    }
    if(winH_index > newLen/2){
        winH_index = (newLen/2)-1;
    }

    //calculate signal power (and a few surrounding frequencies)
    var sigPwr = 0;
    for (i=0;i<newLen/2;i++){
        if(i>=winL_index){
            if(i<=winH_index){
                sigPwr = sigPwr+mag_array[i];
            }
        }
    }
    //calculate noise power (all frequencies but the signal window: N+D)
    var noisePwr = 0;

    for (i=0;i<newLen/2-1;i++){
        if(i<=winL_index-4){
            if(i>DCband){
                noisePwr = noisePwr+mag_array[i];
            }
        }
        if(i>=winH_index+4){
            noisePwr = noisePwr+mag_array[i];
        }
    }
    //noisePwr = noisePwr/3;
    //SNDR calculation
    var SNDR = 10*Math.log10(sigPwr/noisePwr);

    //SFDR calculation
    var lowerMax = Math.max.apply(Math,mag_array.slice(DCband,winL_index+1));
    var upperMax = Math.max.apply(Math,mag_array.slice(winH_index,newLen/2));
    var SFDR = 10*Math.log10(mag_array[fmax_index]/(Math.max(lowerMax,upperMax)));

    //find all the harmonics
    var harmonics = [];
    var harmonics_actual =[]; //sum of the magnitudes at the  frequencies just above to just below the harmonics
    for (i=2;i<10;i++){
        harmonics.push(fmax*i);
    }
    for(i=harmonics.length;i>0;i--){
        if(harmonics[i] > Fsample/2){
            harmonics.pop();
        }
    }
    harmonics.pop();
    var harmonic_sum = 0;
    for (i=0;i<harmonics.length;i++){
        harmonic_sum = 0;
        for (var j=-2;j<3;j++){
            harmonic_sum = harmonic_sum + mag_array[indexOfClosest(frq,harmonics[i])+j];
        }
        harmonics_actual[i] = harmonic_sum;
    }
    var noisepwr_harm = 0;
    for (i=0;i<harmonics_actual.length;i++){
        noisepwr_harm = noisepwr_harm + harmonics_actual[i];
    }

    //SNR calculation
    var SNR = 10*Math.log10(sigPwr/(noisePwr - noisepwr_harm));

    //THD calculation
    var THD = 20*Math.log10(Math.sqrt(noisepwr_harm/sigPwr));

    var ENOB = (SNR-1.76)/6.02;

    var NL = histINL_DNL(hist_data,codes);

    return [fdomain_data,tdomain_data,hist_data,SNDR,SFDR,SNR,THD,ENOB]
}


