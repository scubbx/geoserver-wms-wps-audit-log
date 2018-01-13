# Audit Logging and Viewing Infrastructure for GeoServer

## Overview

This configuration files for the [GeoServer audit log module](http://docs.geoserver.org/stable/en/user/extensions/monitoring/audit.html). This configuration respects WMS and WPS requests and extracts useful information from both of these sources to produce a common log similar to this:

```
# start time|run time|error_flag|host|response_content_type|response_size|remote_address|service_type|service_version|service_operation|layer|image_width|image_height|pixelsize|srs|x1|y1|x2|y2
2018-01-03T10:42:07.114+01|81|success|xxx.xxx.xxx.xxx|image/jpeg|14810|xxx.xxx.xxx.xxx|WMS|1.1.1|GetMap|bev:RGB|768|396|1221.623375|EPSG:31255|-470324.99926320836|43978.44148954676|467881.7525137891|527741.297874561
2018-01-03T10:42:12.342+01|61|success|xxx.xxx.xxx.xxx|image/jpeg|15028|xxx.xxx.xxx.xxx|WMS|1.1.1|GetMap|bev:RGB|768|397|1221.623375|EPSG:31255|-445892.5317690157|32983.831117160065|492314.22000798176|516746.6875021744
```

The produced format is a CSV file with the delimiting character `|` . The reason for not using a semicolon is, that a semicolon could be part of the `response_content_type` (e.g. with 8bit PNG).

To view the produced logs, the log viewer [`lnav`](http://lnav.org/) is used. For this, a configuration file to correctly read the produced log with `lnav` is provided.

## Log Producing

### Overall Settings

The file `monitor.properties` in the folder `monitoring` contains basic settings which have to be adapted to the corresponding environment.

 * The line `audit.enabled=true` activates autit logging.
 * The most important setting is `autit.path` which points to the folder where the audit log files should be stored.
 * `audit.roll_limit` defines the amount of log entries to happen before a log-rollover is performed.
 * The parameter `maxBodySize` describes the maximum allowed size of the request body to be captured. This is of importance here, since the default value of `1024` is too short to catch all neccessary details from the XML POST reqest of the WPS.

Within the file `filter.properties` there are definitions of URL paths which are excluded from audit logging. This list is not exhaustive and will vary from use case to use case.

The three files `header.ftl`, `content.ftl` and `footer.ftl` contain code in the templating language [`Freemarker`](https://freemarker.apache.org/). `header.ftl` contains the data written at the top of a newly created log file. In our case, it is just the header of the CSV.
The file `footer.ftl` is empty, since we do not output a footer. The file `content.ftl` contains a complicated logic structure to extract information from WMS 1.1.1, WMS 1.3.0 and WPS requests and store it in only one format.

## Log Viewing

A complete log file (or folder with multiple log files) can easily be monitored by the awesome [`lnav`](http://lnav.org/) command line application. To facilitate log parsing, this repository contains a custom log format for `lnav` to correctly parse all the details of the previously generated audit log CSV file. To install it, just copy it into the `~/.lnav/formats/installed/` folder.