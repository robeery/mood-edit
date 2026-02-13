enum OperationType { exposure, brightness, warmth }

class Edit {
  final OperationType type;
  final double value;

  @override
  String  toString() => 'Edit(${type.name}: $value)';
  

  
  const Edit({required this.type, required this.value});
}