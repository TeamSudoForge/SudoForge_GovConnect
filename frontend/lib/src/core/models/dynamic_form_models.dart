enum DynamicFieldType {
  text,
  phoneNumber,
  email,
  documentUpload,
  date,
  dropdown,
  radioButton,
  checkbox,
  textarea,
  number,
  dependencyForm,
}

class DynamicFormFieldModel {
  final String id;
  final String label;
  final String fieldName;
  final DynamicFieldType fieldType;
  final bool isRequired;
  final String? placeholder;
  final String? helpText;
  final int orderIndex;
  final Map<String, dynamic>? validationRules;
  final Map<String, dynamic>? options;
  final Map<String, dynamic>? metadata;
  final String sectionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DynamicFormFieldModel({
    required this.id,
    required this.label,
    required this.fieldName,
    required this.fieldType,
    this.isRequired = false,
    this.placeholder,
    this.helpText,
    this.orderIndex = 1,
    this.validationRules,
    this.options,
    this.metadata,
    required this.sectionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DynamicFormFieldModel.fromJson(Map<String, dynamic> json) {
    return DynamicFormFieldModel(
      id: json['id'],
      label: json['label'],
      fieldName: json['fieldName'],
      fieldType: _parseFieldType(json['fieldType']),
      isRequired: json['isRequired'] ?? false,
      placeholder: json['placeholder'],
      helpText: json['helpText'],
      orderIndex: json['orderIndex'] ?? 1,
      validationRules: json['validationRules'],
      options: json['options'],
      metadata: json['metadata'],
      sectionId: json['sectionId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fieldName': fieldName,
      'fieldType': fieldType.toString().split('.').last,
      'isRequired': isRequired,
      'placeholder': placeholder,
      'helpText': helpText,
      'orderIndex': orderIndex,
      'validationRules': validationRules,
      'options': options,
      'metadata': metadata,
      'sectionId': sectionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static DynamicFieldType _parseFieldType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return DynamicFieldType.text;
      case 'phone_number':
        return DynamicFieldType.phoneNumber;
      case 'email':
        return DynamicFieldType.email;
      case 'document_upload':
        return DynamicFieldType.documentUpload;
      case 'date':
        return DynamicFieldType.date;
      case 'dropdown':
        return DynamicFieldType.dropdown;
      case 'radio_button':
        return DynamicFieldType.radioButton;
      case 'checkbox':
        return DynamicFieldType.checkbox;
      case 'textarea':
        return DynamicFieldType.textarea;
      case 'number':
        return DynamicFieldType.number;
      case 'dependency_form':
        return DynamicFieldType.dependencyForm;
      default:
        return DynamicFieldType.text;
    }
  }
}

class DynamicFormSectionModel {
  final String id;
  final String title;
  final String? description;
  final int pageNumber;
  final int orderIndex;
  final String formId;
  final List<DynamicFormFieldModel> fields;
  final DateTime createdAt;
  final DateTime updatedAt;

  DynamicFormSectionModel({
    required this.id,
    required this.title,
    this.description,
    required this.pageNumber,
    this.orderIndex = 1,
    required this.formId,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DynamicFormSectionModel.fromJson(Map<String, dynamic> json) {
    return DynamicFormSectionModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pageNumber: json['pageNumber'],
      orderIndex: json['orderIndex'] ?? 1,
      formId: json['formId'],
      fields: (json['fields'] as List<dynamic>?)
              ?.map((field) => DynamicFormFieldModel.fromJson(field))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pageNumber': pageNumber,
      'orderIndex': orderIndex,
      'formId': formId,
      'fields': fields.map((field) => field.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class DynamicFormModel {
  final String id;
  final String title;
  final String? description;
  final bool isActive;
  final int version;
  final Map<String, dynamic>? metadata;
  final List<DynamicFormSectionModel> sections;
  final DateTime createdAt;
  final DateTime updatedAt;

  DynamicFormModel({
    required this.id,
    required this.title,
    this.description,
    this.isActive = true,
    this.version = 1,
    this.metadata,
    required this.sections,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DynamicFormModel.fromJson(Map<String, dynamic> json) {
    return DynamicFormModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      version: json['version'] ?? 1,
      metadata: json['metadata'],
      sections: (json['sections'] as List<dynamic>?)
              ?.map((section) => DynamicFormSectionModel.fromJson(section))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isActive': isActive,
      'version': version,
      'metadata': metadata,
      'sections': sections.map((section) => section.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  List<DynamicFormSectionModel> getSectionsForPage(int pageNumber) {
    return sections
        .where((section) => section.pageNumber == pageNumber)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  int get totalPages {
    if (sections.isEmpty) return 0;
    return sections.map((s) => s.pageNumber).reduce((a, b) => a > b ? a : b);
  }
}
