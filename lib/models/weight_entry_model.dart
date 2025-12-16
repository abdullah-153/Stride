class WeightEntry {
  final DateTime date;
  final double weight; // in kg
  final String? note;

  const WeightEntry({required this.date, required this.weight, this.note});

  WeightEntry copyWith({DateTime? date, double? weight, String? note}) {
    return WeightEntry(
      date: date ?? this.date,
      weight: weight ?? this.weight,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'weight': weight, 'note': note};
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
      note: json['note'] as String?,
    );
  }

  double calculateBMI(double heightInCm) {
    final heightInMeters = heightInCm / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
