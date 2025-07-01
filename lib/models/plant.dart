class Plant {
  final String naam;
  final String wetenschappelijkeNaam;
  final String beschrijving;
  int vochtigheid;
  final String afbeelding;
  List<Map<String, String>> logboek;
  List<int> history;
  final int droogDrempel;
  String status;
  String trend;

  Plant(
    this.naam,
    this.wetenschappelijkeNaam,
    this.beschrijving,
    this.vochtigheid,
    this.afbeelding,
    this.logboek,
    this.history,
    this.droogDrempel, {
    this.status = "",
    this.trend = "",
  });
}
