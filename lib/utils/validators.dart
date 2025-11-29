class Validators {
  // Validate name (not empty, reasonable length)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  // Validate weight (positive number, reasonable range)
  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Weight cannot be empty';
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }

    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }

    if (weight > 500) {
      return 'Please enter a realistic weight';
    }

    return null;
  }

  // Validate height (positive number, reasonable range in cm)
  static String? validateHeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Height cannot be empty';
    }

    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }

    if (height <= 0) {
      return 'Height must be greater than 0';
    }

    if (height < 50 || height > 300) {
      return 'Please enter a realistic height (50-300 cm)';
    }

    return null;
  }

  // Validate age (positive integer, reasonable range)
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age cannot be empty';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid number';
    }

    if (age <= 0) {
      return 'Age must be greater than 0';
    }

    if (age < 13 || age > 120) {
      return 'Please enter a realistic age (13-120)';
    }

    return null;
  }

  // Validate bio (optional, but with max length)
  static String? validateBio(String? value) {
    if (value != null && value.length > 200) {
      return 'Bio must be less than 200 characters';
    }
    return null;
  }
}
