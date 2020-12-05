class Region {
  String name;
  int id;

  Region(this.id, this.name);

  Region copy() => Region(id, name);
}
