class Party {
  final String name;
  final int? count;

  Party({
    required this.count,
    required this.name,
  });

  factory Party.fromDB(Map data) {
    return Party(
      count: data['count'],
      name: data['name'],
    );
  }
}
