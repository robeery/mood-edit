enum OperationType { 
  exposure,
  brightness,
  highlights,
  shadows,
  contrast,
  warmth, 
  tint,
}

class Edit {
  final OperationType type;
  final double value;

  //debug purposes
  @override
  String  toString() => 'Edit(${type.name}: $value)';
  

  
  const Edit({required this.type, required this.value});
}