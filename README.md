# Radiosonde-Mexico
The data corresponds to the radiosonde data in mexican meterological stations.
The software was made to process this data.

### Folders
The meteorological stations around the world have an indentifier. In this case 679 corresponds to Mexico City station and 692 corresponds to Veracruz stations.

In folders data679 and data692 there is data from the radiosonde. This data has 8 columns: date yyyymmddhh, identifier, pressure mbar, geopotential height, temperature in tenth of ºC, dew point temperature in tenth of ºC, wind direction in degrees 1-360 and wind speed m/s.

The identifier in the second column represents: 254 begin of the measurement, 1 coordinates, 2 speed units, 3, 4 mandatory levels, 5 significant levels of temperature, 6 siginificant levels of pressure, 7 tropopause, 8 maximum speed, 9 surface level,

In the folder temperature there are the codes to obtain the time series of temperature.

In the folder wind there are the  codes to obtain the cylindrical wind distribution of the radiosonde station.

