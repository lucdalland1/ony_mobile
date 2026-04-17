class NetworkInfoModel {
  final String? ipAddress;
  final String? city;
  final String? region;
  final String? countryCode;
  final double? latitude;
  final double? longitude;
  final String? isp;

  NetworkInfoModel({
    this.ipAddress,
    this.city,
    this.region,
    this.countryCode,
    this.latitude,
    this.longitude,
    this.isp,
  });

  factory NetworkInfoModel.fromJson(Map<String, dynamic> json) {
    double? lat;
    double? lon;

    if (json["loc"] != null) {
      final parts = json["loc"].split(",");
      lat = double.tryParse(parts[0]);
      lon = double.tryParse(parts[1]);
    }

    String? cleanISP;
    if (json["org"] != null) {
      final orgParts = json["org"].split(" ");
      if (orgParts.length > 1) {
        cleanISP = orgParts.sublist(1).join(" ");
      } else {
        cleanISP = json["org"];
      }
    }

    return NetworkInfoModel(
      ipAddress: json["ip"],
      city: json["city"],
      region: json["region"],
      countryCode: json["country"],
      latitude: lat,
      longitude: lon,
      isp: cleanISP,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ip_address": ipAddress,
      "city": city,
      "region": region,
      "country_code": countryCode,
      "latitude": latitude,
      "longitude": longitude,
      "isp": isp,
    };
  }
}