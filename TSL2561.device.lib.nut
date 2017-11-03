/**
 * This file is licensed under the MIT License
 * http://opensource.org/licenses/MIT
 * @copyright (c) 2013 - 2017 Electric Imp
 */

/**
 * Simple driver for TSL2561 Digital Ambient Light Sensor, based on
 * https://www.seeedstudio.com/Grove-Digital-Light-Sensor-p-1281.html
 *
 * @author Terrence Barr <terrence@electricimp.com>
 *
 * @version 0.0.1
 */
class TSL2561 {

    static VERSION = [0,0,1];
    static INTEG_TIME = 450; // ms

    static REG_CTRL = "\x80";   // CMD bit + CTRL addr
    static REG_CHAN0L = "\xAC"; // CMD bit + CHAN0L
    static REG_CHAN1L = "\xAE"; // CMD bit + CHAN1L

    _i2c       = null;
    _addr      = null;
    _ready     = false;

     /**
     * Constructor
     * 
     * Parameters
     * i2c - i2c bus used, required
     * addr - base address, optional
     */
    constructor(i2c=null, addr=0x52) { // default address of Grove TSL2561
        _i2c = i2c;
        _addr = addr;
    }

    // Internal function to power on sensor
    function _enable() {
        _i2c.write(_addr, REG_CTRL+"\x03"); // power on
    }
    
    // Internal function to power off sensor
    function _disable() {
        _i2c.write(_addr, REG_CTRL+"\x00"); // power off
    }

    // Internal function to convert register reading to lux value
    function _convert(reg0, reg1) {

        local ch0 = ((reg0[1] & 0xFF) << 8) + (reg0[0] & 0xFF);
        local ch1 = ((reg1[1] & 0xFF) << 8) + (reg1[0] & 0xFF);
    
        local ratio = ch1 / ch0.tofloat();
        local lux = 0.0;
        if (ratio <= 0.5){
            lux = 0.0304*ch0 - 0.062*ch0*math.pow(ratio,1.4);
        } else if( ratio <= 0.61){
            lux = 0.0224 * ch0 - 0.031 * ch1;
        } else if( ratio <= 0.8){
            lux = 0.0128*ch0 - 0.0153*ch1;
        } else if( ratio <= 1.3){
            lux = 0.00146*ch0 - 0.00112*ch1;
        } else {
                throw "Invalid lux calculation: " + ch0 + ", " + ch1;
          return null;
        }

        // Round to 2 decimal places
        lux = (lux*100).tointeger() / 100.0;

        //server.log(format("Ch0: 0x%04X Ch1: 0x%04X Ratio: %f Lux: %f", ch0, ch1, ratio, lux));
        return lux;
    }
    
    // Internal function to read sensor and convert values
    function _readAndConvert() {
        local reg0 = _i2c.read(_addr, REG_CHAN0L, 2);
        local reg1 = _i2c.read(_addr, REG_CHAN1L, 2);
        if (reg0 == null || reg1 == null) {
            return null;
        } else {
            return _convert(reg0, reg1);
        }
    }

     /**
     * Read ambient light value
     * Returns floating point lux value after integration time
     * 
     * Parameters
     * callback - if null value is returned synchronously, else asynchronous callback
     */
    function read(callback = null) {
        // asynchronous case
        if (callback != null) {
            _enable();
            imp.wakeup(INTEG_TIME/1000.0, function() {
                local result = _readAndConvert();
                _disable();
                callback(result);
            }.bindenv(this));
        }
        // synchronous case
        else {
            _enable();
            imp.sleep(INTEG_TIME/1000.0);
            local result = _readAndConvert();
            _disable();
            return result;
        }
        
    }

}

// Example application code
//local i2c = hardware.i2c0; // imp005 i2c bus
//i2c.configure(CLOCK_SPEED_400_KHZ);
//als <- TSL2561(i2c);
//
//function read() {
//    als.read(function(result) {
//        if (result == null) {
//            server.log("error");
//        } else {
//            server.log("value: " + result);
//        }
//    });    
//    imp.wakeup(2, read);
//}
//
//read(); // loop and print readings


