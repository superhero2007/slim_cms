<?php

class conversion
{

    /**
    * @var array
    * Unit conversion based on http://www.convertunits.com/
    */
    
    protected static $conversion = [

        // Acceleration
        'METRE_PER_SECOND_SQUARED' => ['base' => 'METRE_PER_SECOND_SQUARED', 'factor' => 1],

        // Angle
        'TURN'    => ['base' => 'RADIAN', 'factor' => 6.283185307179586],
        'RADIAN'  => ['base' => 'RADIAN', 'factor' => 1],
        'DEGREE'  => ['base' => 'RADIAN', 'factor' => 0.01745329251993791],
        'GRADIAN' => ['base' => 'RADIAN', 'factor' => 0.015707963267938635],

        // Area
        'SQUARE_METRE'     => ['base' => 'SQUARE_METRE', 'factor' => 1],
        'HECTARE'          => ['base' => 'SQUARE_METRE', 'factor' => 10000],
        'SQUARE_KILOMETRE' => ['base' => 'SQUARE_METRE', 'factor' => 1000000],
        'SQUARE_INCH'      => ['base' => 'SQUARE_METRE', 'factor' => 0.0006451599999984183],
        'SQUARE_FEET'      => ['base' => 'SQUARE_METRE', 'factor' => 0.09290304000008391],
        'SQUARE_YARD'      => ['base' => 'SQUARE_METRE', 'factor' => 0.8361273600007553],
        'ACRE'             => ['base' => 'SQUARE_METRE', 'factor' => 4046.856422402708],
        'SQUARE_MILE'      => ['base' => 'SQUARE_METRE', 'factor' => 2589988.1103389906],

        // Storage
        'BIT'      => ['base' => 'KILOBYTE', 'factor' => 0.0001220703125],
        'BYTE'     => ['base' => 'KILOBYTE', 'factor' => 0.0009765625],
        'KILOBIT'  => ['base' => 'KILOBYTE', 'factor' => 0.1220703125],
        'KILOBYTE' => ['base' => 'KILOBYTE', 'factor' => 1],
        'MEGABIT'  => ['base' => 'KILOBYTE', 'factor' => 122.0703125],
        'MEGABYTE' => ['base' => 'KILOBYTE', 'factor' => 1024],
        'GIGABIT'  => ['base' => 'KILOBYTE', 'factor' => 122070.31249999999],
        'GIGABYTE' => ['base' => 'KILOBYTE', 'factor' => 1048576],
        'TERABIT'  => ['base' => 'KILOBYTE', 'factor' => 122070312.5],
        'TERABYTE' => ['base' => 'KILOBYTE', 'factor' => 1073741824.0005517],
        'PETABIT'  => ['base' => 'KILOBYTE', 'factor' => 122070312499.99998],
        'PETABYTE' => ['base' => 'KILOBYTE', 'factor' => 1099511627775.9133],

        // Current
        'STATAMPERE'  => ['base' => 'ABAMPERE', 'factor' => 3.3356410000034974e-10],
        'MICROAMPERE' => ['base' => 'ABAMPERE', 'factor' => 0.000001],
        'MILLIAMPERE' => ['base' => 'ABAMPERE', 'factor' => 0.001],
        'AMPERE'      => ['base' => 'ABAMPERE', 'factor' => 1],
        'ABAMPERE'    => ['base' => 'ABAMPERE', 'factor' => 10],
        'KILOAMPERE'  => ['base' => 'ABAMPERE', 'factor' => 1000],
        'VOLT'        => ['base' => 'ABAMPERE', 'factor' => 1],

        // Fuel
        'KILOMETRES_PER_LITRE'     => ['base' => 'KILOMETRES_PER_LITRE', 'factor' => 1],
        'LITRE_PER_100_KILOMETRES' => ['base' => 'KILOMETRES_PER_LITRE', 'factor' => 100],
        'MILES_PER_GALLON'         => ['base' => 'KILOMETRES_PER_LITRE', 'factor' => 0.35400618997453],
        'US_MILES_PER_GALLON'      => ['base' => 'KILOMETRES_PER_LITRE', 'factor' => 0.42514370749052],

        // Length
        'MILLIMETRE'    => ['base' => 'METRE', 'factor' => 0.001],
        'CENTIMETRE'    => ['base' => 'METRE', 'factor' => 0.01],
        'METRE'         => ['base' => 'METRE', 'factor' => 1],
        'KILOMETRE'     => ['base' => 'METRE', 'factor' => 1000],
        'INCH'          => ['base' => 'METRE', 'factor' => 0.0254],
        'FOOT'          => ['base' => 'METRE', 'factor' => 0.3048],
        'YARD'          => ['base' => 'METRE', 'factor' => 0.9144],
        'MILE'          => ['base' => 'METRE', 'factor' => 1609.344000000865],
        'NAUTICAL_MILE' => ['base' => 'METRE', 'factor' => 1852],

        // Mass
        'MICROGRAM'     => ['base' => 'KILOGRAM', 'factor' => 1e-9],
        'MILLIGRAM'     => ['base' => 'KILOGRAM', 'factor' => 0.000001],
        'GRAM'          => ['base' => 'KILOGRAM', 'factor' => 0.001],
        'KILOGRAM'      => ['base' => 'KILOGRAM', 'factor' => 1],
        'METRIC_TON'    => ['base' => 'KILOGRAM', 'factor' => 1000],
        'TONNE'         => ['base' => 'KILOGRAM', 'factor' => 1000],
        'OUNCE'         => ['base' => 'KILOGRAM', 'factor' => 0.028349523124984257],
        'POUND'         => ['base' => 'KILOGRAM', 'factor' => 0.4535923699997481],
        'STONE'         => ['base' => 'KILOGRAM', 'factor' => 6.350293179990713],
        'SHORT_TON'     => ['base' => 'KILOGRAM', 'factor' => 907.1847400036112],
        'LONG_TON'      => ['base' => 'KILOGRAM', 'factor' => 1016.0469088000625],

        // Pressure
        'PASCAL'                 => ['base' => 'PASCAL', 'factor' => 1],
        'KILOPASCAL'             => ['base' => 'PASCAL', 'factor' => 1000],
        'MEGAPASCAL'             => ['base' => 'PASCAL', 'factor' => 1000000],
        'BAR'                    => ['base' => 'PASCAL', 'factor' => 100000],
        'MILLIMETRES_OF_MERCURY' => ['base' => 'PASCAL', 'factor' => 133.3223899999367],
        'INCHES_OF_MERCURY'      => ['base' => 'PASCAL', 'factor' => 3386.3886666718317],
        'POUNDS_PER_SQUARE_INCH' => ['base' => 'PASCAL', 'factor' => 6894.75728001037],
        'ATMOSPHERE'             => ['base' => 'PASCAL', 'factor' => 101325.01000002761],

        // Speed
        'METRE_PER_SECOND'    => ['base' => 'METRE_PER_SECOND', 'factor' => 1],
        'KILOMETRES_PER_HOUR' => ['base' => 'METRE_PER_SECOND', 'factor' => 0.277777777778],
        'FEET_PER_SECOND'     => ['base' => 'METRE_PER_SECOND', 'factor' => 0.3048],
        'MILES_PER_HOUR'      => ['base' => 'METRE_PER_SECOND', 'factor' => 0.44704],
        'KNOT'                => ['base' => 'METRE_PER_SECOND', 'factor' => 0.514444],

        // Temperature
        'CELSIUS'    => ['base' => 'CELSIUS', 'factor' => 274.15],
        'FAHRENHEIT' => ['base' => 'CELSIUS', 'factor' => 255.9277777777778],
        'KELVIN'     => ['base' => 'CELSIUS', 'factor' => 1],

        // Time
        'NANOSECOND'  => ['base' => 'SECOND', 'factor' => 1e-9],
        'MICROSECOND' => ['base' => 'SECOND', 'factor' => 0.000001],
        'MILLISECOND' => ['base' => 'SECOND', 'factor' => 0.001],
        'SECOND'      => ['base' => 'SECOND', 'factor' => 1],
        'MINUTE'      => ['base' => 'SECOND', 'factor' => 60],
        'HOUR'        => ['base' => 'SECOND', 'factor' => 3600],
        'DAY'         => ['base' => 'SECOND', 'factor' => 86400],
        'WEEK'        => ['base' => 'SECOND', 'factor' => 604800],
        'MONTH'       => ['base' => 'SECOND', 'factor' => 2629746],
        'YEAR'        => ['base' => 'SECOND', 'factor' => 31556952.000011384],
        'DECADE'      => ['base' => 'SECOND', 'factor' => 315359999.9996478],
        'CENTURY'     => ['base' => 'SECOND', 'factor' => 3153599999.996478],
        'MILLENIUM'   => ['base' => 'SECOND', 'factor' => 31556926015.34867],

        // Voltage
        'VOLT'     => ['base' => 'VOLT', 'factor' => 1],
        'KILOVOLT' => ['base' => 'VOLT', 'factor' => 1000],

        // Volume
        'MILLILITRE'    => ['base' => 'CUBIC_METRE', 'factor' => 0.000001],
        'LITRE'         => ['base' => 'CUBIC_METRE', 'factor' => 0.001],
        'CUBIC_METRE'   => ['base' => 'CUBIC_METRE', 'factor' => 1],
        'GALLON'        => ['base' => 'CUBIC_METRE', 'factor' => 0.0045460900000018145],
        'QUART'         => ['base' => 'CUBIC_METRE', 'factor' => 0.0011365225000004536],
        'PINT'          => ['base' => 'CUBIC_METRE', 'factor' => 0.0005682612500008727],
        'TABLESPOON'    => ['base' => 'CUBIC_METRE', 'factor' => 0.000015],
        'TEASPOON'      => ['base' => 'CUBIC_METRE', 'factor' => 0.000005],
        'US_GALLON'     => ['base' => 'CUBIC_METRE', 'factor' => 0.0037854117999936727],
        'US_QUART'      => ['base' => 'CUBIC_METRE', 'factor' => 0.000946353],
        'US_PINT'       => ['base' => 'CUBIC_METRE', 'factor' => 0.00047317647500055247],
        'US_CUP'        => ['base' => 'CUBIC_METRE', 'factor' => 0.00023658823750027623],
        'US_OUNCE'      => ['base' => 'CUBIC_METRE', 'factor' => 0.000029573529687517043],
        'US_TABLESPOON' => ['base' => 'CUBIC_METRE', 'factor' => 0.000014786764843758521],
        'US_TEASPOON'   => ['base' => 'CUBIC_METRE', 'factor' => 0.000004928921614571597],
        'CUBIC_INCH'    => ['base' => 'CUBIC_METRE', 'factor' => 0.00001638706406926407],
        'CUBIC_FOOT'    => ['base' => 'CUBIC_METRE', 'factor' => 0.028316846711706135],
        'CUBIC_YARD'    => ['base' => 'CUBIC_METRE', 'factor' => 1.307951],

        // Energy
        'JOULE'                         => ['base' => 'GIGAJOULE', 'factor' => 1e-9],
        'KILOJOULE'                     => ['base' => 'GIGAJOULE', 'factor' => 0.000001],
        'MEGAJOULE'                     => ['base' => 'GIGAJOULE', 'factor' => 0.001],
        'GIGAJOULE'                     => ['base' => 'GIGAJOULE', 'factor' => 1],
        'WATT_HOUR'                     => ['base' => 'GIGAJOULE', 'factor' => 0.0000036],
        'KILOWATT_HOUR'                 => ['base' => 'GIGAJOULE', 'factor' => 0.0036],
        'MEGAWATT_HOUR'                 => ['base' => 'GIGAJOULE', 'factor' => 3.6],
        'GIGAWATT_HOUR'                 => ['base' => 'GIGAJOULE', 'factor' => 3600],
        'BRITISH_THERMAL_UNIT'          => ['base' => 'GIGAJOULE', 'factor' => 0.0000010550559000001675],
        'MILLION_BRITISH_THERMAL_UNIT'  => ['base' => 'GIGAJOULE', 'factor' => 1.0550559000001676],
        'US_THERM'                      => ['base' => 'GIGAJOULE', 'factor' => 0.10550559000001676],
        'FOOT_POUND'                    => ['base' => 'GIGAJOULE', 'factor' => 1.3558179483318883e-9],

        // Resource
        // Resource unit conversion based on https://www.unitjuggler.com
        'KILOGRAM_LNG'  => ['base' => 'GIGAJOULE', 'factor' => 0.05200993789],
        'LITRE_PETROL'  => ['base' => 'GIGAJOULE', 'factor' => 0.0342],
        'KILOLITRE_PETROL'  => ['base' => 'GIGAJOULE', 'factor' => 34.2],
        'LITRE_DIESEL'  => ['base' => 'GIGAJOULE', 'factor' => 0.0386],
        'KILOLITRE_DIESEL'  => ['base' => 'GIGAJOULE', 'factor' => 38.6],
        'LITRE_LPG'  => ['base' => 'GIGAJOULE', 'factor' => 0.0255],
        'KILOLITRE_LPG'  => ['base' => 'GIGAJOULE', 'factor' => 25.5],
        'LITRE_LNG'  => ['base' => 'GIGAJOULE', 'factor' => 0.0255],
        'KILOLITRE_LNG'  => ['base' => 'GIGAJOULE', 'factor' => 25.5],

        // Drum
        'NUMBER_OF_DRUMS'  => ['base' => 'KILOGRAM', 'factor' => 0.5]
    ];    

