enum OperationType { 
  exposure,
  brightness,
  highlights,
  shadows,
  contrast,
  warmth, 
  tint,
  sharpness
}

extension OperationTypeExtension on OperationType {
  double get minValue {
    switch (this) {
      case OperationType.sharpness:
        return 0;
      default:
        return -100;
    }
  }

  double get maxValue => 100;
}

class Edit {
  final OperationType type;
  final double value;

  //debug purposes
  @override
  String  toString() => 'Edit(${type.name}: $value)';
  

  
  const Edit({required this.type, required this.value});
}