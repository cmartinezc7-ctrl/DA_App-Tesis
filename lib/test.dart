class Badge {
  final int id;
  final String name;
  final String description;
  final bool unlocked;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    this.unlocked = false,
  });
}
