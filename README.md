# Driver for the TSL2561 Digital Ambient Light Sensor

The [TSL2561](https://www.seeedstudio.com/Grove-Digital-Light-Sensor-p-1281.html) is a digital ambient light sensor. The TSL2561 can interface over I&sup2;C.

**To add this library to your project, add** `#require "TSL2561.device.lib.nut:0.0.1"` **to the top of your device code**

## Release Notes

| Version | Description |
| --- | --- |
| 0.0.1 | Initial version |
| 1.0.0 | n/a |

## Class Usage

### Constructor: TSL2561(*impI2cBus[, i2cAddress]*)

The constructor takes two arguments to instantiate the class: a *pre-configured* I&sup2;C bus and the sensor’s I&sup2;C address in 8-bit form. The I&sup2;C address is optional and defaults to `0x52`.

```squirrel
#require "TSL2561.device.lib.nut:0.0.1"

hardware.i2c89.configure(CLOCK_SPEED_400_KHZ);
als <- TSL2561(hardware.i2c89);
```

## Class Methods

### read(*[callback]*)

The *read()* method returns a ambient light reading in lux. If an error occurs during the reading process, the return value will be null. 

If a callback function is provided, the reading executes asynchronously, and the result will be passed to the supplied function as its only parameter. If no callback is provided, the method blocks until the reading has been taken and then returns the result.

#### Asynchronous Example

```squirrel
als.read(function(result) {
    if (result == null) {
        server.error("An Error Occurred");
    } else {
        server.log(format("Ambient light value: ", result));
    }
});
```

#### Synchronous Example

```squirrel
local result = als.read();

if (result == null) {
    server.error("An Error Occurred");
} else {
        server.log(format("Ambient light value: ", result));
}
```

## License

The TSL2561 library is licensed under the [MIT License](./LICENSE).