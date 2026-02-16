enum OperationType {
  exposure,
  brightness,
  highlights,
  shadows,
  contrast,
  warmth, 
  tint,
  sharpness,
  vibrance,
  blackpoint,
  vignette,
  noiseReduction,
  grain,
  fade,
}

extension OperationTypeExtension on OperationType {
  double get minValue {
    switch (this) {
      case OperationType.sharpness:
      case OperationType.blackpoint:
      case OperationType.vignette:
      case OperationType.noiseReduction:
      case OperationType.grain:
      case OperationType.fade:
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