    /**
     * @var string
     */
    protected $value;

    /**
     * @var
     */
    protected $unit;

    /**
     * @param string $value
     * @param string $unit
     */
    public function __construct($value = '', $unit = '')
    {
        $this->unit = $unit;
        $this->value = $value;
    }

    /**
     * @param $value
     * @param $unit
     * @return conversion
     */
    public static function convert($value, $unit)
    {
        return new conversion($value, $unit);
    }


    /**
     * @param $unit
     * @return $this
     */
    public function to($unit)
    {
        $this->value = $this->process($this->value, $this->unit, $unit);
        $this->unit = $unit;

        return $this;
    }


    /**
     * @param $from
     * @param $to
     * @param $value
     * @return float
     */
    protected function process($value, $from, $to)
    {
        return ($value * $this->getConversion($from)) / $this->getConversion($to);
    }


    /**
     * @param $unit
     * @return mixed
     * @throws \Exception
     */
    protected function getConversion($unit)
    {
        if (!isset(static::$conversion[strtoupper(str_replace(' ', '_', $unit))])) {
            throw new \Exception(sprintf('No conversion for "%s" is defined.',$unit));
        }

        if (static::$conversion[strtoupper(str_replace(' ', '_', $unit))]['base'] !== static::$conversion[strtoupper(str_replace(' ', '_', $this->unit))]['base']) {
            throw new \Exception(sprintf('Invalid conversion from "%s" to "%s".',$this->unit, $unit));
        }

        return static::$conversion[strtoupper(str_replace(' ', '_', $unit))]['factor'];
    }


    /**
     * @param int $decimals
     * @param string $decPoint
     * @param string $thousandSep
     * @return string
     */
    public function format($decimals = 2, $decPoint = '.', $thousandSep = ',')
    {
        return number_format($this->value, $decimals, $decPoint, $thousandSep);
    }


    /**
     * @return string
     */
    public function __toString()
    {
        return $this->format();
    }
}